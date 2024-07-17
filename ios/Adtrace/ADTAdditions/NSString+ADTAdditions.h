
#import <Foundation/Foundation.h>

@interface NSString(ADTAdditions)

- (NSString *)adtSha256;
- (NSString *)adtTrim;
- (NSString *)adtUrlEncode;
- (NSString *)adtUrlDecode;

+ (NSString *)adtJoin:(NSString *)strings, ...;
+ (BOOL) adtIsEqual:(NSString *)first toString:(NSString *)second;

@end
