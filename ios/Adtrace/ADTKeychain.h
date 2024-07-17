
#import <Foundation/Foundation.h>

@interface ADTKeychain : NSObject

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service;
+ (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service;

@end
