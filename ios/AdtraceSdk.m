//
//  AdtraceSdk.h
//  Adtrace SDK
//

#import "AdtraceSdk.h"
#import "AdtraceSdkDelegate.h"

@implementation AdtraceSdk

RCT_EXPORT_MODULE(Adtrace);

BOOL _isAttributionCallbackImplemented;
BOOL _isEventTrackingSucceededCallbackImplemented;
BOOL _isEventTrackingFailedCallbackImplemented;
BOOL _isSessionTrackingSucceededCallbackImplemented;
BOOL _isSessionTrackingFailedCallbackImplemented;
BOOL _isDeferredDeeplinkCallbackImplemented;

#pragma mark - Public methods

RCT_EXPORT_METHOD(create:(NSDictionary *)dict) {
    NSString *appToken = dict[@"appToken"];
    NSString *environment = dict[@"environment"];
    NSString *secretId = dict[@"secretId"];
    NSString *info1 = dict[@"info1"];
    NSString *info2 = dict[@"info2"];
    NSString *info3 = dict[@"info3"];
    NSString *info4 = dict[@"info4"];
    NSString *logLevel = dict[@"logLevel"];
    NSString *sdkPrefix = dict[@"sdkPrefix"];
    NSString *userAgent = dict[@"userAgent"];
    NSString *defaultTracker = dict[@"defaultTracker"];
    NSNumber *eventBufferingEnabled = dict[@"eventBufferingEnabled"];
    NSNumber *sendInBackground = dict[@"sendInBackground"];
    NSNumber *shouldLaunchDeeplink = dict[@"shouldLaunchDeeplink"];
    NSNumber *delayStart = dict[@"delayStart"];
    NSNumber *isDeviceKnown = dict[@"isDeviceKnown"];
    BOOL allowSuppressLogLevel = NO;

    // Suppress log level.
    if ([self isFieldValid:logLevel]) {
        if ([logLevel isEqualToString:@"SUPPRESS"]) {
            allowSuppressLogLevel = YES;
        }
    }

    ADTConfig *adtraceConfig = [ADTConfig configWithAppToken:appToken environment:environment allowSuppressLogLevel:allowSuppressLogLevel];
    if (![adtraceConfig isValid]) {
        return;
    }

    // Log level.
    if ([self isFieldValid:logLevel]) {
        [adtraceConfig setLogLevel:[ADTLogger logLevelFromString:[logLevel lowercaseString]]];
    }

    // Event buffering.
    if ([self isFieldValid:eventBufferingEnabled]) {
        [adtraceConfig setEventBufferingEnabled:[eventBufferingEnabled boolValue]];
    }

    // SDK prefix.
    if ([self isFieldValid:sdkPrefix]) {
        [adtraceConfig setSdkPrefix:sdkPrefix];
    }

    // Default tracker.
    if ([self isFieldValid:defaultTracker]) {
        [adtraceConfig setDefaultTracker:defaultTracker];
    }

    // Attribution delegate & other delegates
    BOOL shouldLaunchDeferredDeeplink = [self isFieldValid:shouldLaunchDeeplink] ? [shouldLaunchDeeplink boolValue] : YES;
    if (_isAttributionCallbackImplemented
        || _isEventTrackingSucceededCallbackImplemented
        || _isEventTrackingFailedCallbackImplemented
        || _isSessionTrackingSucceededCallbackImplemented
        || _isSessionTrackingFailedCallbackImplemented
        || _isDeferredDeeplinkCallbackImplemented) {
        [adtraceConfig setDelegate:
         [AdtraceSdkDelegate getInstanceWithSwizzleOfAttributionCallback:_isAttributionCallbackImplemented
                                                 eventSucceededCallback:_isEventTrackingSucceededCallbackImplemented
                                                    eventFailedCallback:_isEventTrackingFailedCallbackImplemented
                                               sessionSucceededCallback:_isSessionTrackingSucceededCallbackImplemented
                                                  sessionFailedCallback:_isSessionTrackingFailedCallbackImplemented
                                               deferredDeeplinkCallback:_isDeferredDeeplinkCallbackImplemented
                                           shouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink]];
    }

    // Send in background.
    if ([self isFieldValid:sendInBackground]) {
        [adtraceConfig setSendInBackground:[sendInBackground boolValue]];
    }

    // User agent.
    if ([self isFieldValid:userAgent]) {
        [adtraceConfig setUserAgent:userAgent];
    }

    // App secret.
    if ([self isFieldValid:secretId]
        && [self isFieldValid:info1]
        && [self isFieldValid:info2]
        && [self isFieldValid:info3]
        && [self isFieldValid:info4]) {
        [adtraceConfig setAppSecret:[[NSNumber numberWithLongLong:[secretId longLongValue]] unsignedIntegerValue]
                         info1:[[NSNumber numberWithLongLong:[info1 longLongValue]] unsignedIntegerValue]
                         info2:[[NSNumber numberWithLongLong:[info2 longLongValue]] unsignedIntegerValue]
                         info3:[[NSNumber numberWithLongLong:[info3 longLongValue]] unsignedIntegerValue]
                         info4:[[NSNumber numberWithLongLong:[info4 longLongValue]] unsignedIntegerValue]];
    }

    // Device known.
    if ([self isFieldValid:isDeviceKnown]) {
        [adtraceConfig setIsDeviceKnown:[isDeviceKnown boolValue]];
    }

    // Delay start.
    if ([self isFieldValid:delayStart]) {
        [adtraceConfig setDelayStart:[delayStart doubleValue]];
    }

    // Start SDK.
    [Adtrace appDidLaunch:adtraceConfig];
    [Adtrace trackSubsessionStart];
}

