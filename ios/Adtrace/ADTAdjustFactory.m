//
//  ADTAdtraceFactory.m
//  Adtrace
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adtrace GmbH. All rights reserved.
//

#import "ADTAdtraceFactory.h"

static id<ADTPackageHandler> internalPackageHandler = nil;
static id<ADTRequestHandler> internalRequestHandler = nil;
static id<ADTActivityHandler> internalActivityHandler = nil;
static id<ADTLogger> internalLogger = nil;
static id<ADTAttributionHandler> internalAttributionHandler = nil;
static id<ADTSdkClickHandler> internalSdkClickHandler = nil;

static double internalSessionInterval    = -1;
static double intervalSubsessionInterval = -1;
static NSTimeInterval internalTimerInterval = -1;
static NSTimeInterval intervalTimerStart = -1;
static ADTBackoffStrategy * packageHandlerBackoffStrategy = nil;
static ADTBackoffStrategy * sdkClickHandlerBackoffStrategy = nil;
static BOOL internalTesting = NO;
static NSTimeInterval internalMaxDelayStart = -1;
static BOOL internaliAdFrameworkEnabled = YES;

static NSString * const kBaseUrl = @"https://app.adtrace.com";
static NSString * internalBaseUrl = @"https://app.adtrace.com";
static NSString * const kGdprUrl = @"https://gdpr.adtrace.com";
static NSString * internalGdprUrl = @"https://gdpr.adtrace.com";

@implementation ADTAdtraceFactory

+ (id<ADTPackageHandler>)packageHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                            startsSending:(BOOL)startsSending {
    if (internalPackageHandler == nil) {
        return [ADTPackageHandler handlerWithActivityHandler:activityHandler startsSending:startsSending];
    }

    return [internalPackageHandler initWithActivityHandler:activityHandler startsSending:startsSending];
}

+ (id<ADTRequestHandler>)requestHandlerForPackageHandler:(id<ADTPackageHandler>)packageHandler
                                      andActivityHandler:(id<ADTActivityHandler>)activityHandler {
    if (internalRequestHandler == nil) {
        return [ADTRequestHandler handlerWithPackageHandler:packageHandler
                                         andActivityHandler:activityHandler];
    }
    return [internalRequestHandler initWithPackageHandler:packageHandler
                                       andActivityHandler:activityHandler];
}

+ (id<ADTActivityHandler>)activityHandlerWithConfig:(ADTConfig *)adtraceConfig
                     savedPreLaunch:(ADTSavedPreLaunch *)savedPreLaunch
{
    if (internalActivityHandler == nil) {
        return [ADTActivityHandler handlerWithConfig:adtraceConfig
                                      savedPreLaunch:savedPreLaunch
                ];
    }
    return [internalActivityHandler initWithConfig:adtraceConfig
                                    savedPreLaunch:savedPreLaunch];
}

+ (id<ADTLogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[ADTLogger alloc] init];
    }
    return internalLogger;
}

+ (double)sessionInterval {
    if (internalSessionInterval < 0) {
        return 30 * 60;           // 30 minutes
    }
    return internalSessionInterval;
}

+ (double)subsessionInterval {
    if (intervalSubsessionInterval == -1) {
        return 1;                 // 1 second
    }
    return intervalSubsessionInterval;
}

+ (NSTimeInterval)timerInterval {
    if (internalTimerInterval < 0) {
        return 60;                // 1 minute
    }
    return internalTimerInterval;
}

+ (NSTimeInterval)timerStart {
    if (intervalTimerStart < 0) {
        return 60;                 // 1 minute
    }
    return intervalTimerStart;
}

+ (ADTBackoffStrategy *)packageHandlerBackoffStrategy {
    if (packageHandlerBackoffStrategy == nil) {
        return [ADTBackoffStrategy backoffStrategyWithType:ADTLongWait];
    }
    return packageHandlerBackoffStrategy;
}

+ (ADTBackoffStrategy *)sdkClickHandlerBackoffStrategy {
    if (sdkClickHandlerBackoffStrategy == nil) {
        return [ADTBackoffStrategy backoffStrategyWithType:ADTShortWait];
    }
    return sdkClickHandlerBackoffStrategy;
}

