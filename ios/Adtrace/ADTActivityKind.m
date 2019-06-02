//
//  ADTActivityKind.m
//  Adtrace
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
        default:
            return @"unknown";
    }
}

@end
