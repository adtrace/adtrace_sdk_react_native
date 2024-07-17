
#import "ADTBackoffStrategy.h"

@implementation ADTBackoffStrategy

#pragma mark - Object lifecycle methods

- (id)initWithType:(ADTBackoffStrategyType)strategyType {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    switch (strategyType) {
        case ADTLongWait:
            [self saveStrategy:1 secondMultiplier:120 maxWait:60*60*24 minRange:0.5 maxRange:1.0];
            break;
        case ADTShortWait:
            [self saveStrategy:1 secondMultiplier:0.2 maxWait:60*60 minRange:0.5 maxRange:1.0];
            break;
        case ADTTestWait:
            [self saveStrategy:1 secondMultiplier:0.2 maxWait:1 minRange:0.5 maxRange:1.0];
            break;
        case ADTNoWait:
            [self saveStrategy:100 secondMultiplier:1 maxWait:1 minRange:0.5 maxRange:1.0];
            break;
        case ADTNoRetry:
            [self saveStrategy:0 secondMultiplier:100000 maxWait:100000 minRange:0.5 maxRange:1.0];
            break;
        default:
            break;
    }

    return self;
}

#pragma mark - Public methods

+ (ADTBackoffStrategy *)backoffStrategyWithType:(ADTBackoffStrategyType)strategyType {
    return [[ADTBackoffStrategy alloc] initWithType:strategyType];
}

#pragma mark - Private & helper methods

- (void)saveStrategy:(NSInteger)minRetries
    secondMultiplier:(NSTimeInterval)secondMultiplier
             maxWait:(NSTimeInterval)maxWait
           minRange:(double)minRange
           maxRange:(double)maxRange {
    self.maxWait = maxWait;
    self.minRange = minRange;
    self.maxRange = maxRange;
    self.minRetries = minRetries;
    self.secondMultiplier = secondMultiplier;
}

@end
