//
//  ADTTimerOnce.h
//  adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
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
