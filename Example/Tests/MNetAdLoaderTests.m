//
//  MNetAdLoaderTests.m
//  MNAdSdk
//
//  Created by nithin.g on 14/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetAdLoaderTests : MNetTestManager
@property (nonatomic) MNetAdLoader *adLoaderMgr;
@property (nonatomic) NSString *adUnitId;
@property (nonatomic) id<MNetBidStoreProtocol> bidStore;
@end

@implementation MNetAdLoaderTests

- (void)setUp{
    [super setUp];
    
    self.adLoaderMgr = [MNetAdLoader getSharedInstance];
    self.adUnitId = @"test_ad_unit_1";
    self.bidStore = [MNetBidStore getStore];
    
    [self.bidStore flushStore];
}

- (void)testGetLoader {
    id loaderObj = [self.adLoaderMgr getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    
    // Testing forced predictBids
    MNetAdLoaderOptions *optionsPredictBids = [MNetAdLoaderOptions getDefaultOptions];
    
    loaderObj = [self.adLoaderMgr getLoaderForAdUnitId:self.adUnitId andOptions:optionsPredictBids];
    XCTAssert([loaderObj isKindOfClass:[MNetAdLoaderPredictBids class]]);
    
    optionsPredictBids.forceAdLoader = MNetAdLoaderTypePrefetchPredictBids;
    loaderObj = [self.adLoaderMgr getLoaderForAdUnitId:self.adUnitId andOptions:optionsPredictBids];
    XCTAssert([loaderObj isKindOfClass:[MNetAdLoaderPrefetchPredictBids class]]);
    optionsPredictBids.forceAdLoader = MNetAdLoaderTypeNone;
    
    // Testing the predictBids after pushing to the bid-store
    
    // Setting a bid-response with the ad-unit-id
    MNetBidResponse *bidResponse = [self getTestBidResponse];
    bidResponse.creativeId = self.adUnitId;
    
    BOOL insertStatus = [self.bidStore insert:bidResponse];
    XCTAssert(insertStatus);
    loaderObj = [self.adLoaderMgr getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([loaderObj isKindOfClass:[MNetAdLoaderPredictBids class]]);
    
    // Testing the predict bids after pushing to bid-store with force option
    insertStatus = [self.bidStore insert:bidResponse];
    XCTAssert(insertStatus);
    loaderObj = [self.adLoaderMgr getLoaderForAdUnitId:self.adUnitId andOptions:optionsPredictBids];
    XCTAssert([loaderObj isKindOfClass:[MNetAdLoaderPredictBids class]]);
}

- (void)testAdLoaderBidInfo{
    MNetBidResponse *bidResponse = [self getTestBidResponse];
    XCTAssert(bidResponse.bidInfo != nil);
    
    NSArray *expectedKeys = @[
                              @"cmp_id",
                              @"adv_id",
                              @"adv_nm",
                              @"adv_url",
                              @"b_id",
                              @"di",
                              @"dt",
                              @"prv_acc_id"
                              ];
    
    for(NSString *expectedKey in expectedKeys){
        XCTAssert([bidResponse.bidInfo objectForKey:expectedKey] != nil);
    }
}

- (void)testAdLoaderBidderInfo{
    MNetBidResponse *bidResponse = [self getTestBidResponse];
    XCTAssert(bidResponse.bidInfo != nil);
    
    MNetBidderInfo *bidderInfo = [MNetBidderInfo createInstanceFromBidResponse:bidResponse];
    XCTAssert(bidderInfo != nil);
    XCTAssert(bidderInfo.bidderId != nil);
    XCTAssert(bidderInfo.bidInfo == bidResponse.bidInfo);
}

- (void)testAdloaderPredictBidsSimpleBidRequest{
    MNetBidResponse *bidResponse = [self getTestBidResponse];
    bidResponse.creativeId = self.adUnitId;
    
    BOOL insertStatus = [self.bidStore insert:bidResponse];
    XCTAssert(insertStatus);
    
    // Fetching the predict-bids ad-loader
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    
    // Creating a bid-request from the ad-request object
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.adUnitId = self.adUnitId;

    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    XCTAssert(bidRequest.bidders == nil);
    
    adLoaderPredictBids.bidRequest = bidRequest;
    
    [adLoaderPredictBids updateCachedBidResponsesFromBidStore];
    [adLoaderPredictBids updateBidRequestWithCachedBids];
    
    MNetBidRequest *modifiedBidRequest = adLoaderPredictBids.bidRequest;
    XCTAssert(modifiedBidRequest != nil);
    XCTAssert(modifiedBidRequest.bidders != nil);
}

- (void)testAdloaderPredictBidsMultipleBidRequest{
    // Adding bid-responses with different bidder_id
    NSUInteger numBidResponses = 10;
    for(NSUInteger i=1; i<=numBidResponses; i++){
        MNetBidResponse *bidResponse = [self getTestBidResponse];
        bidResponse.creativeId = self.adUnitId;
        bidResponse.bidderId = [NSNumber numberWithUnsignedInteger:i];
        
        BOOL insertStatus = [self.bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    // Fetching the predict-bids ad-loader
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    
    // Creating a bid-request from the ad-request object
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.adUnitId = self.adUnitId;
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    XCTAssert(bidRequest.bidders == nil);
    
    adLoaderPredictBids.bidRequest = bidRequest;
    [adLoaderPredictBids updateCachedBidResponsesFromBidStore];
    [adLoaderPredictBids updateBidRequestWithCachedBids];
    
    MNetBidRequest *modifiedBidRequest = adLoaderPredictBids.bidRequest;
    XCTAssert(modifiedBidRequest != nil);
    XCTAssert(modifiedBidRequest.bidders != nil);
    
    NSArray<MNetBidderInfo *> *bidders = modifiedBidRequest.bidders;
    XCTAssert([bidders count] == numBidResponses);
    
    NSString *bidRequestStr = [MNJMManager toJSONStr:modifiedBidRequest];
    NSLog(@"Printing the bid-request");
    NSLog(@"%@", bidRequestStr);
}

- (void)testPredictAdLoaderCanPerformAuctionFailure1{
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    BOOL canPerformAuction = [adLoaderPredictBids canPerformAuctionWithCachedEntries];
    XCTAssert(canPerformAuction == NO);
}

- (void)testPredictAdLoaderCanPerformAuctionFailure2{
    int limit = 5;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] init];
    for(int i=0; i<limit; i++){
        MNetBidResponse *bidResponse = [self getTestBidResponse];
        bidResponse.creativeId = self.adUnitId;
        bidResponse.extension = [[MNetBidResponseExtension alloc] init];
        bidResponse.extension.isFinal = [MNJMBoolean createWithBool:YES];
        bidResponse.expiry = nil;
        bidResponse.bidType = BID_TYPE_FIRST_PARTY;
        bidResponse.bidderId = [NSNumber numberWithInteger:i];
        
        [bidResponsesList addObject:bidResponse];
    }
    
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    adLoaderPredictBids.cachedBidResponses = bidResponsesList;
    adLoaderPredictBids.adUnitId = self.adUnitId;
    
    BOOL canPerformAuction = [adLoaderPredictBids canPerformAuctionWithCachedEntries];
    XCTAssert(canPerformAuction == NO);
}

- (void)testPredictAdLoaderCanPerformAuctionSuccess1{
    int limit = 7;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] init];
    for(int i=1; i<limit; i++){
        MNetBidResponse *bidResponse = [self getTestBidResponse];
        bidResponse.creativeId = self.adUnitId;
        bidResponse.extension = [[MNetBidResponseExtension alloc] init];
        bidResponse.extension.isFinal = [MNJMBoolean createWithBool:YES];
        bidResponse.expiry = nil;
        bidResponse.bidType = BID_TYPE_FIRST_PARTY;
        bidResponse.bidderId = [NSNumber numberWithInteger:i];
        
        [bidResponsesList addObject:bidResponse];
    }
    
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    adLoaderPredictBids.cachedBidResponses = bidResponsesList;
    adLoaderPredictBids.adUnitId = self.adUnitId;
    
    BOOL canPerformAuction = [adLoaderPredictBids canPerformAuctionWithCachedEntries];
    XCTAssert(canPerformAuction == YES);
}

