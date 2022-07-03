//
//  ADTUtil.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADTEvent.h"
#import "ADTConfig.h"
#import "ADTActivityKind.h"
#import "ADTResponseData.h"
#import "ADTActivityPackage.h"
#import "ADTBackoffStrategy.h"
#import "ADTActivityHandler.h"

typedef void (^selfInjectedBlock)(id);
typedef void (^synchronisedBlock)(void);
typedef void (^isInactiveInjected)(BOOL);

@interface ADTUtil : NSObject

+ (void)teardown;

+ (id)readObject:(NSString *)fileName
      objectName:(NSString *)objectName
           class:(Class)classToRead
      syncObject:(id)syncObject;

+ (void)excludeFromBackup:(NSString *)filename;

+ (void)launchDeepLinkMain:(NSURL *)deepLinkUrl NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void)launchInMainThread:(dispatch_block_t)block;

+ (BOOL)isMainThread;

+ (BOOL)isInactive NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void)launchInMainThreadWithInactive:(isInactiveInjected)isInactiveblock;

+ (void)updateUrlSessionConfiguration:(ADTConfig *)config;

+ (void)writeObject:(id)object
           fileName:(NSString *)fileName
         objectName:(NSString *)objectName
         syncObject:(id)syncObject;

+ (void)launchInMainThread:(NSObject *)receiver
                  selector:(SEL)selector
                withObject:(id)object;

+ (void)launchInQueue:(dispatch_queue_t)queue
           selfInject:(id)selfInject
                block:(selfInjectedBlock)block;

+ (void)launchSynchronisedWithObject:(id)synchronisationObject
                               block:(synchronisedBlock)block;

+ (NSString *)clientSdk;

+ (NSString *)formatDate:(NSDate *)value;

+ (NSString *)formatSeconds1970:(double)value;

+ (NSString *)secondsNumberFormat:(double)seconds;

+ (NSString *)queryString:(NSDictionary *)parameters;

+ (NSString *)queryString:(NSDictionary *)parameters
                queueSize:(NSUInteger)queueSize;

+ (NSString *)convertDeviceToken:(NSData *)deviceToken;

+ (BOOL)isNull:(id)value;

+ (BOOL)isNotNull:(id)value;

+ (BOOL)deleteFileWithName:(NSString *)filename;

+ (BOOL)checkAttributionDetails:(NSDictionary *)attributionDetails;

+ (BOOL)isValidParameter:(NSString *)attribute
           attributeType:(NSString *)attributeType
           parameterName:(NSString *)parameterName;

+ (NSDictionary *)convertDictionaryValues:(NSDictionary *)dictionary;

+ (NSDictionary *)mergeParameters:(NSDictionary *)target
                           source:(NSDictionary *)source
                    parameterName:(NSString *)parameterName;

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme;

+ (NSTimeInterval)waitingTime:(NSInteger)retries
              backoffStrategy:(ADTBackoffStrategy *)backoffStrategy;

+ (BOOL)isDeeplinkValid:(NSURL *)url;

+ (NSString *)sdkVersion;

+ (void)updateSkAdNetworkConversionValue:(NSNumber *)conversionValue;

+ (Class)adSupportManager;

+ (Class)appTrackingManager;

+ (BOOL)trackingEnabled;

+ (NSString *)idfa;

+ (NSString *)idfv;

+ (NSString *)fbAnonymousId;

+ (NSString *)deviceType;

+ (NSString *)deviceName;

+ (NSUInteger)startedAt;

+ (int)attStatus;

+ (NSString *)fetchAdServicesAttribution:(NSError **)errorPtr;

+ (void)checkForiAd:(ADTActivityHandler *)activityHandler queue:(dispatch_queue_t)queue;

+ (BOOL)setiAdWithDetails:(ADTActivityHandler *)activityHandler
   adClientSharedInstance:(id)ADClientSharedClientInstance
                    queue:(dispatch_queue_t)queue;

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion;

+ (NSString *)bundleIdentifier;

+ (NSString *)buildNumber;

+ (NSString *)versionNumber;

+ (NSString *)osVersion;

+ (NSString *)installedAt;

+ (NSString *)generateRandomUuid;

+ (NSString *)getPersistedRandomToken;

+ (BOOL)setPersistedRandomToken:(NSString *)randomToken;

@end
