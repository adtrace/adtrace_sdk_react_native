//
//  ADTSessionParameters.h
//  Adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADTSessionParameters : NSObject <NSCopying>

@property (nonatomic, strong) NSMutableDictionary* callbackParameters;
@property (nonatomic, strong) NSMutableDictionary* partnerParameters;

@end
