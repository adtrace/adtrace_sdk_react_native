//
//  AdtraceSdkDelegate.h
//  Adtrace SDK
//

#import "AdtraceSdk.h"
#import "AdtraceEventEmitter.h"

@interface AdtraceSdkDelegate : NSObject<AdtraceDelegate>

@property (nonatomic) BOOL shouldLaunchDeferredDeeplink;

+ (id)getInstanceWithSwizzleOfAttributionCallback:(BOOL)swizzleAttributionCallback
						   eventSucceededCallback:(BOOL)swizzleEventSucceededCallback
							  eventFailedCallback:(BOOL)swizzleEventFailedCallback
						 sessionSucceededCallback:(BOOL)swizzleSessionSucceededCallback
						    sessionFailedCallback:(BOOL)swizzleSessionFailedCallback
					     deferredDeeplinkCallback:(BOOL)swizzleDeferredDeeplinkCallback
                     shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink;

+ (void)teardown;

@end
