
#import "ADTConfig.h"
#import "ADTAdtraceFactory.h"
#import "ADTLogger.h"
#import "ADTUtil.h"
#import "Adtrace.h"

@interface ADTConfig()

@property (nonatomic, weak) id<ADTLogger> logger;

@end

@implementation ADTConfig

+ (ADTConfig *)configWithAppToken:(NSString *)appToken
                      environment:(NSString *)environment {
    return [[ADTConfig alloc] initWithAppToken:appToken environment:environment];
}

+ (ADTConfig *)configWithAppToken:(NSString *)appToken
                      environment:(NSString *)environment
             allowSuppressLogLevel:(BOOL)allowSuppressLogLevel {
    return [[ADTConfig alloc] initWithAppToken:appToken environment:environment allowSuppressLogLevel:allowSuppressLogLevel];
}

- (id)initWithAppToken:(NSString *)appToken
           environment:(NSString *)environment {
    return [self initWithAppToken:appToken
                      environment:environment
             allowSuppressLogLevel:NO];
}

- (id)initWithAppToken:(NSString *)appToken
           environment:(NSString *)environment
  allowSuppressLogLevel:(BOOL)allowSuppressLogLevel {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.logger = ADTAdtraceFactory.logger;

    if (allowSuppressLogLevel && [ADTEnvironmentProduction isEqualToString:environment]) {
        [self setLogLevel:ADTLogLevelSuppress environment:environment];
    } else {
        [self setLogLevel:ADTLogLevelInfo environment:environment];
    }

    if (![self checkEnvironment:environment]) {
        return self;
    }
    if (![self checkAppToken:appToken]) {
        return self;
    }

    _appToken = appToken;
    _environment = environment;
    
    // default values
    self.sendInBackground = NO;
    self.eventBufferingEnabled = NO;
    self.coppaCompliantEnabled = NO;
    self.allowIdfaReading = YES;
    self.allowAdServicesInfoReading = YES;
    self.linkMeEnabled = NO;
    _isSKAdNetworkHandlingActive = YES;

    return self;
}

- (void)setLogLevel:(ADTLogLevel)logLevel {
    [self setLogLevel:logLevel environment:self.environment];
}

- (void)setLogLevel:(ADTLogLevel)logLevel
        environment:(NSString *)environment {
    [self.logger setLogLevel:logLevel
     isProductionEnvironment:[ADTEnvironmentProduction isEqualToString:environment]];
}

- (void)deactivateSKAdNetworkHandling {
    _isSKAdNetworkHandlingActive = NO;
}

- (void)setDelegate:(NSObject<AdtraceDelegate> *)delegate {
    BOOL hasResponseDelegate = NO;
    BOOL implementsDeeplinkCallback = NO;

    if ([ADTUtil isNull:delegate]) {
        [self.logger warn:@"Delegate is nil"];
        _delegate = nil;
        return;
    }

    if ([delegate respondsToSelector:@selector(adtraceAttributionChanged:)]) {
        [self.logger debug:@"Delegate implements adtraceAttributionChanged:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adtraceEventTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adtraceEventTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adtraceEventTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adtraceEventTrackingFailed:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adtraceSessionTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adtraceSessionTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adtraceSessionTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adtraceSessionTrackingFailed:"];
        hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adtraceDeeplinkResponse:)]) {
        [self.logger debug:@"Delegate implements adtraceDeeplinkResponse:"];
        // does not enable hasDelegate flag
        implementsDeeplinkCallback = YES;
    }
    
    if ([delegate respondsToSelector:@selector(adtraceConversionValueUpdated:)]) {
        [self.logger debug:@"Delegate implements adtraceConversionValueUpdated:"];
        hasResponseDelegate = YES;
    }

    if (!(hasResponseDelegate || implementsDeeplinkCallback)) {
        [self.logger error:@"Delegate does not implement any optional method"];
        _delegate = nil;
        return;
    }

    _delegate = delegate;
}

- (BOOL)checkEnvironment:(NSString *)environment {
    if ([ADTUtil isNull:environment]) {
        [self.logger error:@"Missing environment"];
        return NO;
    }
    if ([environment isEqualToString:ADTEnvironmentSandbox]) {
        [self.logger warnInProduction:@"SANDBOX: Adtrace is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing"];
        return YES;
    } else if ([environment isEqualToString:ADTEnvironmentProduction]) {
        [self.logger warnInProduction:@"PRODUCTION: Adtrace is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!"];
        return YES;
    }
    [self.logger error:@"Unknown environment '%@'", environment];
    return NO;
}

- (BOOL)checkAppToken:(NSString *)appToken {
    if ([ADTUtil isNull:appToken]) {
        [self.logger error:@"Missing App Token"];
        return NO;
    }
    if (appToken.length != 12) {
        [self.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

- (BOOL)isValid {
    return self.appToken != nil;
}

- (void)setAppSecret:(NSUInteger)secretId
               info1:(NSUInteger)info1
               info2:(NSUInteger)info2
               info3:(NSUInteger)info3
               info4:(NSUInteger)info4 {
    _secretId = [NSString stringWithFormat:@"%lu", (unsigned long)secretId];
    _appSecret = [NSString stringWithFormat:@"%lu%lu%lu%lu",
                   (unsigned long)info1,
                   (unsigned long)info2,
                   (unsigned long)info3,
                   (unsigned long)info4];
}

- (id)copyWithZone:(NSZone *)zone {
    ADTConfig *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy->_appToken = [self.appToken copyWithZone:zone];
        copy->_environment = [self.environment copyWithZone:zone];
        copy.logLevel = self.logLevel;
        copy.sdkPrefix = [self.sdkPrefix copyWithZone:zone];
        copy.defaultTracker = [self.defaultTracker copyWithZone:zone];
        copy.eventBufferingEnabled = self.eventBufferingEnabled;
        copy.sendInBackground = self.sendInBackground;
        copy.allowIdfaReading = self.allowIdfaReading;
        copy.allowAdServicesInfoReading = self.allowAdServicesInfoReading;
        copy.delayStart = self.delayStart;
        copy.attConsentWaitingInterval = self.attConsentWaitingInterval;
        copy.coppaCompliantEnabled = self.coppaCompliantEnabled;
        copy.userAgent = [self.userAgent copyWithZone:zone];
        copy.externalDeviceId = [self.externalDeviceId copyWithZone:zone];
        copy.isDeviceKnown = self.isDeviceKnown;
        copy.needsCost = self.needsCost;
        copy->_secretId = [self.secretId copyWithZone:zone];
        copy->_appSecret = [self.appSecret copyWithZone:zone];
        copy->_isSKAdNetworkHandlingActive = self.isSKAdNetworkHandlingActive;
        copy->_urlStrategy = [self.urlStrategy copyWithZone:zone];
        copy.linkMeEnabled = self.linkMeEnabled;
        copy.readDeviceInfoOnceEnabled = self.readDeviceInfoOnceEnabled;
        // adtrace delegate not copied
    }

    return copy;
}

@end
