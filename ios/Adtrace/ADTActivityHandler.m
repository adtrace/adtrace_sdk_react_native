//
//  ADTActivityHandler.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADTActivityPackage.h"
#import "ADTActivityHandler.h"
#import "ADTPackageBuilder.h"
#import "ADTPackageHandler.h"
#import "ADTLogger.h"
#import "ADTTimerCycle.h"
#import "ADTTimerOnce.h"
#import "ADTUtil.h"
#import "ADTAdtraceFactory.h"
#import "ADTAttributionHandler.h"
#import "NSString+ADTAdditions.h"
#import "ADTSdkClickHandler.h"
#import "ADTUserDefaults.h"
#import "ADTUrlStrategy.h"

NSString * const ADTiAdPackageKey = @"iad3";
NSString * const ADTAdServicesPackageKey = @"apple_ads";

typedef void (^activityHandlerBlockI)(ADTActivityHandler * activityHandler);

static NSString   * const kActivityStateFilename = @"AdtraceIoActivityState";
static NSString   * const kAttributionFilename   = @"AdtraceIoAttribution";
static NSString   * const kSessionCallbackParametersFilename   = @"AdtraceSessionCallbackParameters";
static NSString   * const kSessionPartnerParametersFilename    = @"AdtraceSessionPartnerParameters";
static NSString   * const kAdtracePrefix          = @"adtrace_";
static const char * const kInternalQueueName     = "io.adtrace.ActivityQueue";
static NSString   * const kForegroundTimerName   = @"Foreground timer";
static NSString   * const kBackgroundTimerName   = @"Background timer";
static NSString   * const kDelayStartTimerName   = @"Delay Start timer";

static NSTimeInterval kForegroundTimerInterval;
static NSTimeInterval kForegroundTimerStart;
static NSTimeInterval kBackgroundTimerInterval;
static double kSessionInterval;
static double kSubSessionInterval;
static const int kiAdRetriesCount = 3;
static const int kAdServicesdRetriesCount = 1;

@implementation ADTInternalState

- (BOOL)isEnabled { return self.enabled; }
- (BOOL)isDisabled { return !self.enabled; }
- (BOOL)isOffline { return self.offline; }
- (BOOL)isOnline { return !self.offline; }
- (BOOL)isInBackground { return self.background; }
- (BOOL)isInForeground { return !self.background; }
- (BOOL)isInDelayedStart { return self.delayStart; }
- (BOOL)isNotInDelayedStart { return !self.delayStart; }
- (BOOL)itHasToUpdatePackages { return self.updatePackages; }
- (BOOL)isFirstLaunch { return self.firstLaunch; }
- (BOOL)hasSessionResponseNotBeenProcessed { return !self.sessionResponseProcessed; }

@end

@implementation ADTSavedPreLaunch

- (id)init {
    self = [super init];
    if (self) {
        // online by default
        self.offline = NO;
    }
    return self;
}

@end

#pragma mark -
@interface ADTActivityHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADTPackageHandler *packageHandler;
@property (nonatomic, strong) ADTAttributionHandler *attributionHandler;
@property (nonatomic, strong) ADTSdkClickHandler *sdkClickHandler;
@property (nonatomic, strong) ADTActivityState *activityState;
@property (nonatomic, strong) ADTTimerCycle *foregroundTimer;
@property (nonatomic, strong) ADTTimerOnce *backgroundTimer;
@property (nonatomic, assign) NSInteger iAdRetriesLeft;
@property (nonatomic, assign) NSInteger adServicesRetriesLeft;
@property (nonatomic, strong) ADTInternalState *internalState;
@property (nonatomic, strong) ADTPackageParams *packageParams;
@property (nonatomic, strong) ADTTimerOnce *delayStartTimer;
@property (nonatomic, strong) ADTSessionParameters *sessionParameters;
// weak for object that Activity Handler does not "own"
@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, weak) NSObject<AdtraceDelegate> *adtraceDelegate;
// copy for objects shared with the user
@property (nonatomic, copy) ADTConfig *adtraceConfig;
@property (nonatomic, weak) ADTSavedPreLaunch *savedPreLaunch;
@property (nonatomic, copy) NSData* deviceTokenData;
@property (nonatomic, copy) NSString* basePath;
@property (nonatomic, copy) NSString* gdprPath;
@property (nonatomic, copy) NSString* subscriptionPath;

- (void)prepareDeeplinkI:(ADTActivityHandler *_Nullable)selfI
            responseData:(ADTAttributionResponseData *_Nullable)attributionResponseData NS_EXTENSION_UNAVAILABLE_IOS("");

@end

// copy from ADClientError
typedef NS_ENUM(NSInteger, AdtADClientError) {
    AdtADClientErrorUnknown = 0,
    AdtADClientErrorTrackingRestrictedOrDenied = 1,
    AdtADClientErrorMissingData = 2,
    AdtADClientErrorCorruptResponse = 3,
    AdtADClientErrorRequestClientError = 4,
    AdtADClientErrorRequestServerError = 5,
    AdtADClientErrorRequestNetworkError = 6,
    AdtADClientErrorUnsupportedPlatform = 7,
    AdtCustomErrorTimeout = 100,
};

#pragma mark -
@implementation ADTActivityHandler

@synthesize attribution = _attribution;
@synthesize trackingStatusManager = _trackingStatusManager;

- (id)initWithConfig:(ADTConfig *)adtraceConfig
      savedPreLaunch:(ADTSavedPreLaunch *)savedPreLaunch
{
    self = [super init];
    if (self == nil) return nil;

    if (adtraceConfig == nil) {
        [ADTAdtraceFactory.logger error:@"AdtraceConfig missing"];
        return nil;
    }

    if (![adtraceConfig isValid]) {
        [ADTAdtraceFactory.logger error:@"AdtraceConfig not initialized correctly"];
        return nil;
    }
    
    // check if ASA and IDFA tracking were switched off and warn just in case
    if (adtraceConfig.allowIdfaReading == NO) {
        [ADTAdtraceFactory.logger warn:@"IDFA reading has been switched off"];
    }
    if (adtraceConfig.allowiAdInfoReading == NO) {
        [ADTAdtraceFactory.logger warn:@"iAd info reading has been switched off"];
    }
    if (adtraceConfig.allowAdServicesInfoReading == NO) {
        [ADTAdtraceFactory.logger warn:@"AdServices info reading has been switched off"];
    }

    self.adtraceConfig = adtraceConfig;
    self.savedPreLaunch = savedPreLaunch;
    self.adtraceDelegate = adtraceConfig.delegate;

    // init logger to be available everywhere
    self.logger = ADTAdtraceFactory.logger;

    [self.logger lockLogLevel];

    // inject app token be available in activity state
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        [ADTActivityState saveAppToken:adtraceConfig.appToken];
    }];

    // read files to have sync values available
    [self readAttribution];
    [self readActivityState];
    
    // register SKAdNetwork attribution if we haven't already
    if ([ADTUserDefaults getSkadRegisterCallTimestamp] == nil) {
        [self registerForSKAdNetworkAttribution];
    } else {
        [ADTAdtraceFactory.logger debug:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method already made for this install"];
    }

    self.internalState = [[ADTInternalState alloc] init];

    if (savedPreLaunch.enabled != nil) {
        if (savedPreLaunch.preLaunchActionsArray == nil) {
            savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
        }

        BOOL newEnabled = [savedPreLaunch.enabled boolValue];
        [savedPreLaunch.preLaunchActionsArray addObject:^(ADTActivityHandler * activityHandler){
            [activityHandler setEnabledI:activityHandler enabled:newEnabled];
        }];
    }

    // check if SDK is enabled/disabled
    self.internalState.enabled = savedPreLaunch.enabled != nil ? [savedPreLaunch.enabled boolValue] : YES;
    // reads offline mode from pre launch
    self.internalState.offline = savedPreLaunch.offline;
    // in the background by default
    self.internalState.background = YES;
    // delay start not configured by default
    self.internalState.delayStart = NO;
    // does not need to update packages by default
    if (self.activityState == nil) {
        self.internalState.updatePackages = NO;
    } else {
        self.internalState.updatePackages = self.activityState.updatePackages;
    }
    if (self.activityState == nil) {
        self.internalState.firstLaunch = YES;
    } else {
        self.internalState.firstLaunch = NO;
    }
    // does not have the session response by default
    self.internalState.sessionResponseProcessed = NO;

    self.iAdRetriesLeft = kiAdRetriesCount;
    self.adServicesRetriesLeft = kAdServicesdRetriesCount;

    self.trackingStatusManager = [[ADTTrackingStatusManager alloc] initWithActivityHandler:self];

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI initI:selfI
                     preLaunchActions:savedPreLaunch];
                     }];

    /* Not needed, done already in initI:preLaunchActionsArray: method.
    // self.deviceTokenData = savedPreLaunch.deviceTokenData;
    if (self.activityState != nil) {
        [self setDeviceToken:[ADTUserDefaults getPushToken]];
    }
    */

    [self addNotificationObserver];

    return self;
}

- (void)applicationDidBecomeActive {
    self.internalState.background = NO;

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI delayStartI:selfI];

                         [selfI stopBackgroundTimerI:selfI];

                         [selfI startForegroundTimerI:selfI];

                         [selfI.logger verbose:@"Subsession start"];

                         [selfI startI:selfI];
                     }];
}

- (void)applicationWillResignActive {
    self.internalState.background = YES;

    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI stopForegroundTimerI:selfI];

                         [selfI startBackgroundTimerI:selfI];

                         [selfI.logger verbose:@"Subsession end"];

                         [selfI endI:selfI];
                     }];
}

- (void)trackEvent:(ADTEvent *)event {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         // track event called before app started
                         if (selfI.activityState == nil) {
                             [selfI startI:selfI];
                         }
                         [selfI eventI:selfI event:event];
                     }];
}

- (void)finishedTracking:(ADTResponseData *)responseData {
    [self checkConversionValue:responseData];

    // redirect session responses to attribution handler to check for attribution information
    if ([responseData isKindOfClass:[ADTSessionResponseData class]]) {
        [self.attributionHandler checkSessionResponse:(ADTSessionResponseData*)responseData];
        return;
    }

    // redirect sdk_click responses to attribution handler to check for attribution information
    if ([responseData isKindOfClass:[ADTSdkClickResponseData class]]) {
        [self.attributionHandler checkSdkClickResponse:(ADTSdkClickResponseData*)responseData];
        return;
    }

    // check if it's an event response
    if ([responseData isKindOfClass:[ADTEventResponseData class]]) {
        [self launchEventResponseTasks:(ADTEventResponseData*)responseData];
        return;
    }
}

