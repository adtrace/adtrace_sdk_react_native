
#import "NSNumber+ADTAdditions.h"

@implementation NSNumber(ADTAdditions)

+ (BOOL)adtIsEqual:(NSNumber *)first toNumber:(NSNumber *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToNumber:second];
}

@end
