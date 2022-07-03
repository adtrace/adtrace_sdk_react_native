//
//  ADTPackageParams.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTPackageParams : NSObject

@property (nonatomic, copy) NSString *fbAnonymousId;
@property (nonatomic, copy) NSString *idfv;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *buildNumber;
@property (nonatomic, copy) NSString *versionNumber;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *osVersion;
@property (nonatomic, copy) NSString *installedAt;
@property (nonatomic, assign) NSUInteger startedAt;

- (id)initWithSdkPrefix:(NSString *)sdkPrefix;

+ (ADTPackageParams *)packageParamsWithSdkPrefix:(NSString *)sdkPrefix;

@end