RCT_EXPORT_METHOD(trackEvent:(NSDictionary *)dict) {
    NSString *eventToken = dict[@"eventToken"];
    NSString *revenue = dict[@"revenue"];
    NSString *currency = dict[@"currency"];
    NSString *transactionId = dict[@"transactionId"];
    NSString *callbackId = dict[@"callbackId"];
    NSDictionary *callbackParameters = dict[@"callbackParameters"];
    NSDictionary *partnerParameters = dict[@"partnerParameters"];

    ADTEvent *adtraceEvent = [ADTEvent eventWithEventToken:eventToken];
    if (![adtraceEvent isValid]) {
        return;
    }

    // Revenue.
    if ([self isFieldValid:revenue]) {
        double revenueValue = [revenue doubleValue];
        [adtraceEvent setRevenue:revenueValue currency:currency];
    }

    // Callback parameters.
    if ([self isFieldValid:callbackParameters]) {
        for (NSString *key in callbackParameters) {
            NSString *value = [callbackParameters objectForKey:key];
            [adtraceEvent addCallbackParameter:key value:value];
        }
    }

    // Partner parameters.
    if ([self isFieldValid:partnerParameters]) {
        for (NSString *key in partnerParameters) {
            NSString *value = [partnerParameters objectForKey:key];
            [adtraceEvent addPartnerParameter:key value:value];
        }
    }

    // Transaction ID.
    if ([self isFieldValid:transactionId]) {
        [adtraceEvent setTransactionId:transactionId];
    }

    // Callback ID.
    if ([self isFieldValid:callbackId]) {
        [adtraceEvent setCallbackId:callbackId];
    }

    // Track event.
    [Adtrace trackEvent:adtraceEvent];
}

RCT_EXPORT_METHOD(setOfflineMode:(NSNumber * _Nonnull)isEnabled) {
    [Adtrace setOfflineMode:[isEnabled boolValue]];
}

RCT_EXPORT_METHOD(setEnabled:(NSNumber * _Nonnull)isEnabled) {
    [Adtrace setEnabled:[isEnabled boolValue]];
}

RCT_EXPORT_METHOD(isEnabled:(RCTResponseSenderBlock)callback) {
    BOOL isEnabled = [Adtrace isEnabled];
    NSNumber *boolNumber = [NSNumber numberWithBool:isEnabled];
    callback(@[boolNumber]);
}

RCT_EXPORT_METHOD(setPushToken:(NSString *)token) {
    if (!([self isFieldValid:token])) {
        return;
    }
    [Adtrace setPushToken:token];
}

RCT_EXPORT_METHOD(appWillOpenUrl:(NSString *)urlStr) {
    if (urlStr == nil) {
        return;
    }

    NSURL *url;
    if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
#pragma clang diagnostic pop
    [Adtrace appWillOpenUrl:url];
}

RCT_EXPORT_METHOD(sendFirstPackages) {
    [Adtrace sendFirstPackages];
}