- (void)testPredictAdLoaderCanPerformAuctionSuccess2{
    int limit = 20;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] init];
    for(int i=1; i<limit; i++){
        MNetBidResponse *bidResponse = [self getTestBidResponse];
        bidResponse.creativeId = self.adUnitId;
        bidResponse.extension = [[MNetBidResponseExtension alloc] init];
        bidResponse.extension.isFinal = [MNJMBoolean createWithBool:YES];
        bidResponse.expiry = nil;
        bidResponse.bidType = BID_TYPE_FIRST_PARTY;
        bidResponse.bidderId = [NSNumber numberWithInteger:i];
        
        [bidResponsesList addObject:bidResponse];
    }
    
    id<MNetAdLoaderProtocol> adLoader = [[MNetAdLoader getSharedInstance] getLoaderForAdUnitId:self.adUnitId andOptions:nil];
    XCTAssert([adLoader isKindOfClass:[MNetAdLoaderPredictBids class]]);
    MNetAdLoaderPredictBids *adLoaderPredictBids = (MNetAdLoaderPredictBids *)adLoader;
    adLoaderPredictBids.cachedBidResponses = bidResponsesList;
    adLoaderPredictBids.adUnitId = self.adUnitId;
    
    BOOL canPerformAuction = [adLoaderPredictBids canPerformAuctionWithCachedEntries];
    XCTAssert(canPerformAuction == YES);
}

