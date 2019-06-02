//
//  ADTRequestHandler.m
//  Adtrace
//


#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTActivityKind.h"
#import "ADTAdtraceFactory.h"
#import "ADTPackageBuilder.h"
#import "ADTActivityPackage.h"
#import "NSString+ADTAdditions.h"

static const char * const kInternalQueueName = "io.adtrace.RequestQueue";

@interface ADTRequestHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;

@property (nonatomic, weak) id<ADTLogger> logger;

@property (nonatomic, weak) id<ADTPackageHandler> packageHandler;

@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;

@property (nonatomic, copy) NSString *basePath;

@property (nonatomic, copy) NSString *gdprPath;

@end

@implementation ADTRequestHandler

#pragma mark - Public methods

+ (ADTRequestHandler *)handlerWithPackageHandler:(id<ADTPackageHandler>)packageHandler
                              andActivityHandler:(id<ADTActivityHandler>)activityHandler {
    return [[ADTRequestHandler alloc] initWithPackageHandler:packageHandler
                                          andActivityHandler:activityHandler];
}

- (id)initWithPackageHandler:(id<ADTPackageHandler>)packageHandler
          andActivityHandler:(id<ADTActivityHandler>)activityHandler {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.activityHandler = activityHandler;
    self.logger = ADTAdtraceFactory.logger;
    self.basePath = [packageHandler getBasePath];
    self.gdprPath = [packageHandler getGdprPath];

    return self;
}

- (void)sendPackage:(ADTActivityPackage *)activityPackage queueSize:(NSUInteger)queueSize {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTRequestHandler* selfI) {
                         [selfI sendI:selfI activityPackage:activityPackage queueSize:queueSize];
                     }];
}

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTRequestHandler teardown"];
    
    self.logger = nil;
    self.internalQueue = nil;
    self.packageHandler = nil;
    self.activityHandler = nil;
}

#pragma mark - Private & helper methods

- (void)sendI:(ADTRequestHandler *)selfI activityPackage:(ADTActivityPackage *)activityPackage queueSize:(NSUInteger)queueSize {
    NSURL *url;

    if (activityPackage.activityKind == ADTActivityKindGdpr) {
        NSString *gdprUrl = [ADTAdtraceFactory gdprUrl];
        if (selfI.gdprPath != nil) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", gdprUrl, selfI.gdprPath]];
        } else {
            url = [NSURL URLWithString:gdprUrl];
        }
    } else {
        NSString *baseUrl = [ADTAdtraceFactory baseUrl];
        if (selfI.basePath != nil) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, selfI.basePath]];
        } else {
            url = [NSURL URLWithString:baseUrl];
        }
    }

    [ADTUtil sendPostRequest:url
                   queueSize:queueSize
          prefixErrorMessage:activityPackage.failureMessage
          suffixErrorMessage:@"Will retry later"
             activityPackage:activityPackage
         responseDataHandler:^(ADTResponseData *responseData) {
             // Check if any package response contains information that user has opted out.
             // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
             if (responseData.trackingState == ADTTrackingStateOptedOut) {
                 [selfI.activityHandler setTrackingStateOptedOut];
                 return;
             }
             if (responseData.jsonResponse == nil) {
                 [selfI.packageHandler closeFirstPackage:responseData activityPackage:activityPackage];
                 return;
             }

             [selfI.packageHandler sendNextPackage:responseData];
         }];
}

@end
