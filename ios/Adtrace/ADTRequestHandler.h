//
//  ADTRequestHandler.h
//  Adtrace
//

#import <Foundation/Foundation.h>
#import "ADTPackageHandler.h"

@protocol ADTRequestHandler

- (id)initWithPackageHandler:(id<ADTPackageHandler>)packageHandler
          andActivityHandler:(id<ADTActivityHandler>)activityHandler;

- (void)sendPackage:(ADTActivityPackage *)activityPackage
          queueSize:(NSUInteger)queueSize;

- (void)teardown;

@end

@interface ADTRequestHandler : NSObject <ADTRequestHandler>

+ (id<ADTRequestHandler>)handlerWithPackageHandler:(id<ADTPackageHandler>)packageHandler
                                andActivityHandler:(id<ADTActivityHandler>)activityHandler;

@end
