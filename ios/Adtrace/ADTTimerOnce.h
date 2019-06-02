//
//  ADTTimerOnce.h
//  adtrace
//

#import <Foundation/Foundation.h>


@interface ADTTimerOnce : NSObject

+ (ADTTimerOnce *)timerWithBlock:(dispatch_block_t)block
                           queue:(dispatch_queue_t)queue
                            name:(NSString*)name;

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
           name:(NSString*)name;

- (void)startIn:(NSTimeInterval)startIn;
- (NSTimeInterval)fireIn;
- (void)cancel;
@end
