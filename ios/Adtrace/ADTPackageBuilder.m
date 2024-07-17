
#include <string.h>

#import "ADTUtil.h"
#import "ADTAttribution.h"
#import "ADTAdtraceFactory.h"
#import "ADTPackageBuilder.h"
#import "ADTActivityPackage.h"
#import "NSData+ADTAdditions.h"
#import "ADTUserDefaults.h"

NSString * const ADTAttributionTokenParameter = @"attribution_token";

@interface ADTPackageBuilder()

@property (nonatomic, assign) double createdAt;

@property (nonatomic, weak) ADTConfig *adtraceConfig;

@property (nonatomic, weak) ADTPackageParams *packageParams;

@property (nonatomic, copy) ADTActivityState *activityState;

@property (nonatomic, weak) ADTSessionParameters *sessionParameters;

@property (nonatomic, weak) ADTTrackingStatusManager *trackingStatusManager;

@end

@implementation ADTPackageBuilder

#pragma mark - Object lifecycle methods

- (id)initWithPackageParams:(ADTPackageParams * _Nullable)packageParams
              activityState:(ADTActivityState * _Nullable)activityState
                     config:(ADTConfig * _Nullable)adtraceConfig
          sessionParameters:(ADTSessionParameters * _Nullable)sessionParameters
      trackingStatusManager:(ADTTrackingStatusManager * _Nullable)trackingStatusManager
                  createdAt:(double)createdAt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.createdAt = createdAt;
    self.packageParams = packageParams;
    self.adtraceConfig = adtraceConfig;
    self.activityState = activityState;
    self.sessionParameters = sessionParameters;
    self.trackingStatusManager = trackingStatusManager;

    return self;
}

#pragma mark - Public methods

- (ADTActivityPackage *)buildSessionPackage:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getSessionParameters:isInDelay];
    ADTActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/session";
    sessionPackage.activityKind = ADTActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;
    sessionPackage.parameters = [ADTUtil deepCopyOfDictionary:sessionPackage.parameters];

    return sessionPackage;
}

- (ADTActivityPackage *)buildEventPackage:(ADTEvent *)event
                                isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getEventParameters:isInDelay forEventPackage:event];
    ADTActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = ADTActivityKindEvent;
    eventPackage.suffix = [self eventSuffix:event];
    eventPackage.parameters = parameters;
    if (isInDelay) {
        eventPackage.callbackParameters = [ADTUtil deepCopyOfDictionary:event.callbackParameters];
        eventPackage.partnerParameters = [ADTUtil deepCopyOfDictionary:event.partnerParameters];
        eventPackage.eventValueParameters = [ADTUtil deepCopyOfDictionary:event.eventValueParameters];
    }
    eventPackage.parameters = [ADTUtil deepCopyOfDictionary:eventPackage.parameters];

    return eventPackage;
}

- (ADTActivityPackage *)buildInfoPackage:(NSString *)infoSource {
    NSMutableDictionary *parameters = [self getInfoParameters:infoSource];
    ADTActivityPackage *infoPackage = [self defaultActivityPackage];
    infoPackage.path = @"/sdk_info";
    infoPackage.activityKind = ADTActivityKindInfo;
    infoPackage.suffix = @"";
    infoPackage.parameters = parameters;
    infoPackage.parameters = [ADTUtil deepCopyOfDictionary:infoPackage.parameters];

    return infoPackage;
}

- (ADTActivityPackage *)buildAdRevenuePackage:(NSString *)source payload:(NSData *)payload {
    NSMutableDictionary *parameters = [self getAdRevenueParameters:source payload:payload];
    ADTActivityPackage *adRevenuePackage = [self defaultActivityPackage];
    adRevenuePackage.path = @"/ad_revenue";
    adRevenuePackage.activityKind = ADTActivityKindAdRevenue;
    adRevenuePackage.suffix = @"";
    adRevenuePackage.parameters = parameters;
    adRevenuePackage.parameters = [ADTUtil deepCopyOfDictionary:adRevenuePackage.parameters];

    return adRevenuePackage;
}

