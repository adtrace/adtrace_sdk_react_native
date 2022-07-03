//
//  NSString+ADTAdditions.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(ADTAdditions)

- (NSString *)adtSha256;
- (NSString *)adtTrim;
- (NSString *)adtUrlEncode;
- (NSString *)adtUrlDecode;

+ (NSString *)adtJoin:(NSString *)strings, ...;
+ (BOOL) adtIsEqual:(NSString *)first toString:(NSString *)second;

@end
