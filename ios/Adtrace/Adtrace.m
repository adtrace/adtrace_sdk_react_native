//
//  Adtrace.m
//  Adtrace
//


#import "Adtrace.h"
#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTUserDefaults.h"
#import "ADTAdtraceFactory.h"
#import "ADTActivityHandler.h"

#if !__has_feature(objc_arc)
#error Adtrace requires ARC
// See README for details: https://github.com/adtrace/ios_sdk/blob/master/README.md
#endif

NSString * const ADTEnvironmentSandbox      = @"sandbox";
NSString * const ADTEnvironmentProduction   = @"production";

@implementation AdtraceTestOptions
@end

@interface Adtrace()

@property (nonatomic, weak) id<ADTLogger> logger;

@property (nonatomic, strong) id<ADTActivityHandler> activityHandler;

@property (nonatomic, strong) ADTSavedPreLaunch *savedPreLaunch;

@end

@implementation Adtrace

#pragma mark - Object lifecycle methods

static Adtrace *defaultInstance = nil;
static dispatch_once_t onceToken = 0;

+ (id)getInstance {
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.activityHandler = nil;
    self.logger = [ADTAdtraceFactory logger];
    self.savedPreLaunch = [[ADTSavedPreLaunch alloc] init];

    return self;
}

#pragma mark - Public static methods

+ (void)appDidLaunch:(ADTConfig *)adtraceConfig {
    [[Adtrace getInstance] appDidLaunch:adtraceConfig];
}

+ (void)trackEvent:(ADTEvent *)event {
    [[Adtrace getInstance] trackEvent:event];
}

+ (void)trackSubsessionStart {
    [[Adtrace getInstance] trackSubsessionStart];
}

+ (void)trackSubsessionEnd {
    [[Adtrace getInstance] trackSubsessionEnd];
}

+ (void)setEnabled:(BOOL)enabled {
    Adtrace *instance = [Adtrace getInstance];
    [instance setEnabled:enabled];
}

+ (BOOL)isEnabled {
    return [[Adtrace getInstance] isEnabled];
}

+ (void)appWillOpenUrl:(NSURL *)url {
    [[Adtrace getInstance] appWillOpenUrl:url];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    [[Adtrace getInstance] setDeviceToken:deviceToken];
}

+ (void)setPushToken:(NSString *)pushToken {
    [[Adtrace getInstance] setPushToken:pushToken];
}

+ (void)setOfflineMode:(BOOL)enabled {
    [[Adtrace getInstance] setOfflineMode:enabled];
}

+ (void)sendAdWordsRequest {
    [[ADTAdtraceFactory logger] warn:@"Send AdWords Request functionality removed"];
}

+ (NSString *)idfa {
    return [[Adtrace getInstance] idfa];
}

+ (NSString *)sdkVersion {
    return [[Adtrace getInstance] sdkVersion];
}

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [[Adtrace getInstance] convertUniversalLink:url scheme:scheme];
}

+ (void)sendFirstPackages {
    [[Adtrace getInstance] sendFirstPackages];
}

+ (void)addSessionCallbackParameter:(NSString *)key value:(NSString *)value {
    [[Adtrace getInstance] addSessionCallbackParameter:key value:value];

}

+ (void)addSessionPartnerParameter:(NSString *)key value:(NSString *)value {
    [[Adtrace getInstance] addSessionPartnerParameter:key value:value];
}


+ (void)removeSessionCallbackParameter:(NSString *)key {
    [[Adtrace getInstance] removeSessionCallbackParameter:key];
}

+ (void)removeSessionPartnerParameter:(NSString *)key {
    [[Adtrace getInstance] removeSessionPartnerParameter:key];
}

+ (void)resetSessionCallbackParameters {
    [[Adtrace getInstance] resetSessionCallbackParameters];
}

+ (void)resetSessionPartnerParameters {
    [[Adtrace getInstance] resetSessionPartnerParameters];
}

+ (void)gdprForgetMe {
    [[Adtrace getInstance] gdprForgetMe];
}

+ (ADTAttribution *)attribution {
    return [[Adtrace getInstance] attribution];
}

