//
//  NSNumber+ADTAdditions.m
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "NSNumber+ADTAdditions.h"

@implementation NSNumber(ADTAdditions)

+ (BOOL)adtIsEqual:(NSNumber *)first toNumber:(NSNumber *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToNumber:second];
}

@end
