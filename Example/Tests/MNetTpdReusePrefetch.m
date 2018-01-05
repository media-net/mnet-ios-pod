//
//  MNetTpdReusePrefetch.m
//  MNAdSdk
//
//  Created by nithin.g on 05/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetTpdReusePrefetch : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) NSString *adUnitId;
@property (nonatomic) MNetAdView *adView;
@property (nonatomic) id<MNetBidStoreProtocol> bidStore;
@end

@implementation MNetTpdReusePrefetch

- (void)setUp {
    [super setUp];
    self.adUnitId = DEMO_MN_AD_UNIT_320x50;
    self.bidStore = [MNetBidStore getStore];
    [self.bidStore flushStore];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testPrefetchWithWinningCall{
    validBannerAdRequestStub([self class]);
    
    self.expectation = [self expectationWithDescription:@"Dedicated slots for prefetch tpd reuse"];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.adUnitId = self.adUnitId;
    [adRequest setWidth:320 andHeight:50];
    [adRequest setIsInterstitial:NO];
    
    [MNetAdPreLoader prefetchWith:adRequest
                         adUnitId:self.adUnitId
                    guestAdUnitId:self.adUnitId
               rootViewController:[self getViewController]
                  timeoutInMillis:nil
                          success:^(NSString * _Nonnull cacheKey, NSDictionary * _Nonnull params, NSString * _Nonnull adCycleId, BOOL areDefaultBids) {
                              self.adView = (MNetAdView *)[[MNetAdViewStore getsharedInstance] popViewForKey:cacheKey];
                              XCTAssert(self.adView != nil);
                              
                              [self.adView setDelegate:self];
                              [self.adView selectBidderIdStr:@"23"];
                              [self.adView loadAd];
                              
                          } failure:^(NSError * _Nonnull error, NSString * _Nonnull adCycleId) {
                              XCTFail(@"Prefetch request should not fail! - %@", error);
                              EXPECTATION_FULFILL(self.expectation);
                          }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    NSArray<MNetBidResponse *> *bidResponsesList = [self.bidStore fetchForAdUnitId:self.adUnitId];
    XCTAssert(bidResponsesList != nil, @"Bidresponses cannot be nil");
    XCTAssert([bidResponsesList count] == 1, @"Bidresponses list cannot be empty");
    MNetBidResponse *bidResponse = [bidResponsesList objectAtIndex:0];
    XCTAssert([[bidResponse bidType] isEqualToString:BID_TYPE_FIRST_PARTY]);
    EXPECTATION_FULFILL(self.expectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTFail(@"Ad-load shouldn't have failed here - %@", error);
    EXPECTATION_FULFILL(self.expectation);
}

@end