+ (NSString *)adid {
    return [[Adtrace getInstance] adid];
}

+ (void)setTestOptions:(AdtraceTestOptions *)testOptions {
    if (testOptions.teardown) {
        if (defaultInstance != nil) {
            [defaultInstance teardown];
        }
        defaultInstance = nil;
        onceToken = 0;
        [ADTAdtraceFactory teardown:testOptions.deleteState];
    }
    [[Adtrace getInstance] setTestOptions:(AdtraceTestOptions *)testOptions];
}

#pragma mark - Public instance methods

- (void)appDidLaunch:(ADTConfig *)adtraceConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adtrace already initialized"];
        return;
    }

    self.activityHandler = [ADTAdtraceFactory activityHandlerWithConfig:adtraceConfig
                                                        savedPreLaunch:self.savedPreLaunch];
}

- (void)trackEvent:(ADTEvent *)event {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler applicationDidBecomeActive];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler applicationWillResignActive];
}

- (void)setEnabled:(BOOL)enabled {
    self.savedPreLaunch.enabled = [NSNumber numberWithBool:enabled];

    if ([self checkActivityHandler:enabled
                       trueMessage:@"enabled mode"
                      falseMessage:@"disabled mode"]) {
        [self.activityHandler setEnabled:enabled];
    }
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) {
        return [self isInstanceEnabled];
    }

    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADTUserDefaults saveDeeplinkUrl:url andClickTime:clickTime];
        return;
    }

    [self.activityHandler appWillOpenUrl:url withClickTime:clickTime];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    [ADTUserDefaults savePushTokenData:deviceToken];

    if ([self checkActivityHandler:@"device token"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setDeviceToken:deviceToken];
        }
    }
}

- (void)setPushToken:(NSString *)pushToken {
    [ADTUserDefaults savePushTokenString:pushToken];

    if ([self checkActivityHandler:@"device token"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setPushToken:pushToken];
        }
    }
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler:enabled
                        trueMessage:@"offline mode"
                       falseMessage:@"online mode"]) {
        self.savedPreLaunch.offline = enabled;
    } else {
        [self.activityHandler setOfflineMode:enabled];
    }
}

- (NSString *)idfa {
    return [ADTUtil idfa];
}

- (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [ADTUtil convertUniversalLink:url scheme:scheme];
}

- (void)sendFirstPackages {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler sendFirstPackages];
}

- (void)addSessionCallbackParameter:(NSString *)key value:(NSString *)value {
    if ([self checkActivityHandler:@"adding session callback parameter"]) {
        [self.activityHandler addSessionCallbackParameter:key value:value];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler addSessionCallbackParameterI:activityHandler key:key value:value];
    }];
}

- (void)addSessionPartnerParameter:(NSString *)key value:(NSString *)value {
    if ([self checkActivityHandler:@"adding session partner parameter"]) {
        [self.activityHandler addSessionPartnerParameter:key value:value];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler addSessionPartnerParameterI:activityHandler key:key value:value];
    }];
}

- (void)removeSessionCallbackParameter:(NSString *)key {
    if ([self checkActivityHandler:@"removing session callback parameter"]) {
        [self.activityHandler removeSessionCallbackParameter:key];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler removeSessionCallbackParameterI:activityHandler key:key];
    }];
}

- (void)removeSessionPartnerParameter:(NSString *)key {
    if ([self checkActivityHandler:@"removing session partner parameter"]) {
        [self.activityHandler removeSessionPartnerParameter:key];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler removeSessionPartnerParameterI:activityHandler key:key];
    }];
}

- (void)resetSessionCallbackParameters {
    if ([self checkActivityHandler:@"resetting session callback parameters"]) {
        [self.activityHandler resetSessionCallbackParameters];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler resetSessionCallbackParametersI:activityHandler];
    }];
}

- (void)resetSessionPartnerParameters {
    if ([self checkActivityHandler:@"resetting session partner parameters"]) {
        [self.activityHandler resetSessionPartnerParameters];
        return;
    }

    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }

    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler *activityHandler) {
        [activityHandler resetSessionPartnerParametersI:activityHandler];
    }];
}

