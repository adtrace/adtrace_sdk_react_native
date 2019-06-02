//
//  ADTSdkClickHandler.h
//  Adtrace SDK
//


#import <Foundation/Foundation.h>
#import "ADTActivityPackage.h"
#import "ADTActivityHandler.h"

@protocol ADTSdkClickHandler

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending;
- (void)pauseSending;
- (void)resumeSending;
- (void)sendSdkClick:(ADTActivityPackage *)sdkClickPackage;
- (void)teardown;

@end

@interface ADTSdkClickHandler : NSObject <ADTSdkClickHandler>

+ (id<ADTSdkClickHandler>)handlerWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                                       startsSending:(BOOL)startsSending;

@end
