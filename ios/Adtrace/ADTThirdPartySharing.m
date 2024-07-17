
#import "ADTThirdPartySharing.h"
#import "ADTAdtraceFactory.h"
#import "ADTUtil.h"

@implementation ADTThirdPartySharing

- (nullable id)initWithIsEnabledNumberBool:(nullable NSNumber *)isEnabledNumberBool {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _enabled = isEnabledNumberBool;
    _granularOptions = [[NSMutableDictionary alloc] init];
    _partnerSharingSettings = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)addGranularOption:(nonnull NSString *)partnerName
                      key:(nonnull NSString *)key
                    value:(nonnull NSString *)value {
    if ([ADTUtil isNull:partnerName] || [ADTUtil isNull:key] || [ADTUtil isNull:value]) {
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

- (void)addPartnerSharingSetting:(nonnull NSString *)partnerName
                             key:(nonnull NSString *)key
                           value:(BOOL)value {
    if ([ADTUtil isNull:partnerName] || [ADTUtil isNull:key]) {
        [ADTAdtraceFactory.logger error:@"Cannot add partner sharing setting with any nil value"];
        return;
    }

    NSMutableDictionary *partnerSharingSetting = [self.partnerSharingSettings objectForKey:partnerName];
    if (partnerSharingSetting == nil) {
        partnerSharingSetting = [[NSMutableDictionary alloc] init];
        [self.partnerSharingSettings setObject:partnerSharingSetting forKey:partnerName];
    }

    [partnerSharingSetting setObject:[NSNumber numberWithBool:value] forKey:key];
}

@end
