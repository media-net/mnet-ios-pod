//
//  MNetVideoWithBannerDelegates.m
//  MNAdSdk
//
//  Created by nithin.g on 28/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"

@interface MNetVideoWithBannerDelegates : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *videoWithBannerDelegatesExpectation;
@end

@implementation MNetVideoWithBannerDelegates

-(void) testVideoAdLoad {
    validVideoAdRequestStub([self class]);
    self.videoWithBannerDelegatesExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setSize:MNET_BANNER_AD_SIZE];
    [adView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [adView setRootViewController:[self getViewController]];
    [adView setDelegate:self];
    [adView loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
    
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    EXPECTATION_FULFILL(self.videoWithBannerDelegatesExpectation)
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTFail(@"Video adview should not fail! - %@", [error getErrorString]);
    EXPECTATION_FULFILL(self.videoWithBannerDelegatesExpectation)
}

@end
