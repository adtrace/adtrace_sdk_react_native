//
//  ADTUrlStrategy.h
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTActivityKind.h"

@interface ADTUrlStrategy : NSObject

@property (nonatomic, readonly, copy) NSString *extraPath;

- (instancetype)initWithUrlStrategyInfo:(NSString *)urlStrategyInfo
                              extraPath:(NSString *)extraPath;

- (NSString *)getUrlHostStringByPackageKind:(ADTActivityKind)activityKind;

- (void)resetAfterSuccess;
- (BOOL)shouldRetryAfterFailure:(ADTActivityKind)activityKind;

@end
