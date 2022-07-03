//
//  ADTActivityKind.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTActivityKind.h"

@implementation ADTActivityKindUtil

#pragma mark - Public methods

+ (ADTActivityKind)activityKindFromString:(NSString *)activityKindString {
    if ([@"session" isEqualToString:activityKindString]) {
        return ADTActivityKindSession;
    } else if ([@"event" isEqualToString:activityKindString]) {
        return ADTActivityKindEvent;
    } else if ([@"click" isEqualToString:activityKindString]) {
        return ADTActivityKindClick;
    } else if ([@"attribution" isEqualToString:activityKindString]) {
        return ADTActivityKindAttribution;
    } else if ([@"info" isEqualToString:activityKindString]) {
        return ADTActivityKindInfo;
    } else if ([@"gdpr" isEqualToString:activityKindString]) {
        return ADTActivityKindGdpr;
    } else if ([@"ad_revenue" isEqualToString:activityKindString]) {
        return ADTActivityKindAdRevenue;
    } else if ([@"disable_third_party_sharing" isEqualToString:activityKindString]) {
        return ADTActivityKindDisableThirdPartySharing;
    } else if ([@"subscription" isEqualToString:activityKindString]) {
        return ADTActivityKindSubscription;
    } else if ([@"third_party_sharing" isEqualToString:activityKindString]) {
        return ADTActivityKindThirdPartySharing;
    } else if ([@"measurement_consent" isEqualToString:activityKindString]) {
        return ADTActivityKindMeasurementConsent;
    } else {
        return ADTActivityKindUnknown;
    }
}

+ (NSString *)activityKindToString:(ADTActivityKind)activityKind {
    switch (activityKind) {
        case ADTActivityKindSession:
            return @"session";
        case ADTActivityKindEvent:
            return @"event";
        case ADTActivityKindClick:
            return @"click";
        case ADTActivityKindAttribution:
            return @"attribution";
        case ADTActivityKindInfo:
            return @"info";
        case ADTActivityKindGdpr:
            return @"gdpr";
        case ADTActivityKindAdRevenue:
            return @"ad_revenue";
        case ADTActivityKindDisableThirdPartySharing:
            return @"disable_third_party_sharing";
        case ADTActivityKindSubscription:
            return @"subscription";
        case ADTActivityKindThirdPartySharing:
            return @"third_party_sharing";
        case ADTActivityKindMeasurementConsent:
            return @"measurement_consent";
        default:
            return @"unknown";
    }
}

@end