- (void)launchEventResponseTasks:(ADTEventResponseData *)eventResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI launchEventResponseTasksI:selfI eventResponseData:eventResponseData];
                     }];
}

- (void)launchSessionResponseTasks:(ADTSessionResponseData *)sessionResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI launchSessionResponseTasksI:selfI sessionResponseData:sessionResponseData];
                     }];
}

- (void)launchSdkClickResponseTasks:(ADTSdkClickResponseData *)sdkClickResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI launchSdkClickResponseTasksI:selfI sdkClickResponseData:sdkClickResponseData];
                     }];
}

- (void)launchAttributionResponseTasks:(ADTAttributionResponseData *)attributionResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI launchAttributionResponseTasksI:selfI attributionResponseData:attributionResponseData];
                     }];
}

- (void)setEnabled:(BOOL)enabled {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setEnabledI:selfI enabled:enabled];
                     }];
}

- (void)setOfflineMode:(BOOL)offline {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setOfflineModeI:selfI offline:offline];
                     }];
}

- (BOOL)isEnabled {
    return [self isEnabledI:self];
}

- (BOOL)isGdprForgotten {
    return [self isGdprForgottenI:self];
}

- (NSString *)adid {
    if (self.activityState == nil) {
        return nil;
    }
    return self.activityState.adid;
}

- (void)appWillOpenUrl:(NSURL *)url withClickTime:(NSDate *)clickTime {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI appWillOpenUrlI:selfI url:url clickTime:clickTime];
                     }];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setDeviceTokenI:selfI deviceToken:deviceToken];
                     }];
}

- (void)setPushToken:(NSString *)pushToken {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setPushTokenI:selfI pushToken:pushToken];
                     }];
}

- (void)setGdprForgetMe {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setGdprForgetMeI:selfI];
                     }];
}

- (void)setTrackingStateOptedOut {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setTrackingStateOptedOutI:selfI];
                     }];
}

- (void)setAdServicesAttributionToken:(NSString *)token
                                error:(NSError *)error {
    if (![ADTUtil isNull:error]) {
        [self.logger warn:@"Unable to read AdServices details"];
        
        // 3 == platform not supported
        if (error.code != 3 && self.adServicesRetriesLeft > 0) {
            self.adServicesRetriesLeft = self.adServicesRetriesLeft - 1;
            // retry after 5 seconds
            dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
            dispatch_after(retryTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self checkForAdServicesAttributionI:self];
            });
        } else {
            [self sendAdServicesClickPackage:self
                                      token:nil
                            errorCodeNumber:[NSNumber numberWithInteger:error.code]];
        }
    } else {
        [self sendAdServicesClickPackage:self
                                  token:token
                        errorCodeNumber:nil];
    }
}

- (void)setAttributionDetails:(NSDictionary *)attributionDetails
                        error:(NSError *)error
{
    if (![ADTUtil isNull:error]) {
        [self.logger warn:@"Unable to read iAd details"];

        if (self.iAdRetriesLeft  < 0) {
            [self.logger warn:@"Number of retries to get iAd information surpassed"];
            return;
        }

        switch (error.code) {
            // if first request was unsuccessful and ended up with one of the following error codes:
            // apply following retry logic:
            //      - 1st retry after 5 seconds
            //      - 2nd retry after 2 seconds
            //      - 3rd retry after 2 seconds
            case AdtADClientErrorUnknown:
            case AdtADClientErrorMissingData:
            case AdtADClientErrorCorruptResponse:
            case AdtADClientErrorRequestClientError:
            case AdtADClientErrorRequestServerError:
            case AdtADClientErrorRequestNetworkError:
            case AdtCustomErrorTimeout: {
                
                [self saveiAdErrorCode:error.code];
                
                int64_t iAdRetryDelay = 0;
                switch (self.iAdRetriesLeft) {
                    case 2:
                        iAdRetryDelay = 5 * NSEC_PER_SEC;
                        break;
                    default:
                        iAdRetryDelay = 2 * NSEC_PER_SEC;
                        break;
                }
                self.iAdRetriesLeft = self.iAdRetriesLeft - 1;
                dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, iAdRetryDelay);
                dispatch_after(retryTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self checkForiAdI:self];
                });
                return;
            }
            case AdtADClientErrorTrackingRestrictedOrDenied:
            case AdtADClientErrorUnsupportedPlatform:
                return;
            default:
                return;
        }
    }

    // check if it's a valid attribution details
    if (![ADTUtil checkAttributionDetails:attributionDetails]) {
        return;
    }

    // send immediately if there is no previous attribution details
    if (self.activityState == nil ||
        self.activityState.attributionDetails == nil)
    {
        // send immediately
        [self sendIad3ClickPackage:self attributionDetails:attributionDetails];
        // save in the background queue
        [ADTUtil launchInQueue:self.internalQueue
                    selfInject:self
                         block:^(ADTActivityHandler * selfI) {
                             [selfI saveAttributionDetailsI:selfI
                                         attributionDetails:attributionDetails];

                         }];
        return;
    }

    // check if new updates previous written one
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         if ([attributionDetails isEqualToDictionary:selfI.activityState.attributionDetails]) {
                             return;
                         }

                         [selfI sendIad3ClickPackage:selfI attributionDetails:attributionDetails];

                         // save new iAd details
                         [selfI saveAttributionDetailsI:selfI
                                     attributionDetails:attributionDetails];
                     }];
}

- (void)saveiAdErrorCode:(NSInteger)code {
    NSString *codeKey;
    switch (code) {
        case AdtADClientErrorUnknown:
            codeKey = @"AdtADClientErrorUnknown";
            break;
        case AdtADClientErrorMissingData:
            codeKey = @"AdtADClientErrorMissingData";
            break;
        case AdtADClientErrorCorruptResponse:
            codeKey = @"AdtADClientErrorCorruptResponse";
            break;
        case AdtCustomErrorTimeout:
            codeKey = @"AdtCustomErrorTimeout";
            break;
        default:
            codeKey = @"";
            break;
    }
    
    if (![codeKey isEqualToString:@""]) {
        [ADTUserDefaults saveiAdErrorKey:codeKey];
    }
}

- (void)sendIad3ClickPackage:(ADTActivityHandler *)selfI
          attributionDetails:(NSDictionary *)attributionDetails
 {
     if (![selfI isEnabledI:selfI]) {
         return;
     }

     if (ADTAdtraceFactory.iAdFrameworkEnabled == NO) {
         [self.logger verbose:@"Sending iAd details to server suppressed."];
         return;
     }

     double now = [NSDate.date timeIntervalSince1970];
     if (selfI.activityState != nil) {
         [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                         block:^{
             double lastInterval = now - selfI.activityState.lastActivity;
             selfI.activityState.lastInterval = lastInterval;
         }];
     }
     ADTPackageBuilder *clickBuilder = [[ADTPackageBuilder alloc]
                                        initWithPackageParams:selfI.packageParams
                                        activityState:selfI.activityState
                                        config:selfI.adtraceConfig
                                        sessionParameters:self.sessionParameters
                                        trackingStatusManager:self.trackingStatusManager
                                        createdAt:now];

     clickBuilder.attributionDetails = attributionDetails;

     ADTActivityPackage *clickPackage = [clickBuilder buildClickPackage:ADTiAdPackageKey];
     [selfI.sdkClickHandler sendSdkClick:clickPackage];
}

- (void)sendAdServicesClickPackage:(ADTActivityHandler *)selfI
                             token:(NSString *)token
                   errorCodeNumber:(NSNumber *)errorCodeNumber
 {
     if (![selfI isEnabledI:selfI]) {
         return;
     }

     if (ADTAdtraceFactory.adServicesFrameworkEnabled == NO) {
         [self.logger verbose:@"Sending AdServices attribution to server suppressed."];
         return;
     }

     double now = [NSDate.date timeIntervalSince1970];
     if (selfI.activityState != nil) {
         [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                         block:^{
             double lastInterval = now - selfI.activityState.lastActivity;
             selfI.activityState.lastInterval = lastInterval;
         }];
     }
     ADTPackageBuilder *clickBuilder = [[ADTPackageBuilder alloc]
                                        initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                       config:selfI.adtraceConfig
                                       sessionParameters:self.sessionParameters
                                       trackingStatusManager:self.trackingStatusManager
                                       createdAt:now];

     ADTActivityPackage *clickPackage =
        [clickBuilder buildClickPackage:ADTAdServicesPackageKey
                                  token:token
                        errorCodeNumber:errorCodeNumber];
     [selfI.sdkClickHandler sendSdkClick:clickPackage];
}

- (void)saveAttributionDetailsI:(ADTActivityHandler *)selfI
             attributionDetails:(NSDictionary *)attributionDetails
{
    // save new iAd details
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.attributionDetails = attributionDetails;
    }];
    [selfI writeAttributionI:selfI];
}

- (void)setAskingAttribution:(BOOL)askingAttribution {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI setAskingAttributionI:selfI
                                   askingAttribution:askingAttribution];
                     }];
}

- (void)foregroundTimerFired {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI foregroundTimerFiredI:selfI];
                     }];
}

- (void)backgroundTimerFired {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI backgroundTimerFiredI:selfI];
                     }];
}

- (void)sendFirstPackages {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI sendFirstPackagesI:selfI];
                     }];
}

- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI addSessionCallbackParameterI:selfI key:key value:value];
                     }];
}

- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI addSessionPartnerParameterI:selfI key:key value:value];
                     }];
}

- (void)removeSessionCallbackParameter:(NSString *)key {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI removeSessionCallbackParameterI:selfI key:key];
                     }];
}

- (void)removeSessionPartnerParameter:(NSString *)key {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI removeSessionPartnerParameterI:selfI key:key];
                     }];
}

- (void)resetSessionCallbackParameters {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI resetSessionCallbackParametersI:selfI];
                     }];
}

- (void)resetSessionPartnerParameters {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI resetSessionPartnerParametersI:selfI];
                     }];
}

- (void)trackAdRevenue:(NSString *)source payload:(NSData *)payload {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI adRevenueI:selfI source:source payload:payload];
                     }];
}

- (void)trackSubscription:(ADTSubscription *)subscription {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
        [selfI trackSubscriptionI:selfI subscription:subscription];
    }];
}

- (void)disableThirdPartySharing {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI disableThirdPartySharingI:selfI];
                     }];
}

