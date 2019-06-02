#import <Foundation/Foundation.h>

@interface ADTSystemProfile : NSObject

+ (BOOL) is64bit;
+ (NSString*) cpuFamily;
+ (NSString*) osVersion;
+ (int) cpuCount;
+ (NSString*) machineArch;
+ (NSString*) machineModel;
+ (NSString*) cpuBrand;
+ (NSString*) cpuFeatures;
+ (NSString*) cpuVendor;
+ (NSString*) appleLanguage;
+ (long long) cpuSpeed;
+ (long long) ramsize;
+ (NSString*) cpuType;
+ (NSString*) cpuSubtype;
@end