- (void)gdprForgetMe {
    [ADTUserDefaults setGdprForgetMe];

    if ([self checkActivityHandler:@"GDPR forget me"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setGdprForgetMe];
        }
    }
}

- (ADTAttribution *)attribution {
    if (![self checkActivityHandler]) {
        return nil;
    }

    return [self.activityHandler attribution];
}

- (NSString *)adid {
    if (![self checkActivityHandler]) {
        return nil;
    }

    return [self.activityHandler adid];
}

- (NSString *)sdkVersion {
    return [ADTUtil sdkVersion];
}

- (void)teardown {
    if (self.activityHandler == nil) {
        [self.logger error:@"Adtrace already down or not initialized"];
        return;
    }

    [self.activityHandler teardown];
    self.activityHandler = nil;
}

- (void)setTestOptions:(AdtraceTestOptions *)testOptions {
    if (testOptions.basePath != nil) {
        self.savedPreLaunch.basePath = testOptions.basePath;
    }
    if (testOptions.gdprPath != nil) {
        self.savedPreLaunch.gdprPath = testOptions.gdprPath;
    }
    if (testOptions.baseUrl != nil) {
        [ADTAdtraceFactory setBaseUrl:testOptions.baseUrl];
    }
    if (testOptions.gdprUrl != nil) {
        [ADTAdtraceFactory setGdprUrl:testOptions.gdprUrl];
    }
    if (testOptions.timerIntervalInMilliseconds != nil) {
        NSTimeInterval timerIntervalInSeconds = [testOptions.timerIntervalInMilliseconds intValue] / 1000.0;
        [ADTAdtraceFactory setTimerInterval:timerIntervalInSeconds];
    }
    if (testOptions.timerStartInMilliseconds != nil) {
        NSTimeInterval timerStartInSeconds = [testOptions.timerStartInMilliseconds intValue] / 1000.0;
        [ADTAdtraceFactory setTimerStart:timerStartInSeconds];
    }
    if (testOptions.sessionIntervalInMilliseconds != nil) {
        NSTimeInterval sessionIntervalInSeconds = [testOptions.sessionIntervalInMilliseconds intValue] / 1000.0;
        [ADTAdtraceFactory setSessionInterval:sessionIntervalInSeconds];
    }
    if (testOptions.subsessionIntervalInMilliseconds != nil) {
        NSTimeInterval subsessionIntervalInSeconds = [testOptions.subsessionIntervalInMilliseconds intValue] / 1000.0;
        [ADTAdtraceFactory setSubsessionInterval:subsessionIntervalInSeconds];
    }
    if (testOptions.noBackoffWait) {
        [ADTAdtraceFactory setSdkClickHandlerBackoffStrategy:[ADTBackoffStrategy backoffStrategyWithType:ADTNoWait]];
        [ADTAdtraceFactory setPackageHandlerBackoffStrategy:[ADTBackoffStrategy backoffStrategyWithType:ADTNoWait]];
    }
    
    [ADTAdtraceFactory setiAdFrameworkEnabled:testOptions.iAdFrameworkEnabled];
}

#pragma mark - Private & helper methods

- (BOOL)checkActivityHandler {
    return [self checkActivityHandler:nil];
}

- (BOOL)checkActivityHandler:(BOOL)status
                 trueMessage:(NSString *)trueMessage
                falseMessage:(NSString *)falseMessage {
    if (status) {
        return [self checkActivityHandler:trueMessage];
    } else {
        return [self checkActivityHandler:falseMessage];
    }
}

- (BOOL)checkActivityHandler:(NSString *)savedForLaunchWarningSuffixMessage {
    if (self.activityHandler == nil) {
        if (savedForLaunchWarningSuffixMessage != nil) {
            [self.logger warn:@"Adtrace not initialized, but %@ saved for launch", savedForLaunchWarningSuffixMessage];
        } else {
            [self.logger error:@"Please initialize Adtrace by calling 'appDidLaunch' before"];
        }

        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isInstanceEnabled {
    return self.savedPreLaunch.enabled == nil || self.savedPreLaunch.enabled;
}

@end
