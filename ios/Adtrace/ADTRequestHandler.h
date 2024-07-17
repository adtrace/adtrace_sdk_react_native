
#import <Foundation/Foundation.h>
#import "ADTActivityPackage.h"
#import "ADTUrlStrategy.h"

@protocol ADTResponseCallback <NSObject>
- (void)responseCallback:(ADTResponseData *)responseData;
@end

@interface ADTRequestHandler : NSObject

- (id)initWithResponseCallback:(id<ADTResponseCallback>)responseCallback
                   urlStrategy:(ADTUrlStrategy *)urlStrategy
                     userAgent:(NSString *)userAgent
                requestTimeout:(double)requestTimeout;

- (void)sendPackageByPOST:(ADTActivityPackage *)activityPackage
        sendingParameters:(NSDictionary *)sendingParameters;

- (void)sendPackageByGET:(ADTActivityPackage *)activityPackage
        sendingParameters:(NSDictionary *)sendingParameters;

@end
