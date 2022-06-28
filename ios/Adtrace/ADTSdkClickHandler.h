//
//  ADTSdkClickHandler.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTActivityPackage.h"
#import "ADTActivityHandler.h"
#import "ADTRequestHandler.h"
#import "ADTUrlStrategy.h"

@interface ADTSdkClickHandler : NSObject <ADTResponseCallback>

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADTUrlStrategy *)urlStrategy;
- (void)pauseSending;
- (void)resumeSending;
- (void)sendSdkClick:(ADTActivityPackage *)sdkClickPackage;
- (void)teardown;

@end