- (ADTActivityPackage *)buildAdRevenuePackage:(ADTAdRevenue *)adRevenue isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getAdRevenueParameters:adRevenue isInDelay:isInDelay];
    ADTActivityPackage *adRevenuePackage = [self defaultActivityPackage];
    adRevenuePackage.path = @"/ad_revenue";
    adRevenuePackage.activityKind = ADTActivityKindAdRevenue;
    adRevenuePackage.suffix = @"";
    adRevenuePackage.parameters = parameters;
    if (isInDelay) {
        adRevenuePackage.callbackParameters = [ADTUtil deepCopyOfDictionary:adRevenue.callbackParameters];
        adRevenuePackage.partnerParameters = [ADTUtil deepCopyOfDictionary:adRevenue.partnerParameters];
    }
    adRevenuePackage.parameters = [ADTUtil deepCopyOfDictionary:adRevenuePackage.parameters];

    return adRevenuePackage;
}

- (ADTActivityPackage *)buildClickPackage:(NSString *)clickSource extraParameters:(NSDictionary *)extraParameters {
    NSMutableDictionary *parameters = [self getClickParameters:clickSource];
    if (extraParameters != nil) {
        [parameters addEntriesFromDictionary:extraParameters];
    }

    ADTActivityPackage *clickPackage = [self defaultActivityPackage];
    clickPackage.path = @"/sdk_click";
    clickPackage.activityKind = ADTActivityKindClick;
    clickPackage.suffix = @"";
    clickPackage.parameters = parameters;
    clickPackage.parameters = [ADTUtil deepCopyOfDictionary:clickPackage.parameters];

    return clickPackage;
}

- (ADTActivityPackage *)buildAttributionPackage:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [self getAttributionParameters:initiatedBy];
    ADTActivityPackage *attributionPackage = [self defaultActivityPackage];
    attributionPackage.path = @"/attribution";
    attributionPackage.activityKind = ADTActivityKindAttribution;
    attributionPackage.suffix = @"";
    attributionPackage.parameters = parameters;
    attributionPackage.parameters = [ADTUtil deepCopyOfDictionary:attributionPackage.parameters];

    return attributionPackage;
}

- (ADTActivityPackage *)buildGdprPackage {
    NSMutableDictionary *parameters = [self getGdprParameters];
    ADTActivityPackage *gdprPackage = [self defaultActivityPackage];
    gdprPackage.path = @"/gdpr_forget_device";
    gdprPackage.activityKind = ADTActivityKindGdpr;
    gdprPackage.suffix = @"";
    gdprPackage.parameters = parameters;
    gdprPackage.parameters = [ADTUtil deepCopyOfDictionary:gdprPackage.parameters];

    return gdprPackage;
}

- (ADTActivityPackage *)buildDisableThirdPartySharingPackage {
    NSMutableDictionary *parameters = [self getDisableThirdPartySharingParameters];
    ADTActivityPackage *dtpsPackage = [self defaultActivityPackage];
    dtpsPackage.path = @"/disable_third_party_sharing";
    dtpsPackage.activityKind = ADTActivityKindDisableThirdPartySharing;
    dtpsPackage.suffix = @"";
    dtpsPackage.parameters = parameters;
    dtpsPackage.parameters = [ADTUtil deepCopyOfDictionary:dtpsPackage.parameters];

    return dtpsPackage;
}


- (ADTActivityPackage *)buildThirdPartySharingPackage:(nonnull ADTThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [self getThirdPartySharingParameters:thirdPartySharing];
    ADTActivityPackage *tpsPackage = [self defaultActivityPackage];
    tpsPackage.path = @"/third_party_sharing";
    tpsPackage.activityKind = ADTActivityKindThirdPartySharing;
    tpsPackage.suffix = @"";
    tpsPackage.parameters = parameters;
    tpsPackage.parameters = [ADTUtil deepCopyOfDictionary:tpsPackage.parameters];

    return tpsPackage;
}

- (ADTActivityPackage *)buildMeasurementConsentPackage:(BOOL)enabled {
    NSMutableDictionary *parameters = [self getMeasurementConsentParameters:enabled];
    ADTActivityPackage *mcPackage = [self defaultActivityPackage];
    mcPackage.path = @"/measurement_consent";
    mcPackage.activityKind = ADTActivityKindMeasurementConsent;
    mcPackage.suffix = @"";
    mcPackage.parameters = parameters;
    mcPackage.parameters = [ADTUtil deepCopyOfDictionary:mcPackage.parameters];

    return mcPackage;
}

