//
//  ADTAttributionHandler.m
//  adtrace
//
//  Created by Nasser Amini (@namini40) on Jun 2022.
//  Copyright © 2022 adtrace io. All rights reserved.
//

#import "ADTAttributionHandler.h"
#import "ADTAdtraceFactory.h"
#import "ADTUtil.h"
#import "ADTActivityHandler.h"
#import "NSString+ADTAdditions.h"
#import "ADTTimerOnce.h"
#import "ADTPackageBuilder.h"
#import "ADTUtil.h"

static const char * const kInternalQueueName     = "io.adtrace.AttributionQueue";
static NSString   * const kAttributionTimerName   = @"Attribution timer";

@interface ADTAttributionHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADTRequestHandler *requestHandler;
@property (nonatomic, weak) id<ADTActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADTLogger> logger;
@property (nonatomic, strong) ADTTimerOnce *attributionTimer;
@property (atomic, assign) BOOL paused;
@property (nonatomic, copy) NSString *lastInitiatedBy;

@end

@implementation ADTAttributionHandler
- (id)initWithActivityHandler:(id<ADTActivityHandler>) activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADTUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.requestHandler = [[ADTRequestHandler alloc]
                                initWithResponseCallback:self
                                urlStrategy:urlStrategy
                                userAgent:userAgent
                                requestTimeout:[ADTAdtraceFactory requestTimeout]];
    self.activityHandler = activityHandler;
    self.logger = ADTAdtraceFactory.logger;
    self.paused = !startsSending;
    __weak __typeof__(self) weakSelf = self;
    self.attributionTimer = [ADTTimerOnce timerWithBlock:^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        [strongSelf requestAttributionI:strongSelf];
    }
                                                   queue:self.internalQueue
                                                    name:kAttributionTimerName];

    return self;
}

- (void)checkSessionResponse:(ADTSessionResponseData *)sessionResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTAttributionHandler* selfI) {
                         [selfI checkSessionResponseI:selfI
                                  sessionResponseData:sessionResponseData];
                     }];
}

- (void)checkSdkClickResponse:(ADTSdkClickResponseData *)sdkClickResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTAttributionHandler* selfI) {
                         [selfI checkSdkClickResponseI:selfI
                                  sdkClickResponseData:sdkClickResponseData];
                     }];
}

- (void)checkAttributionResponse:(ADTAttributionResponseData *)attributionResponseData {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTAttributionHandler* selfI) {
                         [selfI checkAttributionResponseI:selfI
                                  attributionResponseData:attributionResponseData];

                     }];
}

- (void)getAttribution {
    [ADTUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADTAttributionHandler* selfI) {
                         selfI.lastInitiatedBy = @"sdk";
                         [selfI waitRequestAttributionWithDelayI:selfI
                                               milliSecondsDelay:0];

                     }];
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

#pragma mark - internal
- (void)checkSessionResponseI:(ADTAttributionHandler*)selfI
          sessionResponseData:(ADTSessionResponseData *)sessionResponseData {
    [selfI checkAttributionI:selfI responseData:sessionResponseData];
    
    [selfI.activityHandler launchSessionResponseTasks:sessionResponseData];
}

- (void)checkSdkClickResponseI:(ADTAttributionHandler*)selfI
          sdkClickResponseData:(ADTSdkClickResponseData *)sdkClickResponseData {
    [selfI checkAttributionI:selfI responseData:sdkClickResponseData];
    
    [selfI.activityHandler launchSdkClickResponseTasks:sdkClickResponseData];
}

- (void)checkAttributionResponseI:(ADTAttributionHandler*)selfI
                  attributionResponseData:(ADTAttributionResponseData *)attributionResponseData {
    [selfI checkAttributionI:selfI responseData:attributionResponseData];

    [selfI checkDeeplinkI:selfI attributionResponseData:attributionResponseData];
    
    [selfI.activityHandler launchAttributionResponseTasks:attributionResponseData];
}

