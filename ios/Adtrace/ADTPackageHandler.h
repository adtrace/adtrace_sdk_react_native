//
//  ADTPackageHandler.h
//  Adtrace
//

#import <Foundation/Foundation.h>

#import "ADTActivityPackage.h"
#import "ADTPackageHandler.h"
#import "ADTActivityHandler.h"
#import "ADTResponseData.h"
#import "ADTSessionParameters.h"

@protocol ADTPackageHandler

- (id)initWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending;

- (void)addPackage:(ADTActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage:(ADTResponseData *)responseData;
- (void)closeFirstPackage:(ADTResponseData *)responseData
          activityPackage:(ADTActivityPackage *)activityPackage;
- (void)pauseSending;
- (void)resumeSending;
- (void)updatePackages:(ADTSessionParameters *)sessionParameters;
- (void)flush;
- (NSString *)getBasePath;
- (NSString *)getGdprPath;

- (void)teardown;
+ (void)deleteState;
@end

@interface ADTPackageHandler : NSObject <ADTPackageHandler>

+ (id<ADTPackageHandler>)handlerWithActivityHandler:(id<ADTActivityHandler>)activityHandler
                                      startsSending:(BOOL)startsSending;

@end
