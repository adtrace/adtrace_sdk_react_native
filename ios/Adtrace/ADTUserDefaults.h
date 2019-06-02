//
//  ADTUserDefaults.h
//  Adtrace
//

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

+ (void)clearAdtraceStuff;

@end