- (void)trackThirdPartySharing:(nonnull ADTThirdPartySharing *)thirdPartySharing {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
        BOOL tracked =
            [selfI trackThirdPartySharingI:selfI thirdPartySharing:thirdPartySharing];
        if (! tracked) {
            if (self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray == nil) {
                self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray =
                    [[NSMutableArray alloc] init];
            }

            [self.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray
                addObject:thirdPartySharing];
        }
    }];
}

- (void)trackMeasurementConsent:(BOOL)enabled {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
        BOOL tracked =
            [selfI trackMeasurementConsentI:selfI enabled:enabled];
        if (! tracked) {
            selfI.savedPreLaunch.lastMeasurementConsentTracked =
                [NSNumber numberWithBool:enabled];
        }
    }];
}

- (void)trackAdRevenue:(ADTAdRevenue *)adRevenue {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
        [selfI trackAdRevenueI:selfI adRevenue:adRevenue];
    }];
}

- (void)writeActivityState {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                         [selfI writeActivityStateI:selfI];
                     }];
}

- (void)trackAttStatusUpdate {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTActivityHandler * selfI) {
                        [selfI trackAttStatusUpdateI:selfI];
                     }];
}
- (void)trackAttStatusUpdateI:(ADTActivityHandler *)selfI {
    double now = [NSDate.date timeIntervalSince1970];

    ADTPackageBuilder *infoBuilder = [[ADTPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                                activityState:selfI.activityState
                                                config:selfI.adtraceConfig
                                                sessionParameters:selfI.sessionParameters
                                                trackingStatusManager:self.trackingStatusManager
                                                createdAt:now];

    ADTActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"att"];
    [selfI.packageHandler addPackage:infoPackage];
    
    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", infoPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (NSString *)getBasePath {
    return _basePath;
}

- (NSString *)getGdprPath {
    return _gdprPath;
}

- (NSString *)getSubscriptionPath {
    return _subscriptionPath;
}

- (void)teardown
{
    [ADTAdtraceFactory.logger verbose:@"ADTActivityHandler teardown"];
    [self removeNotificationObserver];
    if (self.backgroundTimer != nil) {
        [self.backgroundTimer cancel];
    }
    if (self.foregroundTimer != nil) {
        [self.foregroundTimer cancel];
    }
    if (self.delayStartTimer != nil) {
        [self.delayStartTimer cancel];
    }
    if (self.attributionHandler != nil) {
        [self.attributionHandler teardown];
    }
    if (self.packageHandler != nil) {
        [self.packageHandler teardown];
    }
    if (self.sdkClickHandler != nil) {
        [self.sdkClickHandler teardown];
    }
    [self teardownActivityStateS];
    [self teardownAttributionS];
    [self teardownAllSessionParametersS];

    [ADTUtil teardown];

    self.internalQueue = nil;
    self.packageHandler = nil;
    self.attributionHandler = nil;
    self.sdkClickHandler = nil;
    self.foregroundTimer = nil;
    self.backgroundTimer = nil;
    self.adtraceDelegate = nil;
    self.adtraceConfig = nil;
    self.internalState = nil;
    self.packageParams = nil;
    self.delayStartTimer = nil;
    self.logger = nil;
}

+ (void)deleteState
{
    [ADTActivityHandler deleteActivityState];
    [ADTActivityHandler deleteAttribution];
    [ADTActivityHandler deleteSessionCallbackParameter];
    [ADTActivityHandler deleteSessionPartnerParameter];

    [ADTUserDefaults clearAdtraceStuff];
}

+ (void)deleteActivityState {
    [ADTUtil deleteFileWithName:kActivityStateFilename];
}

+ (void)deleteAttribution {
    [ADTUtil deleteFileWithName:kAttributionFilename];
}

+ (void)deleteSessionCallbackParameter {
    [ADTUtil deleteFileWithName:kSessionCallbackParametersFilename];
}

+ (void)deleteSessionPartnerParameter {
    [ADTUtil deleteFileWithName:kSessionPartnerParametersFilename];
}

#pragma mark - internal
- (void)initI:(ADTActivityHandler *)selfI
preLaunchActions:(ADTSavedPreLaunch*)preLaunchActions
{
    // get session values
    kSessionInterval = ADTAdtraceFactory.sessionInterval;
    kSubSessionInterval = ADTAdtraceFactory.subsessionInterval;
    // get timer values
    kForegroundTimerStart = ADTAdtraceFactory.timerStart;
    kForegroundTimerInterval = ADTAdtraceFactory.timerInterval;
    kBackgroundTimerInterval = ADTAdtraceFactory.timerInterval;

    selfI.packageParams = [ADTPackageParams packageParamsWithSdkPrefix:selfI.adtraceConfig.sdkPrefix];

    // read files that are accessed only in Internal sections
    selfI.sessionParameters = [[ADTSessionParameters alloc] init];
    [selfI readSessionCallbackParametersI:selfI];
    [selfI readSessionPartnerParametersI:selfI];

    if (selfI.adtraceConfig.eventBufferingEnabled)  {
        [selfI.logger info:@"Event buffering is enabled"];
    }

    if (selfI.adtraceConfig.defaultTracker != nil) {
        [selfI.logger info:@"Default tracker: '%@'", selfI.adtraceConfig.defaultTracker];
    }

    if (selfI.deviceTokenData != nil) {
        [selfI.logger info:@"Push token: '%@'", selfI.deviceTokenData];
        if (selfI.activityState != nil) {
            [selfI setDeviceToken:selfI.deviceTokenData];
        }
    } else {
        if (selfI.activityState != nil) {
            NSData *deviceToken = [ADTUserDefaults getPushTokenData];
            [selfI setDeviceToken:deviceToken];
            NSString *pushToken = [ADTUserDefaults getPushTokenString];
            [selfI setPushToken:pushToken];
        }
    }

    if (selfI.activityState != nil) {
        if ([ADTUserDefaults getGdprForgetMe]) {
            [selfI setGdprForgetMe];
        }
    }

    selfI.foregroundTimer = [ADTTimerCycle timerWithBlock:^{
        [selfI foregroundTimerFired];
    }
                                                    queue:selfI.internalQueue
                                                startTime:kForegroundTimerStart
                                             intervalTime:kForegroundTimerInterval
                                                     name:kForegroundTimerName
    ];

    if (selfI.adtraceConfig.sendInBackground) {
        [selfI.logger info:@"Send in background configured"];
        selfI.backgroundTimer = [ADTTimerOnce timerWithBlock:^{ [selfI backgroundTimerFired]; }
                                                      queue:selfI.internalQueue
                                                        name:kBackgroundTimerName];
    }

    if (selfI.activityState == nil &&
        selfI.adtraceConfig.delayStart > 0)
    {
        [selfI.logger info:@"Delay start configured"];
        selfI.internalState.delayStart = YES;
        selfI.delayStartTimer = [ADTTimerOnce timerWithBlock:^{ [selfI sendFirstPackages]; }
                                                       queue:selfI.internalQueue
                                                        name:kDelayStartTimerName];
    }

    [ADTUtil updateUrlSessionConfiguration:selfI.adtraceConfig];

    ADTUrlStrategy *packageHandlerUrlStrategy =
        [[ADTUrlStrategy alloc]
             initWithUrlStrategyInfo:selfI.adtraceConfig.urlStrategy
             extraPath:preLaunchActions.extraPath];

    selfI.packageHandler = [[ADTPackageHandler alloc]
                                initWithActivityHandler:selfI
                                startsSending:
                                    [selfI toSendI:selfI sdkClickHandlerOnly:NO]
                                userAgent:selfI.adtraceConfig.userAgent
                                urlStrategy:packageHandlerUrlStrategy];

    // update session parameters in package queue
    if ([selfI itHasToUpdatePackagesI:selfI]) {
        [selfI updatePackagesI:selfI];
     }


    ADTUrlStrategy *attributionHandlerUrlStrategy =
        [[ADTUrlStrategy alloc]
             initWithUrlStrategyInfo:selfI.adtraceConfig.urlStrategy
             extraPath:preLaunchActions.extraPath];

    selfI.attributionHandler = [[ADTAttributionHandler alloc]
                                    initWithActivityHandler:selfI
                                    startsSending:
                                        [selfI toSendI:selfI sdkClickHandlerOnly:NO]
                                    userAgent:selfI.adtraceConfig.userAgent
                                    urlStrategy:attributionHandlerUrlStrategy];

    ADTUrlStrategy *sdkClickHandlerUrlStrategy =
        [[ADTUrlStrategy alloc]
             initWithUrlStrategyInfo:selfI.adtraceConfig.urlStrategy
             extraPath:preLaunchActions.extraPath];

    selfI.sdkClickHandler = [[ADTSdkClickHandler alloc]
                                initWithActivityHandler:selfI
                                startsSending:[selfI toSendI:selfI sdkClickHandlerOnly:YES]
                                userAgent:selfI.adtraceConfig.userAgent
                                urlStrategy:sdkClickHandlerUrlStrategy];

    [selfI.trackingStatusManager checkForNewAttStatus];

    [selfI preLaunchActionsI:selfI
       preLaunchActionsArray:preLaunchActions.preLaunchActionsArray];

    [ADTUtil launchInMainThreadWithInactive:^(BOOL isInactive) {
        [ADTUtil launchInQueue:self.internalQueue selfInject:self block:^(ADTActivityHandler * selfI) {
            if (!isInactive) {
                [selfI.logger debug:@"Start sdk, since the app is already in the foreground"];
                selfI.internalState.background = NO;
                [selfI startI:selfI];
            } else {
                [selfI.logger debug:@"Wait for the app to go to the foreground to start the sdk"];
            }
        }];
    }];
}

- (void)startI:(ADTActivityHandler *)selfI {
    // it shouldn't start if it was disabled after a first session
    if (selfI.activityState != nil
        && !selfI.activityState.enabled) {
        return;
    }

    [selfI updateHandlersStatusAndSendI:selfI];

    [selfI processSessionI:selfI];

    [selfI checkAttributionStateI:selfI];

    [selfI processCachedDeeplinkI:selfI];
}

