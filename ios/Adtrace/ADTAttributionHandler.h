//
//  ADTAttributionHandler.h
//  adtrace
//


#import <Foundation/Foundation.h>
#import "ADTActivityHandler.h"
#import "ADTActivityPackage.h"

@protocol ADTAttributionHandler

- (id)initWithActivityHandler:(id<ADTActivityHandler>) activityHandler
                startsSending:(BOOL)startsSending;

- (void)checkSessionResponse:(ADTSessionResponseData *)sessionResponseData;

- (void)checkSdkClickResponse:(ADTSdkClickResponseData *)sdkClickResponseData;

- (void)checkAttributionResponse:(ADTAttributionResponseData *)attributionResponseData;

- (void)getAttribution;

- (void)pauseSending;

- (void)resumeSending;

- (void)teardown;

@end

@interface ADTAttributionHandler : NSObject <ADTAttributionHandler>

+ (id<ADTAttributionHandler>)handlerWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                                          startsSending:(BOOL)startsSending;

@end
