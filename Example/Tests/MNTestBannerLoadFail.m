//
//  MNTestBannerLoadFail.m
//  MNAdSdk_Tests
//
//  Created by kunal.ch on 09/04/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"


@interface MNTestBannerLoadFail : MNetTestManager<MNetAdViewDelegate, MNetAdViewSizeDelegate>
@property (nonatomic) XCTestExpectation *bannerAdViewExpectation;
@end

@implementation MNTestBannerLoadFail

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// Here the response will have 320x50, but the adview frame is 200x300
// So the request should fail as the adview cannot handle response frame
- (void)testBannerAdLoadWithInvalidAdViewFrame{
    validBannerAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    UIViewController *vc = [self getViewController];
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSizes: @[MNetAdSizeFromCGSize(kMNetMediumAdSize), MNetAdSizeFromCGSize(kMNetBannerAdSize)]];
    [bannerAd setAdSizeDelegate:self];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:vc];
    [bannerAd setDelegate:self];
    
    [vc.view addSubview:bannerAd];
    [bannerAd setFrame:CGRectMake(0, 0, 200, 300)];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

// In this case the response will have ad size that device cannot handle, so the test should fail
- (void)testBannerAdLoadWithInvalidAdSizeInResponse{
    invalidBannerAdSizeRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.bannerAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    UIViewController *vc = [self getViewController];
    MNetAdView *bannerAd = [[MNetAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [bannerAd setAdSizes: @[MNetAdSizeFromCGSize(kMNetMediumAdSize), MNetAdSizeFromCGSize(kMNetBannerAdSize)]];
    [bannerAd setAdSizeDelegate:self];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:vc];
    [bannerAd setDelegate:self];
    
    [vc.view addSubview:bannerAd];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void)mnetAdDidLoad:(MNetAdView *)adView{
    XCTFail(@"Ad should fail with invalid ad size error");
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    NSLog(@"Error : %@", [error getErrorReasonString]);
    EXPECTATION_FULFILL(self.bannerAdViewExpectation);
}

- (void)mnetAdView:(nonnull MNetAdView *)adView didChangeSize:(nonnull MNetAdSize *)size {
    // Not setting adview frame here as we are testing for fail cases
}

@end
