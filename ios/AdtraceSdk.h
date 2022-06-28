//
//  AdtraceSdk.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "Adtrace.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@interface AdtraceSdk : NSObject <RCTBridgeModule>

@end
