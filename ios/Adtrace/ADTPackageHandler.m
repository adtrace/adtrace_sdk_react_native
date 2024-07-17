
#import "ADTPackageHandler.h"
#import "ADTActivityPackage.h"
#import "ADTLogger.h"
#import "ADTUtil.h"
#import "ADTAdtraceFactory.h"
#import "ADTBackoffStrategy.h"
#import "ADTPackageBuilder.h"
#import "ADTUserDefaults.h"

static NSString   * const kPackageQueueFilename = @"AdtraceIoPackageQueue";
static const char * const kInternalQueueName    = "io.adtrace.PackageQueue";


#pragma mark - private
@interface ADTPackageHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, strong) ADTRequestHandler *requestHandler;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) ADTBackoffStrategy *backoffStrategy;
@property (nonatomic, strong) ADTBackoffStrategy *backoffStrategyForInstallSession;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, assign) NSInteger lastPackageRetriesCount;
@property (nonatomic, assign) BOOL isRetrying;
@property (nonatomic, assign) NSTimeInterval retryStartedAt;
@property (nonatomic, assign) double totalWaitTime;

@end

#pragma mark -
@implementation ADTPackageHandler

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADTUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.backoffStrategy = [ADTAdtraceFactory packageHandlerBackoffStrategy];
    self.backoffStrategyForInstallSession = [ADTAdtraceFactory installSessionBackoffStrategy];
    self.lastPackageRetriesCount = 0;
    self.isRetrying = NO;
    self.totalWaitTime = 0.0;

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler * selfI) {
        [selfI initI:selfI
     activityHandler:activityHandler
       startsSending:startsSending
           userAgent:userAgent
         urlStrategy:urlStrategy];
    }];

    return self;
}

- (void)addPackage:(ADTActivityPackage *)package {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
        [selfI addI:selfI package:package];
    }];
}

- (void)sendFirstPackage {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
        [selfI sendFirstI:selfI];
    }];
}

- (void)responseCallback:(ADTResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:@"Got JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:@"Could not get JSON response with message: %@", responseData.message];
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADTTrackingStateOptedOut) {
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }
    if (responseData.jsonResponse == nil) {
        [self closeFirstPackage:responseData];
    } else {
        [self sendNextPackage:responseData];
    }
}

- (void)sendNextPackage:(ADTResponseData *)responseData {
    self.lastPackageRetriesCount = 0;
    self.isRetrying = NO;
    self.retryStartedAt = 0.0;

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
        [selfI sendNextI:selfI];
    }];

    [self.activityHandler finishedTracking:responseData];
}

- (void)closeFirstPackage:(ADTResponseData *)responseData {
    responseData.willRetry = YES;

    [self.activityHandler finishedTracking:responseData];

    self.lastPackageRetriesCount++;

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
                         [selfI writePackageQueueS:selfI];
                     }];

    NSTimeInterval waitTime;
    if (responseData.activityKind == ADTActivityKindSession && [ADTUserDefaults getInstallTracked] == NO) {
        waitTime = [ADTUtil waitingTime:self.lastPackageRetriesCount backoffStrategy:self.backoffStrategyForInstallSession];
    } else {
        waitTime = [ADTUtil waitingTime:self.lastPackageRetriesCount backoffStrategy:self.backoffStrategy];
    }
    NSString *waitTimeFormatted = [ADTUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying the %d time", waitTimeFormatted, self.lastPackageRetriesCount];
    self.totalWaitTime += waitTime;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, ^{
        [self.logger verbose:@"Package handler finished waiting"];
        dispatch_semaphore_signal(self.sendingSemaphore);
        responseData.sdkPackage.waitBeforeSend += waitTime;
        [self sendFirstPackage];
    });
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)updatePackagesWithSessionParams:(ADTSessionParameters *)sessionParameters {
    // make copy to prevent possible Activity Handler changes of it
    ADTSessionParameters * sessionParametersCopy = [sessionParameters copy];

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
        [selfI updatePackagesI:selfI sessionParameters:sessionParametersCopy];
    }];
}

- (void)updatePackagesWithAttStatus:(int)attStatus {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
        [selfI updatePackagesTrackingI:selfI
                             attStatus:attStatus];
    }];
}

