
#import "Adtrace.h"
#import "ADTUtil.h"
#import "ADTLogger.h"
#import "ADTUserDefaults.h"
#import "ADTAdtraceFactory.h"
#import "ADTActivityHandler.h"
#import "ADTSKAdNetwork.h"

#if !__has_feature(objc_arc)
#error Adtrace requires ARC

#endif

NSString * const ADTEnvironmentSandbox = @"sandbox";
NSString * const ADTEnvironmentProduction = @"production";

NSString * const ADTAdRevenueSourceAppLovinMAX = @"applovin_max_sdk";
NSString * const ADTAdRevenueSourceMopub = @"mopub";
NSString * const ADTAdRevenueSourceAdMob = @"admob_sdk";
NSString * const ADTAdRevenueSourceIronSource = @"ironsource_sdk";
NSString * const ADTAdRevenueSourceAdMost = @"admost_sdk";
NSString * const ADTAdRevenueSourceUnity = @"unity_sdk";
NSString * const ADTAdRevenueSourceHeliumChartboost = @"helium_chartboost_sdk";
NSString * const ADTAdRevenueSourcePublisher = @"publisher_sdk";
NSString * const ADTAdRevenueSourceTopOn = @"topon_sdk";
NSString * const ADTAdRevenueSourceADX = @"adx_sdk";
NSString * const ADTAdRevenueSourceTradplus = @"tradplus_sdk";

NSString * const ADTUrlStrategyIR = @"UrlStrategyIR";
NSString * const ADTUrlStrategyMobi = @"UrlStrategyMobi";

NSString * const ADTDataResidencyIR = @"DataResidencyIR";

@implementation AdtraceTestOptions
@end

@interface Adtrace()

@property (nonatomic, weak) id<ADTLogger> logger;

@property (nonatomic, strong) id<ADTActivityHandler> activityHandler;

@property (nonatomic, strong) ADTSavedPreLaunch *savedPreLaunch;

@property (nonatomic) AdtraceResolvedDeeplinkBlock cachedResolvedDeeplinkBlock;

@end

@implementation Adtrace

#pragma mark - Object lifecycle methods

static Adtrace *defaultInstance = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)getInstance {
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.activityHandler = nil;
    self.logger = [ADTAdtraceFactory logger];
    self.savedPreLaunch = [[ADTSavedPreLaunch alloc] init];
    self.cachedResolvedDeeplinkBlock = nil;
    return self;
}

#pragma mark - Public static methods

+ (void)appDidLaunch:(ADTConfig *)adtraceConfig {
    @synchronized (self) {
        [[Adtrace getInstance] appDidLaunch:adtraceConfig];
    }
}

+ (void)trackEvent:(ADTEvent *)event {
    @synchronized (self) {
        [[Adtrace getInstance] trackEvent:event];
    }
}

+ (void)trackSubsessionStart {
    @synchronized (self) {
        [[Adtrace getInstance] trackSubsessionStart];
    }
}

+ (void)trackSubsessionEnd {
    @synchronized (self) {
        [[Adtrace getInstance] trackSubsessionEnd];
    }
}

+ (void)setEnabled:(BOOL)enabled {
    @synchronized (self) {
        Adtrace *instance = [Adtrace getInstance];
        [instance setEnabled:enabled];
    }
}

+ (BOOL)isEnabled {
    @synchronized (self) {
        return [[Adtrace getInstance] isEnabled];
    }
}

+ (void)appWillOpenUrl:(NSURL *)url {
    @synchronized (self) {
        [[Adtrace getInstance] appWillOpenUrl:[url copy]];
    }
}

+ (void)processDeeplink:(nonnull NSURL *)deeplink
      completionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completionHandler {
    @synchronized (self) {
        [[Adtrace getInstance] processDeeplink:deeplink completionHandler:completionHandler];
    }
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    @synchronized (self) {
        [[Adtrace getInstance] setDeviceToken:[deviceToken copy]];
    }
}

+ (void)setPushToken:(NSString *)pushToken {
    @synchronized (self) {
        [[Adtrace getInstance] setPushToken:[pushToken copy]];
    }
}

+ (void)setOfflineMode:(BOOL)enabled {
    @synchronized (self) {
        [[Adtrace getInstance] setOfflineMode:enabled];
    }
}

+ (void)sendAdWordsRequest {
    [[ADTAdtraceFactory logger] warn:@"Send AdWords Request functionality removed"];
}

+ (NSString *)idfa {
    @synchronized (self) {
        return [[Adtrace getInstance] idfa];
    }
}

+ (NSString *)idfv {
    @synchronized (self) {
        return [[Adtrace getInstance] idfv];
    }
}

+ (NSString *)sdkVersion {
    @synchronized (self) {
        return [[Adtrace getInstance] sdkVersion];
    }
}

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    @synchronized (self) {
        return [[Adtrace getInstance] convertUniversalLink:[url copy] scheme:[scheme copy]];
    }
}

+ (void)sendFirstPackages {
    @synchronized (self) {
        [[Adtrace getInstance] sendFirstPackages];
    }
}

