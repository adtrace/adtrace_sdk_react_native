//
//  ADTAdtraceFactory.h
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADTLogger.h"
#import "ADTActivityPackage.h"
#import "ADTBackoffStrategy.h"
#import "ADTSdkClickHandler.h"

@interface ADTAdtraceFactory : NSObject

+ (id<ADTLogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (double)requestTimeout;
+ (NSTimeInterval)timerInterval;
+ (NSTimeInterval)timerStart;
+ (ADTBackoffStrategy *)packageHandlerBackoffStrategy;
+ (ADTBackoffStrategy *)sdkClickHandlerBackoffStrategy;
+ (ADTBackoffStrategy *)installSessionBackoffStrategy;

+ (BOOL)testing;
+ (NSTimeInterval)maxDelayStart;
+ (NSString *)baseUrl;
+ (NSString *)gdprUrl;
+ (NSString *)subscriptionUrl;
+ (NSString *)purchaseVerificationUrl;
+ (BOOL)adServicesFrameworkEnabled;

+ (void)setLogger:(id<ADTLogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setRequestTimeout:(double)requestTimeout;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;
+ (void)setTimerStart:(NSTimeInterval)timerStart;
+ (void)setPackageHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setSdkClickHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setTesting:(BOOL)testing;
+ (void)setAdServicesFrameworkEnabled:(BOOL)adServicesFrameworkEnabled;
+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart;
+ (void)setBaseUrl:(NSString *)baseUrl;
+ (void)setGdprUrl:(NSString *)gdprUrl;
+ (void)setSubscriptionUrl:(NSString *)subscriptionUrl;
+ (void)setPurchaseVerificationUrl:(NSString *)purchaseVerificationUrl;

+ (void)enableSigning;
+ (void)disableSigning;

+ (void)teardown:(BOOL)deleteState;
@end
