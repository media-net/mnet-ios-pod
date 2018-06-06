//
//  MNetBannerAd.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//


#import "XCTest+MNetTestUtils.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestBannerIncomplete : MNetTestManager <MNetAdViewDelegate>

@end

@implementation MNetTestBannerIncomplete

XCTestExpectation *bannerIncompleteExpectation;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBannerAdLoadIncompleteFields {
    bannerIncompleteExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [bannerAd setDelegate:self];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testBannerAdWrongRequest {
    bannerIncompleteExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    // Incomplete request
    MNetAdRequest *request = [[MNetAdRequest alloc] init];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setDelegate:self];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd loadAdForRequest:request];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testBannerAdLoadIncompleteAdunit {
    bannerIncompleteExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    XCTFail(@"AdView is expected to fail!");
    EXPECTATION_FULFILL(bannerIncompleteExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    NSLog(@"Ad view failed! - %@", error);
    EXPECTATION_FULFILL(bannerIncompleteExpectation);
}

@end
