//
//  MNetPulseRegulationTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 20/12/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetPulseRegulationTests : MNetTestManager

@end

@implementation MNetPulseRegulationTests

- (void)testPulseWithRegulation{
    [[MNet getInstance] setAppContainsChildDirectedContent:YES];
    
    // TODO: Figure out a way to automatically fetch these constants
    NSArray <NSString *> *allEvents  = @[
                                         MNetPulseEventSessionTime,
                                         MNetPulseEventEnteredBackground,
                                         MNetPulseEventAnalytics,
                                         MNetPulseEventActivityContext,
                                         MNetPulseEventResponseDuration,
                                         MNetPulseEventPredictedBidParticipated,
                                         MNetPulseEventPredictedBidProcessed,
                                         MNetPulseEventAdVisible,
                                         MNetPulseEventTrackingSuccess,
                                         MNetPulseEventTrackingError,
                                         MNetPulseEventBannerAdClicked,
                                         MNetPulseEventInterstitialAdClicked,
                                         MNetPulseEventHbAdSlot,
                                         MNetPulseEventError,
                                         MNetPulseEventNetwork,
                                         MNetPulseEventDevice,
                                         MNetPulseEventLocation,
                                         MNetPulseEventDeviceLang,
                                         MNetPulseEventTimezone,
                                         MNetPulseEventAddress,
                                         MNetPulseEventUserAgent,
                                         MNetPulseEventLog,
                                         MNetPulseEventDefault,
                                         MNetPulseEventVideo,
                                         MNetPulseEventImpressionLoad,
                                         MNetPulseEventImpressionSeen,
                                         ];
    NSArray <NSString *> *regulatedEvents = [MNetPulseHttp getRegulatedPulseEvents];
    XCTAssert([regulatedEvents count] > 0, @"There are no un-regulated pulse events");
    
    for(NSString *eventType in allEvents){
        MNetPulseEvent *pulseEvent = [[MNetPulseEvent alloc] initWithType:eventType
                                                              withSubType:eventType
                                                              withMessage:nil
                                                            andCustomData:nil];
        BOOL isRegulated = [MNetPulseHttp isRegulatedForPulseEvent:pulseEvent];
        
        BOOL expectedRegulation = NO;
        for(NSString *regulatedEventType in regulatedEvents){
            if([regulatedEventType isEqualToString:eventType]){
                expectedRegulation = YES;
                break;
            }
        }
        
        XCTAssert(isRegulated == expectedRegulation,
                  @"Event - %@, isRegulated - %@, expectedRegulation - %@",
                  eventType,
                  isRegulated?@"yes":@"no",
                  expectedRegulation?@"yes":@"no"
                  );
    }
}

@end
