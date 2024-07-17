
#import "ADTLogger.h"

static NSString * const kLogTag = @"Adtrace";

@interface ADTLogger()

@property (nonatomic, assign) ADTLogLevel loglevel;
@property (nonatomic, assign) BOOL logLevelLocked;
@property (nonatomic, assign) BOOL isProductionEnvironment;

@end

#pragma mark -
@implementation ADTLogger

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    //default values
    _loglevel = ADTLogLevelInfo;
    self.logLevelLocked = NO;
    self.isProductionEnvironment = NO;

    return self;
}

- (void)setLogLevel:(ADTLogLevel)logLevel
isProductionEnvironment:(BOOL)isProductionEnvironment
{
    if (self.logLevelLocked) {
        return;
    }
    _loglevel = logLevel;
    self.isProductionEnvironment = isProductionEnvironment;
}

- (void)lockLogLevel {
    self.logLevelLocked = YES;
}

- (void)verbose:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}
- (void)warnInProduction:(nonnull NSString *)format, ... {
    if (self.loglevel > ADTLogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

- (void)assert:(NSString *)format, ... {
    if (self.isProductionEnvironment) return;
    if (self.loglevel > ADTLogLevelAssert) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"a" format:format parameters:parameters];
}

// private implementation
- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list)parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logLevel, line);
    }
}

+ (ADTLogLevel)logLevelFromString:(NSString *)logLevelString {
    if ([logLevelString isEqualToString:@"verbose"])
        return ADTLogLevelVerbose;

    if ([logLevelString isEqualToString:@"debug"])
        return ADTLogLevelDebug;

    if ([logLevelString isEqualToString:@"info"])
        return ADTLogLevelInfo;

    if ([logLevelString isEqualToString:@"warn"])
        return ADTLogLevelWarn;

    if ([logLevelString isEqualToString:@"error"])
        return ADTLogLevelError;

    if ([logLevelString isEqualToString:@"assert"])
        return ADTLogLevelAssert;

    if ([logLevelString isEqualToString:@"suppress"])
        return ADTLogLevelSuppress;

    // default value if string does not match
    return ADTLogLevelInfo;
}

@end