- (void)processSessionI:(ADTActivityHandler *)selfI {
    double now = [NSDate.date timeIntervalSince1970];

    // very first session
    if (selfI.activityState == nil) {
        selfI.activityState = [[ADTActivityState alloc] init];

        // selfI.activityState.deviceToken = [ADTUtil convertDeviceToken:selfI.deviceTokenData];
        NSData *deviceToken = [ADTUserDefaults getPushTokenData];
        NSString *deviceTokenString = [ADTUtil convertDeviceToken:deviceToken];
        NSString *pushToken = [ADTUserDefaults getPushTokenString];
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.deviceToken = deviceTokenString != nil ? deviceTokenString : pushToken;
        }];

        // track the first session package only if it's enabled
        if ([selfI.internalState isEnabled]) {
            // If user chose to be forgotten before install has ever tracked, don't track it.
            if ([ADTUserDefaults getGdprForgetMe]) {
                [selfI setGdprForgetMeI:selfI];
            } else {
                // check if disable third party sharing request came, then send it first
                if ([ADTUserDefaults getDisableThirdPartySharing]) {
                    [selfI disableThirdPartySharingI:selfI];
                }
                if (selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray != nil) {
                    for (ADTThirdPartySharing *thirdPartySharing
                         in selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray)
                    {
                        [selfI trackThirdPartySharingI:selfI
                                     thirdPartySharing:thirdPartySharing];
                    }

                    selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray = nil;
                }
                if (selfI.savedPreLaunch.lastMeasurementConsentTracked != nil) {
                    [selfI
                        trackMeasurementConsentI:selfI
                        enabled:[selfI.savedPreLaunch.lastMeasurementConsentTracked boolValue]];

                    selfI.savedPreLaunch.lastMeasurementConsentTracked = nil;
                }

                [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                                block:^{
                    selfI.activityState.sessionCount = 1; // this is the first session
                }];
                [selfI transferSessionPackageI:selfI now:now];
            }
        }

        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            [selfI.activityState resetSessionAttributes:now];
            selfI.activityState.enabled = [selfI.internalState isEnabled];
            selfI.activityState.updatePackages = [selfI.internalState itHasToUpdatePackages];
        }];

        if (selfI.adtraceConfig.allowiAdInfoReading == YES) {
            [selfI checkForiAdI:selfI];
        }
        if (selfI.adtraceConfig.allowAdServicesInfoReading == YES) {
            [selfI checkForAdServicesAttributionI:selfI];
        }

        [selfI writeActivityStateI:selfI];
        [ADTUserDefaults removePushToken];
        [ADTUserDefaults removeDisableThirdPartySharing];

        return;
    }

    double lastInterval = now - selfI.activityState.lastActivity;
    if (lastInterval < 0) {
        [selfI.logger error:@"Time travel!"];
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.lastActivity = now;
        }];
        [selfI writeActivityStateI:selfI];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        [self trackNewSessionI:now withActivityHandler:selfI];
        return;
    }

    // new subsession
    if (lastInterval > kSubSessionInterval) {
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.subsessionCount++;
            selfI.activityState.sessionLength += lastInterval;
            selfI.activityState.lastActivity = now;
        }];
        [selfI.logger verbose:@"Started subsession %d of session %d",
         selfI.activityState.subsessionCount,
         selfI.activityState.sessionCount];
        [selfI writeActivityStateI:selfI];
        return;
    }

    [selfI.logger verbose:@"Time span since last activity too short for a new subsession"];
}

- (void)trackNewSessionI:(double)now withActivityHandler:(ADTActivityHandler *)selfI {
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    [selfI checkForAdServicesAttributionI:selfI];

    double lastInterval = now - selfI.activityState.lastActivity;
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.sessionCount++;
        selfI.activityState.lastInterval = lastInterval;
    }];
    [selfI transferSessionPackageI:selfI now:now];
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        [selfI.activityState resetSessionAttributes:now];
    }];
    [selfI writeActivityStateI:selfI];
}

- (void)transferSessionPackageI:(ADTActivityHandler *)selfI
                            now:(double)now {
    ADTPackageBuilder *sessionBuilder = [[ADTPackageBuilder alloc]
                                         initWithPackageParams:selfI.packageParams
                                         activityState:selfI.activityState
                                         config:selfI.adtraceConfig
                                         sessionParameters:selfI.sessionParameters
                                         trackingStatusManager:self.trackingStatusManager
                                         createdAt:now];
    ADTActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage:[selfI.internalState isInDelayedStart]];
    [selfI.packageHandler addPackage:sessionPackage];
    [selfI.packageHandler sendFirstPackage];
}

- (void)checkAttributionStateI:(ADTActivityHandler *)selfI {
    if (![selfI checkActivityStateI:selfI]) return;

    // if it's the first launch
    if ([selfI.internalState isFirstLaunch]) {
        // and it hasn't received the session response
        if ([selfI.internalState hasSessionResponseNotBeenProcessed]) {
            return;
        }
    }

    // if there is already an attribution saved and there was no attribution being asked
    if (selfI.attribution != nil && !selfI.activityState.askingAttribution) {
        return;
    }

    [selfI.attributionHandler getAttribution];
}

- (void)processCachedDeeplinkI:(ADTActivityHandler *)selfI {
    if (![selfI checkActivityStateI:selfI]) return;

    NSURL *cachedDeeplinkUrl = [ADTUserDefaults getDeeplinkUrl];
    if (cachedDeeplinkUrl == nil) {
        return;
    }
    NSDate *cachedDeeplinkClickTime = [ADTUserDefaults getDeeplinkClickTime];
    if (cachedDeeplinkClickTime == nil) {
        return;
    }

    [selfI appWillOpenUrlI:selfI url:cachedDeeplinkUrl clickTime:cachedDeeplinkClickTime];
    [ADTUserDefaults removeDeeplink];
}

- (void)endI:(ADTActivityHandler *)selfI {
    // pause sending if it's not allowed to send
    if (![selfI toSendI:selfI]) {
        [selfI pauseSendingI:selfI];
    }

    double now = [NSDate.date timeIntervalSince1970];
    if ([selfI updateActivityStateI:selfI now:now]) {
        [selfI writeActivityStateI:selfI];
    }
}

- (void)eventI:(ADTActivityHandler *)selfI
         event:(ADTEvent *)event {
    if (![selfI isEnabledI:selfI]) return;
    if (![selfI checkEventI:selfI event:event]) return;
    if (![selfI checkTransactionIdI:selfI transactionId:event.transactionId]) return;
    if (selfI.activityState.isGdprForgotten) { return; }

    double now = [NSDate.date timeIntervalSince1970];

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.eventCount++;
    }];
    [selfI updateActivityStateI:selfI now:now];

    // create and populate event package
    ADTPackageBuilder *eventBuilder = [[ADTPackageBuilder alloc]
                                       initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                       config:selfI.adtraceConfig
                                       sessionParameters:selfI.sessionParameters
                                       trackingStatusManager:self.trackingStatusManager
                                       createdAt:now];
    ADTActivityPackage *eventPackage = [eventBuilder buildEventPackage:event
                                                             isInDelay:[selfI.internalState isInDelayedStart]];
    [selfI.packageHandler addPackage:eventPackage];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", eventPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }

    // if it is in the background and it can send, start the background timer
    if (selfI.adtraceConfig.sendInBackground && [selfI.internalState isInBackground]) {
        [selfI startBackgroundTimerI:selfI];
    }

    [selfI writeActivityStateI:selfI];
}

