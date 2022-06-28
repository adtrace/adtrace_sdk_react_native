//
//  ADTSuccessResponseData.h
//  adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTSessionSuccess : NSObject <NSCopying>

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
 * @brief Backend response in JSON format.
 */
@property (nonatomic, strong, nullable) NSDictionary *jsonResponse;

/**
 * @brief Initialisation method.
 *
 * @return ADTSessionSuccess instance.
 */
+ (nullable ADTSessionSuccess *)sessionSuccessResponseData;

@end