RCT_EXPORT_METHOD(addSessionCallbackParameter:(NSString *)key value:(NSString *)value) {
    if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
        return;
    }
    [Adtrace addSessionCallbackParameter:key value:value];
}

RCT_EXPORT_METHOD(removeSessionCallbackParameter:(NSString *)key) {
    if (!([self isFieldValid:key])) {
        return;
    }
    [Adtrace removeSessionCallbackParameter:key];
}

RCT_EXPORT_METHOD(resetSessionCallbackParameters) {
    [Adtrace resetSessionCallbackParameters];
}

RCT_EXPORT_METHOD(addSessionPartnerParameter:(NSString *)key value:(NSString *)value) {
    if (!([self isFieldValid:key]) || !([self isFieldValid:value])) {
        return;
    }
    [Adtrace addSessionPartnerParameter:key value:value];
}

RCT_EXPORT_METHOD(removeSessionPartnerParameter:(NSString *)key) {
    if (!([self isFieldValid:key])) {
        return;
    }
    [Adtrace removeSessionPartnerParameter:key];
}

RCT_EXPORT_METHOD(resetSessionPartnerParameters) {
    [Adtrace resetSessionPartnerParameters];
}

RCT_EXPORT_METHOD(gdprForgetMe) {
    [Adtrace gdprForgetMe];
}

RCT_EXPORT_METHOD(getIdfa:(RCTResponseSenderBlock)callback) {
    NSString *idfa = [Adtrace idfa];
    if (nil == idfa) {
        callback(@[@""]);
    } else {
        callback(@[idfa]);
    }
}

RCT_EXPORT_METHOD(getGoogleAdId:(RCTResponseSenderBlock)callback) {
    callback(@[@""]);
}

RCT_EXPORT_METHOD(getAmazonAdId:(RCTResponseSenderBlock)callback) {
    callback(@[@""]);
}

RCT_EXPORT_METHOD(getAdid:(RCTResponseSenderBlock)callback) {
    NSString *adid = [Adtrace adid];
    if (nil == adid) {
        callback(@[@""]);
    } else {
        callback(@[adid]);
    }
}

RCT_EXPORT_METHOD(getSdkVersion:(NSString *)sdkPrefix callback:(RCTResponseSenderBlock)callback) {
    NSString *sdkVersion = [Adtrace sdkVersion];
    if (nil == sdkVersion) {
        callback(@[@""]);
    } else {
        callback(@[[NSString stringWithFormat:@"%@@%@", sdkPrefix, sdkVersion]]);
    }
}

RCT_EXPORT_METHOD(setReferrer:(NSString *)referrer) {}

RCT_EXPORT_METHOD(getAttribution:(RCTResponseSenderBlock)callback) {
    ADTAttribution *attribution = [Adtrace attribution];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (attribution == nil) {
        callback(@[dictionary]);
        return;
    }

    [self addValueOrEmpty:dictionary key:@"trackerToken" value:attribution.trackerToken];
    [self addValueOrEmpty:dictionary key:@"trackerName" value:attribution.trackerName];
    [self addValueOrEmpty:dictionary key:@"network" value:attribution.network];
    [self addValueOrEmpty:dictionary key:@"campaign" value:attribution.campaign];
    [self addValueOrEmpty:dictionary key:@"creative" value:attribution.creative];
    [self addValueOrEmpty:dictionary key:@"adgroup" value:attribution.adgroup];
    [self addValueOrEmpty:dictionary key:@"clickLabel" value:attribution.clickLabel];
    [self addValueOrEmpty:dictionary key:@"adid" value:attribution.adid];
    callback(@[dictionary]);
}

RCT_EXPORT_METHOD(setAttributionCallbackListener) {
    _isAttributionCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setEventTrackingSucceededCallbackListener) {
    _isEventTrackingSucceededCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setEventTrackingFailedCallbackListener) {
    _isEventTrackingFailedCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setSessionTrackingSucceededCallbackListener) {
    _isSessionTrackingSucceededCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setSessionTrackingFailedCallbackListener) {
    _isSessionTrackingFailedCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setDeferredDeeplinkCallbackListener) {
    _isDeferredDeeplinkCallbackImplemented = YES;
}