- (void)testPredictAdLoaderEndToEndWithCachedResponse{
    [self stubPredictWithValidResp];
    
    MNetBidResponse *bidResponse = [self getTestBidResponse];
    bidResponse.creativeId = self.adUnitId;
    bidResponse.extension = [[MNetBidResponseExtension alloc] init];
    bidResponse.extension.isFinal = [MNJMBoolean createWithBool:NO];
    bidResponse.expiry = nil;
    bidResponse.bidType = BID_TYPE_FIRST_PARTY;
    
    [self.bidStore insert:bidResponse];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:self.adUnitId];
    
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:adRequest
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesContainer)
     {
         XCTAssert(bidResponsesContainer != nil);
         NSArray<MNetBidResponse *> *bidResponsesArr = [bidResponsesContainer bidResponsesArr];
         XCTAssert(bidResponsesArr != nil);
         XCTAssert([bidResponsesArr count] != 0);
         EXPECTATION_FULFILL(expectation);
     }
                   fail:^(NSError * _Nonnull error)
     {
         XCTFail(@"Cannot fail!");
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testPredictAdLoaderEndToEndSimpleResponse{
    [self stubPredictWithValidResp];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:self.adUnitId];
    
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:adRequest
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesContainer)
     {
         XCTAssert(bidResponsesContainer != nil);
         NSArray<MNetBidResponse *> *bidResponsesArr = [bidResponsesContainer bidResponsesArr];
         XCTAssert(bidResponsesArr != nil);
         XCTAssert([bidResponsesArr count] != 0);
         EXPECTATION_FULFILL(expectation);
     }
                   fail:^(NSError * _Nonnull error)
     {
         XCTFail(@"Cannot fail!");
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testPredictAdLoaderEndToEndWithEmptyResponse{
    [self stubPredictWithValidResp];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:@"some_random_adunit_id"];
    
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:adRequest
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesContainer)
     {
         XCTFail(@"Cannot Succeed! Adunit id is wrong!");
     }
                   fail:^(NSError * _Nonnull error)
     {
         EXPECTATION_FULFILL(expectation);
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testPredictAdLoaderEndToEndWithInvalidResponse{
    [self stubPredictBidsWithErrorResp];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:@"some_random_adunit_id"];
    
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:adRequest
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesArr)
     {
         XCTFail(@"Cannot Succeed! Adunit id is wrong!");
     }
                   fail:^(NSError * _Nonnull error)
     {
         EXPECTATION_FULFILL(expectation);
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testAdLoadersWithEmptyRequest{
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:nil
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesArr)
     {
         XCTFail(@"Cannot pass!");
     }
                   fail:^(NSError * _Nonnull error)
     {
         EXPECTATION_FULFILL(expectation);
         
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testPredictAdLoaderWithInvalidResponseForCachedAds{
    [self stubPredictBidsWithErrorResp];
    NSString *dummyAdUnitId = @"some_random_adunit_id";
    
    // Add the bidResponse to the bidStore
    MNetBidResponse *sampleBidResponse = [self getTestBidResponse];
    sampleBidResponse.creativeId = dummyAdUnitId;
    [self.bidStore insert:sampleBidResponse];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:dummyAdUnitId];
    
    MNetAdLoader *adLoader = [MNetAdLoader getSharedInstance];
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Ad-loader end-end"];
    
    [adLoader loadAdFor:adRequest
            withOptions:nil
       onViewController:nil
                success:^(MNetBidResponsesContainer * _Nonnull bidResponsesContainer)
     {
         EXPECTATION_FULFILL(expectation);
     }
                   fail:^(NSError * _Nonnull error)
     {
         XCTFail(@"Cannot fail!");
         EXPECTATION_FULFILL(expectation);
     }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError * _Nullable error)
     {
         if(error){
             NSLog(@"%@", error);
         }
     }];
}

