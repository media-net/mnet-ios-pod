//
//  MNetTpdReusePrefetchTimeout.m
//  MNAdSdk
//
//  Created by nithin.g on 05/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetTpdReusePrefetchTimeout : MNetTestManager
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) NSString *adUnitId;
@property (nonatomic) id<MNetBidStoreProtocol> bidStore;
@end

@implementation MNetTpdReusePrefetchTimeout

- (void)setUp {
    [super setUp];
    self.adUnitId = DEMO_MN_AD_UNIT_320x50;
    self.bidStore = [MNetBidStore getStore];
    [self.bidStore flushStore];
    MNetAdViewStore *adViewStore = [MNetAdViewStore getsharedInstance];
    [adViewStore setDefaultTtl:[NSNumber numberWithInteger:0]];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testPrefetchTimeout{
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
                          success:^(NSString * _Nonnull cacheKey,
                                    NSDictionary * _Nonnull params,
                                    NSString * _Nonnull adCycleId,
                                    BOOL areDefaultBids) {
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                  MNetAdView *adView = (MNetAdView *)[[MNetAdViewStore getsharedInstance] popViewForKey:cacheKey];
                                  XCTAssert(adView == nil);
                                  
                                  NSArray<MNetBidResponse *> *bidResponsesList = [self.bidStore fetchForAdUnitId:self.adUnitId];
                                  XCTAssert(bidResponsesList != nil, @"Bidresponses cannot be nil");
                                  XCTAssert([bidResponsesList count] == 2, @"Bidresponses list cannot be empty");
                                  EXPECTATION_FULFILL(self.expectation);
                              });
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

@end
