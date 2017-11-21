//
//  MNetTestInterstitialNoAd.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "XCTest+MNetTestUtils.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestInterstitialNoAd : MNetTestManager <MNetInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *interstitialNoAdExpectation;
@end

@implementation MNetTestInterstitialNoAd

- (void)setUp {
    [super setUp];
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    [bidStore flushStore];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInterstitialNoAd {
    noAdRequestStub([self class]);
    
    self.interstitialNoAdExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    MNetInterstitialAd *interstitalAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitalAd setInterstitialDelegate:self];
    [interstitalAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd{
    XCTFail(@"Ad view is supposed to fail");
    EXPECTATION_FULFILL(self.interstitialNoAdExpectation);
}

- (void)mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error{
    EXPECTATION_FULFILL(self.interstitialNoAdExpectation);
}

@end