- (void)adRevenueI:(ADTActivityHandler *)selfI
            source:(NSString *)source
           payload:(NSData *)payload {
    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // Create and submit ad revenue package.
    ADTPackageBuilder *adRevenueBuilder = [[ADTPackageBuilder alloc]
                                           initWithPackageParams:selfI.packageParams
                                                   activityState:selfI.activityState
                                                   config:selfI.adtraceConfig
                                                   sessionParameters:selfI.sessionParameters
                                                   trackingStatusManager:self.trackingStatusManager
                                                   createdAt:now];

    ADTActivityPackage *adRevenuePackage = [adRevenueBuilder buildAdRevenuePackage:source payload:payload];
    [selfI.packageHandler addPackage:adRevenuePackage];
    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", adRevenuePackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)trackSubscriptionI:(ADTActivityHandler *)selfI
              subscription:(ADTSubscription *)subscription {
    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // Create and submit ad revenue package.
    ADTPackageBuilder *subscriptionBuilder = [[ADTPackageBuilder alloc]
                                              initWithPackageParams:selfI.packageParams
                                                    activityState:selfI.activityState
                                                    config:selfI.adtraceConfig
                                                    sessionParameters:selfI.sessionParameters
                                                    trackingStatusManager:self.trackingStatusManager
                                                    createdAt:now];

    ADTActivityPackage *subscriptionPackage = [subscriptionBuilder buildSubscriptionPackage:subscription
                                                                                  isInDelay:[selfI.internalState isInDelayedStart]];
    [selfI.packageHandler addPackage:subscriptionPackage];
    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", subscriptionPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)disableThirdPartySharingI:(ADTActivityHandler *)selfI {
    // cache the disable third party sharing request, so that the request order maintains
    // even this call returns before making server request
    [ADTUserDefaults setDisableThirdPartySharing];

    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }
    if (selfI.activityState.isThirdPartySharingDisabled) {
        return;
    }

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.isThirdPartySharingDisabled = YES;
    }];
    [selfI writeActivityStateI:selfI];

    double now = [NSDate.date timeIntervalSince1970];

    // build package
    ADTPackageBuilder *dtpsBuilder = [[ADTPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                            activityState:selfI.activityState
                                            config:selfI.adtraceConfig
                                            sessionParameters:selfI.sessionParameters
                                            trackingStatusManager:self.trackingStatusManager
                                            createdAt:now];

    ADTActivityPackage *dtpsPackage = [dtpsBuilder buildDisableThirdPartySharingPackage];

    [selfI.packageHandler addPackage:dtpsPackage];

    [ADTUserDefaults removeDisableThirdPartySharing];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", dtpsPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (BOOL)trackThirdPartySharingI:(ADTActivityHandler *)selfI
                thirdPartySharing:(nonnull ADTThirdPartySharing *)thirdPartySharing
{
    if (!selfI.activityState) {
        return NO;
    }
    if (![selfI isEnabledI:selfI]) {
        return NO;
    }
    if (selfI.activityState.isGdprForgotten) {
        return NO;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // build package
    ADTPackageBuilder *tpsBuilder = [[ADTPackageBuilder alloc]
                                     initWithPackageParams:selfI.packageParams
                                            activityState:selfI.activityState
                                            config:selfI.adtraceConfig
                                            sessionParameters:selfI.sessionParameters
                                            trackingStatusManager:self.trackingStatusManager
                                            createdAt:now];

    ADTActivityPackage *dtpsPackage = [tpsBuilder buildThirdPartySharingPackage:thirdPartySharing];

    [selfI.packageHandler addPackage:dtpsPackage];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", dtpsPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }

    return YES;
}

- (BOOL)trackMeasurementConsentI:(ADTActivityHandler *)selfI
                         enabled:(BOOL)enabled
{
    if (!selfI.activityState) {
        return NO;
    }
    if (![selfI isEnabledI:selfI]) {
        return NO;
    }
    if (selfI.activityState.isGdprForgotten) {
        return NO;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // build package
    ADTPackageBuilder *tpsBuilder = [[ADTPackageBuilder alloc]
                                     initWithPackageParams:selfI.packageParams
                                            activityState:selfI.activityState
                                            config:selfI.adtraceConfig
                                            sessionParameters:selfI.sessionParameters
                                            trackingStatusManager:self.trackingStatusManager
                                            createdAt:now];

    ADTActivityPackage *mcPackage = [tpsBuilder buildMeasurementConsentPackage:enabled];

    [selfI.packageHandler addPackage:mcPackage];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", mcPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }

    return YES;
}

- (void)trackAdRevenueI:(ADTActivityHandler *)selfI
              adRevenue:(ADTAdRevenue *)adRevenue
{
    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }
    if (![selfI checkAdRevenueI:selfI adRevenue:adRevenue]) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // Create and submit ad revenue package.
    ADTPackageBuilder *adRevenueBuilder = [[ADTPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                                                          activityState:selfI.activityState
                                                                                 config:selfI.adtraceConfig
                                                                      sessionParameters:selfI.sessionParameters
                                                                  trackingStatusManager:self.trackingStatusManager
                                                                              createdAt:now];

    ADTActivityPackage *adRevenuePackage = [adRevenueBuilder buildAdRevenuePackage:adRevenue
                                                                         isInDelay:[selfI.internalState isInDelayedStart]];
    [selfI.packageHandler addPackage:adRevenuePackage];
    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered event %@", adRevenuePackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)launchEventResponseTasksI:(ADTActivityHandler *)selfI
                eventResponseData:(ADTEventResponseData *)eventResponseData {
    [selfI updateAdidI:selfI adid:eventResponseData.adid];

    // event success callback
    if (eventResponseData.success
        && [selfI.adtraceDelegate respondsToSelector:@selector(adtraceEventTrackingSucceeded:)])
    {
        [selfI.logger debug:@"Launching success event tracking delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceEventTrackingSucceeded:)
                         withObject:[eventResponseData successResponseData]];
        return;
    }
    // event failure callback
    if (!eventResponseData.success
        && [selfI.adtraceDelegate respondsToSelector:@selector(adtraceEventTrackingFailed:)])
    {
        [selfI.logger debug:@"Launching failed event tracking delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceEventTrackingFailed:)
                         withObject:[eventResponseData failureResponseData]];
        return;
    }
}

- (void)launchSessionResponseTasksI:(ADTActivityHandler *)selfI
                sessionResponseData:(ADTSessionResponseData *)sessionResponseData {
    [selfI updateAdidI:selfI adid:sessionResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI attribution:sessionResponseData.attribution];

    // mark install as tracked on success
    if (sessionResponseData.success) {
        [ADTUserDefaults setInstallTracked];
    }

    // session success callback
    if (sessionResponseData.success
        && [selfI.adtraceDelegate respondsToSelector:@selector(adtraceSessionTrackingSucceeded:)])
    {
        [selfI.logger debug:@"Launching success session tracking delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceSessionTrackingSucceeded:)
                         withObject:[sessionResponseData successResponseData]];
    }
    // session failure callback
    if (!sessionResponseData.success
        && [selfI.adtraceDelegate respondsToSelector:@selector(adtraceSessionTrackingFailed:)])
    {
        [selfI.logger debug:@"Launching failed session tracking delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceSessionTrackingFailed:)
                         withObject:[sessionResponseData failureResponseData]];
    }

    // try to update and launch the attribution changed delegate
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceAttributionChanged:)
                         withObject:sessionResponseData.attribution];
    }

    // if attribution didn't update and it's still null -> ask for attribution
    if (selfI.attribution == nil && selfI.activityState.askingAttribution == NO) {
        [selfI.attributionHandler getAttribution];
    }

    selfI.internalState.sessionResponseProcessed = YES;
}

- (void)launchSdkClickResponseTasksI:(ADTActivityHandler *)selfI
                sdkClickResponseData:(ADTSdkClickResponseData *)sdkClickResponseData {
    [selfI updateAdidI:selfI adid:sdkClickResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI attribution:sdkClickResponseData.attribution];

    // try to update and launch the attribution changed delegate
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceAttributionChanged:)
                         withObject:sdkClickResponseData.attribution];
    }
}

- (void)launchAttributionResponseTasksI:(ADTActivityHandler *)selfI
                attributionResponseData:(ADTAttributionResponseData *)attributionResponseData {
    [selfI checkConversionValue:attributionResponseData];

    [selfI updateAdidI:selfI adid:attributionResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI
                                                     attribution:attributionResponseData.attribution];

    // try to update and launch the attribution changed delegate non-blocking
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADTUtil launchInMainThread:selfI.adtraceDelegate
                           selector:@selector(adtraceAttributionChanged:)
                         withObject:attributionResponseData.attribution];
    }

    [selfI prepareDeeplinkI:selfI responseData:attributionResponseData];
}

- (void)prepareDeeplinkI:(ADTActivityHandler *)selfI
            responseData:(ADTAttributionResponseData *)attributionResponseData {
    if (attributionResponseData == nil) {
        return;
    }

    if (attributionResponseData.deeplink == nil) {
        return;
    }

    [selfI.logger info:@"Open deep link (%@)", attributionResponseData.deeplink.absoluteString];

    [ADTUtil launchInMainThread:^{
        BOOL toLaunchDeeplink = YES;

        if ([selfI.adtraceDelegate respondsToSelector:@selector(adtraceDeeplinkResponse:)]) {
            toLaunchDeeplink = [selfI.adtraceDelegate adtraceDeeplinkResponse:attributionResponseData.deeplink];
        }

        if (toLaunchDeeplink) {
            [ADTUtil launchDeepLinkMain:attributionResponseData.deeplink];
        }
    }];
}

- (void)updateAdidI:(ADTActivityHandler *)selfI
               adid:(NSString *)adid {
    if (adid == nil) {
        return;
    }

    if ([adid isEqualToString:selfI.activityState.adid]) {
        return;
    }

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.adid = adid;
    }];
    [selfI writeActivityStateI:selfI];
}

- (BOOL)updateAttributionI:(ADTActivityHandler *)selfI
               attribution:(ADTAttribution *)attribution {
    if (attribution == nil) {
        return NO;
    }
    if ([attribution isEqual:selfI.attribution]) {
        return NO;
    }
    // copy attribution property
    //  to avoid using the same object for the delegate
    selfI.attribution = attribution;
    [selfI writeAttributionI:selfI];

    if (selfI.adtraceDelegate == nil) {
        return NO;
    }

    if (![selfI.adtraceDelegate respondsToSelector:@selector(adtraceAttributionChanged:)]) {
        return NO;
    }

    return YES;
}

- (void)setEnabledI:(ADTActivityHandler *)selfI enabled:(BOOL)enabled {
    // compare with the saved or internal state
    if (![selfI hasChangedStateI:selfI
                   previousState:[selfI isEnabled]
                       nextState:enabled
                     trueMessage:@"Adtrace already enabled"
                    falseMessage:@"Adtrace already disabled"]) {
        return;
    }

    // If user is forgotten, forbid re-enabling.
    if (enabled) {
        if ([selfI isGdprForgottenI:selfI]) {
            [selfI.logger debug:@"Re-enabling SDK for forgotten user not allowed"];
            return;
        }
    }

    // save new enabled state in internal state
    selfI.internalState.enabled = enabled;

    if (selfI.activityState == nil) {
        [selfI checkStatusI:selfI
               pausingState:!enabled
              pausingMessage:@"Handlers will start as paused due to the SDK being disabled"
        remainsPausedMessage:@"Handlers will still start as paused"
            unPausingMessage:@"Handlers will start as active due to the SDK being enabled"];
        return;
    }

    // Save new enabled state in activity state.
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.enabled = enabled;
    }];
    [selfI writeActivityStateI:selfI];

    // Check if upon enabling install has been tracked.
    if (enabled) {
        if (![ADTUserDefaults getInstallTracked]) {
            double now = [NSDate.date timeIntervalSince1970];
            [self trackNewSessionI:now withActivityHandler:selfI];
        }
        NSData *deviceToken = [ADTUserDefaults getPushTokenData];
        if (deviceToken != nil && ![selfI.activityState.deviceToken isEqualToString:[ADTUtil convertDeviceToken:deviceToken]]) {
            [self setDeviceToken:deviceToken];
        }
        NSString *pushToken = [ADTUserDefaults getPushTokenString];
        if (pushToken != nil && ![selfI.activityState.deviceToken isEqualToString:pushToken]) {
            [self setPushToken:pushToken];
        }
        if ([ADTUserDefaults getGdprForgetMe]) {
            [selfI setGdprForgetMe];
        } else {
            if ([ADTUserDefaults getDisableThirdPartySharing]) {
                [selfI disableThirdPartySharing];
            }
            if (selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray != nil) {
                for (ADTThirdPartySharing *thirdPartySharing
                     in selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray)
                {
                    [selfI trackThirdPartySharing:thirdPartySharing];
                }

                selfI.savedPreLaunch.preLaunchAdtraceThirdPartySharingArray = nil;
            }
            if (selfI.savedPreLaunch.lastMeasurementConsentTracked != nil) {
                [selfI
                    trackMeasurementConsent:
                        [selfI.savedPreLaunch.lastMeasurementConsentTracked boolValue]];

                selfI.savedPreLaunch.lastMeasurementConsentTracked = nil;
            }

        }
        if (selfI.adtraceConfig.allowiAdInfoReading == YES) {
            [selfI checkForiAdI:selfI];
        }
        if (selfI.adtraceConfig.allowAdServicesInfoReading == YES) {
            [selfI checkForAdServicesAttributionI:selfI];
        }
    }

    [selfI checkStatusI:selfI
           pausingState:!enabled
          pausingMessage:@"Pausing handlers due to SDK being disabled"
    remainsPausedMessage:@"Handlers remain paused"
        unPausingMessage:@"Resuming handlers due to SDK being enabled"];
}

- (void)checkForiAdI:(ADTActivityHandler *)selfI {
    [ADTUtil checkForiAd:selfI queue:selfI.internalQueue];
}

