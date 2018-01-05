//
//  MNetDefaultBidsManagerTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 27/12/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetDefaultBidsManagerTests : MNetTestManager
@property (nonatomic) MNetDefaultBid *defaultBid;
@end

@implementation MNetDefaultBidsManagerTests

static NSString *sampleAdUnitId = @"sample-ad-unit-id";
static NSString *contextUrlRegex = @"http://mnadsdkdemo\\.beta\\.media\\.net\\.imnapp[^.]+";
static NSString *contextUrl = @"http://mnadsdkdemo.beta.media.net.imnapp/1-3-0b21/uiviewcontroller?intent=a6e7d5d1b1032af2b708d9f17caf0a27";
static NSUInteger bidVal = 300;
static NSUInteger bidderIdVal = 41;

- (void)setUp{
    self.defaultBid = [self generateDefaultBid];
}

- (MNetDefaultBid *)generateDefaultBid{
    MNetDefaultBid *defaultBid = [MNetDefaultBid new];
    defaultBid.bid = [NSNumber numberWithInteger:bidVal];
    defaultBid.bidderId = [NSNumber numberWithInteger:bidderIdVal];
    defaultBid.contextUrlRegex = contextUrlRegex;
    defaultBid.adUnitId = sampleAdUnitId;
    defaultBid.bidResponse = [self getTestBidResponse];
    
    return defaultBid;
}

- (NSArray<MNetDefaultBid *> *)generatedMultipleBids{
    NSMutableArray<MNetDefaultBid *> *defaultBidsList = [NSMutableArray new];
    NSUInteger numBids = 10;
    NSUInteger numAdUnits = 3;
    for(NSUInteger i=0;i<numBids;i++){
        for (NSUInteger j=0;j<numAdUnits;j++){
            NSNumber *bidderId = [NSNumber numberWithInteger:i];
            NSString *adUnitId = [NSString stringWithFormat:@"%@-%lud", sampleAdUnitId,(unsigned long)j];
            MNetDefaultBid *defaultBid = [self generateDefaultBid];
            defaultBid.bidderId = bidderId;
            defaultBid.adUnitId = adUnitId;
            defaultBid.bidResponse.bidderId = bidderId;
            defaultBid.bidResponse.creativeId = adUnitId;
            [defaultBidsList addObject:defaultBid];
        }
    }
    return defaultBidsList;
}

- (void)testAddBids{
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    NSArray *defaultBidsList = @[self.defaultBid];
    BOOL additionStatus = [bidsManager addDefaultBids:defaultBidsList];
    XCTAssert(additionStatus, @"Addition into the default bid-store failed!");
}

- (void)testAddMultipleBids{
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    BOOL additionStatus = [bidsManager addDefaultBids:[self generatedMultipleBids]];
    XCTAssert(additionStatus, @"Adding multiple default-bids failed!");
}

- (void)testFiltersOnDefaultBids{
    NSMutableArray *defaultBidsList = [[self generatedMultipleBids] mutableCopy];
    MNetDefaultBidsDataStore *dataStore = [MNetDefaultBidsDataStore getSharedInstance];
    
    MNetBidResponse *bidResponse = [dataStore applyFiltersOnDefaultBids:defaultBidsList withContextUrl:contextUrl];
    XCTAssert(bidResponse != nil, @"Apply filters on bids failed to fetch a response");
}

- (void)testGetBids{
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    BOOL additionStatus = [bidsManager addDefaultBids:[self generatedMultipleBids]];
    XCTAssert(additionStatus, @"Adding multiple default-bids failed!");
    
    NSArray<MNetBidResponse *> *bidResponses = [bidsManager getBidResponsesForAdUnitId:@"invalid-adunit-id" andContextUrl:contextUrl];
    XCTAssert(bidResponses == nil, @"getBidResponsesForAdUnitId should return nil for invalid adunitIds");
    NSString *expectedAdUnitId = [NSString stringWithFormat:@"%@-%lud", sampleAdUnitId,(unsigned long)0];
    bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:contextUrl];
    XCTAssert(bidResponses != nil, @"Fetching getBidResponsesForAdUnitIdAndContextUrl failed!");
}

- (void)testGetBidForInvalidUrls{
    NSString *expectedAdUnitId = [NSString stringWithFormat:@"%@-%lud", sampleAdUnitId,(unsigned long)0];
    
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    BOOL additionStatus = [bidsManager addDefaultBids:[self generatedMultipleBids]];
    XCTAssert(additionStatus, @"Adding multiple default-bids failed!");
    
    NSArray<MNetBidResponse *> *bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:nil];
    XCTAssert(bidResponses == nil, "getBidResponsesForAdUnitId should fail");
    
    bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:nil];
    XCTAssert(bidResponses == nil, "getBidResponsesForAdUnitId should fail");
    
    bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:@""];
    XCTAssert(bidResponses == nil, "getBidResponsesForAdUnitId should fail");
    
    bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:@"http://mnadsdkdemo.beta.media.net.imnapp"];
    XCTAssert(bidResponses == nil, "getBidResponsesForAdUnitId should fail");
    
    bidResponses = [bidsManager getBidResponsesForAdUnitId:expectedAdUnitId andContextUrl:@"http://mnadsdkdemo.beta.media.net.imnapp?something_random"];
    XCTAssert(bidResponses != nil, "getBidResponsesForAdUnitId should not fail");
}

- (void)testResponsesContainer{
    NSString *expectedAdUnitId = [NSString stringWithFormat:@"%@-%lud", sampleAdUnitId,(unsigned long)0];
    
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    BOOL additionStatus = [bidsManager addDefaultBids:[self generatedMultipleBids]];
    XCTAssert(additionStatus, @"Adding multiple default-bids failed!");
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    [adRequest setAdUnitId:expectedAdUnitId];
    [adRequest setContextLink:contextUrl];
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    MNetBidResponsesContainer *responseContainer = [bidsManager getDefaultBidsForBidRequest:bidRequest];
    XCTAssert(responseContainer != nil, @"Response container cannot be empty!");
    XCTAssert([responseContainer areDefaultBids] == YES, @"Default bids need to be set in the default-bids response container");
}

- (void)testEmptyBidInsertion{
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    MNetDefaultBid *sampleBid = [self generateDefaultBid];
    sampleBid.adUnitId = @"";
    BOOL additionStatus = [bidsManager addDefaultBids:@[sampleBid]];
    XCTAssert(additionStatus == NO, @"bidsManager should prevent adding bids");
}

- (void)testCatchAllDefaultBid{
    MNetDefaultBidsManager *bidsManager = [MNetDefaultBidsManager getSharedInstance];
    MNetDefaultBid *sampleBid = [self generateDefaultBid];
    [sampleBid setAdUnitId:@"*"];
    [sampleBid setContextUrlRegex:@".*"];
    [bidsManager addDefaultBids:@[sampleBid]];
    
    NSArray<MNetBidResponse *> *bidResponsesList = [bidsManager getBidResponsesForAdUnitId:@"random-adunit-id" andContextUrl:@"random-context-url"];
    XCTAssert(bidResponsesList != nil, @"bid-responses cannot be nil in catch-all case");
    XCTAssert([bidResponsesList count] > 0, @"bid-responses needs to have atleast 1 entry");
}
@end