+ (id<ADTAttributionHandler>)attributionHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                                    startsSending:(BOOL)startsSending
{
    if (internalAttributionHandler == nil) {
        return [ADTAttributionHandler handlerWithActivityHandler:activityHandler
                                                   startsSending:startsSending];
    }

    return [internalAttributionHandler initWithActivityHandler:activityHandler
                                                 startsSending:startsSending];
}

+ (id<ADTSdkClickHandler>)sdkClickHandlerForActivityHandler:(id<ADTActivityHandler>)activityHandler
                                              startsSending:(BOOL)startsSending
{
    if (internalSdkClickHandler == nil) {
        return [ADTSdkClickHandler handlerWithActivityHandler:activityHandler startsSending:startsSending];
    }

    return [internalSdkClickHandler initWithActivityHandler:activityHandler startsSending:startsSending];
}

+ (BOOL)testing {
    return internalTesting;
}

+ (BOOL)iAdFrameworkEnabled {
    return internaliAdFrameworkEnabled;
}

+ (NSTimeInterval)maxDelayStart {
    if (internalMaxDelayStart < 0) {
        return 10.0;               // 10 seconds
    }
    return internalMaxDelayStart;
}

+ (NSString *)baseUrl {
    return internalBaseUrl;
}

+ (NSString *)gdprUrl {
    return internalGdprUrl;
}

+ (void)setPackageHandler:(id<ADTPackageHandler>)packageHandler {
    internalPackageHandler = packageHandler;
}

+ (void)setRequestHandler:(id<ADTRequestHandler>)requestHandler {
    internalRequestHandler = requestHandler;
}

+ (void)setActivityHandler:(id<ADTActivityHandler>)activityHandler {
    internalActivityHandler = activityHandler;
}

+ (void)setLogger:(id<ADTLogger>)logger {
    internalLogger = logger;
}

+ (void)setSessionInterval:(double)sessionInterval {
    internalSessionInterval = sessionInterval;
}

+ (void)setSubsessionInterval:(double)subsessionInterval {
    intervalSubsessionInterval = subsessionInterval;
}

+ (void)setTimerInterval:(NSTimeInterval)timerInterval {
    internalTimerInterval = timerInterval;
}

+ (void)setTimerStart:(NSTimeInterval)timerStart {
    intervalTimerStart = timerStart;
}

+ (void)setAttributionHandler:(id<ADTAttributionHandler>)attributionHandler {
    internalAttributionHandler = attributionHandler;
}

+ (void)setSdkClickHandler:(id<ADTSdkClickHandler>)sdkClickHandler {
    internalSdkClickHandler = sdkClickHandler;
}

+ (void)setPackageHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy {
    packageHandlerBackoffStrategy = backoffStrategy;
}

+ (void)setSdkClickHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy {
    sdkClickHandlerBackoffStrategy = backoffStrategy;
}

+ (void)setTesting:(BOOL)testing {
    internalTesting = testing;
}

+ (void)setiAdFrameworkEnabled:(BOOL)iAdFrameworkEnabled {
    internaliAdFrameworkEnabled = iAdFrameworkEnabled;
}

+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart {
    internalMaxDelayStart = maxDelayStart;
}

+ (void)setBaseUrl:(NSString *)baseUrl {
    internalBaseUrl = baseUrl;
}

+ (void)setGdprUrl:(NSString *)gdprUrl {
    internalGdprUrl = gdprUrl;
}

+ (void)teardown:(BOOL)deleteState {
    if (deleteState) {
        [ADTActivityHandler deleteState];
        [ADTPackageHandler deleteState];
    }
    internalPackageHandler = nil;
    internalRequestHandler = nil;
    internalActivityHandler = nil;
    internalLogger = nil;
    internalAttributionHandler = nil;
    internalSdkClickHandler = nil;

    internalSessionInterval    = -1;
    intervalSubsessionInterval = -1;
    internalTimerInterval = -1;
    intervalTimerStart = -1;
    packageHandlerBackoffStrategy = nil;
    sdkClickHandlerBackoffStrategy = nil;
    internalTesting = NO;
    internalMaxDelayStart = -1;
    internalBaseUrl = kBaseUrl;
    internalGdprUrl = kGdprUrl;
    internaliAdFrameworkEnabled = YES;
}
@end
