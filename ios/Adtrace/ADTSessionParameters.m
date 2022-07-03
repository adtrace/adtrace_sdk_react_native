//
//  ADTSessionParameters.m
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTSessionParameters.h"

@implementation ADTSessionParameters

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    ADTSessionParameters* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters  = [self.partnerParameters copyWithZone:zone];
    }

    return copy;
}

@end
