
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADTPurchase : NSObject<NSCopying>

@property (nonatomic, copy, readonly, nonnull) NSString *transactionId;

@property (nonatomic, copy, readonly, nonnull) NSData *receipt;

@property (nonatomic, copy, readonly, nonnull) NSString *productId;

- (nullable id)initWithTransactionId:(nonnull NSString *)transactionId
                           productId:(nonnull NSString *)productId
                          andReceipt:(nonnull NSData *)receipt;

@end

NS_ASSUME_NONNULL_END
