
#import <Foundation/Foundation.h>
#import "ADTActivityPackage.h"
#import "ADTActivityHandler.h"
#import "ADTRequestHandler.h"
#import "ADTUrlStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADTPurchaseVerificationHandler : NSObject <ADTResponseCallback>

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADTUrlStrategy *)urlStrategy;
- (void)pauseSending;
- (void)resumeSending;
- (void)sendPurchaseVerificationPackage:(ADTActivityPackage *)purchaseVerificationPackage;
- (void)updatePackagesWithAttStatus:(int)attStatus;
- (void)teardown;

@end

NS_ASSUME_NONNULL_END
