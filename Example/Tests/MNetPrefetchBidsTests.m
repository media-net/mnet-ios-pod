//
//  MNetPrefetchBidsTests.m
//  MNAdSdk
//
//  Created by nithin.g on 18/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetPrefetchBidsTests : MNetTestManager
@property (nonatomic) XCTestExpectation *prefetchExpectation;
@end

@implementation MNetPrefetchBidsTests

- (void)testPrefetchBidRequestEmptyRequest {
    self.prefetchExpectation = [self expectationWithDescription:@"Empty prefetch"];
    
    [[MNetPrefetchBids getInstance] prefetchBidsForAdRequest:nil withCb:^(NSError * _Nullable prefetchErr)
     {
         XCTAssert(prefetchErr != nil);
         EXPECTATION_FULFILL(self.prefetchExpectation);
     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"Error - %@", error);
         }
     }];
}

- (void)testPrefetchBidRequestSample{
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    
    MNetPrefetchBids *prefetcher = [MNetPrefetchBids getInstance];
    prefetcher.adRequest = adRequest;
    [prefetcher modifyAdRequest];
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    XCTAssert(bidRequest != nil);
    XCTAssert([bidRequest fetchAdUnitId] == nil);
    XCTAssert([[[[bidRequest hostAppInfo] intentData] externalData] url] != nil);
    XCTAssert([bidRequest viewControllerTitle] != nil);
    NSLog(@"%@", [MNJMManager toJSONStr:bidRequest]);
}

- (void)testPrefetchBidRequestComplex{
    NSString *contextLink = @"dummy-context-link";
    NSString *VCTitle = @"dummy-title";
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.rootViewController = [self getViewController];
    adRequest.contextLink = contextLink;
    adRequest.viewControllerTitle = VCTitle;
    
    MNetPrefetchBids *prefetcher = [MNetPrefetchBids getInstance];
    prefetcher.adRequest = adRequest;
    [prefetcher modifyAdRequest];
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    XCTAssert(bidRequest != nil);
    XCTAssert([bidRequest fetchAdUnitId] == nil);
    NSString *url = [[[[bidRequest hostAppInfo] intentData] externalData] url];
    XCTAssert(url != nil);
    XCTAssert([bidRequest viewControllerTitle] != nil);
    XCTAssert([[bidRequest viewControllerTitle] isEqualToString:VCTitle]);
    XCTAssert([url isEqualToString:contextLink]);
}

- (void)testPrefetchFlowPositive{
    [self stubPrefetchWithValidResp];
    
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    [bidStore flushStore];
    
    __block NSString *testAdUnitId1 = @"test_ad_unit_1";
    __block NSString *testAdUnitId2 = @"test_ad_unit_2";
    
    self.prefetchExpectation = [self expectationWithDescription:@"End-End prefetch flow"];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setRootViewController:[self getViewController]];
    
    [[MNetPrefetchBids getInstance] prefetchBidsForAdRequest:adRequest
                                                      withCb:^(NSError * _Nullable prefetchErr)
     {
         XCTAssert(prefetchErr == nil);
         NSArray<MNetBidResponse *> *bidResponsesList = [bidStore fetchForAdUnitId:testAdUnitId1];
         XCTAssert(bidResponsesList != nil);
         // NOTE: Only one will be fetched since the other will've expired
         XCTAssert([bidResponsesList count] == 1);
         
         bidResponsesList = nil;
         bidResponsesList = [bidStore fetchForAdUnitId:testAdUnitId2];
         XCTAssert(bidResponsesList != nil);
         // NOTE: Only one will be fetched since the other will've expired
         XCTAssert([bidResponsesList count] == 1);
         
         EXPECTATION_FULFILL(self.prefetchExpectation);
     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"Error - %@", error);
         }
     }];
}

- (void)testPrefetchFlowNegative{
    [self stubPrefetchBidsWithErrorResp];
    
    self.prefetchExpectation = [self expectationWithDescription:@"End-End prefetch flow"];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [[MNetPrefetchBids getInstance] prefetchBidsForAdRequest:adRequest
                                                      withCb:^(NSError * _Nullable prefetchErr)
     {
         XCTAssert(prefetchErr != nil);
         EXPECTATION_FULFILL(self.prefetchExpectation);
     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"Error - %@", error);
         }
     }];
}


- (void)stubPrefetchBidsWithErrorResp{
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPrefetchPredictBidsUrl];
    NSString *requestUrl = [NSString stringWithFormat:@"%@.*", url];
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(@"Invalid Str");
}

- (void)stubPrefetchWithValidResp{
    NSString *respStr = readFile([self class], @"MNetPredictBidsRelayResponse", @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPrefetchPredictBidsUrl];
    NSString *requestUrl = [NSString stringWithFormat:@"%@.*", url];
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
}

@end
