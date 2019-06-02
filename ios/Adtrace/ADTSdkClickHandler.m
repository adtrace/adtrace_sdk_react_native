//
//  ADTSdkClickHandler.m
//  Adtrace SDK
//

#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTAdtraceFactory.h"
#import "ADTSdkClickHandler.h"
#import "ADTBackoffStrategy.h"

static const char * const kInternalQueueName = "com.adtrace.SdkClickQueue";

@interface ADTSdkClickHandler()

@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) dispatch_queue_t internalQueue;

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) ADTBackoffStrategy *backoffStrategy;

@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;

@end

@implementation ADTSdkClickHandler

#pragma mark - Public class methods

+ (id<ADTSdkClickHandler>)handlerWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                                       startsSending:(BOOL)startsSending {
    return [[ADTSdkClickHandler alloc] initWithActivityHandler:activityHandler
                                                 startsSending:startsSending];
}

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADTAdtraceFactory.logger;
    self.basePath = [activityHandler getBasePath];

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTSdkClickHandler *selfI) {
                         [selfI initI:selfI
                      activityHandler:activityHandler
                        startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
    [self sendNextSdkClick];
}

- (void)sendSdkClick:(ADTActivityPackage *)sdkClickPackage {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTSdkClickHandler *selfI) {
                         [selfI sendSdkClickI:selfI sdkClickPackage:sdkClickPackage];
                     }];
}

- (void)sendNextSdkClick {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTSdkClickHandler *selfI) {
                         [selfI sendNextSdkClickI:selfI];
                     }];
}

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTSdkClickHandler teardown"];

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

-   (void)initI:(ADTSdkClickHandler *)selfI
activityHandler:(id<ADTActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.backoffStrategy = [ADTAdtraceFactory sdkClickHandlerBackoffStrategy];
    selfI.packageQueue = [NSMutableArray array];
}

- (void)sendSdkClickI:(ADTSdkClickHandler *)selfI
      sdkClickPackage:(ADTActivityPackage *)sdkClickPackage {
    [selfI.packageQueue addObject:sdkClickPackage];
    [selfI.logger debug:@"Added sdk_click %d", selfI.packageQueue.count];
    [selfI.logger verbose:@"%@", sdkClickPackage.extendedString];
    [selfI sendNextSdkClick];
}

- (void)sendNextSdkClickI:(ADTSdkClickHandler *)selfI {
    if (selfI.paused) {
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"sdk_click request won't be fired for forgotten user"];
        return;
    }

    ADTActivityPackage *sdkClickPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![sdkClickPackage isKindOfClass:[ADTActivityPackage class]]) {
        [selfI.logger error:@"Failed to read sdk_click package"];
        [selfI sendNextSdkClick];
        return;
    }

    NSURL *url;
    NSString *baseUrl = [ADTAdtraceFactory baseUrl];
    if (selfI.basePath != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, selfI.basePath]];
    } else {
        url = [NSURL URLWithString:baseUrl];
    }

    dispatch_block_t work = ^{
        [ADTUtil sendPostRequest:url
                       queueSize:queueSize - 1
              prefixErrorMessage:sdkClickPackage.failureMessage
              suffixErrorMessage:@"Will retry later"
                 activityPackage:sdkClickPackage
             responseDataHandler:^(ADTResponseData *responseData) {
                 // Check if any package response contains information that user has opted out.
                 // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
                 if (responseData.trackingState == ADTTrackingStateOptedOut) {
                     [selfI.activityHandler setTrackingStateOptedOut];
                     return;
                 }
                 if (responseData.jsonResponse == nil) {
                     NSInteger retries = [sdkClickPackage increaseRetries];
                     [selfI.logger error:@"Retrying sdk_click package for the %d time", retries];
                     [selfI sendSdkClick:sdkClickPackage];
                     return;
                 }

                 [selfI.activityHandler finishedTracking:responseData];
             }];

        [selfI sendNextSdkClick];
    };

    NSInteger retries = [sdkClickPackage retries];
    if (retries <= 0) {
        work();
        return;
    }

    NSTimeInterval waitTime = [ADTUtil waitingTime:retries backoffStrategy:self.backoffStrategy];
    NSString *waitTimeFormatted = [ADTUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying sdk_click for the %d time", waitTimeFormatted, retries];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

@end
