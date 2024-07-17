
#import "ADTEventFailure.h"

@implementation ADTEventFailure

#pragma mark - Object lifecycle methods

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    return self;
}

+ (ADTEventFailure *)eventFailureResponseData {
    return [[ADTEventFailure alloc] init];
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADTEventFailure *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.message = [self.message copyWithZone:zone];
        copy.timeStamp = [self.timeStamp copyWithZone:zone];
        copy.adid = [self.adid copyWithZone:zone];
        copy.eventToken = [self.eventToken copyWithZone:zone];
        copy.callbackId = [self.callbackId copyWithZone:zone];
        copy.willRetry = self.willRetry;
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
    }

    return copy;
}

#pragma mark - NSObject protocol methods

- (NSString *)description {
    return [NSString stringWithFormat: @"Event Failure msg:%@ time:%@ adid:%@ event:%@ cid:%@, retry:%@ json:%@",
            self.message,
            self.timeStamp,
            self.adid,
            self.eventToken,
            self.callbackId,
            self.willRetry ? @"YES" : @"NO",
            self.jsonResponse];
}

@end
