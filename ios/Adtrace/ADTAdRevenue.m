//
//  ADTAdRevenue.m
//  Adtrace SDK
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTAdRevenue.h"
#import "ADTAdtraceFactory.h"
#import "ADTUtil.h"

@interface ADTAdRevenue()

@property (nonatomic, weak) id<ADTLogger> logger;

@property (nonatomic, strong) NSMutableDictionary *mutableCallbackParameters;

@property (nonatomic, strong) NSMutableDictionary *mutablePartnerParameters;

@end

@implementation ADTAdRevenue

- (nullable id)initWithSource:(NSString *)source {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _source = source;
    _logger = ADTAdtraceFactory.logger;
    
    return self;
}

- (void)setRevenue:(double)amount currency:(NSString *)currency {
    NSNumber *revenue = [NSNumber numberWithDouble:amount];

    _revenue = revenue;
    @synchronized (self) {
        _currency = [currency copy];
    }
}

- (void)setAdImpressionsCount:(int)adImpressionsCount {
    NSNumber *nAdImpressionsCount = [NSNumber numberWithInt:adImpressionsCount];
    _adImpressionsCount = nAdImpressionsCount;
}

- (void)setAdRevenueNetwork:(nonnull NSString *)adRevenueNetwork {
    @synchronized (self) {
        _adRevenueNetwork = [adRevenueNetwork copy];
    }
}

- (void)setAdRevenueUnit:(nonnull NSString *)adRevenueUnit {
    @synchronized (self) {
        _adRevenueUnit = [adRevenueUnit copy];
    }
}

- (void)setAdRevenuePlacement:(nonnull NSString *)adRevenuePlacement {
    @synchronized (self) {
        _adRevenuePlacement = [adRevenuePlacement copy];
    }
}

- (void)addCallbackParameter:(nonnull NSString *)key
                       value:(nonnull NSString *)value
{
    @synchronized (self) {
        NSString *immutableKey = [key copy];
        NSString *immutableValue = [value copy];

        if (![ADTUtil isValidParameter:immutableKey
                         attributeType:@"key"
                         parameterName:@"Callback"]) {
            return;
        }
        if (![ADTUtil isValidParameter:immutableValue
                         attributeType:@"value"
                         parameterName:@"Callback"]) {
            return;
        }

        if (self.mutableCallbackParameters == nil) {
            self.mutableCallbackParameters = [[NSMutableDictionary alloc] init];
        }

        if ([self.mutableCallbackParameters objectForKey:immutableKey]) {
            [self.logger warn:@"key %@ was overwritten", immutableKey];
        }

        [self.mutableCallbackParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (void)addPartnerParameter:(nonnull NSString *)key
                      value:(nonnull NSString *)value
{
    @synchronized (self) {
        NSString *immutableKey = [key copy];
        NSString *immutableValue = [value copy];

        if (![ADTUtil isValidParameter:immutableKey
                         attributeType:@"key"
                         parameterName:@"Partner"]) {
            return;
        }
        if (![ADTUtil isValidParameter:immutableValue
                         attributeType:@"value"
                         parameterName:@"Partner"]) {
            return;
        }

        if (self.mutablePartnerParameters == nil) {
            self.mutablePartnerParameters = [[NSMutableDictionary alloc] init];
        }

        if ([self.mutablePartnerParameters objectForKey:immutableKey]) {
            [self.logger warn:@"key %@ was overwritten", immutableKey];
        }

        [self.mutablePartnerParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (NSDictionary *)callbackParameters {
    @synchronized (self) {
        return (NSDictionary *)self.mutableCallbackParameters;
    }
}

- (NSDictionary *)partnerParameters {
    @synchronized (self) {
        return (NSDictionary *)self.mutablePartnerParameters;
    }
}

- (BOOL)isValid {
    return self.source != nil && [self.source length] > 0;
}

- (id)copyWithZone:(NSZone *)zone {
    ADTAdRevenue *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_source = [self.source copyWithZone:zone];
        copy->_revenue = [self.revenue copyWithZone:zone];
        copy->_currency = [self.currency copyWithZone:zone];
        copy.mutableCallbackParameters = [self.mutableCallbackParameters copyWithZone:zone];
        copy.mutablePartnerParameters = [self.mutablePartnerParameters copyWithZone:zone];
        copy->_adImpressionsCount = [self.adImpressionsCount copyWithZone:zone];
        copy->_adRevenueUnit = [self.adRevenueUnit copyWithZone:zone];
        copy->_adRevenueNetwork = [self.adRevenueNetwork copyWithZone:zone];
        copy->_adRevenuePlacement = [self.adRevenuePlacement copyWithZone:zone];
    }

    return copy;
}

@end
