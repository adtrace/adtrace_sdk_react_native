
#import <Foundation/Foundation.h>

@interface ADTDeviceInfo : NSObject

@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *fbAnonymousId;
@property (nonatomic, assign) BOOL trackingEnabled;
@property (nonatomic, copy) NSString *vendorId;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, copy) NSString *bundeIdentifier;
@property (nonatomic, copy) NSString *bundleVersion;
@property (nonatomic, copy) NSString *bundleShortVersion;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *machineModel;
@property (nonatomic, copy) NSString *cpuSubtype;
@property (nonatomic, copy) NSString *installReceiptBase64;
@property (nonatomic, copy) NSString *osBuild;

- (id)initWithSdkPrefix:(NSString *)sdkPrefix;
+ (ADTDeviceInfo *)deviceInfoWithSdkPrefix:(NSString *)sdkPrefix;

@end
