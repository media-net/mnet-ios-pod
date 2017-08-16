//
//  MNetBannerAdTests.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestBannerSansParent : MNetTestManager <MNetAdViewDelegate>

@end

@implementation MNetTestBannerSansParent

XCTestExpectation *adLoadWithoutParentExpectation;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBannerAdCreationWithoutParentView {
    adLoadWithoutParentExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    XCTFail(@"Ad view is supposed to fail!");
    EXPECTATION_FULFILL(adLoadWithoutParentExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    EXPECTATION_FULFILL(adLoadWithoutParentExpectation);
}
@end
