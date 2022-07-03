//
//  ADTUrlStrategy.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTUrlStrategy.h"
#import "Adtrace.h"
#import "ADTAdtraceFactory.h"

static NSString * const baseUrl = @"https://app.adtrace.io";
static NSString * const gdprUrl = @"https://gdpr.adtrace.io";
static NSString * const subscriptionUrl = @"https://subscription.adtrace.io";

static NSString * const baseUrlIndia = @"https://app.adtrace.io.in";
static NSString * const gdprUrlIndia = @"https://gdpr.adtrace.io.in";
static NSString * const subscritionUrlIndia = @"https://subscription.adtrace.io.in";

static NSString * const baseUrlChina = @"https://app.adtrace.world";
static NSString * const gdprUrlChina = @"https://gdpr.adtrace.world";
static NSString * const subscritionUrlChina = @"https://subscription.adtrace.world";

static NSString * const baseUrlEU = @"https://app.eu.adtrace.io";
static NSString * const gdprUrlEU = @"https://gdpr.eu.adtrace.io";
static NSString * const subscriptionUrlEU = @"https://subscription.eu.adtrace.io";

static NSString * const baseUrlTR = @"https://app.tr.adtrace.io";
static NSString * const gdprUrlTR = @"https://gdpr.tr.adtrace.io";
static NSString * const subscriptionUrlTR = @"https://subscription.tr.adtrace.io";

static NSString * const baseUrlUS = @"https://app.us.adtrace.io";
static NSString * const gdprUrlUS = @"https://gdpr.us.adtrace.io";
static NSString * const subscriptionUrlUS = @"https://subscription.us.adtrace.io";

@interface ADTUrlStrategy ()

@property (nonatomic, copy) NSArray<NSString *> *baseUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *gdprUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *subscriptionUrlChoicesArray;

@property (nonatomic, copy) NSString *overridenBaseUrl;
@property (nonatomic, copy) NSString *overridenGdprUrl;
@property (nonatomic, copy) NSString *overridenSubscriptionUrl;

@property (nonatomic, assign) BOOL wasLastAttemptSuccess;

@property (nonatomic, assign) NSUInteger choiceIndex;
@property (nonatomic, assign) NSUInteger startingChoiceIndex;

@end

@implementation ADTUrlStrategy

- (instancetype)initWithUrlStrategyInfo:(NSString *)urlStrategyInfo
                              extraPath:(NSString *)extraPath
{
    self = [super init];

    _extraPath = extraPath ?: @"";

    _baseUrlChoicesArray = [ADTUrlStrategy baseUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];
    _gdprUrlChoicesArray = [ADTUrlStrategy gdprUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];
    _subscriptionUrlChoicesArray = [ADTUrlStrategy
                                    subscriptionUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];

    _overridenBaseUrl = [ADTAdtraceFactory baseUrl];
    _overridenGdprUrl = [ADTAdtraceFactory gdprUrl];
    _overridenSubscriptionUrl = [ADTAdtraceFactory subscriptionUrl];

    _wasLastAttemptSuccess = NO;

    _choiceIndex = 0;
    _startingChoiceIndex = 0;

    return self;
}

+ (NSArray<NSString *> *)baseUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADTUrlStrategyIndia]) {
        return @[baseUrlIndia, baseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTUrlStrategyChina]) {
        return @[baseUrlChina, baseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyEU]) {
        return @[baseUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyTR]) {
        return @[baseUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyUS]) {
        return @[baseUrlUS];
    } else {
        return @[baseUrl, baseUrlIndia, baseUrlChina];
    }
}

+ (NSArray<NSString *> *)gdprUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADTUrlStrategyIndia]) {
        return @[gdprUrlIndia, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTUrlStrategyChina]) {
        return @[gdprUrlChina, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyEU]) {
        return @[gdprUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyTR]) {
        return @[gdprUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyUS]) {
        return @[gdprUrlUS];
    } else {
        return @[gdprUrl, gdprUrlIndia, gdprUrlChina];
    }
}

+ (NSArray<NSString *> *)subscriptionUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADTUrlStrategyIndia]) {
        return @[subscritionUrlIndia, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTUrlStrategyChina]) {
        return @[subscritionUrlChina, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyEU]) {
        return @[subscriptionUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyTR]) {
        return @[subscriptionUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADTDataResidencyUS]) {
        return @[subscriptionUrlUS];
    } else {
        return @[subscriptionUrl, subscritionUrlIndia, subscritionUrlChina];
    }
}

- (NSString *)getUrlHostStringByPackageKind:(ADTActivityKind)activityKind {
    if (activityKind == ADTActivityKindGdpr) {
        if (self.overridenGdprUrl != nil) {
            return self.overridenGdprUrl;
        } else {
            return [self.gdprUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    } else if (activityKind == ADTActivityKindSubscription) {
        if (self.overridenSubscriptionUrl != nil) {
            return self.overridenSubscriptionUrl;
        } else {
            return [self.subscriptionUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    } else {
        if (self.overridenBaseUrl != nil) {
            return self.overridenBaseUrl;
        } else {
            return [self.baseUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    }
}

- (void)resetAfterSuccess {
    self.startingChoiceIndex = self.choiceIndex;
    self.wasLastAttemptSuccess = YES;
}

- (BOOL)shouldRetryAfterFailure:(ADTActivityKind)activityKind {
    self.wasLastAttemptSuccess = NO;

    NSUInteger choiceListSize;
    if (activityKind == ADTActivityKindGdpr) {
        choiceListSize = [_gdprUrlChoicesArray count];
    } else if (activityKind == ADTActivityKindSubscription) {
        choiceListSize = [_subscriptionUrlChoicesArray count];
    } else {
        choiceListSize = [_baseUrlChoicesArray count];
    }

    NSUInteger nextChoiceIndex = (self.choiceIndex + 1) % choiceListSize;
    self.choiceIndex = nextChoiceIndex;

    BOOL nextChoiceHasNotReturnedToStartingChoice = self.choiceIndex != self.startingChoiceIndex;
    return nextChoiceHasNotReturnedToStartingChoice;
}

@end