- (void)flush {
    [ADTUtil launchInQueue:self.internalQueue selfInject:self block:^(ADTPackageHandler *selfI) {
        [selfI flushI:selfI];
    }];
}

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTPackageHandler teardown"];
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
    [self teardownPackageQueueS];
    self.internalQueue = nil;
    self.sendingSemaphore = nil;
    self.requestHandler = nil;
    self.backoffStrategy = nil;
    self.activityHandler = nil;
    self.logger = nil;
}

+ (void)deleteState {
    [ADTPackageHandler deletePackageQueue];
}

+ (void)deletePackageQueue {
    [ADTUtil deleteFileWithName:kPackageQueueFilename];
}

#pragma mark - internal
- (void)initI:(ADTPackageHandler *)selfI
activityHandler:(id<ADTActivityHandler>)activityHandler
startsSending:(BOOL)startsSending
    userAgent:(NSString *)userAgent
  urlStrategy:(ADTUrlStrategy *)urlStrategy {

    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.requestHandler = [[ADTRequestHandler alloc]
                            initWithResponseCallback:self
                            urlStrategy:urlStrategy
                            userAgent:userAgent
                            requestTimeout:[ADTAdtraceFactory requestTimeout]];
    selfI.logger = ADTAdtraceFactory.logger;
    selfI.sendingSemaphore = dispatch_semaphore_create(1);
    [selfI readPackageQueueI:selfI];
}

- (void)addI:(ADTPackageHandler *)selfI
     package:(ADTActivityPackage *)newPackage
{
    if (self.isRetrying == YES) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        newPackage.waitBeforeSend = self.totalWaitTime - (now - self.retryStartedAt);
    }
    [ADTPackageBuilder parameters:newPackage.parameters
                           setInt:(int)selfI.packageQueue.count
                           forKey:@"enqueue_size"];
    [selfI.packageQueue addObject:newPackage];

    [selfI.logger debug:@"Added package %d (%@)", selfI.packageQueue.count, newPackage];
    [selfI.logger verbose:@"%@", newPackage.extendedString];

    [selfI writePackageQueueS:selfI];
}