- (BOOL)shouldFetchAdServicesI:(ADTActivityHandler *)selfI {
    if (selfI.adtraceConfig.allowAdServicesInfoReading == NO) {
        return NO;
    }
    
    // Fetch if no attribution OR not sent to backend yet
    if ([ADTUserDefaults getAdServicesTracked]) {
        [selfI.logger debug:@"AdServices attribution info already read"];
    }
    return (selfI.attribution == nil || ![ADTUserDefaults getAdServicesTracked]);
}

- (void)checkForAdServicesAttributionI:(ADTActivityHandler *)selfI {
    if (@available(iOS 14.3, tvOS 14.3, *)) {
        if ([selfI shouldFetchAdServicesI:selfI]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                NSString *token = [ADTUtil fetchAdServicesAttribution:&error];
                [selfI setAdServicesAttributionToken:token error:error];
            });
        }
    }
}

- (void)setOfflineModeI:(ADTActivityHandler *)selfI
                offline:(BOOL)offline {
    // compare with the internal state
    if (![selfI hasChangedStateI:selfI
                   previousState:[selfI.internalState isOffline]
                       nextState:offline
                     trueMessage:@"Adtrace already in offline mode"
                    falseMessage:@"Adtrace already in online mode"])
    {
        return;
    }

    // save new offline state in internal state
    selfI.internalState.offline = offline;

    if (selfI.activityState == nil) {
        [selfI checkStatusI:selfI
               pausingState:offline
             pausingMessage:@"Handlers will start paused due to SDK being offline"
       remainsPausedMessage:@"Handlers will still start as paused"
           unPausingMessage:@"Handlers will start as active due to SDK being online"];
        return;
    }

    [selfI checkStatusI:selfI
           pausingState:offline
         pausingMessage:@"Pausing handlers to put SDK offline mode"
   remainsPausedMessage:@"Handlers remain paused"
       unPausingMessage:@"Resuming handlers to put SDK in online mode"];
}

- (BOOL)hasChangedStateI:(ADTActivityHandler *)selfI
           previousState:(BOOL)previousState
               nextState:(BOOL)nextState
             trueMessage:(NSString *)trueMessage
            falseMessage:(NSString *)falseMessage
{
    if (previousState != nextState) {
        return YES;
    }

    if (previousState) {
        [selfI.logger debug:trueMessage];
    } else {
        [selfI.logger debug:falseMessage];
    }

    return NO;
}

- (void)checkStatusI:(ADTActivityHandler *)selfI
        pausingState:(BOOL)pausingState
      pausingMessage:(NSString *)pausingMessage
remainsPausedMessage:(NSString *)remainsPausedMessage
    unPausingMessage:(NSString *)unPausingMessage
{
    // it is changing from an active state to a pause state
    if (pausingState) {
        [selfI.logger info:pausingMessage];
    }
    // check if it's remaining in a pause state
    else if ([selfI pausedI:selfI sdkClickHandlerOnly:NO]) {
        // including the sdk click handler
        if ([selfI pausedI:selfI sdkClickHandlerOnly:YES]) {
            [selfI.logger info:remainsPausedMessage];
        } else {
            // or except it
            [selfI.logger info:[remainsPausedMessage stringByAppendingString:@", except the Sdk Click Handler"]];
        }
    } else {
        // it is changing from a pause state to an active state
        [selfI.logger info:unPausingMessage];
    }

    [selfI updateHandlersStatusAndSendI:selfI];
}

- (void)appWillOpenUrlI:(ADTActivityHandler *)selfI
                    url:(NSURL *)url
              clickTime:(NSDate *)clickTime {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if ([ADTUtil isNull:url]) {
        return;
    }
    if (![ADTUtil isDeeplinkValid:url]) {
        return;
    }

    NSArray *queryArray = [url.query componentsSeparatedByString:@"&"];
    if (queryArray == nil) {
        queryArray = @[];
    }

    NSMutableDictionary *adtraceDeepLinks = [NSMutableDictionary dictionary];
    ADTAttribution *deeplinkAttribution = [[ADTAttribution alloc] init];
    for (NSString *fieldValuePair in queryArray) {
        [selfI readDeeplinkQueryStringI:selfI queryString:fieldValuePair adtraceDeepLinks:adtraceDeepLinks attribution:deeplinkAttribution];
    }

    double now = [NSDate.date timeIntervalSince1970];
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        double lastInterval = now - selfI.activityState.lastActivity;
        selfI.activityState.lastInterval = lastInterval;
    }];
    ADTPackageBuilder *clickBuilder = [[ADTPackageBuilder alloc]
                                       initWithPackageParams:selfI.packageParams
                                                activityState:selfI.activityState
                                                config:selfI.adtraceConfig
                                                sessionParameters:selfI.sessionParameters
                                                trackingStatusManager:self.trackingStatusManager
                                                createdAt:now];

    clickBuilder.deeplinkParameters = [adtraceDeepLinks copy];
    clickBuilder.attribution = deeplinkAttribution;
    clickBuilder.clickTime = clickTime;
    clickBuilder.deeplink = [url absoluteString];

    ADTActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"deeplink"];
    [selfI.sdkClickHandler sendSdkClick:clickPackage];
}

- (BOOL)readDeeplinkQueryStringI:(ADTActivityHandler *)selfI
                     queryString:(NSString *)queryString
                 adtraceDeepLinks:(NSMutableDictionary*)adtraceDeepLinks
                     attribution:(ADTAttribution *)deeplinkAttribution
{
    NSArray* pairComponents = [queryString componentsSeparatedByString:@"="];
    if (pairComponents.count != 2) return NO;

    NSString* key = [pairComponents objectAtIndex:0];
    if (![key hasPrefix:kAdtracePrefix]) return NO;

    NSString* keyDecoded = [key adtUrlDecode];

    NSString* value = [pairComponents objectAtIndex:1];
    if (value.length == 0) return NO;

    NSString* valueDecoded = [value adtUrlDecode];
    if (!valueDecoded) return NO;

    NSString* keyWOutPrefix = [keyDecoded substringFromIndex:kAdtracePrefix.length];
    if (keyWOutPrefix.length == 0) return NO;

    if (![selfI trySetAttributionDeeplink:deeplinkAttribution withKey:keyWOutPrefix withValue:valueDecoded]) {
        [adtraceDeepLinks setObject:valueDecoded forKey:keyWOutPrefix];
    }

    return YES;
}

- (BOOL)trySetAttributionDeeplink:(ADTAttribution *)deeplinkAttribution
                          withKey:(NSString *)key
                        withValue:(NSString*)value
{
    if ([key isEqualToString:@"tracker"]) {
        deeplinkAttribution.trackerName = value;
        return YES;
    }

    if ([key isEqualToString:@"campaign"]) {
        deeplinkAttribution.campaign = value;
        return YES;
    }

    if ([key isEqualToString:@"adgroup"]) {
        deeplinkAttribution.adgroup = value;
        return YES;
    }

    if ([key isEqualToString:@"creative"]) {
        deeplinkAttribution.creative = value;
        return YES;
    }

    return NO;
}

- (void)setDeviceTokenI:(ADTActivityHandler *)selfI
            deviceToken:(NSData *)deviceToken {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    NSString *deviceTokenString = [ADTUtil convertDeviceToken:deviceToken];

    if (deviceTokenString == nil) {
        return;
    }

    if ([deviceTokenString isEqualToString:selfI.activityState.deviceToken]) {
        return;
    }

    // save new push token
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.deviceToken = deviceTokenString;
    }];
    [selfI writeActivityStateI:selfI];

    // send info package
    double now = [NSDate.date timeIntervalSince1970];
    ADTPackageBuilder *infoBuilder = [[ADTPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                                activityState:selfI.activityState
                                                config:selfI.adtraceConfig
                                                sessionParameters:selfI.sessionParameters
                                                trackingStatusManager:self.trackingStatusManager
                                                createdAt:now];

    ADTActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"push"];

    [selfI.packageHandler addPackage:infoPackage];

    // if push token was cached, remove it
    [ADTUserDefaults removePushToken];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered info %@", infoPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)setPushTokenI:(ADTActivityHandler *)selfI
            pushToken:(NSString *)pushToken {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }
    if (pushToken == nil) {
        return;
    }
    if ([pushToken isEqualToString:selfI.activityState.deviceToken]) {
        return;
    }

    // save new push token
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.deviceToken = pushToken;
    }];
    [selfI writeActivityStateI:selfI];

    // send info package
    double now = [NSDate.date timeIntervalSince1970];
    ADTPackageBuilder *infoBuilder = [[ADTPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                                activityState:selfI.activityState
                                                config:selfI.adtraceConfig
                                                sessionParameters:selfI.sessionParameters
                                                trackingStatusManager:self.trackingStatusManager
                                                createdAt:now];

    ADTActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"push"];
    [selfI.packageHandler addPackage:infoPackage];

    // if push token was cached, remove it
    [ADTUserDefaults removePushToken];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered info %@", infoPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)setGdprForgetMeI:(ADTActivityHandler *)selfI {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten == YES) {
        [ADTUserDefaults removeGdprForgetMe];
        return;
    }

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.isGdprForgotten = YES;
    }];
    [selfI writeActivityStateI:selfI];

    // Send GDPR package
    double now = [NSDate.date timeIntervalSince1970];
    ADTPackageBuilder *gdprBuilder = [[ADTPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                            activityState:selfI.activityState
                                            config:selfI.adtraceConfig
                                            sessionParameters:selfI.sessionParameters
                                            trackingStatusManager:self.trackingStatusManager
                                            createdAt:now];

    ADTActivityPackage *gdprPackage = [gdprBuilder buildGdprPackage];
    [selfI.packageHandler addPackage:gdprPackage];

    [ADTUserDefaults removeGdprForgetMe];

    if (selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.logger info:@"Buffered gdpr %@", gdprPackage.suffix];
    } else {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)setTrackingStateOptedOutI:(ADTActivityHandler *)selfI {
    // In case of web opt out, once response from backend arrives isGdprForgotten field in this moment defaults to NO.
    // Set it to YES regardless of state, since at this moment it should be YES.
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.isGdprForgotten = YES;
    }];
    [selfI writeActivityStateI:selfI];

    [selfI setEnabled:NO];
    [selfI.packageHandler flush];
}

#pragma mark - private

- (BOOL)isEnabledI:(ADTActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.enabled;
    } else {
        return [selfI.internalState isEnabled];
    }
}

- (BOOL)isGdprForgottenI:(ADTActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.isGdprForgotten;
    } else {
        return NO;
    }
}

