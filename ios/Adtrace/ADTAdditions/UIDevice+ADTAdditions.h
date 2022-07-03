//
//  UIDevice+ADTAdditions.h
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ADTDeviceInfo.h"
#import "ADTActivityHandler.h"

@interface UIDevice(ADTAdditions)

- (int)adtATTStatus;
- (BOOL)adtTrackingEnabled;
- (NSString *)adtIdForAdvertisers;
- (NSString *)adtFbAnonymousId;
- (NSString *)adtDeviceType;
- (NSString *)adtDeviceName;
- (NSString *)adtCreateUuid;
- (NSString *)adtVendorId;
- (void)adtCheckForiAd:(ADTActivityHandler *)activityHandler queue:(dispatch_queue_t)queue;
- (NSString *)adtFetchAdServicesAttribution:(NSError **)errorPtr;

- (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion;

@end