+ (void)addSessionCallbackParameter:(NSString *)key value:(NSString *)value {
    @synchronized (self) {
        [[Adtrace getInstance] addSessionCallbackParameter:[key copy] value:[value copy]];
    }
}

+ (void)addSessionPartnerParameter:(NSString *)key value:(NSString *)value {
    @synchronized (self) {
        [[Adtrace getInstance] addSessionPartnerParameter:[key copy] value:[value copy]];
    }
}

+ (void)removeSessionCallbackParameter:(NSString *)key {
    @synchronized (self) {
        [[Adtrace getInstance] removeSessionCallbackParameter:[key copy]];
    }
}

+ (void)removeSessionPartnerParameter:(NSString *)key {
    @synchronized (self) {
        [[Adtrace getInstance] removeSessionPartnerParameter:[key copy]];
    }
}

+ (void)resetSessionCallbackParameters {
    @synchronized (self) {
        [[Adtrace getInstance] resetSessionCallbackParameters];
    }
}

+ (void)resetSessionPartnerParameters {
    @synchronized (self) {
        [[Adtrace getInstance] resetSessionPartnerParameters];
    }
}

+ (void)gdprForgetMe {
    @synchronized (self) {
        [[Adtrace getInstance] gdprForgetMe];
    }
}

+ (void)trackAdRevenue:(nonnull NSString *)source payload:(nonnull NSData *)payload {
    @synchronized (self) {
        [[Adtrace getInstance] trackAdRevenue:[source copy] payload:[payload copy]];
    }
}

+ (void)disableThirdPartySharing {
    @synchronized (self) {
        [[Adtrace getInstance] disableThirdPartySharing];
    }
}

+ (void)trackThirdPartySharing:(nonnull ADTThirdPartySharing *)thirdPartySharing {
    @synchronized (self) {
        [[Adtrace getInstance] trackThirdPartySharing:thirdPartySharing];
    }
}

+ (void)trackMeasurementConsent:(BOOL)enabled {
    @synchronized (self) {
        [[Adtrace getInstance] trackMeasurementConsent:enabled];
    }
}

+ (void)trackSubscription:(nonnull ADTSubscription *)subscription {
    @synchronized (self) {
        [[Adtrace getInstance] trackSubscription:subscription];
    }
}

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    @synchronized (self) {
        [[Adtrace getInstance] requestTrackingAuthorizationWithCompletionHandler:completion];
    }
}

+ (int)appTrackingAuthorizationStatus {
    @synchronized (self) {
        return [[Adtrace getInstance] appTrackingAuthorizationStatus];
    }
}

+ (void)updateConversionValue:(NSInteger)conversionValue {
    @synchronized (self) {
        [[Adtrace getInstance] updateConversionValue:conversionValue];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adtrace getInstance] updatePostbackConversionValue:conversionValue
                                          completionHandler:completion];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adtrace getInstance] updatePostbackConversionValue:fineValue
                                                coarseValue:coarseValue
                                          completionHandler:completion];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adtrace getInstance] updatePostbackConversionValue:fineValue
                                                coarseValue:coarseValue
                                                 lockWindow:lockWindow
                                          completionHandler:completion];
    }
}

+ (void)trackAdRevenue:(ADTAdRevenue *)adRevenue {
    @synchronized (self) {
        [[Adtrace getInstance] trackAdRevenue:adRevenue];
    }
}

+ (ADTAttribution *)attribution {
    @synchronized (self) {
        return [[Adtrace getInstance] attribution];
    }
}

+ (NSString *)adid {
    @synchronized (self) {
        return [[Adtrace getInstance] adid];
    }
}

+ (void)checkForNewAttStatus {
    @synchronized (self) {
        [[Adtrace getInstance] checkForNewAttStatus];
    }
}

+ (NSURL *)lastDeeplink {
    @synchronized (self) {
        return [[Adtrace getInstance] lastDeeplink];
    }
}

+ (void)verifyPurchase:(nonnull ADTPurchase *)purchase
     completionHandler:(void (^_Nonnull)(ADTPurchaseVerificationResult * _Nonnull verificationResult))completionHandler {
    @synchronized (self) {
        [[Adtrace getInstance] verifyPurchase:purchase completionHandler:completionHandler];
    }
}

+ (void)setTestOptions:(AdtraceTestOptions *)testOptions {
    @synchronized (self) {
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
}

#pragma mark - Public instance methods

- (void)appDidLaunch:(ADTConfig *)adtraceConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adtrace already initialized"];
        return;
    }
    self.activityHandler = [[ADTActivityHandler alloc] initWithConfig:adtraceConfig
                                                       savedPreLaunch:self.savedPreLaunch
                                           deeplinkResolutionCallback:self.cachedResolvedDeeplinkBlock];
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
    [ADTUserDefaults cacheDeeplinkUrl:url];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADTUserDefaults saveDeeplinkUrl:url andClickTime:clickTime];
        return;
    }
    [self.activityHandler appWillOpenUrl:url withClickTime:clickTime];
}

