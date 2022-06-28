//
//  ADTEventSuccess.h
//  adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTEventSuccess : NSObject

/**
 * @brief Message from the adtrace backend.
 */
@property (nonatomic, copy) NSString *message;

/**
 * @brief Timestamp from the adtrace backend.
 */
@property (nonatomic, copy) NSString *timeStamp;

/**
 * @brief Adtrace identifier of the device.
 */
@property (nonatomic, copy) NSString *adid;

/**
 * @brief Event token value.
 */
@property (nonatomic, copy) NSString *eventToken;

/**
 * @brief Event callback ID.
 */
@property (nonatomic, copy) NSString *callbackId;

/**
 * @brief Backend response in JSON format.
 */
@property (nonatomic, strong) NSDictionary *jsonResponse;

/**
 * @brief Initialisation method.
 *
 * @return ADTEventSuccess instance.
 */
+ (ADTEventSuccess *)eventSuccessResponseData;

@end
