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

@interface MNetTestBannerLoad : MNetTestManager <MNetAdViewDelegate, MNetAdViewSizeDelegate>
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
    
    MNetAdView *bannerAd = [[MNetAdView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 50.0)];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
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
    
    MNetAdView *bannerAd = [[MNetAdView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 50.0)];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
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

- (void)testBannerAdLoadWithMultipleAdSizes{
    validBannerAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSizes:@[MNetAdSizeFromCGSize(kMNetBannerAdSize), MNetAdSizeFromCGSize(kMNetMediumAdSize)]];
    [bannerAd setAdSizeDelegate:self];
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

- (void)testContextLink{
    validBannerAdUrlRequestStub([self class]);
    stubPrefetchReq([self class]);
    NSString *contextLink = @"https://media.net";
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 50.0)];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setContextLink:contextLink];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
    XCTAssertTrue([[bannerAd.adBaseObj fetchVCLink] isEqualToString:contextLink]);
}

-(void)mnetAdDidLoad:(MNetAdView *)adView{
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
    XCTAssertTrue([adView.adBaseObj isAdLoaded]);
    XCTAssertFalse([adView.adBaseObj isAdShown]);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTFail(@"Ad view failed! - %@", error);
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
    XCTAssertFalse([adView.adBaseObj isAdLoaded]);
    XCTAssertFalse([adView.adBaseObj isAdShown]);
}

- (void)mnetAdView:(MNetAdView *)adView didChangeSize:(MNetAdSize *)size{
    CGSize adSize = MNetCGSizeFromAdSize(size);
    [adView setFrame:CGRectMake(0.0, 0.0, adSize.width, adSize.height)];
}
@end
