//
//  UIDevice+ADTAdditions.m
//  Adtrace
//


#import "UIDevice+ADTAdditions.h"
#import "NSString+ADTAdditions.h"

#import <sys/sysctl.h>

#if !ADTUST_NO_IDFA
#import <AdSupport/ASIdentifierManager.h>
#endif

#if !ADTUST_NO_IAD && !TARGET_OS_TV
#import <iAd/iAd.h>
#endif

#import "ADTAdtraceFactory.h"

@implementation UIDevice(ADTAdditions)

- (BOOL)adtTrackingEnabled {
#if ADTUST_NO_IDFA
    return NO;
#else
    // return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    NSString *className = [NSString adtJoin:@"A", @"S", @"identifier", @"manager", nil];
    Class class = NSClassFromString(className);
    if (class == nil) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *keyManager = [NSString adtJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![class respondsToSelector:selManager]) {
        return NO;
    }
    id manager = [class performSelector:selManager];

    NSString *keyEnabled = [NSString adtJoin:@"is", @"advertising", @"tracking", @"enabled", nil];
    SEL selEnabled = NSSelectorFromString(keyEnabled);
    if (![manager respondsToSelector:selEnabled]) {
        return NO;
    }
    BOOL enabled = (BOOL)[manager performSelector:selEnabled];
    return enabled;
#pragma clang diagnostic pop
#endif
}

- (NSString *)adtIdForAdvertisers {
#if ADTUST_NO_IDFA
    return @"";
#else
    // return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *className = [NSString adtJoin:@"A", @"S", @"identifier", @"manager", nil];
    Class class = NSClassFromString(className);
    if (class == nil) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    NSString *keyManager = [NSString adtJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![class respondsToSelector:selManager]) {
        return @"";
    }
    id manager = [class performSelector:selManager];

    NSString *keyIdentifier = [NSString adtJoin:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (![manager respondsToSelector:selIdentifier]) {
        return @"";
    }
    id identifier = [manager performSelector:selIdentifier];

    NSString *keyString = [NSString adtJoin:@"UUID", @"string", nil];
    SEL selString = NSSelectorFromString(keyString);
    if (![identifier respondsToSelector:selString]) {
        return @"";
    }
    NSString *string = [identifier performSelector:selString];
    return string;

#pragma clang diagnostic pop
#endif
}

- (NSString *)adtFbAttributionId {
#if ADTUST_NO_UIPASTEBOARD || TARGET_OS_TV
    return @"";
#else
    __block NSString *result;
    void(^resultRetrievalBlock)(void) = ^{
        result = [UIPasteboard pasteboardWithName:@"fb_app_attribution" create:NO].string;
        if (result == nil) {
            result = @"";
        }
    };
    [NSThread isMainThread] ? resultRetrievalBlock() : dispatch_sync(dispatch_get_main_queue(), resultRetrievalBlock);
    return result;
#endif
}

- (NSString *)adtDeviceType {
    NSString *type = [self.model stringByReplacingOccurrencesOfString:@" " withString:@""];
    return type;
}

- (NSString *)adtDeviceName {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [NSString stringWithUTF8String:name];
    free(name);
    return machine;
}

- (NSString *)adtCreateUuid {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *uuidString = (__bridge_transfer NSString*)stringRef;
    NSString *lowerUuid = [uuidString lowercaseString];
    CFRelease(newUniqueId);
    return lowerUuid;
}

- (NSString *)adtVendorId {
    if ([UIDevice.currentDevice respondsToSelector:@selector(identifierForVendor)]) {
        return [UIDevice.currentDevice.identifierForVendor UUIDString];
    }
    return @"";
}

- (void)adtSetIad:(ADTActivityHandler *)activityHandler
      triesV3Left:(int)triesV3Left {
    id<ADTLogger> logger = [ADTAdtraceFactory logger];

#if ADTUST_NO_IAD || TARGET_OS_TV
    [logger debug:@"ADTUST_NO_IAD or TARGET_OS_TV set"];
    return;
#else
    [logger debug:@"ADTUST_NO_IAD or TARGET_OS_TV not set"];

    // [[ADClient sharedClient] ...]
    Class ADClientClass = NSClassFromString(@"ADClient");
    if (ADClientClass == nil) {
        [logger warn:@"iAd framework not found in user's app (ADClientClass not found)"];
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sharedClientSelector = NSSelectorFromString(@"sharedClient");
    if (![ADClientClass respondsToSelector:sharedClientSelector]) {
        [logger warn:@"iAd framework not found in user's app (sharedClient method not found)"];
        return;
    }
    id ADClientSharedClientInstance = [ADClientClass performSelector:sharedClientSelector];
    if (ADClientSharedClientInstance == nil) {
        [logger warn:@"iAd framework not found in user's app (ADClientSharedClientInstance is nil)"];
        return;
    }

    [logger debug:@"iAd framework successfully found in user's app"];
    [logger debug:@"iAd with %d tries to read v3", triesV3Left];

    // if no tries for iad v3 left, stop trying
    if (triesV3Left == 0) {
        [logger warn:@"Reached limit number of retry for iAd v3"];
        return;
    }

    BOOL isIadV3Avaliable = [self adtSetIadWithDetails:activityHandler
                          ADClientSharedClientInstance:ADClientSharedClientInstance
                                           retriesLeft:(triesV3Left - 1)];

    // if iad v3 not available
    if (!isIadV3Avaliable) {
        [logger warn:@"iAd v3 not available"];
        return;
    }
#pragma clang diagnostic pop
#endif
}

- (BOOL)adtSetIadWithDetails:(ADTActivityHandler *)activityHandler
ADClientSharedClientInstance:(id)ADClientSharedClientInstance
                 retriesLeft:(int)retriesLeft {
    SEL iadDetailsSelector = NSSelectorFromString(@"requestAttributionDetailsWithBlock:");
    if (![ADClientSharedClientInstance respondsToSelector:iadDetailsSelector]) {
        return NO;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [ADClientSharedClientInstance performSelector:iadDetailsSelector
                                       withObject:^(NSDictionary *attributionDetails, NSError *error) {
                                           [activityHandler setAttributionDetails:attributionDetails error:error retriesLeft:retriesLeft];
                                       }];
#pragma clang diagnostic pop

    return YES;
}

@end
