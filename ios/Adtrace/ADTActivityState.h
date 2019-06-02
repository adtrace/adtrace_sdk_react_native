//
//  ADTActivityState.h
//  Adtrace
//

#import <Foundation/Foundation.h>

@interface ADTActivityState : NSObject <NSCoding, NSCopying>

// Persistent data
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isGdprForgotten;
@property (nonatomic, assign) BOOL askingAttribution;

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, assign) BOOL updatePackages;

@property (nonatomic, copy) NSString *adid;
@property (nonatomic, strong) NSDictionary *attributionDetails;

// Global counters
@property (nonatomic, assign) int eventCount;
@property (nonatomic, assign) int sessionCount;

// Session attributes
@property (nonatomic, assign) int subsessionCount;

@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double lastActivity;      // Entire time in seconds since 1970
@property (nonatomic, assign) double sessionLength;     // Entire duration in seconds

// last ten transaction identifiers
@property (nonatomic, strong) NSMutableArray *transactionIds;

// Not persisted, only injected
@property (nonatomic, assign) BOOL isPersisted;
@property (nonatomic, assign) double lastInterval;

- (void)resetSessionAttributes:(double)now;

+ (void)saveAppToken:(NSString *)appTokenToSave;

// Transaction ID management
- (void)addTransactionId:(NSString *)transactionId;
- (BOOL)findTransactionId:(NSString *)transactionId;

@end
