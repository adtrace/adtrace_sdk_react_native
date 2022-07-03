//
//  ADTPackageBuilder.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTEvent.h"
#import "ADTConfig.h"
#import "ADTPackageParams.h"
#import "ADTActivityState.h"
#import "ADTActivityPackage.h"
#import "ADTSessionParameters.h"
#import <Foundation/Foundation.h>
#import "ADTActivityHandler.h"
#import "ADTThirdPartySharing.h"

@interface ADTPackageBuilder : NSObject

@property (nonatomic, copy) NSString * _Nullable deeplink;

@property (nonatomic, copy) NSDate * _Nullable clickTime;

@property (nonatomic, copy) NSDate * _Nullable purchaseTime;

@property (nonatomic, strong) NSDictionary * _Nullable attributionDetails;

@property (nonatomic, strong) NSDictionary * _Nullable deeplinkParameters;

@property (nonatomic, copy) ADTAttribution * _Nullable attribution;

- (id _Nullable)initWithPackageParams:(ADTPackageParams * _Nullable)packageParams
                        activityState:(ADTActivityState * _Nullable)activityState
                               config:(ADTConfig * _Nullable)adtraceConfig
                    sessionParameters:(ADTSessionParameters * _Nullable)sessionParameters
                trackingStatusManager:(ADTTrackingStatusManager * _Nullable)trackingStatusManager
                            createdAt:(double)createdAt;

- (ADTActivityPackage * _Nullable)buildSessionPackage:(BOOL)isInDelay;

- (ADTActivityPackage * _Nullable)buildEventPackage:(ADTEvent * _Nullable)event
                                isInDelay:(BOOL)isInDelay;

- (ADTActivityPackage * _Nullable)buildInfoPackage:(NSString * _Nullable)infoSource;

- (ADTActivityPackage * _Nullable)buildAdRevenuePackage:(NSString * _Nullable)source
                                                payload:(NSData * _Nullable)payload;

- (ADTActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource;

- (ADTActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource
                                              token:(NSString * _Nullable)token
                                    errorCodeNumber:(NSNumber * _Nullable)errorCodeNumber;

- (ADTActivityPackage * _Nullable)buildAttributionPackage:(NSString * _Nullable)initiatedBy;

- (ADTActivityPackage * _Nullable)buildGdprPackage;

- (ADTActivityPackage * _Nullable)buildDisableThirdPartySharingPackage;

- (ADTActivityPackage * _Nullable)buildThirdPartySharingPackage:(nonnull ADTThirdPartySharing *)thirdPartySharing;

- (ADTActivityPackage * _Nullable)buildMeasurementConsentPackage:(BOOL)enabled;

- (ADTActivityPackage * _Nullable)buildSubscriptionPackage:( ADTSubscription * _Nullable)subscription
                                                 isInDelay:(BOOL)isInDelay;

- (ADTActivityPackage * _Nullable)buildAdRevenuePackage:(ADTAdRevenue * _Nullable)adRevenue
                                              isInDelay:(BOOL)isInDelay;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
     setDictionary:(NSDictionary * _Nullable)dictionary
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
         setString:(NSString * _Nullable)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
            setInt:(int)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
       setDate1970:(double)value
            forKey:(NSString * _Nullable)key;

+ (BOOL)isAdServicesPackage:(ADTActivityPackage * _Nullable)activityPackage;

@end
// TODO change to ADT...
extern NSString * _Nullable const ADTAttributionTokenParameter;
