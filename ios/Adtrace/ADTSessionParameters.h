//
//  ADTSessionParameters.h
//  Adtrace
//


#import <Foundation/Foundation.h>

@interface ADTSessionParameters : NSObject <NSCopying>

@property (nonatomic, strong) NSMutableDictionary* callbackParameters;
@property (nonatomic, strong) NSMutableDictionary* partnerParameters;

@end