- (void)testPrefetchCachedBidEntries1{
    NSUInteger numAdUnits = 1;
    NSUInteger numBidders = 10;
    for(NSUInteger adUnitId=0; adUnitId < numAdUnits; adUnitId++){
        for(NSUInteger bidderId=0; bidderId< numBidders; bidderId++){
            MNetBidResponse *bidResponse = [self getTestBidResponse];
            bidResponse.creativeId = self.adUnitId;
            bidResponse.bidderId = [NSNumber numberWithInteger:bidderId];
            BOOL insertStatus = [self.bidStore insert:bidResponse];
            XCTAssert(insertStatus == YES);
        }
    }
    
    MNetBidRequest *bidRequest = [MNetBidRequest new];
    MNetAdLoaderPrefetchPredictBids *adLoader = [MNetAdLoaderPrefetchPredictBids getLoaderInstance];
    [adLoader updateBidRequestWithBidCounts:bidRequest];
    
    NSDictionary *cachedBidInfoMap = [bidRequest cachedBidInfoMap];
    XCTAssert(cachedBidInfoMap != nil);
    XCTAssert([[cachedBidInfoMap allKeys] count] == 1);
    XCTAssert([[[cachedBidInfoMap allKeys] firstObject] isEqualToString:self.adUnitId]);
    
    NSDictionary *countMap = [cachedBidInfoMap objectForKey:self.adUnitId];
    XCTAssert([countMap count] == numBidders);
    for(NSString *bidderIdStr in countMap){
        NSNumber *val = [countMap objectForKey:bidderIdStr];
        XCTAssert([val isEqualToValue: [NSNumber numberWithInteger:1]]);
    }
    
    NSDictionary *expectedCachedMap = @{
                                        @"0": [NSNumber numberWithInteger:1],
                                        @"1": [NSNumber numberWithInteger:1],
                                        @"2": [NSNumber numberWithInteger:1],
                                        @"3": [NSNumber numberWithInteger:1],
                                        @"4": [NSNumber numberWithInteger:1],
                                        @"5": [NSNumber numberWithInteger:1],
                                        @"6": [NSNumber numberWithInteger:1],
                                        @"7": [NSNumber numberWithInteger:1],
                                        @"8": [NSNumber numberWithInteger:1],
                                        @"9": [NSNumber numberWithInteger:1],
                                        };
    XCTAssert([expectedCachedMap isEqualToDictionary:countMap]);
}

- (void)testPrefetchCachedBidEntries2{
    NSUInteger numAdUnits = 10;
    NSUInteger numBidders = 10;
    for(NSUInteger adUnitId=1; adUnitId <= numAdUnits; adUnitId++){
        for(NSUInteger bidderId=1; bidderId<= numBidders; bidderId++){
            for(NSUInteger entries=0; entries< bidderId; entries++){
                MNetBidResponse *bidResponse = [self getTestBidResponse];
                bidResponse.creativeId = [[NSNumber numberWithInteger:adUnitId] stringValue];
                bidResponse.bidderId = [NSNumber numberWithInteger:bidderId];
                BOOL insertStatus = [self.bidStore insert:bidResponse];
                XCTAssert(insertStatus == YES);
            }
        }
    }
    
    MNetBidRequest *bidRequest = [MNetBidRequest new];
    MNetAdLoaderPrefetchPredictBids *adLoader = [MNetAdLoaderPrefetchPredictBids getLoaderInstance];
    [adLoader updateBidRequestWithBidCounts:bidRequest];
    
    NSDictionary *cachedBidInfoMap = [bidRequest cachedBidInfoMap];
    XCTAssert(cachedBidInfoMap != nil);
    XCTAssert([[cachedBidInfoMap allKeys] count] == numAdUnits);
    
    NSDictionary *expectedCachedMap = @{
                                        @"1": [NSNumber numberWithInteger:1],
                                        @"2": [NSNumber numberWithInteger:2],
                                        @"3": [NSNumber numberWithInteger:3],
                                        @"4": [NSNumber numberWithInteger:4],
                                        @"5": [NSNumber numberWithInteger:5],
                                        @"6": [NSNumber numberWithInteger:6],
                                        @"7": [NSNumber numberWithInteger:7],
                                        @"8": [NSNumber numberWithInteger:8],
                                        @"9": [NSNumber numberWithInteger:9],
                                        @"10": [NSNumber numberWithInteger:10],
                                        };
    
    for(NSString *adUnitId in cachedBidInfoMap){
        NSDictionary *countMap = [cachedBidInfoMap objectForKey:adUnitId];
        XCTAssert([countMap isEqualToDictionary:expectedCachedMap]);
    }
}

