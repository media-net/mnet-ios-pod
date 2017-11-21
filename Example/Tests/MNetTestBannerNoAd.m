//
//  MNetTestBannerNoAd.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "XCTest+MNetTestUtils.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestBannerNoAd : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *bannerNoAdExpectation;
@end

@implementation MNetTestBannerNoAd

- (void)setUp {
    [super setUp];
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    [bidStore flushStore];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBannerNoAd {
    noAdRequestStub([self class]);
    
    self.bannerNoAdExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
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
    XCTFail(@"Adview should not have rendered!");
    EXPECTATION_FULFILL(self.bannerNoAdExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    EXPECTATION_FULFILL(self.bannerNoAdExpectation);
}

@end
