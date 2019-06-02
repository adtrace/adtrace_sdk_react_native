//
//  ADTActivityHandler.h
//  Adtrace
//

#import "Adtrace.h"
#import "ADTResponseData.h"
#import "ADTActivityState.h"
#import "ADTDeviceInfo.h"
#import "ADTSessionParameters.h"

@interface ADTInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL delayStart;
@property (nonatomic, assign) BOOL updatePackages;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL sessionResponseProcessed;

- (id)init;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isInBackground;
- (BOOL)isInForeground;
- (BOOL)isInDelayedStart;
- (BOOL)isNotInDelayedStart;
- (BOOL)itHasToUpdatePackages;
- (BOOL)isFirstLaunch;
- (BOOL)hasSessionResponseNotBeenProcessed;

@end

@interface ADTSavedPreLaunch : NSObject

@property (nonatomic, strong) NSMutableArray *preLaunchActionsArray;
@property (nonatomic, copy) NSData *deviceTokenData;
@property (nonatomic, copy) NSNumber *enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, copy) NSString *gdprPath;

- (id)init;

@end

@protocol ADTActivityHandler <NSObject>

@property (nonatomic, copy) ADTAttribution *attribution;
- (NSString *)adid;

- (id)initWithConfig:(ADTConfig *)adtraceConfig
      savedPreLaunch:(ADTSavedPreLaunch *)savedPreLaunch;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADTEvent *)event;

- (void)finishedTracking:(ADTResponseData *)responseData;
- (void)launchEventResponseTasks:(ADTEventResponseData *)eventResponseData;
- (void)launchSessionResponseTasks:(ADTSessionResponseData *)sessionResponseData;
- (void)launchSdkClickResponseTasks:(ADTSdkClickResponseData *)sdkClickResponseData;
- (void)launchAttributionResponseTasks:(ADTAttributionResponseData *)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (BOOL)isGdprForgotten;

- (void)appWillOpenUrl:(NSURL*)url withClickTime:(NSDate *)clickTime;
- (void)setDeviceToken:(NSData *)deviceToken;
- (void)setPushToken:(NSString *)deviceToken;
- (void)setGdprForgetMe;
- (void)setTrackingStateOptedOut;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttributionI:(id<ADTActivityHandler>)selfI attribution:(ADTAttribution *)attribution;
- (void)setAttributionDetails:(NSDictionary *)attributionDetails
                        error:(NSError *)error
                  retriesLeft:(int)retriesLeft;

- (void)setOfflineMode:(BOOL)offline;
- (void)sendFirstPackages;

- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value;
- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value;
- (void)removeSessionCallbackParameter:(NSString *)key;
- (void)removeSessionPartnerParameter:(NSString *)key;
- (void)resetSessionCallbackParameters;
- (void)resetSessionPartnerParameters;
- (NSString *)getBasePath;
- (NSString *)getGdprPath;

- (ADTDeviceInfo *)deviceInfo;
- (ADTActivityState *)activityState;
- (ADTConfig *)adtraceConfig;
- (ADTSessionParameters *)sessionParameters;

- (void)teardown;
+ (void)deleteState;
@end

@interface ADTActivityHandler : NSObject <ADTActivityHandler>

+ (id<ADTActivityHandler>)handlerWithConfig:(ADTConfig *)adtraceConfig
                             savedPreLaunch:(ADTSavedPreLaunch *)savedPreLaunch;

- (void)addSessionCallbackParameterI:(ADTActivityHandler *)selfI
                                 key:(NSString *)key
                               value:(NSString *)value;

- (void)addSessionPartnerParameterI:(ADTActivityHandler *)selfI
                                key:(NSString *)key
                              value:(NSString *)value;
- (void)removeSessionCallbackParameterI:(ADTActivityHandler *)selfI
                                    key:(NSString *)key;
- (void)removeSessionPartnerParameterI:(ADTActivityHandler *)selfI
                                   key:(NSString *)key;
- (void)resetSessionCallbackParametersI:(ADTActivityHandler *)selfI;
- (void)resetSessionPartnerParametersI:(ADTActivityHandler *)selfI;

@end
