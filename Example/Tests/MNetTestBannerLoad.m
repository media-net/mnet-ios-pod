//
//  MNetTestBannerLoad.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestBannerLoad : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *bannerAdViewExpectation;
@end

@implementation MNetTestBannerLoad

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBannerAdLoad {
    validBannerAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testBannerAdUrlLoad{
    validBannerAdUrlRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void)mnetAdDidLoad:(MNetAdView *)adView{
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{\
    XCTFail(@"Ad view failed! - %@", error);
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
}

@end
