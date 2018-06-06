//
//  MNetTestChildContentRequests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 20/12/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetTestChildContentRequests : MNetTestManager

@end

static NSString *DUMMY_AD_UNIT_ID = @"dummy-ad-unit-id";
static NSString *DUMMY_CONTEXT_LINK = @"context-link";

@implementation MNetTestChildContentRequests

- (void)testChildContentRequest{
    [self runTestWithChildDirectedStatus:YES];
}
- (void)testNonChildContentRequest{
    [self runTestWithChildDirectedStatus:NO];
}

- (void)runTestWithChildDirectedStatus:(BOOL)isChildDirected{
    [[MNet getInstance] setAppContainsChildDirectedContent:isChildDirected];
    
    BOOL isInterstitial = NO;
    CGSize dummySize = kMNetBannerAdSize;
    
    // Create a bid-request
    MNetAdRequest *request = [MNetAdRequest newRequest];
    [request setAdUnitId:DUMMY_AD_UNIT_ID];
    [request setIsInterstitial:isInterstitial];
    [request setAdSizes:@[MNetAdSizeFromCGSize(dummySize)]];
    [request setContextLink:DUMMY_CONTEXT_LINK];
    [request setRootViewController:[self getViewController]];
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:request];
    id reqDict = [MNJMManager getCollectionFromObj:bidRequest];
    // NSString *reqJson = [MNJMManager toJSONStr:bidRequest];
    
    // Assert for correctness here
    XCTAssert(reqDict != nil, @"Parsed object shouldn't be nil");
    NSLog(@"The parsed object is - ");
    
    MNetDeviceInfo *deviceInfo = [bidRequest deviceInfo];
    // Force doNotTrackForEurope flag to be same as isChildDirected flag
    [deviceInfo setDoNotTrackForEurope:isChildDirected];
    
    // Nil value keys -
    NSArray *nilValKeys = @[
                            @"deviceLang",
                            @"mac",
                            @"carrier"
                            ];
    for(NSString *nilValKey in nilValKeys){
        if(isChildDirected){
            XCTAssert([deviceInfo valueForKey:nilValKey] == nil,
                      @"Device info key - %@ is not nil in child-directed-content!", nilValKey);
        }else{
            XCTAssert([deviceInfo valueForKey:nilValKey] != nil,
                      @"Device info key - %@ is nil in non-child-directed-content", nilValKey);
        }
    }
    
    if(isChildDirected){
        XCTAssert([[[bidRequest requestRegulation] isChildDirected] intValue] == 1,
                  @"Request regulation for coppa is incorrectly set to 0");
        XCTAssert([deviceInfo.limitedAdTracking boolValue] == YES,
                  @"Limited ad-tracking needs to be YES");
    }else{
        XCTAssert([[[bidRequest requestRegulation] isChildDirected] intValue] == 0,
                  @"Request regulation for coppa is incorrectly set to 1");
        XCTAssert([deviceInfo.limitedAdTracking boolValue] == NO,
                  @"Limited ad-tracking needs to be NO"
                  );
    }
}

- (void)skip_testBenchmarkForIfaWithChildDirectedDisabled{
    [[MNet getInstance] setAppContainsChildDirectedContent:NO];
    MNetAdIdManager *adIdManager = [MNetAdIdManager getSharedInstance];
    [self measureBlock:^{
        [adIdManager getAdvertId];
    }];
    
    NSString *adId = [adIdManager getAdvertId];
    XCTAssert(adId != nil, @"Ad id cannot be nil");
}

- (void)skip_testBenchmarkForIfaWithChildDirectedEnabled{
    [[MNet getInstance] setAppContainsChildDirectedContent:YES];
    MNetAdIdManager *adIdManager = [MNetAdIdManager getSharedInstance];
    [self measureBlock:^{
        [adIdManager getAdvertId];
    }];
    
    NSString *adId = [adIdManager getAdvertId];
    XCTAssert(adId != nil, @"Ad id cannot be nil");
}

@end
