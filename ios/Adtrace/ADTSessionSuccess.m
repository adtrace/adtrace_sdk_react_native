//
//  ADTSuccessResponseData.m
//  adtrace
//


#import "ADTSessionSuccess.h"

@implementation ADTSessionSuccess

#pragma mark - Public methods

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    return self;
}

+ (ADTSessionSuccess *)sessionSuccessResponseData {
    return [[ADTSessionSuccess alloc] init];
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADTSessionSuccess *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.message = [self.message copyWithZone:zone];
        copy.timeStamp = [self.timeStamp copyWithZone:zone];
        copy.adid = [self.adid copyWithZone:zone];
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
    }

    return copy;
}

#pragma mark - NSObject protocol methods

- (NSString *)description {
    return [NSString stringWithFormat: @"Session Success msg:%@ time:%@ adid:%@ json:%@",
            self.message,
            self.timeStamp,
            self.adid,
            self.jsonResponse];
}

@end