- (ADTActivityPackage *)buildSubscriptionPackage:(ADTSubscription *)subscription
                                       isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getSubscriptionParameters:isInDelay forSubscriptionPackage:subscription];
    ADTActivityPackage *subscriptionPackage = [self defaultActivityPackage];
    subscriptionPackage.path = @"/v2/purchase";
    subscriptionPackage.activityKind = ADTActivityKindSubscription;
    subscriptionPackage.suffix = @"";
    subscriptionPackage.parameters = parameters;
    if (isInDelay) {
        subscriptionPackage.callbackParameters = [ADTUtil deepCopyOfDictionary:subscription.callbackParameters];
        subscriptionPackage.partnerParameters = [ADTUtil deepCopyOfDictionary:subscription.partnerParameters];
    }
    subscriptionPackage.parameters = [ADTUtil deepCopyOfDictionary:subscriptionPackage.parameters];

    return subscriptionPackage;
}

- (ADTActivityPackage *)buildPurchaseVerificationPackageWithExtraParams:(NSDictionary *)extraParameters {
    NSMutableDictionary *parameters = [self getPurchaseVerificationParameters];
    if (extraParameters != nil) {
        [parameters addEntriesFromDictionary:extraParameters];
    }

    ADTActivityPackage *purchaseVerificationPackage = [self defaultActivityPackage];
    purchaseVerificationPackage.path = @"/verify";
    purchaseVerificationPackage.activityKind = ADTActivityKindPurchaseVerification;
    purchaseVerificationPackage.suffix = @"";
    purchaseVerificationPackage.parameters = parameters;
    purchaseVerificationPackage.parameters = [ADTUtil deepCopyOfDictionary:purchaseVerificationPackage.parameters];

    return purchaseVerificationPackage;
}

- (ADTActivityPackage *)buildClickPackage:(NSString *)clickSource {
    return [self buildClickPackage:clickSource extraParameters:nil];
}

- (ADTActivityPackage *)buildClickPackage:(NSString *)clickSource
                                    token:(NSString *)token
                          errorCodeNumber:(NSNumber *)errorCodeNumber {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (token != nil) {
        [ADTPackageBuilder parameters:parameters
                            setString:token
                               forKey:ADTAttributionTokenParameter];
    }
    if (errorCodeNumber != nil) {
        [ADTPackageBuilder parameters:parameters
                               setInt:errorCodeNumber.intValue
                               forKey:@"error_code"];
    }

    return [self buildClickPackage:clickSource extraParameters:parameters];
}

- (ADTActivityPackage *)buildClickPackage:(NSString *)clickSource
                                linkMeUrl:(NSString * _Nullable)linkMeUrl {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (linkMeUrl != nil) {
        [ADTPackageBuilder parameters:parameters
                            setString:linkMeUrl
                               forKey:@"content"];
    }

    return [self buildClickPackage:clickSource extraParameters:parameters];
}

