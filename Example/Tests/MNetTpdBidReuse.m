//
//  MNetTpdBidReuse.m
//  MNAdSdk
//
//  Created by nithin.g on 05/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetTpdBidReuse : MNetTestManager <MNetAdViewDelegate>
@property id<MNetBidStoreProtocol> bidStore;
@property XCTestExpectation *expectation;
@property NSString *adUnitId;
@end

@implementation MNetTpdBidReuse

- (void)setUp {
    [super setUp];
    self.adUnitId = DEMO_MN_AD_UNIT_320x50;
    self.bidStore = [MNetBidStore getStore];
    [self.bidStore flushStore];
}

- (void)testDedicatedSlot{
    validBannerAdRequestStub([self class]);
    
    self.expectation = [self expectationWithDescription:@"Dedicated slots for tpd reuse"];
    
    MNetAdView *adView = [MNetAdView initWithAdUnitId:self.adUnitId];
    [adView setSize:kMNetBannerAdSize];
    [adView setDelegate:self];
    [adView setRootViewController:[self getViewController]];
    [adView loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    NSArray<MNetBidResponse *> *bidResponsesList = [self.bidStore fetchForAdUnitId:self.adUnitId];
    XCTAssert(bidResponsesList != nil, @"Bidresponses cannot be nil");
    XCTAssert([bidResponsesList count] == 1, @"Bidresponses list cannot be empty");
    
    EXPECTATION_FULFILL(self.expectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTFail(@"Ad load cannot fail! - %@", error);
    EXPECTATION_FULFILL(self.expectation);
}

@end
