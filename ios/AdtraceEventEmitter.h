//
//  AdtraceEventEmitter.h
//  Adtrace SDK
//


#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#else
#import "RCTBridgeModule.h"
#import <RCTEventEmitter.h>
#endif

@interface AdtraceEventEmitter : RCTEventEmitter <RCTBridgeModule>

+ (void)dispatchEvent:(NSString *)eventName withDictionary:(NSDictionary *)dictionary;

@end