- (void)processDeeplink:(nonnull NSURL *)deeplink
      completionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completionHandler {
    // if resolution result is not wanted, fallback to default method
    if (completionHandler == nil) {
        [self appWillOpenUrl:deeplink];
        return;
    }
    // if deep link processing is triggered prior to SDK being initialized
    [ADTUserDefaults cacheDeeplinkUrl:deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADTUserDefaults saveDeeplinkUrl:deeplink andClickTime:clickTime];
        self.cachedResolvedDeeplinkBlock = completionHandler;
        return;
    }
    // if deep link processing was triggered with SDK being initialized
    [self.activityHandler processDeeplink:deeplink
                                clickTime:clickTime
                        completionHandler:completionHandler];
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

- (NSString *)idfv {
    return [ADTUtil idfv];
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

- (void)trackAdRevenue:(NSString *)source payload:(NSData *)payload {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:source payload:payload];
}

- (void)disableThirdPartySharing {
    if (![self checkActivityHandler:@"disable third party sharing"]) {
        [ADTUserDefaults setDisableThirdPartySharing];
        return;
    }
    [self.activityHandler disableThirdPartySharing];
}

- (void)trackThirdPartySharing:(nonnull ADTThirdPartySharing *)thirdPartySharing {
    if (![self checkActivityHandler]) {
        if (self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray == nil) {
            self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray =
                [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray addObject:thirdPartySharing];
        return;
    }
    [self.activityHandler trackThirdPartySharing:thirdPartySharing];
}

- (void)trackMeasurementConsent:(BOOL)enabled {
    if (![self checkActivityHandler]) {
        self.savedPreLaunch.lastMeasurementConsentTracked = [NSNumber numberWithBool:enabled];
        return;
    }
    [self.activityHandler trackMeasurementConsent:enabled];
}

- (void)trackSubscription:(ADTSubscription *)subscription {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackSubscription:subscription];
}

- (void)requestTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    [ADTUtil requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
        if (completion) {
            completion(status);
        }
        if (![self checkActivityHandler:@"request Tracking Authorization"]) {
            return;
        }
        [self.activityHandler updateAttStatusFromUserCallback:(int)status];
    }];
}

- (int)appTrackingAuthorizationStatus {
    return [ADTUtil attStatus];
}

- (void)updateConversionValue:(NSInteger)conversionValue {
    [[ADTSKAdNetwork getInstance] updateConversionValue:conversionValue];
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADTSKAdNetwork getInstance] updatePostbackConversionValue:conversionValue
                                              completionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADTSKAdNetwork getInstance] updatePostbackConversionValue:fineValue
                                                    coarseValue:coarseValue
                                              completionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADTSKAdNetwork getInstance] updatePostbackConversionValue:fineValue
                                                    coarseValue:coarseValue
                                                     lockWindow:lockWindow
                                              completionHandler:completion];
}

- (void)trackAdRevenue:(ADTAdRevenue *)adRevenue {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:adRevenue];
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

- (void)checkForNewAttStatus {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler checkForNewAttStatus];
}

- (NSURL *)lastDeeplink {
    return [ADTUserDefaults getCachedDeeplinkUrl];
}

- (void)verifyPurchase:(nonnull ADTPurchase *)purchase
     completionHandler:(void (^_Nonnull)(ADTPurchaseVerificationResult * _Nonnull verificationResult))completionHandler {
    if (![self checkActivityHandler]) {
        if (completionHandler != nil) {
            ADTPurchaseVerificationResult *result = [[ADTPurchaseVerificationResult alloc] init];
            result.verificationStatus = @"not_verified";
            result.code = 100;
            result.message = @"SDK needs to be initialized before making purchase verification request";
            completionHandler(result);
        }
        return;
    }
    [self.activityHandler verifyPurchase:purchase completionHandler:completionHandler];
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
    if (testOptions.extraPath != nil) {
        self.savedPreLaunch.extraPath = testOptions.extraPath;
    }
    if (testOptions.urlOverwrite != nil) {
        [ADTAdtraceFactory setUrlOverwrite:testOptions.urlOverwrite];
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
    if (testOptions.attStatusInt != nil) {
        [ADTAdtraceFactory setAttStatus:testOptions.attStatusInt];
    }
    if (testOptions.idfa != nil) {
        [ADTAdtraceFactory setIdfa:testOptions.idfa];
    }
    if (testOptions.noBackoffWait) {
        [ADTAdtraceFactory setSdkClickHandlerBackoffStrategy:[ADTBackoffStrategy backoffStrategyWithType:ADTNoWait]];
        [ADTAdtraceFactory setPackageHandlerBackoffStrategy:[ADTBackoffStrategy backoffStrategyWithType:ADTNoWait]];
    }
    if (testOptions.enableSigning) {
        [ADTAdtraceFactory enableSigning];
    }
    if (testOptions.disableSigning) {
        [ADTAdtraceFactory disableSigning];
    }

    [ADTAdtraceFactory setAdServicesFrameworkEnabled:testOptions.adServicesFrameworkEnabled];
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