- (ADTActivityPackage * _Nullable)buildPurchaseVerificationPackage:(ADTPurchase * _Nullable)purchase {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (purchase.receipt != nil) {
        NSString *receiptBase64 = [purchase.receipt adtEncodeBase64];
        [ADTPackageBuilder parameters:parameters
                            setString:receiptBase64
                               forKey:@"receipt"];
    }
    if (purchase.transactionId != nil) {
        [ADTPackageBuilder parameters:parameters
                            setString:purchase.transactionId
                               forKey:@"transaction_id"];
    }
    if (purchase.productId != nil) {
        [ADTPackageBuilder parameters:parameters
                            setString:purchase.productId
                               forKey:@"product_id"];
    }

    return [self buildPurchaseVerificationPackageWithExtraParams:parameters];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) {
        return;
    }
    if (dictionary.count == 0) {
        return;
    }

    NSDictionary *convertedDictionary = [ADTUtil convertDictionaryValues:dictionary];
    [ADTPackageBuilder parameters:parameters setDictionaryJson:convertedDictionary forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setString:(NSString *)value forKey:(NSString *)key {
    if (value == nil || [value isEqualToString:@""]) {
        return;
    }
    [parameters setObject:value forKey:key];
}

#pragma mark - Private & helper methods

- (NSMutableDictionary *)getSessionParameters:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (!isInDelay) {
        [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindSession];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getEventParameters:(BOOL)isInDelay forEventPackage:(ADTEvent *)event {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:event.currency forKey:@"currency"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:event.callbackId forKey:@"event_callback_id"];
    [ADTPackageBuilder parameters:parameters setString:event.eventToken forKey:@"event_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setNumber:event.revenue forKey:@"revenue"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    // FYI: long time ago deprecated way of purchase verification, to be removed
    // if (event.emptyReceipt) {
    //     NSString *emptyReceipt = @"empty";
    //     [ADTPackageBuilder parameters:parameters setString:emptyReceipt forKey:@"receipt"];
    //     [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    // } else if (event.receipt != nil) {
    //     NSString *receiptBase64 = [event.receipt adtEncodeBase64];
    //     [ADTPackageBuilder parameters:parameters setString:receiptBase64 forKey:@"receipt"];
    //     [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    // }
    // FYI: event.transactionId being historically used for deduplication + for IAP verification
    // if (event.transactionId) {
    //     [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"deduplication_id"];
    // }
    [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"deduplication_id"];
    [ADTPackageBuilder parameters:parameters setString:event.productId forKey:@"product_id"];
    [ADTPackageBuilder parameters:parameters setString:[event.receipt adtEncodeBase64] forKey:@"receipt"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADTUtil mergeParameters:[self.sessionParameters.callbackParameters copy]
                                                                   source:[event.callbackParameters copy]
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADTUtil mergeParameters:[self.sessionParameters.partnerParameters copy]
                                                                  source:[event.partnerParameters copy]
                                                           parameterName:@"Partner"];
        NSDictionary *mergedValueParameters = [ADTUtil mergeParameters:[self.sessionParameters.partnerParameters copy]
                                                                  source:[event.eventValueParameters copy]
                                                           parameterName:@"Value"];

        [ADTPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:mergedValueParameters forKey:@"event_value_params"];
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindEvent];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getInfoParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (self.attribution != nil) {
        [ADTPackageBuilder parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.creative forKey:@"creative"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindInfo];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAdRevenueParameters:(NSString *)source payload:(NSData *)payload {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    [ADTPackageBuilder parameters:parameters setData:payload forKey:@"payload"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindAdRevenue];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAdRevenueParameters:(ADTAdRevenue *)adRevenue isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    [ADTPackageBuilder parameters:parameters setString:adRevenue.source forKey:@"source"];
    [ADTPackageBuilder parameters:parameters setNumberWithoutRounding:adRevenue.revenue forKey:@"revenue"];
    [ADTPackageBuilder parameters:parameters setString:adRevenue.currency forKey:@"currency"];
    [ADTPackageBuilder parameters:parameters setNumberInt:adRevenue.adImpressionsCount forKey:@"ad_impressions_count"];
    [ADTPackageBuilder parameters:parameters setString:adRevenue.adRevenueNetwork forKey:@"ad_revenue_network"];
    [ADTPackageBuilder parameters:parameters setString:adRevenue.adRevenueUnit forKey:@"ad_revenue_unit"];
    [ADTPackageBuilder parameters:parameters setString:adRevenue.adRevenuePlacement forKey:@"ad_revenue_placement"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }
    
    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADTUtil mergeParameters:[self.sessionParameters.callbackParameters copy]
                                                                   source:[adRevenue.callbackParameters copy]
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADTUtil mergeParameters:[self.sessionParameters.partnerParameters copy]
                                                                  source:[adRevenue.partnerParameters copy]
                                                           parameterName:@"Partner"];

        [ADTPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindAdRevenue];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getClickParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (self.attribution != nil) {
        [ADTPackageBuilder parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.creative forKey:@"creative"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindClick];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAttributionParameters:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setString:initiatedBy forKey:@"initiated_by"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adtraceConfig.needsCost) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindAttribution];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getGdprParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindGdpr];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getDisableThirdPartySharingParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }
    
    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindDisableThirdPartySharing];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getThirdPartySharingParameters:(nonnull ADTThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    // Third Party Sharing
    if (thirdPartySharing.enabled != nil) {
        NSString *enableValue = thirdPartySharing.enabled.boolValue ? @"enable" : @"disable";
        [ADTPackageBuilder parameters:parameters setString:enableValue forKey:@"sharing"];
    }
    [ADTPackageBuilder parameters:parameters
                setDictionaryJson:thirdPartySharing.granularOptions
                           forKey:@"granular_third_party_sharing_options"];
    [ADTPackageBuilder parameters:parameters
                setDictionaryJson:thirdPartySharing.partnerSharingSettings
                           forKey:@"partner_sharing_settings"];

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindThirdPartySharing];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getMeasurementConsentParameters:(BOOL)enabled {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    // Measurement Consent
    NSString *enableValue = enabled ? @"enable" : @"disable";
    [ADTPackageBuilder parameters:parameters
                        setString:enableValue
                           forKey:@"measurement"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindMeasurementConsent];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}
