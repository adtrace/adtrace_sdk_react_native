//
//  ADTActivityPackage.h
//  Adtrace
//


#import "ADTActivityKind.h"

@interface ADTActivityPackage : NSObject <NSCoding>

// Data

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *clientSdk;

@property (nonatomic, assign) NSInteger retries;

@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, strong) NSDictionary *partnerParameters;

@property (nonatomic, strong) NSDictionary *callbackParameters;

// Logs

@property (nonatomic, copy) NSString *suffix;

@property (nonatomic, assign) ADTActivityKind activityKind;

- (NSString *)extendedString;

- (NSString *)successMessage;

- (NSString *)failureMessage;

- (NSInteger)getRetries;

- (NSInteger)increaseRetries;

@end
