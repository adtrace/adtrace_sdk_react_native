
#import <Foundation/Foundation.h>

@interface ADTUserDefaults : NSObject

+ (void)savePushTokenData:(NSData *)pushToken;

+ (void)savePushTokenString:(NSString *)pushToken;

+ (NSData *)getPushTokenData;

+ (NSString *)getPushTokenString;

+ (void)removePushToken;

+ (void)setInstallTracked;

+ (BOOL)getInstallTracked;

+ (void)setGdprForgetMe;

+ (BOOL)getGdprForgetMe;

+ (void)removeGdprForgetMe;

+ (void)saveDeeplinkUrl:(NSURL *)deeplink
           andClickTime:(NSDate *)clickTime;

+ (NSURL *)getDeeplinkUrl;

+ (NSDate *)getDeeplinkClickTime;

+ (void)removeDeeplink;

+ (void)setDisableThirdPartySharing;

+ (BOOL)getDisableThirdPartySharing;

+ (void)removeDisableThirdPartySharing;

+ (void)clearAdtraceStuff;

+ (void)setAdServicesTracked;

+ (BOOL)getAdServicesTracked;

+ (void)saveSkadRegisterCallTimestamp:(NSDate *)callTime;

+ (NSDate *)getSkadRegisterCallTimestamp;

+ (void)setLinkMeChecked;

+ (BOOL)getLinkMeChecked;

+ (void)cacheDeeplinkUrl:(NSURL *)deeplink;

+ (NSURL *)getCachedDeeplinkUrl;

+ (BOOL)attWaitingRemainingSecondsKeyExists;

+ (void)setAttWaitingRemainingSeconds:(NSUInteger)seconds;

+ (NSUInteger)getAttWaitingRemainingSeconds;

+ (void)removeAttWaitingRemainingSeconds;


@end