- (NSMutableDictionary *)getSubscriptionParameters:(BOOL)isInDelay forSubscriptionPackage:(ADTSubscription *)subscription {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADTUtil mergeParameters:self.sessionParameters.callbackParameters
                                                                   source:subscription.callbackParameters
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADTUtil mergeParameters:self.sessionParameters.partnerParameters
                                                                  source:subscription.partnerParameters
                                                           parameterName:@"Partner"];

        [ADTPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }
    
    [ADTPackageBuilder parameters:parameters setNumber:subscription.price forKey:@"revenue"];
    [ADTPackageBuilder parameters:parameters setString:subscription.currency forKey:@"currency"];
    [ADTPackageBuilder parameters:parameters setString:subscription.transactionId forKey:@"transaction_id"];
    [ADTPackageBuilder parameters:parameters setString:[subscription.receipt adtEncodeBase64] forKey:@"receipt"];
    [ADTPackageBuilder parameters:parameters setString:subscription.billingStore forKey:@"billing_store"];
    [ADTPackageBuilder parameters:parameters setDate:subscription.transactionDate forKey:@"transaction_date"];
    [ADTPackageBuilder parameters:parameters setString:subscription.salesRegion forKey:@"sales_region"];

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindSubscription];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getPurchaseVerificationParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.externalDeviceId forKey:@"external_device_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setDate:[ADTUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADTPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADTPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADTPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADTPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addConsentToParameters:parameters forActivityKind:ADTActivityKindPurchaseVerification];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (void)addIdfvIfPossibleToParameters:(NSMutableDictionary *)parameters {
    id<ADTLogger> logger = [ADTAdtraceFactory logger];

    if (self.adtraceConfig.coppaCompliantEnabled) {
        [logger info:@"Cannot read IDFV with COPPA enabled"];
        return;
    }
    [ADTPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
}

- (void)injectFeatureFlagsWithParameters:(NSMutableDictionary *)parameters {
    [ADTPackageBuilder parameters:parameters
                          setBool:self.adtraceConfig.eventBufferingEnabled
                           forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters
                          setBool:self.adtraceConfig.sendInBackground
                           forKey:@"send_in_background_enabled"];
    if (self.internalState != nil) {
        [ADTPackageBuilder parameters:parameters
                              setBool:self.internalState.isOffline
                               forKey:@"offline_mode_enabled"];
        if (self.internalState.isInForeground == YES) {
            [ADTPackageBuilder parameters:parameters
                                  setBool:YES
                                   forKey:@"foreground"];
        } else {
            [ADTPackageBuilder parameters:parameters
                                  setBool:YES
                                   forKey:@"background"];
        }
    }
    if (self.adtraceConfig.coppaCompliantEnabled == YES) {
        [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"ff_coppa"];
    }
    if (self.adtraceConfig.isSKAdNetworkHandlingActive == NO) {
        [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"ff_skadn_disabled"];
    }
    if (self.adtraceConfig.allowIdfaReading == NO) {
        [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"ff_idfa_disabled"];
    }
    if (self.adtraceConfig.allowAdServicesInfoReading == NO) {
        [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"ff_adserv_disabled"];
    }
}

- (ADTActivityPackage *)defaultActivityPackage {
    ADTActivityPackage *activityPackage = [[ADTActivityPackage alloc] init];
    activityPackage.clientSdk = self.packageParams.clientSdk;
    return activityPackage;
}

- (NSString *)eventSuffix:(ADTEvent *)event {
    if (event.revenue == nil) {
        return [NSString stringWithFormat:@"'%@'", event.eventToken];
    } else {
        return [NSString stringWithFormat:@"(%.5f %@, '%@')", [event.revenue doubleValue], event.currency, event.eventToken];
    }
}

