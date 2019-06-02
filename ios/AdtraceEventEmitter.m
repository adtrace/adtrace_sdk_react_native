//
//  AdtraceEventEmitter.m
//  Adtrace SDK
//

#import "AdtraceEventEmitter.h"

@implementation AdtraceEventEmitter

RCT_EXPORT_MODULE();

+ (id)allocWithZone:(NSZone *)zone {
    static AdtraceEventEmitter *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });

    return sharedInstance;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"adtrace_attribution",
             @"adtrace_eventTrackingSucceeded",
             @"adtrace_eventTrackingFailed",
             @"adtrace_sessionTrackingSucceeded",
             @"adtrace_sessionTrackingFailed",
             @"adtrace_deferredDeeplink"];
}

- (void)startObserving {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSString *notificationName in [self supportedEvents]) {
        [center addObserver:self
                   selector:@selector(emitEventInternal:)
                       name:notificationName
                     object:nil];
    }
}

- (void)stopObserving {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)emitEventInternal:(NSNotification *)notification {
    [self sendEventWithName:notification.name
                       body:notification.userInfo];
}

+ (void)dispatchEvent:(NSString *)eventName withDictionary:(NSDictionary *)dictionary {
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName
                                                        object:self
                                                      userInfo:dictionary];
}

@end
