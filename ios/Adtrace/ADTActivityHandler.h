
#import "Adtrace.h"
#import "ADTResponseData.h"
#import "ADTActivityState.h"
#import "ADTPackageParams.h"
#import "ADTSessionParameters.h"
#import "ADTThirdPartySharing.h"

@interface ADTInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL delayStart;
@property (nonatomic, assign) BOOL updatePackages;
@property (nonatomic, assign) BOOL updatePackagesAttData;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL sessionResponseProcessed;
@property (nonatomic, assign) BOOL waitingForAttStatus;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isInBackground;
- (BOOL)isInForeground;
- (BOOL)isInDelayedStart;
- (BOOL)isNotInDelayedStart;
- (BOOL)itHasToUpdatePackages;
- (BOOL)itHasToUpdatePackagesAttData;
- (BOOL)isFirstLaunch;
- (BOOL)hasSessionResponseNotBeenProcessed;
- (BOOL)isWaitingForAttStatus;

@end

@interface ADTSavedPreLaunch : NSObject

@property (nonatomic, strong) NSMutableArray * _Nullable preLaunchActionsArray;
@property (nonatomic, copy) NSData *_Nullable deviceTokenData;
@property (nonatomic, copy) NSNumber *_Nullable enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, copy) NSString *_Nullable extraPath;
@property (nonatomic, strong) NSMutableArray *_Nullable preLaunchAdtraceThirdPartySharingArray;
@property (nonatomic, copy) NSNumber *_Nullable lastMeasurementConsentTracked;

- (nonnull id)init;

@end

@class ADTTrackingStatusManager;

@protocol ADTActivityHandler <NSObject>

@property (nonatomic, copy) ADTAttribution * _Nullable attribution;
@property (nonatomic, strong) ADTTrackingStatusManager * _Nullable trackingStatusManager;

- (NSString *_Nullable)adid;

- (id _Nullable)initWithConfig:(ADTConfig *_Nullable)adtraceConfig
                savedPreLaunch:(ADTSavedPreLaunch * _Nullable)savedPreLaunch
    deeplinkResolutionCallback:(AdtraceResolvedDeeplinkBlock _Nullable)deepLinkResolutionCallback;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADTEvent * _Nullable)event;

- (void)finishedTracking:(ADTResponseData * _Nullable)responseData;
- (void)launchEventResponseTasks:(ADTEventResponseData * _Nullable)eventResponseData;
- (void)launchSessionResponseTasks:(ADTSessionResponseData * _Nullable)sessionResponseData;
- (void)launchSdkClickResponseTasks:(ADTSdkClickResponseData * _Nullable)sdkClickResponseData;
- (void)launchAttributionResponseTasks:(ADTAttributionResponseData * _Nullable)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (BOOL)isGdprForgotten;

- (void)appWillOpenUrl:(NSURL * _Nullable)url
         withClickTime:(NSDate * _Nullable)clickTime;
- (void)processDeeplink:(NSURL * _Nullable)deeplink
              clickTime:(NSDate * _Nullable)clickTime
      completionHandler:(AdtraceResolvedDeeplinkBlock _Nullable)completionHandler;
- (void)setDeviceToken:(NSData * _Nullable)deviceToken;
- (void)setPushToken:(NSString * _Nullable)deviceToken;
- (void)setGdprForgetMe;
- (void)setTrackingStateOptedOut;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttributionI:(id<ADTActivityHandler> _Nullable)selfI
               attribution:(ADTAttribution * _Nullable)attribution;
- (void)setAdServicesAttributionToken:(NSString * _Nullable)token
                                error:(NSError * _Nullable)error;

- (void)setOfflineMode:(BOOL)offline;
- (void)sendFirstPackages;

- (void)addSessionCallbackParameter:(NSString * _Nullable)key
                              value:(NSString * _Nullable)value;
- (void)addSessionPartnerParameter:(NSString * _Nullable)key
                             value:(NSString * _Nullable)value;
- (void)removeSessionCallbackParameter:(NSString * _Nullable)key;
- (void)removeSessionPartnerParameter:(NSString * _Nullable)key;
- (void)resetSessionCallbackParameters;
- (void)resetSessionPartnerParameters;
- (void)trackAdRevenue:(NSString * _Nullable)soruce
               payload:(NSData * _Nullable)payload;
- (void)disableThirdPartySharing;
- (void)trackThirdPartySharing:(nonnull ADTThirdPartySharing *)thirdPartySharing;
- (void)trackMeasurementConsent:(BOOL)enabled;
- (void)trackSubscription:(ADTSubscription * _Nullable)subscription;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (void)trackAdRevenue:(ADTAdRevenue * _Nullable)adRevenue;
- (void)checkForNewAttStatus;
- (void)verifyPurchase:(nonnull ADTPurchase *)purchase
     completionHandler:(void (^_Nonnull)(ADTPurchaseVerificationResult * _Nonnull verificationResult))completionHandler;

- (ADTPackageParams * _Nullable)packageParams;
- (ADTActivityState * _Nullable)activityState;
- (ADTConfig * _Nullable)adtraceConfig;
- (ADTSessionParameters * _Nullable)sessionParameters;

- (void)teardown;
+ (void)deleteState;
@end

@interface ADTActivityHandler : NSObject <ADTActivityHandler>

- (id _Nullable)initWithConfig:(ADTConfig *_Nullable)adtraceConfig
                savedPreLaunch:(ADTSavedPreLaunch * _Nullable)savedPreLaunch
    deeplinkResolutionCallback:(AdtraceResolvedDeeplinkBlock _Nullable)deepLinkResolutionCallback;

- (void)addSessionCallbackParameterI:(ADTActivityHandler * _Nullable)selfI
                                 key:(NSString * _Nullable)key
                               value:(NSString * _Nullable)value;

- (void)addSessionPartnerParameterI:(ADTActivityHandler * _Nullable)selfI
                                key:(NSString * _Nullable)key
                              value:(NSString * _Nullable)value;
- (void)removeSessionCallbackParameterI:(ADTActivityHandler * _Nullable)selfI
                                    key:(NSString * _Nullable)key;
- (void)removeSessionPartnerParameterI:(ADTActivityHandler * _Nullable)selfI
                                   key:(NSString * _Nullable)key;
- (void)resetSessionCallbackParametersI:(ADTActivityHandler * _Nullable)selfI;
- (void)resetSessionPartnerParametersI:(ADTActivityHandler * _Nullable)selfI;

@end

@interface ADTTrackingStatusManager : NSObject

@property (nonatomic, readonly, assign) BOOL trackingEnabled;
@property (nonatomic, readonly, assign) int attStatus;

- (instancetype _Nullable)initWithActivityHandler:(ADTActivityHandler * _Nullable)activityHandler;
- (void)checkForNewAttStatus;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (BOOL)canGetAttStatus;
- (void)setAppInActiveState:(BOOL)activeState;
- (BOOL)shouldWaitForAttStatus;

@end

extern NSString * _Nullable const ADTAdServicesPackageKey;
