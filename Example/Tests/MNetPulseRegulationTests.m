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
    
    // TODO: Need to fetch the regulated events from the pulse-event types or something I guess
    NSArray <NSString *> *allEvents  = @[
                                         MNetPulseEventBase,
                                         MNetPulseEventSessionTime,
                                         MNetPulseEventEnteredBackground,
                                         MNetPulseEventAnalytics,
                                         MNetPulseEventActivityContext,
                                         MNetPulseEventResponseDuration,
                                         MNetPulseEventProcessedPrediction,
                                         MNetPulseEventAdVisible,
                                         MNetPulseEventTrackingSuccess,
                                         MNetPulseEventTrackingError,
                                         MNetPulseEventBannerAdClicked,
                                         MNetPulseEventInterstitialAdClicked,
                                         MNetPulseEventLocalApps,
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
    NSArray <NSString *>*unregulatedEvents = [MNetPulseHttp getUnregulatedPulseEvents];
    XCTAssert([unregulatedEvents count] > 0, @"There are no un-regulated pulse events");
    NSString *dummySubType = @"dummy";
    for(NSString *eventType in allEvents){
        MNetPulseEvent *pulseEvent = [[MNetPulseEvent alloc] initEventWithType:eventType
                                                                    AndSubType:dummySubType
                                                                 AndCustomData:nil];
        BOOL isRegulated = [MNetPulseHttp isRegulatedForPulseEvent:pulseEvent];
        BOOL expectedRegulation = YES;
        
        for(NSString *unregulatedEventType in unregulatedEvents){
            if([unregulatedEventType isEqualToString: eventType]){
                expectedRegulation = NO;
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