+ (void)parameters:(NSMutableDictionary *)parameters setInt:(int)value forKey:(NSString *)key {
    if (value < 0) {
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%d", value];
    [ADTPackageBuilder parameters:parameters setString:valueString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDouble:(double)value forKey:(NSString *)key {
    if (value <= 0.0) {
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%.2f", value];
    [ADTPackageBuilder parameters:parameters setString:valueString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate1970:(double)value forKey:(NSString *)key {
    if (value < 0) {
        return;
    }
    NSString *dateString = [ADTUtil formatSeconds1970:value];
    [ADTPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate:(NSDate *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *dateString = [ADTUtil formatDate:value];
    [ADTPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (value < 0) {
        return;
    }
    int intValue = round(value);
    [ADTPackageBuilder parameters:parameters setInt:intValue forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionaryJson:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) {
        return;
    }
    if (dictionary.count == 0) {
        return;
    }
    if (![NSJSONSerialization isValidJSONObject:dictionary]) {
        return;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dictionaryString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [ADTPackageBuilder parameters:parameters setString:dictionaryString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setBool:(BOOL)value forKey:(NSString *)key {
    int valueInt = [[NSNumber numberWithBool:value] intValue];
    [ADTPackageBuilder parameters:parameters setInt:valueInt forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumber:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *numberString = [NSString stringWithFormat:@"%.5f", [value doubleValue]];
    [ADTPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberWithoutRounding:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *numberString = [value stringValue];
    [ADTPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberInt:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    [ADTPackageBuilder parameters:parameters setInt:[value intValue] forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setData:(NSData *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    [ADTPackageBuilder parameters:parameters
                        setString:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding]
                           forKey:key];
}

+ (BOOL)isAdServicesPackage:(ADTActivityPackage *)activityPackage {
    NSString *source = activityPackage.parameters[@"source"];
    return ([ADTUtil isNotNull:source] && [source isEqualToString:ADTAdServicesPackageKey]);
}

#pragma mark - Consent params

+ (void)addConsentDataToParameters:(NSMutableDictionary * _Nullable)parameters
                   forActivityKind:(ADTActivityKind)activityKind
                     withAttStatus:(NSString * _Nullable)attStatusString
                     configuration:(ADTConfig * _Nullable)adtConfig
                     packageParams:(ADTPackageParams * _Nullable)packageParams {

    if (![ADTUtil shouldUseConsentParamsForActivityKind:activityKind
                                       andAttStatus:attStatusString]) {
        return;
    }

    // idfa
    if (!adtConfig.allowIdfaReading) {
        [[ADTAdtraceFactory logger] info:@"Cannot read IDFA because it's forbidden by ADTConfig setting"];
        return;
    }
    if (adtConfig.coppaCompliantEnabled) {
        [[ADTAdtraceFactory logger] info:@"Cannot read IDFA with COPPA enabled"];
        return;
    }

    __block NSString *idfa = nil;
    [ADTUtil launchSynchronisedWithObject:[ADTPackageBuilder class] block:^{
        // read once && IDFA not cached
        if (adtConfig.readDeviceInfoOnceEnabled && packageParams.idfaCached != nil) {
            idfa = packageParams.idfaCached;
        } else {
            // read IDFA
            idfa = [ADTUtil idfa];
            if (idfa == nil ||
                idfa.length == 0 ||
                [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"])
            {
                idfa = nil;
            } else {
                // cache IDFA
                packageParams.idfaCached = idfa;
            }
        }
    }];

    if (idfa != nil) {
        // add IDFA to payload
        [ADTPackageBuilder parameters:parameters setString:idfa forKey:@"idfa"];
    }
}

+ (void)removeConsentDataFromParameters:(nonnull NSMutableDictionary *)parameters {
    [parameters removeObjectForKey:@"idfa"];
}

+ (void)updateAttStatusInParameters:(nonnull NSMutableDictionary *)parameters {
    [ADTPackageBuilder parameters:parameters setInt:[ADTUtil attStatus] forKey:@"att_status"];
}

- (void)addConsentToParameters:(NSMutableDictionary *)parameters
               forActivityKind:(ADTActivityKind)activityKind {
    [ADTPackageBuilder addConsentDataToParameters:parameters
                              forActivityKind:activityKind
                                withAttStatus:[parameters objectForKey:@"att_status"]
                                configuration:self.adtraceConfig
                                packageParams:self.packageParams];
}

@end
