//
//  ADTPackageHandler.m
//  Adtrace
//


#import "ADTRequestHandler.h"
#import "ADTActivityPackage.h"
#import "ADTLogger.h"
#import "ADTUtil.h"
#import "ADTAdtraceFactory.h"
#import "ADTBackoffStrategy.h"
#import "ADTPackageBuilder.h"

static NSString   * const kPackageQueueFilename = @"AdtraceIoPackageQueue";
static const char * const kInternalQueueName    = "io.adtrace.PackageQueue";


#pragma mark - private
@interface ADTPackageHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, strong) id<ADTRequestHandler> requestHandler;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) ADTBackoffStrategy * backoffStrategy;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, copy) NSString *gdprPath;

@end

#pragma mark -
@implementation ADTPackageHandler

+ (id<ADTPackageHandler>)handlerWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                                      startsSending:(BOOL)startsSending
{
    return [[ADTPackageHandler alloc] initWithActivityHandler:activityHandler startsSending:startsSending];
}

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.backoffStrategy = [ADTAdtraceFactory packageHandlerBackoffStrategy];
    self.basePath = [activityHandler getBasePath];
    self.gdprPath = [activityHandler getGdprPath];

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler * selfI) {
                         [selfI initI:selfI
                     activityHandler:activityHandler
                       startsSending:startsSending];
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

- (void)sendNextPackage:(ADTResponseData *)responseData{
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
                         [selfI sendNextI:selfI];
                     }];

    [self.activityHandler finishedTracking:responseData];
}

- (void)closeFirstPackage:(ADTResponseData *)responseData
          activityPackage:(ADTActivityPackage *)activityPackage
{
    responseData.willRetry = YES;
    [self.activityHandler finishedTracking:responseData];

    dispatch_block_t work = ^{
        [self.logger verbose:@"Package handler can send"];
        dispatch_semaphore_signal(self.sendingSemaphore);

        [self sendFirstPackage];
    };

    if (activityPackage == nil) {
        work();
        return;
    }

    NSInteger retries = [activityPackage increaseRetries];
    NSTimeInterval waitTime = [ADTUtil waitingTime:retries backoffStrategy:self.backoffStrategy];
    NSString * waitTimeFormatted = [ADTUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying the %d time", waitTimeFormatted, retries];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)updatePackages:(ADTSessionParameters *)sessionParameters
{
    // make copy to prevent possible Activity Handler changes of it
    ADTSessionParameters * sessionParametersCopy = [sessionParameters copy];

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTPackageHandler* selfI) {
                         [selfI updatePackagesI:selfI sessionParameters:sessionParametersCopy];
                     }];
}

- (void)flush {
    [ADTUtil launchInQueue:self.internalQueue selfInject:self block:^(ADTPackageHandler *selfI) {
        [selfI flushI:selfI];
    }];
}

- (NSString *)getBasePath {
    return _basePath;
}

- (NSString *)getGdprPath {
    return _gdprPath;
}

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTPackageHandler teardown"];
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
    if (self.requestHandler != nil) {
        [self.requestHandler teardown];
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
{
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.requestHandler = [ADTAdtraceFactory requestHandlerForPackageHandler:selfI
                                                          andActivityHandler:selfI.activityHandler];
    selfI.logger = ADTAdtraceFactory.logger;
    selfI.sendingSemaphore = dispatch_semaphore_create(1);
    [selfI readPackageQueueI:selfI];
}

- (void)addI:(ADTPackageHandler *)selfI
     package:(ADTActivityPackage *)newPackage
{
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

    [selfI.requestHandler sendPackage:activityPackage
                            queueSize:queueSize - 1];
}

- (void)sendNextI:(ADTPackageHandler *)selfI {
    if ([selfI.packageQueue count] > 0) {
        [selfI.packageQueue removeObjectAtIndex:0];
        [selfI writePackageQueueS:selfI];
    }

    dispatch_semaphore_signal(selfI.sendingSemaphore);
    [selfI sendFirstI:selfI];
}

- (void)updatePackagesI:(ADTPackageHandler *)selfI
      sessionParameters:(ADTSessionParameters *)sessionParameters
{
    [selfI.logger debug:@"Updating package handler queue"];
    [selfI.logger verbose:@"Session callback parameters: %@", sessionParameters.callbackParameters];
    [selfI.logger verbose:@"Session partner parameters: %@", sessionParameters.partnerParameters];

    for (ADTActivityPackage * activityPackage in selfI.packageQueue) {
        // callback parameters
        NSDictionary * mergedCallbackParameters = [ADTUtil mergeParameters:sessionParameters.callbackParameters
                                                                    source:activityPackage.callbackParameters
                                                             parameterName:@"Callback"];

        [ADTPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedCallbackParameters
                               forKey:@"callback_params"];

        // partner parameters
        NSDictionary * mergedPartnerParameters = [ADTUtil mergeParameters:sessionParameters.partnerParameters
                                                                   source:activityPackage.partnerParameters
                                                            parameterName:@"Partner"];

        [ADTPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedPartnerParameters
                               forKey:@"partner_params"];
    }

    [selfI writePackageQueueS:selfI];
}

- (void)flushI:(ADTPackageHandler *)selfI {
    [selfI.packageQueue removeAllObjects];
    [selfI writePackageQueueS:selfI];
}

#pragma mark - private
- (void)readPackageQueueI:(ADTPackageHandler *)selfI {
    [NSKeyedUnarchiver setClass:[ADTActivityPackage class] forClassName:@"AIActivityPackage"];

    id object = [ADTUtil readObject:kPackageQueueFilename objectName:@"Package queue" class:[NSArray class]];

    if (object != nil) {
        selfI.packageQueue = object;
    } else {
        selfI.packageQueue = [NSMutableArray array];
    }
}

- (void)writePackageQueueS:(ADTPackageHandler *)selfS {
    @synchronized ([ADTPackageHandler class]) {
        if (selfS.packageQueue == nil) {
            return;
        }

        [ADTUtil writeObject:selfS.packageQueue fileName:kPackageQueueFilename objectName:@"Package queue"];
    }
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