- (BOOL)itHasToUpdatePackagesI:(ADTActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.updatePackages;
    } else {
        return [selfI.internalState itHasToUpdatePackages];
    }
}

// returns whether or not the activity state should be written
- (BOOL)updateActivityStateI:(ADTActivityHandler *)selfI
                         now:(double)now {
    if (![selfI checkActivityStateI:selfI]) return NO;

    double lastInterval = now - selfI.activityState.lastActivity;

    // ignore late updates
    if (lastInterval > kSessionInterval) return NO;

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.lastActivity = now;
    }];

    if (lastInterval < 0) {
        [selfI.logger error:@"Time travel!"];
        return YES;
    } else {
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.sessionLength += lastInterval;
            selfI.activityState.timeSpent += lastInterval;
        }];
    }

    return YES;
}

- (void)writeActivityStateI:(ADTActivityHandler *)selfI
{
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        if (selfI.activityState == nil) {
            return;
        }
        [ADTUtil writeObject:selfI.activityState
                    fileName:kActivityStateFilename
                  objectName:@"Activity state"
                  syncObject:[ADTActivityState class]];
    }];
}

- (void)teardownActivityStateS
{
    @synchronized ([ADTActivityState class]) {
        if (self.activityState == nil) {
            return;
        }
        self.activityState = nil;
    }
}

- (void)writeAttributionI:(ADTActivityHandler *)selfI {
    @synchronized ([ADTAttribution class]) {
        if (selfI.attribution == nil) {
            return;
        }
        [ADTUtil writeObject:selfI.attribution
                    fileName:kAttributionFilename
                  objectName:@"Attribution"
                  syncObject:[ADTAttribution class]];
    }
}

- (void)teardownAttributionS
{
    @synchronized ([ADTAttribution class]) {
        if (self.attribution == nil) {
            return;
        }
        self.attribution = nil;
    }
}

- (void)readActivityState {
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        [NSKeyedUnarchiver setClass:[ADTActivityState class] forClassName:@"AIActivityState"];
        self.activityState = [ADTUtil readObject:kActivityStateFilename
                                      objectName:@"Activity state"
                                           class:[ADTActivityState class]
                                      syncObject:[ADTActivityState class]];
    }];
}

- (void)readAttribution {
    self.attribution = [ADTUtil readObject:kAttributionFilename
                                objectName:@"Attribution"
                                     class:[ADTAttribution class]
                                syncObject:[ADTAttribution class]];
}

- (void)writeSessionCallbackParametersI:(ADTActivityHandler *)selfI {
    @synchronized ([ADTSessionParameters class]) {
        if (selfI.sessionParameters == nil) {
            return;
        }
        [ADTUtil writeObject:selfI.sessionParameters.callbackParameters
                    fileName:kSessionCallbackParametersFilename
                  objectName:@"Session Callback parameters"
                  syncObject:[ADTSessionParameters class]];
    }
}

- (void)writeSessionPartnerParametersI:(ADTActivityHandler *)selfI {
    @synchronized ([ADTSessionParameters class]) {
        if (selfI.sessionParameters == nil) {
            return;
        }
        [ADTUtil writeObject:selfI.sessionParameters.partnerParameters
                    fileName:kSessionPartnerParametersFilename
                  objectName:@"Session Partner parameters"
                  syncObject:[ADTSessionParameters class]];
    }
}

- (void)teardownAllSessionParametersS {
    @synchronized ([ADTSessionParameters class]) {
        if (self.sessionParameters == nil) {
            return;
        }
        [self.sessionParameters.callbackParameters removeAllObjects];
        [self.sessionParameters.partnerParameters removeAllObjects];
        self.sessionParameters = nil;
    }
}

- (void)readSessionCallbackParametersI:(ADTActivityHandler *)selfI {
    selfI.sessionParameters.callbackParameters = [ADTUtil readObject:kSessionCallbackParametersFilename
                                                         objectName:@"Session Callback parameters"
                                                              class:[NSDictionary class]
                                                         syncObject:[ADTSessionParameters class]];
}

- (void)readSessionPartnerParametersI:(ADTActivityHandler *)selfI {
    selfI.sessionParameters.partnerParameters = [ADTUtil readObject:kSessionPartnerParametersFilename
                                                        objectName:@"Session Partner parameters"
                                                             class:[NSDictionary class]
                                                        syncObject:[ADTSessionParameters class]];
}

# pragma mark - handlers status
- (void)updateHandlersStatusAndSendI:(ADTActivityHandler *)selfI {
    // check if it should stop sending
    if (![selfI toSendI:selfI]) {
        [selfI pauseSendingI:selfI];
        return;
    }

    [selfI resumeSendingI:selfI];

    // try to send if it's the first launch and it hasn't received the session response
    //  even if event buffering is enabled
    if ([selfI.internalState isFirstLaunch] &&
        [selfI.internalState hasSessionResponseNotBeenProcessed])
    {
        [selfI.packageHandler sendFirstPackage];
    }

    // try to send
    if (!selfI.adtraceConfig.eventBufferingEnabled) {
        [selfI.packageHandler sendFirstPackage];
    }
}

- (void)pauseSendingI:(ADTActivityHandler *)selfI {
    [selfI.attributionHandler pauseSending];
    [selfI.packageHandler pauseSending];
    // the conditions to pause the sdk click handler are less restrictive
    // it's possible for the sdk click handler to be active while others are paused
    if (![selfI toSendI:selfI sdkClickHandlerOnly:YES]) {
        [selfI.sdkClickHandler pauseSending];
    } else {
        [selfI.sdkClickHandler resumeSending];
    }
}

- (void)resumeSendingI:(ADTActivityHandler *)selfI {
    [selfI.attributionHandler resumeSending];
    [selfI.packageHandler resumeSending];
    [selfI.sdkClickHandler resumeSending];
}

- (BOOL)pausedI:(ADTActivityHandler *)selfI {
    return [selfI pausedI:selfI sdkClickHandlerOnly:NO];
}

- (BOOL)pausedI:(ADTActivityHandler *)selfI
sdkClickHandlerOnly:(BOOL)sdkClickHandlerOnly
{
    if (sdkClickHandlerOnly) {
        // sdk click handler is paused if either:
        return [selfI.internalState isOffline] ||    // it's offline
         ![selfI isEnabledI:selfI];                  // is disabled
    }
    // other handlers are paused if either:
    return [selfI.internalState isOffline] ||        // it's offline
            ![selfI isEnabledI:selfI] ||             // is disabled
            [selfI.internalState isInDelayedStart];      // is in delayed start
}

- (BOOL)toSendI:(ADTActivityHandler *)selfI {
    return [selfI toSendI:selfI sdkClickHandlerOnly:NO];
}

- (BOOL)toSendI:(ADTActivityHandler *)selfI
sdkClickHandlerOnly:(BOOL)sdkClickHandlerOnly
{
    // don't send when it's paused
    if ([selfI pausedI:selfI sdkClickHandlerOnly:sdkClickHandlerOnly]) {
        return NO;
    }

    // has the option to send in the background -> is to send
    if (selfI.adtraceConfig.sendInBackground) {
        return YES;
    }

    // doesn't have the option -> depends on being on the background/foreground
    return [selfI.internalState isInForeground];
}

- (void)setAskingAttributionI:(ADTActivityHandler *)selfI
            askingAttribution:(BOOL)askingAttribution
{
    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        selfI.activityState.askingAttribution = askingAttribution;
    }];
    [selfI writeActivityStateI:selfI];
}

# pragma mark - timer
- (void)startForegroundTimerI:(ADTActivityHandler *)selfI {
    // don't start the timer when it's disabled
    if (![selfI isEnabledI:selfI]) {
        return;
    }

    [selfI.foregroundTimer resume];
}

- (void)stopForegroundTimerI:(ADTActivityHandler *)selfI {
    [selfI.foregroundTimer suspend];
}

- (void)foregroundTimerFiredI:(ADTActivityHandler *)selfI {
    // stop the timer cycle when it's disabled
    if (![selfI isEnabledI:selfI]) {
        [selfI stopForegroundTimerI:selfI];
        return;
    }

    if ([selfI toSendI:selfI]) {
        [selfI.packageHandler sendFirstPackage];
    }

    double now = [NSDate.date timeIntervalSince1970];
    if ([selfI updateActivityStateI:selfI now:now]) {
        [selfI writeActivityStateI:selfI];
    }

    [selfI.trackingStatusManager checkForNewAttStatus];
}

- (void)startBackgroundTimerI:(ADTActivityHandler *)selfI {
    if (selfI.backgroundTimer == nil) {
        return;
    }

    // check if it can send in the background
    if (![selfI toSendI:selfI]) {
        return;
    }

    // background timer already started
    if ([selfI.backgroundTimer fireIn] > 0) {
        return;
    }

    [selfI.backgroundTimer startIn:kBackgroundTimerInterval];
}

- (void)stopBackgroundTimerI:(ADTActivityHandler *)selfI {
    if (selfI.backgroundTimer == nil) {
        return;
    }

    [selfI.backgroundTimer cancel];
}

- (void)backgroundTimerFiredI:(ADTActivityHandler *)selfI {
    if ([selfI toSendI:selfI]) {
        [selfI.packageHandler sendFirstPackage];
    }
}

#pragma mark - delay
- (void)delayStartI:(ADTActivityHandler *)selfI {
    // it's not configured to start delayed or already finished
    if ([selfI.internalState isNotInDelayedStart]) {
        return;
    }

    // the delay has already started
    if ([selfI itHasToUpdatePackagesI:selfI]) {
        return;
    }

    // check against max start delay
    double delayStart = selfI.adtraceConfig.delayStart;
    double maxDelayStart = [ADTAdtraceFactory maxDelayStart];

    if (delayStart > maxDelayStart) {
        NSString * delayStartFormatted = [ADTUtil secondsNumberFormat:delayStart];
        NSString * maxDelayStartFormatted = [ADTUtil secondsNumberFormat:maxDelayStart];

        [selfI.logger warn:@"Delay start of %@ seconds bigger than max allowed value of %@ seconds", delayStartFormatted, maxDelayStartFormatted];
        delayStart = maxDelayStart;
    }

    NSString * delayStartFormatted = [ADTUtil secondsNumberFormat:delayStart];
    [selfI.logger info:@"Waiting %@ seconds before starting first session", delayStartFormatted];

    [selfI.delayStartTimer startIn:delayStart];

    selfI.internalState.updatePackages = YES;

    if (selfI.activityState != nil) {
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.updatePackages = YES;
        }];
        [selfI writeActivityStateI:selfI];
    }
}

