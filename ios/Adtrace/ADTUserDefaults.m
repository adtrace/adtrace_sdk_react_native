//
//  ADTUserDefaults.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTUserDefaults.h"

static NSString * const PREFS_KEY_PUSH_TOKEN_DATA = @"adt_push_token";
static NSString * const PREFS_KEY_PUSH_TOKEN_STRING = @"adt_push_token_string";
static NSString * const PREFS_KEY_GDPR_FORGET_ME = @"adt_gdpr_forget_me";
static NSString * const PREFS_KEY_INSTALL_TRACKED = @"adt_install_tracked";
static NSString * const PREFS_KEY_DEEPLINK_URL = @"adt_deeplink_url";
static NSString * const PREFS_KEY_DEEPLINK_CLICK_TIME = @"adt_deeplink_click_time";
static NSString * const PREFS_KEY_DISABLE_THIRD_PARTY_SHARING = @"adt_disable_third_party_sharing";
static NSString * const PREFS_KEY_IAD_ERRORS = @"adt_iad_errors";
static NSString * const PREFS_KEY_ADSERVICES_TRACKED = @"adt_adservices_tracked";
static NSString * const PREFS_KEY_SKAD_REGISTER_CALL_TIME = @"adt_skad_register_call_time";

@implementation ADTUserDefaults

#pragma mark - Public methods

+ (void)savePushTokenData:(NSData *)pushToken {
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:PREFS_KEY_PUSH_TOKEN_DATA];
}

+ (void)savePushTokenString:(NSString *)pushToken {
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (NSData *)getPushTokenData {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
}

+ (NSString *)getPushTokenString {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (void)removePushToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (void)setInstallTracked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_INSTALL_TRACKED];
}

+ (BOOL)getInstallTracked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_INSTALL_TRACKED];
}

+ (void)setGdprForgetMe {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (BOOL)getGdprForgetMe {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (void)removeGdprForgetMe {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (void)saveDeeplinkUrl:(NSURL *)deeplink andClickTime:(NSDate *)clickTime {
    [[NSUserDefaults standardUserDefaults] setURL:deeplink forKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] setObject:clickTime forKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (NSURL *)getDeeplinkUrl {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PREFS_KEY_DEEPLINK_URL];
}

+ (NSDate *)getDeeplinkClickTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)removeDeeplink {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)setDisableThirdPartySharing {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
}

+ (BOOL)getDisableThirdPartySharing {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
}

+ (void)removeDisableThirdPartySharing {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
}

+ (void)saveiAdErrorKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary<NSString *, NSNumber *> *errors = [[userDefaults dictionaryForKey:PREFS_KEY_IAD_ERRORS] mutableCopy];
    if (errors) {
        NSNumber *value = errors[key];
        if (!value) {
            value = @(1);
        } else {
            value = @([value integerValue] + 1);
        }
        
        errors[key] = value;
    } else {
        errors[key] = @(1);
    }
    
    [userDefaults setObject:errors forKey:PREFS_KEY_IAD_ERRORS];
}

+ (NSDictionary<NSString *, NSNumber *> *)getiAdErrors {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:PREFS_KEY_IAD_ERRORS];
}

+ (void)cleariAdErrors {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_IAD_ERRORS];
}

+ (void)setAdServicesTracked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_ADSERVICES_TRACKED];
}

+ (BOOL)getAdServicesTracked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_ADSERVICES_TRACKED];
}

+ (void)saveSkadRegisterCallTimestamp:(NSDate *)callTime {
    [[NSUserDefaults standardUserDefaults] setObject:callTime forKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
}

+ (NSDate *)getSkadRegisterCallTimestamp {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
}

+ (void)clearAdtraceStuff {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_INSTALL_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_GDPR_FORGET_ME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_IAD_ERRORS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ADSERVICES_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
}

@end