RCT_EXPORT_METHOD(setTestOptions:(NSDictionary *)dict) {
    AdtraceTestOptions *testOptions = [[AdtraceTestOptions alloc] init];
    if ([dict objectForKey:@"hasContext"]) {
        NSString *value = dict[@"hasContext"];
        if ([self isFieldValid:value]) {
            testOptions.deleteState = [value boolValue];
        }
    }
    if ([dict objectForKey:@"baseUrl"]) {
        NSString *value = dict[@"baseUrl"];
        if ([self isFieldValid:value]) {
            testOptions.baseUrl = value;
        }
    }
    if ([dict objectForKey:@"gdprUrl"]) {
        NSString *value = dict[@"gdprUrl"];
        if ([self isFieldValid:value]) {
            testOptions.gdprUrl = value;
        }
    }
    if ([dict objectForKey:@"basePath"]) {
        NSString *value = dict[@"basePath"];
        if ([self isFieldValid:value]) {
            testOptions.basePath = value;
        }
    }
    if ([dict objectForKey:@"gdprPath"]) {
        NSString *value = dict[@"gdprPath"];
        if ([self isFieldValid:value]) {
            testOptions.gdprPath = value;
        }
    }
    if ([dict objectForKey:@"timerIntervalInMilliseconds"]) {
        NSString *value = dict[@"timerIntervalInMilliseconds"];
        if ([self isFieldValid:value]) {
            testOptions.timerIntervalInMilliseconds = [self convertMilliStringToNumber:value];
        }
    }
    if ([dict objectForKey:@"timerStartInMilliseconds"]) {
        NSString *value = dict[@"timerStartInMilliseconds"];
        if ([self isFieldValid:value]) {
            testOptions.timerStartInMilliseconds = [self convertMilliStringToNumber:value];
        }
    }
    if ([dict objectForKey:@"sessionIntervalInMilliseconds"]) {
        NSString *value = dict[@"sessionIntervalInMilliseconds"];
        if ([self isFieldValid:value]) {
            testOptions.sessionIntervalInMilliseconds = [self convertMilliStringToNumber:value];
        }
    }
    if ([dict objectForKey:@"subsessionIntervalInMilliseconds"]) {
        NSString *value = dict[@"subsessionIntervalInMilliseconds"];
        if ([self isFieldValid:value]) {
            testOptions.subsessionIntervalInMilliseconds = [self convertMilliStringToNumber:value];
        }
    }
    if ([dict objectForKey:@"teardown"]) {
        NSString *value = dict[@"teardown"];
        if ([self isFieldValid:value]) {
            testOptions.teardown = [value boolValue];
        }
    }
    if ([dict objectForKey:@"noBackoffWait"]) {
        NSString *value = dict[@"noBackoffWait"];
        if ([self isFieldValid:value]) {
            testOptions.noBackoffWait = [value boolValue];
        }
    }

    [Adtrace setTestOptions:testOptions];
}

RCT_EXPORT_METHOD(teardown) {
    _isAttributionCallbackImplemented = NO;
    _isEventTrackingSucceededCallbackImplemented = NO;
    _isEventTrackingFailedCallbackImplemented = NO;
    _isSessionTrackingSucceededCallbackImplemented = NO;
    _isSessionTrackingFailedCallbackImplemented = NO;
    _isDeferredDeeplinkCallbackImplemented = NO;
    [AdtraceSdkDelegate teardown];
}

RCT_EXPORT_METHOD(onResume) {
    [Adtrace trackSubsessionStart];
}

RCT_EXPORT_METHOD(onPause) {
    [Adtrace trackSubsessionEnd];
}

#pragma mark - Private & helper methods

- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }

    // Check if its an instance of the singleton NSNull.
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }

    // If 'field' can be converted to a string, check if it has any content.
    NSString *str = [NSString stringWithFormat:@"%@", field];
    if (str != nil) {
        if ([str length] == 0) {
            return NO;
        }
        if ([str isEqualToString:@"null"]) {
            return NO;
        }
    }

    return YES;
}

- (void)addValueOrEmpty:(NSMutableDictionary *)dictionary
                    key:(NSString *)key
                  value:(NSObject *)value {
    if (nil != value) {
        [dictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    } else {
        [dictionary setObject:@"" forKey:key];
    }
}

- (NSNumber *)convertMilliStringToNumber:(NSString *)milliS {
    NSNumber *number = [NSNumber numberWithInt:[milliS intValue]];
    return number;
}

@end
