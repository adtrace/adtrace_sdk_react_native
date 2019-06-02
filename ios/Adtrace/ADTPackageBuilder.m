//
//  ADTPackageBuilder.m
//  Adtrace SDK
//

#import "ADTUtil.h"
#import "ADTAttribution.h"
#import "ADTAdtraceFactory.h"
#import "ADTPackageBuilder.h"
#import "ADTActivityPackage.h"
#import "NSData+ADTAdditions.h"
#import "UIDevice+ADTAdditions.h"

@interface ADTPackageBuilder()

@property (nonatomic, assign) double createdAt;

@property (nonatomic, weak) ADTConfig *adtraceConfig;

@property (nonatomic, weak) ADTDeviceInfo *deviceInfo;

@property (nonatomic, copy) ADTActivityState *activityState;

@property (nonatomic, weak) ADTSessionParameters *sessionParameters;

@end

@implementation ADTPackageBuilder

#pragma mark - Object lifecycle methods

- (id)initWithDeviceInfo:(ADTDeviceInfo *)deviceInfo
           activityState:(ADTActivityState *)activityState
                  config:(ADTConfig *)adtraceConfig
       sessionParameters:(ADTSessionParameters *)sessionParameters
               createdAt:(double)createdAt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.createdAt = createdAt;
    self.deviceInfo = deviceInfo;
    self.adtraceConfig = adtraceConfig;
    self.activityState = activityState;
    self.sessionParameters = sessionParameters;

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
        eventPackage.callbackParameters = event.callbackParameters;
        eventPackage.partnerParameters = event.partnerParameters;
    }

    return eventPackage;
}

- (ADTActivityPackage *)buildInfoPackage:(NSString *)infoSource {
    NSMutableDictionary *parameters = [self getInfoParameters:infoSource];
    ADTActivityPackage *infoPackage = [self defaultActivityPackage];
    infoPackage.path = @"/sdk_info";
    infoPackage.activityKind = ADTActivityKindInfo;
    infoPackage.suffix = @"";
    infoPackage.parameters = parameters;
    return infoPackage;
}

- (ADTActivityPackage *)buildClickPackage:(NSString *)clickSource {
    NSMutableDictionary *parameters = [self getClickParameters:clickSource];
    ADTActivityPackage *clickPackage = [self defaultActivityPackage];
    clickPackage.path = @"/sdk_click";
    clickPackage.activityKind = ADTActivityKindClick;
    clickPackage.suffix = @"";
    clickPackage.parameters = parameters;
    return clickPackage;
}

- (ADTActivityPackage *)buildAttributionPackage:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [self getAttributionParameters:initiatedBy];
    ADTActivityPackage *attributionPackage = [self defaultActivityPackage];
    attributionPackage.path = @"/attribution";
    attributionPackage.activityKind = ADTActivityKindAttribution;
    attributionPackage.suffix = @"";
    attributionPackage.parameters = parameters;
    return attributionPackage;
}

- (ADTActivityPackage *)buildGdprPackage {
    NSMutableDictionary *parameters = [self getGdprParameters];
    ADTActivityPackage *gdprPackage = [self defaultActivityPackage];
    gdprPackage.path = @"/gdpr_forget_device";
    gdprPackage.activityKind = ADTActivityKindGdpr;
    gdprPackage.suffix = @"";
    gdprPackage.parameters = parameters;
    return gdprPackage;
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) {
        return;
    }
    if (dictionary.count == 0) {
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
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil getUpdateTime] forKey:@"app_updated_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleVersion forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleShortVersion forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundeIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setNumberInt:[ADTUtil readReachabilityFlags] forKey:@"connectivity_type"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.countryCode forKey:@"country"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.cpuSubtype forKey:@"cpu_type"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.fbAttributionId forKey:@"fb_id"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.machineModel forKey:@"hardware_name"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.installReceiptBase64 forKey:@"install_receipt"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil getInstallTime] forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.languageCode forKey:@"language"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osBuild forKey:@"os_build"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.systemVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setInt:UIDevice.currentDevice.adjTrackingEnabled forKey:@"tracking_enabled"];

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
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    if (!isInDelay) {
        [ADTPackageBuilder parameters:parameters setDictionary:self.sessionParameters.callbackParameters forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:self.sessionParameters.partnerParameters forKey:@"partner_params"];
    }

#if !TARGET_OS_TV
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMCC] forKey:@"mcc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMNC] forKey:@"mnc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readCurrentRadioAccessTechnology] forKey:@"network_type"];
#endif

    return parameters;
}