- (void)checkAttributionI:(ADTAttributionHandler*)selfI
             responseData:(ADTResponseData *)responseData {
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSNumber *timerMilliseconds = [responseData.jsonResponse objectForKey:@"ask_in"];

    if (timerMilliseconds != nil) {
        [selfI.activityHandler setAskingAttribution:YES];

        selfI.lastInitiatedBy = @"backend";
        [selfI waitRequestAttributionWithDelayI:selfI
                              milliSecondsDelay:[timerMilliseconds intValue]];

        return;
    }

    [selfI.activityHandler setAskingAttribution:NO];

    NSDictionary * jsonAttribution = [responseData.jsonResponse objectForKey:@"attribution"];
    responseData.attribution = [ADTAttribution dataWithJsonDict:jsonAttribution adid:responseData.adid];
}

- (void)checkDeeplinkI:(ADTAttributionHandler*)selfI
attributionResponseData:(ADTAttributionResponseData *)attributionResponseData {
    if (attributionResponseData.jsonResponse == nil) {
        return;
    }

    NSDictionary * jsonAttribution = [attributionResponseData.jsonResponse objectForKey:@"attribution"];
    if (jsonAttribution == nil) {
        return;
    }

    NSString *deepLink = [jsonAttribution objectForKey:@"deeplink"];
    if (deepLink == nil) {
        return;
    }

    attributionResponseData.deeplink = [NSURL URLWithString:deepLink];
}

- (void)requestAttributionI:(ADTAttributionHandler*)selfI {
    if (selfI.paused) {
        [selfI.logger debug:@"Attribution handler is paused"];
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"Attribution request won't be fired for forgotten user"];
        return;
    }

    ADTActivityPackage* attributionPackage = [selfI buildAndGetAttributionPackageI:selfI];

    [selfI.logger verbose:@"%@", attributionPackage.extendedString];

    NSDictionary *sendingParameters = @{
        @"sent_at": [ADTUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
    };

    [selfI.requestHandler sendPackageByGET:attributionPackage
                        sendingParameters:sendingParameters];
}

- (void)responseCallback:(ADTResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got attribution JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:
            @"Could not get attribution JSON response with message: %@", responseData.message];
    }

    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADTTrackingStateOptedOut) {
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }

    if ([responseData isKindOfClass:[ADTAttributionResponseData class]]) {
        [self checkAttributionResponse:(ADTAttributionResponseData*)responseData];
    }
}

- (void)waitRequestAttributionWithDelayI:(ADTAttributionHandler*)selfI
                       milliSecondsDelay:(int)milliSecondsDelay {
    NSTimeInterval secondsDelay = milliSecondsDelay / 1000;
    NSTimeInterval nextAskIn = [selfI.attributionTimer fireIn];
    if (nextAskIn > secondsDelay) {
        return;
    }

    if (milliSecondsDelay > 0) {
        [selfI.logger debug:@"Waiting to query attribution in %d milliseconds", milliSecondsDelay];
    }

    // set the new time the timer will fire in
    [selfI.attributionTimer startIn:secondsDelay];
}

- (ADTActivityPackage *)buildAndGetAttributionPackageI:(ADTAttributionHandler*)selfI
{
    double now = [NSDate.date timeIntervalSince1970];

    ADTPackageBuilder *attributionBuilder = [[ADTPackageBuilder alloc]
                                             initWithPackageParams:selfI.activityHandler.packageParams
                                             activityState:selfI.activityHandler.activityState
                                             config:selfI.activityHandler.adtraceConfig
                                             sessionParameters:selfI.activityHandler.sessionParameters
                                             trackingStatusManager:selfI.activityHandler.trackingStatusManager
                                             createdAt:now];
    ADTActivityPackage *attributionPackage = [attributionBuilder buildAttributionPackage:selfI.lastInitiatedBy];

    selfI.lastInitiatedBy = nil;

    return attributionPackage;
}

#pragma mark - private

- (void)teardown {
    [ADTAdtraceFactory.logger verbose:@"ADTAttributionHandler teardown"];

    if (self.attributionTimer != nil) {
        [self.attributionTimer cancel];
    }
    self.internalQueue = nil;
    self.activityHandler = nil;
    self.logger = nil;
    self.attributionTimer = nil;
    self.requestHandler = nil;
}

@end
