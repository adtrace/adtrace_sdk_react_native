
#import <Foundation/Foundation.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(int, ADTActivityKind) {
    ADTActivityKindUnknown = 0,
    ADTActivityKindSession = 1,
    ADTActivityKindEvent = 2,
    // ADTActivityKindRevenue = 3,
    ADTActivityKindClick = 4,
    ADTActivityKindAttribution = 5,
    ADTActivityKindInfo = 6,
    ADTActivityKindGdpr = 7,
    ADTActivityKindAdRevenue = 8,
    ADTActivityKindDisableThirdPartySharing = 9,
    ADTActivityKindSubscription = 10,
    ADTActivityKindThirdPartySharing = 11,
    ADTActivityKindMeasurementConsent = 12,
    ADTActivityKindPurchaseVerification = 13
};

@interface ADTActivityKindUtil : NSObject

+ (NSString *)activityKindToString:(ADTActivityKind)activityKind;

+ (ADTActivityKind)activityKindFromString:(NSString *)activityKindString;

@end
