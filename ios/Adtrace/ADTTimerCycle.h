//
//  ADTTimerCycle.h
//  adtrace
//

#import <Foundation/Foundation.h>

@interface ADTTimerCycle : NSObject

+ (ADTTimerCycle *)timerWithBlock:(dispatch_block_t)block
                            queue:(dispatch_queue_t)queue
                        startTime:(NSTimeInterval)startTime
                     intervalTime:(NSTimeInterval)intervalTime
                             name:(NSString*)name;

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime
           name:(NSString*)name;

- (void)resume;
- (void)suspend;
- (void)cancel;
@end
