//
//  MNetAdViewRepositoryTests.m
//  MNAdSdk
//
//  Created by kunal.ch on 11/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetAdViewRepository.h"
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetAdViewRepositoryTests : MNetTestManager

@end

@implementation MNetAdViewRepositoryTests

- (void)testRepositoryViewPush{
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:bannerAd withCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    MNetAdView *adView = (MNetAdView *)[[MNetAdViewRepository getSharedInstance] getAdViewForCreativeId:DEMO_MN_AD_UNIT_320x50];
    XCTAssertNotNil(adView);
}

- (void)testRepositoryViewFetchFail{
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:bannerAd withCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    MNetAdView *adView = (MNetAdView *)[[MNetAdViewRepository getSharedInstance] getAdViewForCreativeId:@""];
    XCTAssertNil(adView);
}

- (void)testRepositoryMultipleViewsPush{
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:bannerAd withCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    MNetAdView *dummyAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:dummyAd withCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    MNetAdView *dummyBannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:dummyBannerAd withCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    MNetAdView *dummyBannerView = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [[MNetAdViewRepository getSharedInstance] cacheAdView:dummyBannerView withCreativeId:DEMO_MN_AD_UNIT_320x50];

    MNetAdView *adView = (MNetAdView *)[[MNetAdViewRepository getSharedInstance] getAdViewForCreativeId:DEMO_MN_AD_UNIT_320x50];
    
    XCTAssertEqual(adView, dummyAd);
}

- (void)testQueueTimeout{
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Queue timeout tests"];
    NSTimeInterval timeout = 1;
    
    NSString *adUnitId = @"dummy-id";
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    
    NSMutableArray *tempMutableArr = [[NSMutableArray alloc] initWithCapacity:2];
    [tempMutableArr pushQueue:bannerAd withCreativeId:adUnitId andTimeout:timeout];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id item = [tempMutableArr popQueue];
        XCTAssert(item == nil);
        EXPECTATION_FULFILL(expectation);
    });
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Error - %@", error);
        }
    }];
}

@end
