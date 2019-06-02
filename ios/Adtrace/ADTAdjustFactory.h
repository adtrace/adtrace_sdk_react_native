//
//  ADTAdtraceFactory.h
//  Adtrace
//

#import <Foundation/Foundation.h>

#import "ADTActivityHandler.h"
#import "ADTPackageHandler.h"
#import "ADTRequestHandler.h"
#import "ADTLogger.h"
#import "ADTAttributionHandler.h"
#import "ADTActivityPackage.h"
#import "ADTBackoffStrategy.h"
#import "ADTSdkClickHandler.h"

@interface ADTAdtraceFactory : NSObject

+ (id<ADTPackageHandler>)packageHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                            startsSending:(BOOL)startsSending;
+ (id<ADTRequestHandler>)requestHandlerForPackageHandler:(id<ADTPackageHandler>)packageHandler
                                      andActivityHandler:(id<ADTActivityHandler>)activityHandler;
+ (id<ADTActivityHandler>)activityHandlerWithConfig:(ADTConfig *)adtraceConfig
                     savedPreLaunch:(ADTSavedPreLaunch *)savedPreLaunch;
+ (id<ADTSdkClickHandler>)sdkClickHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                              startsSending:(BOOL)startsSending;

+ (id<ADTLogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (NSTimeInterval)timerInterval;
+ (NSTimeInterval)timerStart;
+ (ADTBackoffStrategy *)packageHandlerBackoffStrategy;
+ (ADTBackoffStrategy *)sdkClickHandlerBackoffStrategy;

+ (id<ADTAttributionHandler>)attributionHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                                    startsSending:(BOOL)startsSending;
+ (BOOL)testing;
+ (NSTimeInterval)maxDelayStart;
+ (NSString *)baseUrl;
+ (NSString *)gdprUrl;
+ (BOOL)iAdFrameworkEnabled;

+ (void)setPackageHandler:(id<ADTPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<ADTRequestHandler>)requestHandler;
+ (void)setActivityHandler:(id<ADTActivityHandler>)activityHandler;
+ (void)setSdkClickHandler:(id<ADTSdkClickHandler>)sdkClickHandler;
+ (void)setLogger:(id<ADTLogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;
+ (void)setTimerStart:(NSTimeInterval)timerStart;
+ (void)setAttributionHandler:(id<ADTAttributionHandler>)attributionHandler;
+ (void)setPackageHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setSdkClickHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setTesting:(BOOL)testing;
+ (void)setiAdFrameworkEnabled:(BOOL)iAdFrameworkEnabled;
+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart;
+ (void)setBaseUrl:(NSString *)baseUrl;
+ (void)setGdprUrl:(NSString *)gdprUrl;

+ (void)teardown:(BOOL)deleteState;
@end
