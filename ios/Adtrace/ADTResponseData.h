//
//  ADTResponseData.h
//  adtrace
//


#import <Foundation/Foundation.h>

#import "ADTAttribution.h"
#import "ADTEventSuccess.h"
#import "ADTEventFailure.h"
#import "ADTSessionSuccess.h"
#import "ADTSessionFailure.h"
#import "ADTActivityPackage.h"

typedef NS_ENUM(int, ADTTrackingState) {
    ADTTrackingStateOptedOut = 1
};

@interface ADTResponseData : NSObject <NSCopying>

@property (nonatomic, assign) ADTActivityKind activityKind;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, copy) NSString *adid;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) BOOL willRetry;

@property (nonatomic, assign) ADTTrackingState trackingState;

@property (nonatomic, strong) NSDictionary *jsonResponse;

@property (nonatomic, copy) ADTAttribution *attribution;

- (id)init;

+ (ADTResponseData *)responseData;

+ (id)buildResponseData:(ADTActivityPackage *)activityPackage;

@end

@interface ADTSessionResponseData : ADTResponseData

- (ADTSessionSuccess *)successResponseData;

- (ADTSessionFailure *)failureResponseData;

@end

@interface ADTSdkClickResponseData : ADTResponseData
@end

@interface ADTEventResponseData : ADTResponseData

@property (nonatomic, copy) NSString *eventToken;

@property (nonatomic, copy) NSString *callbackId;

- (ADTEventSuccess *)successResponseData;

- (ADTEventFailure *)failureResponseData;

- (id)initWithActivityPackage:(ADTActivityPackage *)activityPackage;

+ (ADTResponseData *)responseDataWithActivityPackage:(ADTActivityPackage *)activityPackage;

@end

@interface ADTAttributionResponseData : ADTResponseData

@property (nonatomic, strong) NSURL *deeplink;

@end
