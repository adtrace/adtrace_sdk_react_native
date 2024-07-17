
#import <Foundation/Foundation.h>

#import "ADTLogger.h"
#import "ADTActivityPackage.h"
#import "ADTBackoffStrategy.h"
#import "ADTSdkClickHandler.h"

@interface ADTAdtraceFactory : NSObject

+ (id<ADTLogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (double)requestTimeout;
+ (NSNumber *)attStatus;
+ (NSString *)idfa;
+ (NSTimeInterval)timerInterval;
+ (NSTimeInterval)timerStart;
+ (ADTBackoffStrategy *)packageHandlerBackoffStrategy;
+ (ADTBackoffStrategy *)sdkClickHandlerBackoffStrategy;
+ (ADTBackoffStrategy *)installSessionBackoffStrategy;

+ (BOOL)testing;
+ (NSTimeInterval)maxDelayStart;
+ (NSString *)urlOverwrite;
+ (BOOL)adServicesFrameworkEnabled;

+ (void)setLogger:(id<ADTLogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setAttStatus:(NSNumber *)attStatus;
+ (void)setIdfa:(NSString *)idfa;
+ (void)setRequestTimeout:(double)requestTimeout;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;
+ (void)setTimerStart:(NSTimeInterval)timerStart;
+ (void)setPackageHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setSdkClickHandlerBackoffStrategy:(ADTBackoffStrategy *)backoffStrategy;
+ (void)setTesting:(BOOL)testing;
+ (void)setAdServicesFrameworkEnabled:(BOOL)adServicesFrameworkEnabled;
+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart;
+ (void)setUrlOverwrite:(NSString *)urlOverwrite;

+ (void)enableSigning;
+ (void)disableSigning;

+ (void)teardown:(BOOL)deleteState;
@end
