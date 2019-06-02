//
//  AdtraceSdk.h
//  Adtrace SDK
//


#import "Adtrace.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@interface AdtraceSdk : NSObject <RCTBridgeModule>

@end
