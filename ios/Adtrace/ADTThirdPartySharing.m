//
//  ADTThirdPartySharing.m
//  AdtraceSdk
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTThirdPartySharing.h"
#import "ADTAdtraceFactory.h"

@implementation ADTThirdPartySharing

- (nullable id)initWithIsEnabledNumberBool:(nullable NSNumber *)isEnabledNumberBool {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _granularOptions = [[NSMutableDictionary alloc] init];
    _enabled = isEnabledNumberBool;

    return self;
}

- (void)addGranularOption:(nonnull NSString *)partnerName
                      key:(nonnull NSString *)key
                    value:(nonnull NSString *)value
{
    if (partnerName == nil || key == nil || value == nil) {
        [ADTAdtraceFactory.logger error:@"Cannot add granular option with any nil value"];
        return;
    }

    NSMutableDictionary *partnerOptions = [self.granularOptions objectForKey:partnerName];
    if (partnerOptions == nil) {
        partnerOptions = [[NSMutableDictionary alloc] init];
        [self.granularOptions setObject:partnerOptions forKey:partnerName];
    }

    [partnerOptions setObject:value forKey:key];
}

@end
