//
//  NSNumber+ADTAdditions.h
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber(ADTAdditions)

+ (BOOL)adtIsEqual:(NSNumber *)first toNumber:(NSNumber *)second;

@end
