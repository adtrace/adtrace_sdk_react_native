//
//  ADTPackageParams.m
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADTPackageParams.h"
#import "ADTUtil.h"

@implementation ADTPackageParams

+ (ADTPackageParams *) packageParamsWithSdkPrefix:(NSString *)sdkPrefix {
    return [[ADTPackageParams alloc] initWithSdkPrefix:sdkPrefix];
}

- (id)initWithSdkPrefix:(NSString *)sdkPrefix {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.osName = @"ios";
    self.idfv = [ADTUtil idfv];
    self.fbAnonymousId = [ADTUtil fbAnonymousId];
    self.bundleIdentifier = [ADTUtil bundleIdentifier];
    self.buildNumber = [ADTUtil buildNumber];
    self.versionNumber = [ADTUtil versionNumber];
    self.deviceType = [ADTUtil deviceType];
    self.deviceName = [ADTUtil deviceName];
    self.osVersion = [ADTUtil osVersion];
    self.installedAt = [ADTUtil installedAt];
    self.startedAt = [ADTUtil startedAt];
    if (sdkPrefix == nil) {
        self.clientSdk = ADTUtil.clientSdk;
    } else {
        self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, ADTUtil.clientSdk];
    }

    return self;
}

@end
