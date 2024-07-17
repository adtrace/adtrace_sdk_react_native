
#import "ADTTimerCycle.h"
#import "ADTLogger.h"
#import "ADTAdtraceFactory.h"
#import "ADTUtil.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

#pragma mark - private
@interface ADTTimerCycle()

@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, assign) BOOL suspended;
@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, copy) NSString *name;

@end

#pragma mark -
@implementation ADTTimerCycle

+ (ADTTimerCycle *)timerWithBlock:(dispatch_block_t)block
                            queue:(dispatch_queue_t)queue
                        startTime:(NSTimeInterval)startTime
                     intervalTime:(NSTimeInterval)intervalTime
                             name:(NSString*)name
{
    return [[ADTTimerCycle alloc] initBlock:block queue:queue startTime:startTime intervalTime:intervalTime name:name];
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime
           name:(NSString*)name

{
    self = [super init];
    if (self == nil) return nil;

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.logger = ADTAdtraceFactory.logger;
    self.name = name;

    dispatch_source_set_timer(self.source,
                              dispatch_walltime(NULL, startTime * NSEC_PER_SEC),
                              intervalTime * NSEC_PER_SEC,
                              kTimerLeeway);

    dispatch_source_set_event_handler(self.source,
                                      ^{ [self.logger verbose:@"%@ fired", self.name];
                                          block();
                                      });

    self.suspended = YES;

    NSString * startTimeFormatted = [ADTUtil secondsNumberFormat:startTime];
    NSString * intervalTimeFormatted = [ADTUtil secondsNumberFormat:intervalTime];

    [self.logger verbose:@"%@ configured to fire after %@ seconds of starting and cycles every %@ seconds", self.name, startTimeFormatted, intervalTimeFormatted];

    return self;
}

- (void)resume {
    if (self.source == nil) return;
    if (!self.suspended) {
        [self.logger verbose:@"%@ is already started", self.name];
        return;
    }

    [self.logger verbose:@"%@ starting", self.name];

    dispatch_resume(self.source);
    self.suspended = NO;
}

- (void)suspend {
    if (self.source == nil) return;
    if (self.suspended) {
        [self.logger verbose:@"%@ is already suspended", self.name];
        return;
    }

    [self.logger verbose:@"%@ suspended", self.name];
    dispatch_suspend(self.source);
    self.suspended = YES;
}

- (void)cancel {
    if (self.source != nil) {
        [self resume];
        dispatch_cancel(self.source);
    }
    self.source = nil;
}

- (void)dealloc {
    [self.logger verbose:@"%@ dealloc", self.name];
}

@end
