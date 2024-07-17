
#import "ADTResponseData.h"
#import "ADTActivityKind.h"

@implementation ADTResponseData

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    return self;
}

+ (ADTResponseData *)responseData {
    return [[ADTResponseData alloc] init];
}

+ (id)buildResponseData:(ADTActivityPackage *)activityPackage {
    ADTActivityKind activityKind;
    
    if (activityPackage == nil) {
        activityKind = ADTActivityKindUnknown;
    } else {
        activityKind = activityPackage.activityKind;
    }

    ADTResponseData *responseData = nil;

    switch (activityKind) {
        case ADTActivityKindSession:
            responseData = [[ADTSessionResponseData alloc] init];
            break;
        case ADTActivityKindClick:
            responseData = [[ADTSdkClickResponseData alloc] init];
            responseData.sdkClickPackage = activityPackage;
            break;
        case ADTActivityKindEvent:
            responseData = [[ADTEventResponseData alloc]
                                initWithEventToken:
                                    [activityPackage.parameters
                                        objectForKey:@"event_token"]
                                callbackId:
                                    [activityPackage.parameters
                                        objectForKey:@"event_callback_id"]];
            break;
        case ADTActivityKindAttribution:
            responseData = [[ADTAttributionResponseData alloc] init];
            break;
        case ADTActivityKindPurchaseVerification:
            responseData = [[ADTPurchaseVerificationResponseData alloc] init];
            responseData.purchaseVerificationPackage = activityPackage;
            break;
        default:
            responseData = [[ADTResponseData alloc] init];
            break;
    }

    responseData.sdkPackage = activityPackage;
    responseData.activityKind = activityKind;

    return responseData;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ success:%d willRetry:%d attribution:%@ trackingState:%d, json:%@",
            self.message, self.timeStamp, self.adid, self.success, self.willRetry, self.attribution, self.trackingState, self.jsonResponse];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ADTResponseData* copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.message = [self.message copyWithZone:zone];
        copy.timeStamp = [self.timeStamp copyWithZone:zone];
        copy.adid = [self.adid copyWithZone:zone];
        copy.willRetry = self.willRetry;
        copy.trackingState = self.trackingState;
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
        copy.attribution = [self.attribution copyWithZone:zone];
        copy.errorCode = [self.errorCode copyWithZone:zone];
    }

    return copy;
}

@end

@implementation ADTSessionResponseData

- (ADTSessionSuccess *)successResponseData {
    ADTSessionSuccess *successResponseData = [ADTSessionSuccess sessionSuccessResponseData];

    successResponseData.message = self.message;
    successResponseData.timeStamp = self.timeStamp;
    successResponseData.adid = self.adid;
    successResponseData.jsonResponse = self.jsonResponse;

    return successResponseData;
}

- (ADTSessionFailure *)failureResponseData {
    ADTSessionFailure *failureResponseData = [ADTSessionFailure sessionFailureResponseData];

    failureResponseData.message = self.message;
    failureResponseData.timeStamp = self.timeStamp;
    failureResponseData.adid = self.adid;
    failureResponseData.willRetry = self.willRetry;
    failureResponseData.jsonResponse = self.jsonResponse;

    return failureResponseData;
}

- (id)copyWithZone:(NSZone *)zone {
    ADTSessionResponseData* copy = [super copyWithZone:zone];
    return copy;
}

@end

@implementation ADTSdkClickResponseData

@end

@implementation ADTPurchaseVerificationResponseData

@end

@implementation ADTEventResponseData

- (id)initWithEventToken:(NSString *)eventToken
       callbackId:(NSString *)callbackId
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    self.eventToken = eventToken;
    self.callbackId = callbackId;

    return self;
}

- (ADTEventSuccess *)successResponseData {
    ADTEventSuccess *successResponseData = [ADTEventSuccess eventSuccessResponseData];

    successResponseData.message = self.message;
    successResponseData.timeStamp = self.timeStamp;
    successResponseData.adid = self.adid;
    successResponseData.eventToken = self.eventToken;
    successResponseData.callbackId = self.callbackId;
    successResponseData.jsonResponse = self.jsonResponse;

    return successResponseData;
}

- (ADTEventFailure *)failureResponseData {
    ADTEventFailure *failureResponseData = [ADTEventFailure eventFailureResponseData];

    failureResponseData.message = self.message;
    failureResponseData.timeStamp = self.timeStamp;
    failureResponseData.adid = self.adid;
    failureResponseData.eventToken = self.eventToken;
    failureResponseData.callbackId = self.callbackId;
    failureResponseData.willRetry = self.willRetry;
    failureResponseData.jsonResponse = self.jsonResponse;

    return failureResponseData;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ eventToken:%@ success:%d willRetry:%d attribution:%@ json:%@",
            self.message, self.timeStamp, self.adid, self.eventToken, self.success, self.willRetry, self.attribution, self.jsonResponse];
}

- (id)copyWithZone:(NSZone *)zone {
    ADTEventResponseData *copy = [super copyWithZone:zone];

    if (copy) {
        copy.eventToken = [self.eventToken copyWithZone:zone];
    }

    return copy;
}

@end

@implementation ADTAttributionResponseData

- (id)copyWithZone:(NSZone *)zone {
    ADTAttributionResponseData *copy = [super copyWithZone:zone];
    
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ success:%d willRetry:%d attribution:%@ deeplink:%@ json:%@",
            self.message, self.timeStamp, self.adid, self.success, self.willRetry, self.attribution, self.deeplink, self.jsonResponse];
}

@end