- (void)sendFirstPackagesI:(ADTActivityHandler *)selfI {
    if ([selfI.internalState isNotInDelayedStart]) {
        [selfI.logger info:@"Start delay expired or never configured"];
        return;
    }
    // update packages in queue
    [selfI updatePackagesI:selfI];
    // no longer is in delay start
    selfI.internalState.delayStart = NO;
    // cancel possible still running timer if it was called by user
    [selfI.delayStartTimer cancel];
    // and release timer
    selfI.delayStartTimer = nil;
    // update the status and try to send first package
    [selfI updateHandlersStatusAndSendI:selfI];
}

- (void)updatePackagesI:(ADTActivityHandler *)selfI {
    // update activity packages
    [selfI.packageHandler updatePackages:selfI.sessionParameters];
    // no longer needs to update packages
    selfI.internalState.updatePackages = NO;
    if (selfI.activityState != nil) {
        [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                        block:^{
            selfI.activityState.updatePackages = NO;
        }];
        [selfI writeActivityStateI:selfI];
    }
}

#pragma mark - session parameters
- (void)addSessionCallbackParameterI:(ADTActivityHandler *)selfI
                                 key:(NSString *)key
                              value:(NSString *)value
{
    if (![ADTUtil isValidParameter:key
                  attributeType:@"key"
                  parameterName:@"Session Callback"]) return;

    if (![ADTUtil isValidParameter:value
                  attributeType:@"value"
                  parameterName:@"Session Callback"]) return;

    if (selfI.sessionParameters.callbackParameters == nil) {
        selfI.sessionParameters.callbackParameters = [NSMutableDictionary dictionary];
    }

    NSString * oldValue = [selfI.sessionParameters.callbackParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:value]) {
            [selfI.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [selfI.logger warn:@"Key %@ will be overwritten", key];
    }

    [selfI.sessionParameters.callbackParameters setObject:value forKey:key];

    [selfI writeSessionCallbackParametersI:selfI];
}

- (void)addSessionPartnerParameterI:(ADTActivityHandler *)selfI
                               key:(NSString *)key
                             value:(NSString *)value
{
    if (![ADTUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Partner"]) return;

    if (![ADTUtil isValidParameter:value
                     attributeType:@"value"
                     parameterName:@"Session Partner"]) return;

    if (selfI.sessionParameters.partnerParameters == nil) {
        selfI.sessionParameters.partnerParameters = [NSMutableDictionary dictionary];
    }

    NSString * oldValue = [selfI.sessionParameters.partnerParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:value]) {
            [selfI.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [selfI.logger warn:@"Key %@ will be overwritten", key];
    }


    [selfI.sessionParameters.partnerParameters setObject:value forKey:key];

    [selfI writeSessionPartnerParametersI:selfI];
}

- (void)removeSessionCallbackParameterI:(ADTActivityHandler *)selfI
                                    key:(NSString *)key {
    if (![ADTUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Callback"]) return;

    if (selfI.sessionParameters.callbackParameters == nil) {
        [selfI.logger warn:@"Session Callback parameters are not set"];
        return;
    }

    NSString * oldValue = [selfI.sessionParameters.callbackParameters objectForKey:key];
    if (oldValue == nil) {
        [selfI.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [selfI.logger debug:@"Key %@ will be removed", key];
    [selfI.sessionParameters.callbackParameters removeObjectForKey:key];
    [selfI writeSessionCallbackParametersI:selfI];
}

- (void)removeSessionPartnerParameterI:(ADTActivityHandler *)selfI
                                   key:(NSString *)key {
    if (![ADTUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Partner"]) return;

    if (selfI.sessionParameters.partnerParameters == nil) {
        [selfI.logger warn:@"Session Partner parameters are not set"];
        return;
    }

    NSString * oldValue = [selfI.sessionParameters.partnerParameters objectForKey:key];
    if (oldValue == nil) {
        [selfI.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [selfI.logger debug:@"Key %@ will be removed", key];
    [selfI.sessionParameters.partnerParameters removeObjectForKey:key];
    [selfI writeSessionPartnerParametersI:selfI];
}

- (void)resetSessionCallbackParametersI:(ADTActivityHandler *)selfI {
    if (selfI.sessionParameters.callbackParameters == nil) {
        [selfI.logger warn:@"Session Callback parameters are not set"];
        return;
    }
    selfI.sessionParameters.callbackParameters = nil;
    [selfI writeSessionCallbackParametersI:selfI];
}

- (void)resetSessionPartnerParametersI:(ADTActivityHandler *)selfI {
    if (selfI.sessionParameters.partnerParameters == nil) {
        [selfI.logger warn:@"Session Partner parameters are not set"];
        return;
    }
    selfI.sessionParameters.partnerParameters = nil;
    [selfI writeSessionPartnerParametersI:selfI];
}

- (void)preLaunchActionsI:(ADTActivityHandler *)selfI
    preLaunchActionsArray:(NSArray*)preLaunchActionsArray
{
    if (preLaunchActionsArray == nil) {
        return;
    }
    for (activityHandlerBlockI activityHandlerActionI in preLaunchActionsArray) {
        activityHandlerActionI(selfI);
    }
}

#pragma mark - notifications
- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(applicationWillResignActive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

- (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - checks

- (BOOL)checkTransactionIdI:(ADTActivityHandler *)selfI
              transactionId:(NSString *)transactionId {
    if (transactionId == nil || transactionId.length == 0) {
        return YES; // no transaction ID given
    }

    if ([selfI.activityState findTransactionId:transactionId]) {
        [selfI.logger info:@"Skipping duplicate transaction ID '%@'", transactionId];
        [selfI.logger verbose:@"Found transaction ID in %@", selfI.activityState.transactionIds];
        return NO; // transaction ID found -> used already
    }
    
    [selfI.activityState addTransactionId:transactionId];
    [selfI.logger verbose:@"Added transaction ID %@", selfI.activityState.transactionIds];
    // activity state will get written by caller
    return YES;
}

- (BOOL)checkEventI:(ADTActivityHandler *)selfI
              event:(ADTEvent *)event {
    if (event == nil) {
        [selfI.logger error:@"Event missing"];
        return NO;
    }

    if (![event isValid]) {
        [selfI.logger error:@"Event not initialized correctly"];
        return NO;
    }

    return YES;
}

- (BOOL)checkActivityStateI:(ADTActivityHandler *)selfI {
    if (selfI.activityState == nil) {
        [selfI.logger error:@"Missing activity state"];
        return NO;
    }
    return YES;
}

- (BOOL)checkAdRevenueI:(ADTActivityHandler *)selfI
              adRevenue:(ADTAdRevenue *)adRevenue {
    if (adRevenue == nil) {
        [selfI.logger error:@"Ad revenue missing"];
        return NO;
    }

    if (![adRevenue isValid]) {
        [selfI.logger error:@"Ad revenue not initialized correctly"];
        return NO;
    }

    return YES;
}

- (void)registerForSKAdNetworkAttribution {
    if (!self.adtraceConfig.isSKAdNetworkHandlingActive) {
        return;
    }
    id<ADTLogger> logger = [ADTAdtraceFactory logger];
    
    Class skAdNetwork = NSClassFromString(@"SKAdNetwork");
    if (skAdNetwork == nil) {
        [logger warn:@"StoreKit framework not found in the app (SKAdNetwork not found)"];
        return;
    }
    
    SEL registerAttributionSelector = NSSelectorFromString(@"registerAppForAdNetworkAttribution");
    if ([skAdNetwork respondsToSelector:registerAttributionSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [skAdNetwork performSelector:registerAttributionSelector];
#pragma clang diagnostic pop
        [logger verbose:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method made"];
        
        // store timestamp of when register call was successfully made
        NSDate *callTime = [NSDate date];
        [ADTUserDefaults saveSkadRegisterCallTimestamp:callTime];
    }
}

- (void)checkConversionValue:(ADTResponseData *)responseData {
    if (!self.adtraceConfig.isSKAdNetworkHandlingActive) {
        return;
    }
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSNumber *conversionValue = [responseData.jsonResponse objectForKey:@"skadn_conv_value"];

    if (!conversionValue) {
        return;
    }
    
    [ADTUtil updateSkAdNetworkConversionValue:conversionValue];

    if ([self.adtraceDelegate respondsToSelector:@selector(adtraceConversionValueUpdated:)]) {
        [self.logger debug:@"Launching conversion value updated delegate"];
        [ADTUtil launchInMainThread:self.adtraceDelegate
                           selector:@selector(adtraceConversionValueUpdated:)
                         withObject:conversionValue];
    }
}

- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser {
    [self.trackingStatusManager updateAttStatusFromUserCallback:newAttStatusFromUser];
}

@end

@interface ADTTrackingStatusManager ()

@property (nonatomic, readonly, weak) ADTActivityHandler *activityHandler;

@end

@implementation ADTTrackingStatusManager
// constructors
- (instancetype)initWithActivityHandler:(ADTActivityHandler *)activityHandler {
    self = [super init];

    _activityHandler = activityHandler;

    return self;
}
// public api
- (BOOL)canGetAttStatus {
    if (@available(iOS 14.0, tvOS 14.0, *)) {
        return YES;
    }
    return NO;
}

- (BOOL)trackingEnabled {
    return [ADTUtil trackingEnabled];
}

- (int)attStatus {
    int readAttStatus = [ADTUtil attStatus];
    [self updateAttStatus:readAttStatus];
    return readAttStatus;
}

- (void)checkForNewAttStatus {
    int readAttStatus = [ADTUtil attStatus];
    BOOL didUpdateAttStatus = [self updateAttStatus:readAttStatus];
    if (!didUpdateAttStatus) {
        return;
    }
    [self.activityHandler trackAttStatusUpdate];
}
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser {
    BOOL didUpdateAttStatus = [self updateAttStatus:newAttStatusFromUser];
    if (!didUpdateAttStatus) {
        return;
    }
    [self.activityHandler trackAttStatusUpdate];
}

// internal methods
- (BOOL)updateAttStatus:(int)readAttStatus {
    if (readAttStatus < 0) {
        return NO;
    }

    if (self.activityHandler == nil || self.activityHandler.activityState == nil) {
        return NO;
    }

    if (readAttStatus == self.activityHandler.activityState.trackingManagerAuthorizationStatus) {
        return NO;
    }

    [ADTUtil launchSynchronisedWithObject:[ADTActivityState class]
                                    block:^{
        self.activityHandler.activityState.trackingManagerAuthorizationStatus = readAttStatus;
    }];
    [self.activityHandler writeActivityState];

    return YES;
}
@end
