//
//  UIDevice+ADTAdditions.h
//  Adtrace
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADTActivityHandler.h"

@interface UIDevice(ADTAdditions)

- (BOOL)adtTrackingEnabled;
- (NSString *)adtIdForAdvertisers;
- (NSString *)adtFbAttributionId;
- (NSString *)adtDeviceType;
- (NSString *)adtDeviceName;
- (NSString *)adtCreateUuid;
- (NSString *)adtVendorId;
- (void)adtSetIad:(ADTActivityHandler *)activityHandler
      triesV3Left:(int)triesV3Left;
@end
