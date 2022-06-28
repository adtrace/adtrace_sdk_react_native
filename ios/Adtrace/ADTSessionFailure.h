//
//  ADTFailureResponseData.h
//  adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTSessionFailure : NSObject <NSCopying>

/**
 * @brief Message from the adtrace backend.
 */
@property (nonatomic, copy, nullable) NSString *message;

/**
 * @brief Timestamp from the adtrace backend.
 */
@property (nonatomic, copy, nullable) NSString *timeStamp;

/**
 * @brief Adtrace identifier of the device.
 */
@property (nonatomic, copy, nullable) NSString *adid;

/**
 * @brief Information whether sending of the package will be retried or not.
 */
@property (nonatomic, assign) BOOL willRetry;

/**
 * @brief Backend response in JSON format.
 */
@property (nonatomic, strong, nullable) NSDictionary *jsonResponse;

/**
 * @brief Initialisation method.
 *
 * @return ADTSessionFailure instance.
 */
+ (nullable ADTSessionFailure *)sessionFailureResponseData;

@end