- (void)sendFirstI:(ADTPackageHandler *)selfI
{
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) return;

    if (selfI.paused) {
        [selfI.logger debug:@"Package handler is paused"];
        return;
    }

    if (dispatch_semaphore_wait(selfI.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [selfI.logger verbose:@"Package handler is already sending"];
        return;
    }

    ADTActivityPackage *activityPackage = [selfI.packageQueue objectAtIndex:0];
    if (![activityPackage isKindOfClass:[ADTActivityPackage class]]) {
        [selfI.logger error:@"Failed to read activity package"];
        [selfI sendNextI:selfI];
        return;
    }

    NSMutableDictionary *sendingParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (queueSize - 1 > 0) {
        [ADTPackageBuilder parameters:sendingParameters
                               setInt:(int)queueSize - 1
                               forKey:@"queue_size"];
    }
    [ADTPackageBuilder parameters:sendingParameters
                        setString:[ADTUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
                           forKey:@"sent_at"];

    [ADTPackageBuilder parameters:sendingParameters
                           setInt:(int)activityPackage.errorCount
                           forKey:@"retry_count"];
    [ADTPackageBuilder parameters:sendingParameters
         setNumberWithoutRounding:activityPackage.firstErrorCode
                           forKey:@"first_error"];
    [ADTPackageBuilder parameters:sendingParameters
         setNumberWithoutRounding:activityPackage.lastErrorCode
                           forKey:@"last_error"];
    [ADTPackageBuilder parameters:sendingParameters
                        setDouble:self.totalWaitTime
                           forKey:@"wait_total"];
    [ADTPackageBuilder parameters:sendingParameters
                        setDouble:activityPackage.waitBeforeSend
                           forKey:@"wait_time"];

    [selfI.requestHandler sendPackageByPOST:activityPackage
                          sendingParameters:[sendingParameters copy]];
}

- (void)sendNextI:(ADTPackageHandler *)selfI {
    if ([selfI.packageQueue count] > 0) {
        [selfI.packageQueue removeObjectAtIndex:0];
        [selfI writePackageQueueS:selfI];
    } else {
        // at this point, the queue has been emptied
        // reset total_wait in this moment to allow all requests to populate total_wait
        selfI.totalWaitTime = 0.0;
    }

    dispatch_semaphore_signal(selfI.sendingSemaphore);
    [selfI sendFirstI:selfI];
}

- (void)updatePackagesI:(ADTPackageHandler *)selfI
      sessionParameters:(ADTSessionParameters *)sessionParameters {
    [selfI.logger debug:@"Updating package handler queue"];
    [selfI.logger verbose:@"Session callback parameters: %@", sessionParameters.callbackParameters];
    [selfI.logger verbose:@"Session partner parameters: %@", sessionParameters.partnerParameters];

    // create package queue copy for new state of array
    NSMutableArray *packageQueueCopy = [NSMutableArray array];

    for (ADTActivityPackage *activityPackage in selfI.packageQueue) {
        // callback parameters
        NSDictionary *mergedCallbackParameters = [ADTUtil mergeParameters:sessionParameters.callbackParameters
                                                                   source:activityPackage.callbackParameters
                                                            parameterName:@"Callback"];
        [ADTPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedCallbackParameters
                               forKey:@"callback_params"];

        // partner parameters
        NSDictionary *mergedPartnerParameters = [ADTUtil mergeParameters:sessionParameters.partnerParameters
                                                                  source:activityPackage.partnerParameters
                                                           parameterName:@"Partner"];
        [ADTPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedPartnerParameters
                               forKey:@"partner_params"];
        // add to copy queue
        [packageQueueCopy addObject:activityPackage];
    }

    // write package queue copy
    selfI.packageQueue = packageQueueCopy;
    [selfI writePackageQueueS:selfI];
}

- (void)updatePackagesTrackingI:(ADTPackageHandler *)selfI
                      attStatus:(int)attStatus {
    [selfI.logger debug:@"Updating package queue with idfa and att_status: %d", (long)attStatus];
    // create package queue copy for new state of array
    NSMutableArray *packageQueueCopy = [NSMutableArray array];

    for (ADTActivityPackage *activityPackage in selfI.packageQueue) {
        [ADTPackageBuilder parameters:activityPackage.parameters setInt:attStatus forKey:@"att_status"];

        [ADTPackageBuilder addConsentDataToParameters:activityPackage.parameters
                                      forActivityKind:activityPackage.activityKind
                                        withAttStatus:[activityPackage.parameters objectForKey:@"att_status"]
                                        configuration:selfI.activityHandler.adtraceConfig
                                        packageParams:selfI.activityHandler.packageParams];
        // add to copy queue
        [packageQueueCopy addObject:activityPackage];
    }

    // write package queue copy
    selfI.packageQueue = packageQueueCopy;
    [selfI writePackageQueueS:selfI];
}

- (void)flushI:(ADTPackageHandler *)selfI {
    [selfI.packageQueue removeAllObjects];
    [selfI writePackageQueueS:selfI];
}

#pragma mark - private
- (void)readPackageQueueI:(ADTPackageHandler *)selfI {
    [NSKeyedUnarchiver setClass:[ADTActivityPackage class] forClassName:@"AIActivityPackage"];
    
    id object = [ADTUtil readObject:kPackageQueueFilename
                         objectName:@"Package queue"
                              class:[NSArray class]
                         syncObject:[ADTPackageHandler class]];
    
    if (object != nil) {
        selfI.packageQueue = object;
    } else {
        selfI.packageQueue = [NSMutableArray array];
    }

}

- (void)writePackageQueueS:(ADTPackageHandler *)selfS {
    if (selfS.packageQueue == nil) {
        return;
    }
    
    [ADTUtil writeObject:selfS.packageQueue
                fileName:kPackageQueueFilename
              objectName:@"Package queue"
              syncObject:[ADTPackageHandler class]];
}

- (void)teardownPackageQueueS {
    @synchronized ([ADTPackageHandler class]) {
        if (self.packageQueue == nil) {
            return;
        }
        
        [self.packageQueue removeAllObjects];
        self.packageQueue = nil;
    }
}

- (void)dealloc {
    // Cleanup code
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
}

@end
