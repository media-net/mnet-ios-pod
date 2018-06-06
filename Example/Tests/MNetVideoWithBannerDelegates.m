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

- (void)setUp{
    [self cacheVideoUrl:[[self class] getVideoUrl]];
    [super setUp];
}

-(void) testVideoAdLoad {
    validVideoAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.videoWithBannerDelegatesExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [adView setAdUnitId:@"216427370"];
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
