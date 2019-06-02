//
//  ADTLogger.h
//  Adtrace
//

#import <Foundation/Foundation.h>

typedef enum {
    ADTLogLevelVerbose  = 1,
    ADTLogLevelDebug    = 2,
    ADTLogLevelInfo     = 3,
    ADTLogLevelWarn     = 4,
    ADTLogLevelError    = 5,
    ADTLogLevelAssert   = 6,
    ADTLogLevelSuppress = 7
} ADTLogLevel;

/**
 * @brief Adtrace logger protocol.
 */
@protocol ADTLogger

/**
 * @brief Set the log level of the SDK.
 *
 * @param logLevel Level of the logs to be displayed.
 */
- (void)setLogLevel:(ADTLogLevel)logLevel isProductionEnvironment:(BOOL)isProductionEnvironment;

/**
 * @brief Prevent log level changes.
 */
- (void)lockLogLevel;

/**
 * @brief Print verbose logs.
 */
- (void)verbose:(nonnull NSString *)message, ...;

/**
 * @brief Print debug logs.
 */
- (void)debug:(nonnull NSString *)message, ...;

/**
 * @brief Print info logs.
 */
- (void)info:(nonnull NSString *)message, ...;

/**
 * @brief Print warn logs.
 */
- (void)warn:(nonnull NSString *)message, ...;
- (void)warnInProduction:(nonnull NSString *)message, ...;

/**
 * @brief Print error logs.
 */
- (void)error:(nonnull NSString *)message, ...;

/**
 * @brief Print assert logs.
 */
- (void)assert:(nonnull NSString *)message, ...;

@end

/**
 * @brief Adtrace logger class.
 */
@interface ADTLogger : NSObject<ADTLogger>

/**
 * @brief Convert log level string to ADTLogLevel enumeration.
 *
 * @param logLevelString Log level as string.
 *
 * @return Log level as ADTLogLevel enumeration.
 */
+ (ADTLogLevel)logLevelFromString:(nonnull NSString *)logLevelString;

@end
