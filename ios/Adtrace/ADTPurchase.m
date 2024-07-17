
#import "ADTPurchase.h"

@implementation ADTPurchase

- (nullable id)initWithTransactionId:(NSString *)transactionId
                           productId:(NSString *)productId
                          andReceipt:(NSData *)receipt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _transactionId = [transactionId copy];
    _productId = [productId copy];
    _receipt = [receipt copy];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ADTPurchase *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_receipt = [self.receipt copyWithZone:zone];
        copy->_productId = [self.productId copyWithZone:zone];
    }

    return copy;
}

@end
