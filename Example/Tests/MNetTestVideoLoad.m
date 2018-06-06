//
//  MNetTestVideoLoad.m
//  MNAdSdk
//
//  Created by kunal.ch on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestVideoLoad : MNetTestManager <MNetVideoDelegate, MNetAdViewDelegate, MNetAdViewSizeDelegate>
@property (nonatomic) XCTestExpectation *videoAdViewExpectation;
@end

@implementation MNetTestVideoLoad

- (void)setUp {
    [self cacheVideoUrl:[[self class] getVideoUrl]];
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testVideoAdLoad {
    validVideoAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.videoAdViewExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [adView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [adView setRootViewController:[self getViewController]];
    [adView setVideoDelegate:self];
    [adView setDelegate:self];
    [adView loadAd];
   
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
    
}

- (void)testVideoAdLoadWithMulitpleAdSizes{
    validVideoAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.videoAdViewExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setAdSizes:@[MNetAdSizeFromCGSize(kMNetBannerAdSize), MNetAdSizeFromCGSize(kMNetMediumAdSize)]];
    [adView setAdSizeDelegate:self];
    [adView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [adView setRootViewController:[self getViewController]];
    [adView setVideoDelegate:self];
    [adView setDelegate:self];
    [adView loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetVideoDidLoad:(MNetAdView *)adView{
    EXPECTATION_FULFILL(self.videoAdViewExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTAssert(error != nil);
    EXPECTATION_FULFILL(self.videoAdViewExpectation);
}

- (void)mnetAdView:(MNetAdView *)adView didChangeSize:(MNetAdSize *)size{
    CGSize adSize = MNetCGSizeFromAdSize(size);
    [adView setFrame:CGRectMake(0.0, 0.0, adSize.width, adSize.height)];
}
@end