- (void)testPrefetchCachedBidEntriesForAdUnitId{
    NSUInteger numAdUnits = 10;
    NSUInteger numBidders = 10;
    for(NSUInteger adUnitId=1; adUnitId <= numAdUnits; adUnitId++){
        for(NSUInteger bidderId=1; bidderId<= numBidders; bidderId++){
            for(NSUInteger entries=0; entries< bidderId; entries++){
                MNetBidResponse *bidResponse = [self getTestBidResponse];
                bidResponse.creativeId = [[NSNumber numberWithInteger:adUnitId] stringValue];
                bidResponse.bidderId = [NSNumber numberWithInteger:bidderId];
                BOOL insertStatus = [self.bidStore insert:bidResponse];
                XCTAssert(insertStatus == YES);
            }
        }
    }
    
    MNetBidRequest *bidRequest = [MNetBidRequest new];
    MNetAdLoaderPrefetchPredictBids *adLoader = [MNetAdLoaderPrefetchPredictBids getLoaderInstance];
    NSString *adUnitId = @"7";
    [adLoader setAdUnitId:adUnitId];
    [adLoader updateBidRequestWithBidCounts:bidRequest];
    
    NSDictionary *cachedBidInfoMap = [bidRequest cachedBidInfoMap];
    XCTAssert(cachedBidInfoMap != nil);
    XCTAssert([[cachedBidInfoMap allKeys] count] == 1);
    XCTAssert([[cachedBidInfoMap allKeys] firstObject] == adUnitId);
    
    NSDictionary *expectedCachedMap = @{
                                        @"1": [NSNumber numberWithInteger:1],
                                        @"2": [NSNumber numberWithInteger:2],
                                        @"3": [NSNumber numberWithInteger:3],
                                        @"4": [NSNumber numberWithInteger:4],
                                        @"5": [NSNumber numberWithInteger:5],
                                        @"6": [NSNumber numberWithInteger:6],
                                        @"7": [NSNumber numberWithInteger:7],
                                        @"8": [NSNumber numberWithInteger:8],
                                        @"9": [NSNumber numberWithInteger:9],
                                        @"10": [NSNumber numberWithInteger:10],
                                        };
    NSDictionary *countMap = [cachedBidInfoMap objectForKey:adUnitId];
    XCTAssert([countMap isEqualToDictionary:expectedCachedMap]);
}

- (void)testPrefetchCachedBidEntriesForAdUnitIdInvalid{
    MNetBidRequest *bidRequest = [MNetBidRequest new];
    MNetAdLoaderPrefetchPredictBids *adLoader = [MNetAdLoaderPrefetchPredictBids getLoaderInstance];
    NSString *adUnitId = @"7";
    [adLoader setAdUnitId:adUnitId];
    [adLoader updateBidRequestWithBidCounts:bidRequest];
    
    NSDictionary *cachedBidInfoMap = [bidRequest cachedBidInfoMap];
    XCTAssert(cachedBidInfoMap == nil);
}

#pragma mark - Stubs

- (void)stubPredictBidsWithErrorResp{
    NSString *requestUrl = @"http://.*?/rtb/bids.*";
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(@"Invalid Str");
    stubPrefetchReq([self class]);
}

- (void)stubPredictWithValidResp{
    NSString *respStr = readFile([self class], @"MNetPredictBidsRelayResponse", @"json");
    
    NSString *requestUrl = @"http://.*?/rtb/bids.*";
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
    
    stubPrefetchReq([self class]);
}

@end
