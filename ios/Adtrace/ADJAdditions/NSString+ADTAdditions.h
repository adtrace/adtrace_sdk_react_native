//
//  NSString+ADTAdditions.h
//  Adtrace
//

#import <Foundation/Foundation.h>

@interface NSString(ADTAdditions)

- (NSString *)adtMd5;
- (NSString *)adtSha1;
- (NSString *)adtSha256;
- (NSString *)adtTrim;
- (NSString *)adtUrlEncode;
- (NSString *)adtUrlDecode;
- (NSString *)adtRemoveColons;

+ (NSString *)adtJoin:(NSString *)strings, ...;
+ (BOOL) adtIsEqual:(NSString *)first toString:(NSString *)second;

@end