- (NSMutableDictionary *)getEventParameters:(BOOL)isInDelay forEventPackage:(ADTEvent *)event {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleVersion forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleShortVersion forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundeIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setNumberInt:[ADTUtil readReachabilityFlags] forKey:@"connectivity_type"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.countryCode forKey:@"country"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.cpuSubtype forKey:@"cpu_type"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:event.currency forKey:@"currency"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:event.callbackId forKey:@"event_callback_id"];
    [ADTPackageBuilder parameters:parameters setString:event.eventToken forKey:@"event_token"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.fbAttributionId forKey:@"fb_id"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.machineModel forKey:@"hardware_name"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.installReceiptBase64 forKey:@"install_receipt"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.languageCode forKey:@"language"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osBuild forKey:@"os_build"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.systemVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setNumber:event.revenue forKey:@"revenue"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setInt:UIDevice.currentDevice.adjTrackingEnabled forKey:@"tracking_enabled"];

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
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADTUtil mergeParameters:self.sessionParameters.callbackParameters
                                                                   source:event.callbackParameters
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADTUtil mergeParameters:self.sessionParameters.partnerParameters
                                                                  source:event.partnerParameters
                                                           parameterName:@"Partner"];

        [ADTPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADTPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }

    if (event.emptyReceipt) {
        NSString *emptyReceipt = @"empty";
        [ADTPackageBuilder parameters:parameters setString:emptyReceipt forKey:@"receipt"];
        [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    } else if (event.receipt != nil) {
        NSString *receiptBase64 = [event.receipt adjEncodeBase64];
        [ADTPackageBuilder parameters:parameters setString:receiptBase64 forKey:@"receipt"];
        [ADTPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    }

#if !TARGET_OS_TV
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMCC] forKey:@"mcc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMNC] forKey:@"mnc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readCurrentRadioAccessTechnology] forKey:@"network_type"];
#endif

    return parameters;
}

- (NSMutableDictionary *)getInfoParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setString:source forKey:@"source"];

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADTPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    return parameters;
}

- (NSMutableDictionary *)getClickParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil getUpdateTime] forKey:@"app_updated_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleVersion forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleShortVersion forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundeIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.sessionParameters.callbackParameters forKey:@"callback_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADTPackageBuilder parameters:parameters setNumberInt:[ADTUtil readReachabilityFlags] forKey:@"connectivity_type"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.countryCode forKey:@"country"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.cpuSubtype forKey:@"cpu_type"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.defaultTracker forKey:@"default_tracker"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.fbAttributionId forKey:@"fb_id"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.machineModel forKey:@"hardware_name"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.installReceiptBase64 forKey:@"install_receipt"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil getInstallTime] forKey:@"installed_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.languageCode forKey:@"language"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osBuild forKey:@"os_build"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.systemVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADTPackageBuilder parameters:parameters setDictionary:self.sessionParameters.partnerParameters forKey:@"partner_params"];
    [ADTPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];
    [ADTPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADTPackageBuilder parameters:parameters setInt:UIDevice.currentDevice.adjTrackingEnabled forKey:@"tracking_enabled"];

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
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    if (self.attribution != nil) {
        [ADTPackageBuilder parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.creative forKey:@"creative"];
        [ADTPackageBuilder parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
    }

#if !TARGET_OS_TV
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMCC] forKey:@"mcc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readMNC] forKey:@"mnc"];
    [ADTPackageBuilder parameters:parameters setString:[ADTUtil readCurrentRadioAccessTechnology] forKey:@"network_type"];
#endif

    return parameters;
}

- (NSMutableDictionary *)getAttributionParameters:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleVersion forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleShortVersion forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundeIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setString:initiatedBy forKey:@"initiated_by"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osBuild forKey:@"os_build"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.systemVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    return parameters;
}

- (NSMutableDictionary *)getGdprParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appToken forKey:@"app_token"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.appSecret forKey:@"app_secret"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleVersion forKey:@"app_version"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundleShortVersion forKey:@"app_version_short"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.bundeIdentifier forKey:@"bundle_id"];
    [ADTPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceName forKey:@"device_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.deviceType forKey:@"device_type"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.environment forKey:@"environment"];
    [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.eventBufferingEnabled forKey:@"event_buffering_enabled"];
    [ADTPackageBuilder parameters:parameters setString:UIDevice.currentDevice.adjIdForAdvertisers forKey:@"idfa"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.vendorId forKey:@"idfv"];
    [ADTPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osBuild forKey:@"os_build"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.osName forKey:@"os_name"];
    [ADTPackageBuilder parameters:parameters setString:self.deviceInfo.systemVersion forKey:@"os_version"];
    [ADTPackageBuilder parameters:parameters setString:self.adtraceConfig.secretId forKey:@"secret_id"];

    if (self.adtraceConfig.isDeviceKnown) {
        [ADTPackageBuilder parameters:parameters setBool:self.adtraceConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"persistent_ios_uuid"];
        } else {
            [ADTPackageBuilder parameters:parameters setString:self.activityState.uuid forKey:@"ios_uuid"];
        }
    }

    return parameters;
}

- (ADTActivityPackage *)defaultActivityPackage {
    ADTActivityPackage *activityPackage = [[ADTActivityPackage alloc] init];
    activityPackage.clientSdk = self.deviceInfo.clientSdk;
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

+ (void)parameters:(NSMutableDictionary *)parameters setNumberInt:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    [ADTPackageBuilder parameters:parameters setInt:[value intValue] forKey:key];
}

@end
