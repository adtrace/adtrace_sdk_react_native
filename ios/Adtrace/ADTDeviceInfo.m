//
//  ADTDeviceInfo.m
//  adtrace
//


#import "ADTDeviceInfo.h"
#import "UIDevice+ADTAdditions.h"
#import "NSString+ADTAdditions.h"
#import "ADTUtil.h"
#import "ADTSystemProfile.h"
#import "NSData+ADTAdditions.h"
#import "ADTReachability.h"

#if !TARGET_OS_TV
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#endif

@implementation ADTDeviceInfo

+ (ADTDeviceInfo *) deviceInfoWithSdkPrefix:(NSString *)sdkPrefix {
    return [[ADTDeviceInfo alloc] initWithSdkPrefix:sdkPrefix];
}

- (id)initWithSdkPrefix:(NSString *)sdkPrefix {
    self = [super init];
    if (self == nil) return nil;

    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;

    self.trackingEnabled  = UIDevice.currentDevice.adjTrackingEnabled;
    self.idForAdvertisers = UIDevice.currentDevice.adjIdForAdvertisers;
    self.fbAttributionId  = UIDevice.currentDevice.adjFbAttributionId;
    self.vendorId         = UIDevice.currentDevice.adjVendorId;
    self.bundeIdentifier  = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    self.bundleVersion    = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    self.bundleShortVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.languageCode     = [locale objectForKey:NSLocaleLanguageCode];
    self.countryCode      = [locale objectForKey:NSLocaleCountryCode];
    self.osName           = @"ios";
    self.deviceType       = device.adjDeviceType;
    self.deviceName       = device.adjDeviceName;
    self.systemVersion    = device.systemVersion;
    self.machineModel     = [ADTSystemProfile machineModel];
    self.cpuSubtype       = [ADTSystemProfile cpuSubtype];
    self.osBuild          = [ADTSystemProfile osVersion];
    
    if (sdkPrefix == nil) {
        self.clientSdk        = ADTUtil.clientSdk;
    } else {
        self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, ADTUtil.clientSdk];
    }

    [self injectInstallReceipt:bundle];

    return self;
}

- (void)injectInstallReceipt:(NSBundle *)bundle{
    @try {
        if (![bundle respondsToSelector:@selector(appStoreReceiptURL)]) {
            return;
        }
        NSURL * installReceiptLocation = [bundle appStoreReceiptURL];
        if (installReceiptLocation == nil) return;

        NSData * installReceiptData = [NSData dataWithContentsOfURL:installReceiptLocation];
        if (installReceiptData == nil) return;

        self.installReceiptBase64 = [installReceiptData adjEncodeBase64];
    } @catch (NSException *exception) {
    }
}

/*
-(id)copyWithZone:(NSZone *)zone
{
    ADTDeviceInfo* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.idForAdvertisers = [self.idForAdvertisers copyWithZone:zone];
        copy.fbAttributionId = [self.fbAttributionId copyWithZone:zone];
        copy.trackingEnabled = self.trackingEnabled;
        copy.vendorId = [self.vendorId copyWithZone:zone];
        copy.clientSdk = [self.clientSdk copyWithZone:zone];
        copy.bundeIdentifier = [self.bundeIdentifier copyWithZone:zone];
        copy.bundleVersion = [self.bundleVersion copyWithZone:zone];
        copy.bundleShortVersion = [self.bundleShortVersion copyWithZone:zone];
        copy.deviceType = [self.deviceType copyWithZone:zone];
        copy.deviceName = [self.deviceName copyWithZone:zone];
        copy.osName = [self.osName copyWithZone:zone];
        copy.systemVersion = [self.systemVersion copyWithZone:zone];
        copy.languageCode = [self.languageCode copyWithZone:zone];
        copy.countryCode = [self.countryCode copyWithZone:zone];
        copy.machineModel = [self.machineModel copyWithZone:zone];
        copy.cpuSubtype = [self.cpuSubtype copyWithZone:zone];
    }

    return copy;
}
*/

@end
