//
//  MNetPrefetchTests.m
//  MNAdSdk
//
//  Created by nithin.g on 11/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetPrefetchTests : MNetTestManager
@property (nonatomic) XCTestExpectation *prefetchExpectation;
@end

@implementation MNetPrefetchTests

- (void)setUp {
    [super setUp];
}

- (void)testPrefetchRequest{
    validBannerAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.prefetchExpectation = [self expectationWithDescription:@"Expectation for prefetching request"];
    
    NSString *adUnitId = DEMO_MN_AD_UNIT_320x50;
    
    MNetAdRequest *request = [[MNetAdRequest alloc] init];
    [request setWidth:MNET_BANNER_AD_SIZE.width andHeight:MNET_BANNER_AD_SIZE.width];
    [request setAdUnitId:adUnitId];
    [request setRootViewController:[self getViewController]];
    
    [MNetAdPreLoader prefetchWith:request
                         adUnitId:adUnitId
                    guestAdUnitId:adUnitId
               rootViewController:[self getViewController]
                  timeoutInMillis:nil
                          success:^(NSString * _Nonnull cacheKey, NSDictionary * _Nonnull prefetchServerParams, NSString * _Nonnull prefetchAdCycleId) {
                              MNetAdView *adView = (MNetAdView *)[MNetAdPreLoader getCachedViewForCacheKey:cacheKey];
                              
                              NSDictionary *fetchedServerParams = [adView fetchServerParams];
                              XCTAssert(fetchedServerParams != nil);
                              XCTAssert([fetchedServerParams isEqualToDictionary:prefetchServerParams]);
                              
                              NSString *fetchedAdCycleId = [adView fetchAdCycleId];
                              XCTAssert(fetchedAdCycleId != nil);
                              XCTAssert([fetchedAdCycleId isEqualToString:prefetchAdCycleId]);
                              
                              [self.prefetchExpectation fulfill];
                          }
                          failure:^(NSError * _Nonnull error, NSString * _Nonnull adCycleId) {
                              
                          }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Error - %@", error);
        }
    }];
}

@end
