
#import "ADTPurchaseVerificationHandler.h"
#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTAdtraceFactory.h"
#import "ADTBackoffStrategy.h"
#import "ADTUserDefaults.h"
#import "ADTPackageBuilder.h"

static const char * const kInternalQueueName = "io.adtrace.PurchaseVerificationQueue";

@interface ADTPurchaseVerificationHandler()

@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADTRequestHandler *requestHandler;

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) ADTBackoffStrategy *backoffStrategy;

@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;

@property (nonatomic, assign) NSInteger lastPackageRetriesCount;

@end

@implementation ADTPurchaseVerificationHandler

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADTUrlStrategy *)urlStrategy {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADTAdtraceFactory.logger;
    self.lastPackageRetriesCount = 0;

    self.requestHandler = [[ADTRequestHandler alloc] initWithResponseCallback:self
                                                                  urlStrategy:urlStrategy
                                                                    userAgent:userAgent
                                                               requestTimeout:[ADTAdtraceFactory requestTimeout]];

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPurchaseVerificationHandler *selfI) {
                         [selfI initI:selfI activityHandler:activityHandler startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
    [self sendNextPurchaseVerificationPackage];
}

- (void)sendPurchaseVerificationPackage:(ADTActivityPackage *)purchaseVerificationPackage {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPurchaseVerificationHandler *selfI) {
                         [selfI sendPurchaseVerificationPackageI:selfI purchaseVerificationPackage:purchaseVerificationPackage];
                     }];
}

- (void)sendNextPurchaseVerificationPackage {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPurchaseVerificationHandler *selfI) {
                         [selfI sendNextPurchaseVerificationPackageI:selfI];
                     }];
}

- (void)updatePackagesWithAttStatus:(int)attStatus {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPurchaseVerificationHandler *selfI) {
        [selfI updatePackagesTrackingI:selfI
                             attStatus:attStatus];
    }];
}

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTPurchaseVerificationHandler teardown"];

    if (self.packageQueue != nil) {
        [self.packageQueue removeAllObjects];
    }

    self.internalQueue = nil;
    self.logger = nil;
    self.backoffStrategy = nil;
    self.packageQueue = nil;
    self.activityHandler = nil;
}

#pragma mark - Private & helper methods

-   (void)initI:(ADTPurchaseVerificationHandler *)selfI
activityHandler:(id<ADTActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.backoffStrategy = [ADTAdtraceFactory sdkClickHandlerBackoffStrategy];
    selfI.packageQueue = [NSMutableArray array];
}

- (void)sendPurchaseVerificationPackageI:(ADTPurchaseVerificationHandler *)selfI
             purchaseVerificationPackage:(ADTActivityPackage *)purchaseVerificationPackage {
    [selfI.packageQueue addObject:purchaseVerificationPackage];
    [selfI.logger debug:@"Added purchase_verification %d", selfI.packageQueue.count];
    [selfI.logger verbose:@"%@", purchaseVerificationPackage.extendedString];
    [selfI sendNextPurchaseVerificationPackage];
}

- (void)sendNextPurchaseVerificationPackageI:(ADTPurchaseVerificationHandler *)selfI {
    if (selfI.paused) {
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"purchase_verification request won't be fired for forgotten user"];
        return;
    }

    ADTActivityPackage *purchaseVerificationPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![purchaseVerificationPackage isKindOfClass:[ADTActivityPackage class]]) {
        [selfI.logger error:@"Failed to read purchase_verification package"];
        [selfI sendNextPurchaseVerificationPackage];
        return;
    }

    dispatch_block_t work = ^{
        NSDictionary *sendingParameters = @{
            @"sent_at": [ADTUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
        };
        [selfI.requestHandler sendPackageByPOST:purchaseVerificationPackage
                              sendingParameters:sendingParameters];
        [selfI sendNextPurchaseVerificationPackage];
    };

    if (selfI.lastPackageRetriesCount <= 0) {
        work();
        return;
    }

    NSTimeInterval waitTime = [ADTUtil waitingTime:selfI.lastPackageRetriesCount backoffStrategy:self.backoffStrategy];
    NSString *waitTimeFormatted = [ADTUtil secondsNumberFormat:waitTime];
    [self.logger verbose:@"Waiting for %@ seconds before retrying purchase_verification for the %d time",
     waitTimeFormatted,
     selfI.lastPackageRetriesCount];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

- (void)updatePackagesTrackingI:(ADTPurchaseVerificationHandler *)selfI
                      attStatus:(int)attStatus {
    [selfI.logger debug:@"Updating purchase_verification queue with idfa and att_status: %d", attStatus];
    for (ADTActivityPackage *activityPackage in selfI.packageQueue) {
        [ADTPackageBuilder parameters:activityPackage.parameters
                               setInt:attStatus
                               forKey:@"att_status"];

        [ADTPackageBuilder addConsentDataToParameters:activityPackage.parameters
                                      forActivityKind:activityPackage.activityKind
                                        withAttStatus:[activityPackage.parameters objectForKey:@"att_status"]
                                        configuration:selfI.activityHandler.adtraceConfig
                                        packageParams:selfI.activityHandler.packageParams];
    }
}

- (void)responseCallback:(ADTResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got purchase_verification JSON response with message: %@", responseData.message];
        ADTPurchaseVerificationResult *verificationResult = [[ADTPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = responseData.jsonResponse[@"verification_status"];
        verificationResult.code = [(NSNumber *)responseData.jsonResponse[@"code"] intValue];
        verificationResult.message = responseData.jsonResponse[@"message"];
        responseData.purchaseVerificationPackage.purchaseVerificationCallback(verificationResult);
    } else {
        [self.logger error:
            @"Could not get purchase_verification JSON response with message: %@", responseData.message];
        ADTPurchaseVerificationResult *verificationResult = [[ADTPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 102;
        verificationResult.message = responseData.message;
        responseData.purchaseVerificationPackage.purchaseVerificationCallback(verificationResult);
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADTTrackingStateOptedOut) {
        self.lastPackageRetriesCount = 0;
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }
    if (responseData.jsonResponse == nil) {
        self.lastPackageRetriesCount++;
        [self.logger error:@"Retrying purchase_verification package for the %d time", self.lastPackageRetriesCount];
        [self sendPurchaseVerificationPackage:responseData.purchaseVerificationPackage];
        return;
    }
    self.lastPackageRetriesCount = 0;
    [self.activityHandler finishedTracking:responseData];
}

@end
