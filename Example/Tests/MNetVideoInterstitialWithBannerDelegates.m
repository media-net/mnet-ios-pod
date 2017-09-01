//
//  MNetVideoInterstitialWithBannerDelegates.m
//  MNAdSdk
//
//  Created by nithin.g on 28/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetVideoInterstitialWithBannerDelegates : MNetTestManager <MNetInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *interstitialTestExpectation;
@end

@implementation MNetVideoInterstitialWithBannerDelegates

-(void) testInterstitialVideoAdLoad {
    validVideoAdRequestStub([self class]);
    self.interstitialTestExpectation = [self expectationWithDescription:@"interstitial video load"];
    MNetInterstitialAd *interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitialAd setInterstitialDelegate:self];
    [interstitialAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd{
    EXPECTATION_FULFILL(self.interstitialTestExpectation)
}

- (void)mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error{
    XCTFail(@"The video request should not fail! - %@", [error getErrorString]);
    EXPECTATION_FULFILL(self.interstitialTestExpectation)
}

@end
