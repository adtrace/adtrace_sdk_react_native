
#import "ADTUtil.h"
#import "ADTSubscription.h"
#import "ADTAdtraceFactory.h"

@interface ADTSubscription()

@property (nonatomic, weak) id<ADTLogger> logger;

@property (nonatomic, strong) NSMutableDictionary *mutableCallbackParameters;

@property (nonatomic, strong) NSMutableDictionary *mutablePartnerParameters;

@end

@implementation ADTSubscription

- (nullable id)initWithPrice:(nonnull NSDecimalNumber *)price
                    currency:(nonnull NSString *)currency
               transactionId:(nonnull NSString *)transactionId
                  andReceipt:(nonnull NSData *)receipt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _price = [price copy];
    _currency = [currency copy];
    _transactionId = [transactionId copy];
    _receipt = [receipt copy];
    _billingStore = @"iOS";

    _logger = ADTAdtraceFactory.logger;
    
    return self;
}

- (void)setTransactionDate:(NSDate *)transactionDate {
    @synchronized (self) {
        _transactionDate = [transactionDate copy];
    }
}

- (void)setSalesRegion:(NSString *)salesRegion {
    @synchronized (self) {
        _salesRegion = [salesRegion copy];
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

- (nonnull NSDictionary *)callbackParameters {
    return [self.mutableCallbackParameters copy];
}

- (nonnull NSDictionary *)partnerParameters {
    return [self.mutablePartnerParameters copy];
}

- (id)copyWithZone:(NSZone *)zone {
    ADTSubscription *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_price = [self.price copyWithZone:zone];
        copy->_currency = [self.currency copyWithZone:zone];
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_receipt = [self.receipt copyWithZone:zone];
        copy->_billingStore = [self.billingStore copyWithZone:zone];
        copy->_transactionDate = [self.transactionDate copyWithZone:zone];
        copy->_salesRegion = [self.salesRegion copyWithZone:zone];
        copy.mutableCallbackParameters = [self.mutableCallbackParameters copyWithZone:zone];
        copy.mutablePartnerParameters = [self.mutablePartnerParameters copyWithZone:zone];
    }

    return copy;
}

@end
