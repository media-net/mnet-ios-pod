//
//  MNetBidStoreTests.m
//  MNAdSdk
//
//  Created by nithin.g on 07/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetBidStoreTests : MNetTestManager
@end

static NSString *adUnitPrefix = @"creative_";
@implementation MNetBidStoreTests

- (void)setUp{
    [super setUp];
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    [bidStore flushStore];
}

- (void)testEmptyBidStores{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    XCTAssert([bidStore insert:nil] == NO);
}

- (void)testExpiryBids{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    NSUInteger numEntries = 10;
    NSUInteger numAdUnits = 2;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numEntries withNumAdunits:numAdUnits withNumBidIds:numEntries];
    
    NSMutableArray<NSString *> *expectedPubIds = [[NSMutableArray<NSString *> alloc] init];
    
    for(int i=0; i<numEntries; i++){
        MNetBidResponse *bidResponse = [bidResponsesList objectAtIndex:i];
        
        // Making some responses expire, and skip them in the final list
        if([bidResponse.creativeId isEqualToString:[NSString stringWithFormat:@"%@%d", adUnitPrefix, 1]]){
            bidResponse.expiry = [MNetUtil getTimestampInMillis];
        }else{
            [expectedPubIds addObject:bidResponse.publisherId];
        }
        
        BOOL insertResp = [bidStore insert:bidResponse];
        XCTAssert(insertResp == YES);
    }
    
    XCTAssert([expectedPubIds count] > 0);
    
    for(int i=0; i<numAdUnits; i++){
        NSString *adUnitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, i+1];
        NSArray<MNetBidResponse *> *poppedResponseList = [bidStore fetchForAdUnitId:adUnitId withAdSizes:nil andReqUrl:nil];
        NSLog(@"Adunit = %@", adUnitId);
        
        if(i == 0){
            XCTAssert(poppedResponseList == nil);
        }else{
            XCTAssert(poppedResponseList != nil);
            XCTAssert([poppedResponseList count] > 0);
            
            for(MNetBidResponse *resp in poppedResponseList){
                NSString *respPubId = resp.publisherId;
                NSUInteger objIndex = [expectedPubIds indexOfObject:respPubId];
                XCTAssert(objIndex != NSNotFound);
                [expectedPubIds removeObjectAtIndex:objIndex];
            }
        }
    }
    
    XCTAssert([expectedPubIds count] == 0);
}

- (void)testBulkExpiryPop{
    // Commenting out the measure block since that takes up ~20 seconds,
    // and when running all the tests together, it's a bit heavy.
    // Uncomment if you want to run this individually.
    /*
    [self measureBlock:^{
        [self performBulkPop];
    }];
     */
    // Running this in a measureBlock gives somewhere around 5 millis for 999 pops
    [self performBulkPop];
}

- (void)performBulkPop{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    NSUInteger numEntries = 1000;
    NSUInteger numAdUnits = 1;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numEntries withNumAdunits:numAdUnits withNumBidIds:1];
    
    for(int i=0; i<numEntries; i++){
        MNetBidResponse *bidResponse = [bidResponsesList objectAtIndex:i];
        long expiry = ([[MNetUtil getTimestampInMillis] longValue] + 1000);
        if(i == (numEntries - 1)){
            expiry = ([[MNetUtil getTimestampInMillis] longValue] + 20000);
        }
        bidResponse.expiry = [NSNumber numberWithLong:expiry];
        BOOL insertResp = [bidStore insert:bidResponse];
        XCTAssert(insertResp == YES);
    }
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *adUnitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
        
        NSNumber *startTime = [MNetUtil getTimestampInMillis];
        NSArray<MNetBidResponse *> *bidResponseList = [bidStore fetchForAdUnitId:adUnitId withAdSizes:nil andReqUrl:nil];
        NSNumber *endTime = [MNetUtil getTimestampInMillis];
        
        XCTAssert([bidResponseList count] == 1);
        [bidStore fetchForAdUnitId:adUnitId withAdSizes:nil andReqUrl:nil];
        XCTAssert([bidStore fetchForAdUnitId:adUnitId withAdSizes:nil andReqUrl:nil] == nil, );
        
        double timeDiff = [endTime doubleValue] - [startTime doubleValue];
        NSLog(@"TIME_DIFF: %f", timeDiff);
        EXPECTATION_FULFILL(expectation);
    });
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Error! - %@", error);
        }else{
            NSLog(@"DONE!");
        }
    }];
}

- (void)testBidStore{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId withAdSizes:nil andReqUrl:nil];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 3);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        [bidVals addObject:[response bidderId]];
    }
}

- (void)testBidStoreWithEmptyAdSizes{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId withAdSizes:[NSArray new] andReqUrl:nil];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 3);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        [bidVals addObject:[response bidderId]];
    }
}

- (void)testBidStoreWithInvalidAdSizes{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSArray<MNetAdSize *> *adSizes = [NSArray arrayWithObjects:MNetCreateAdSize(5000, 3000),MNetCreateAdSize(3000, 4000),MNetCreateAdSize(5000, 7000), nil];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId withAdSizes:adSizes andReqUrl:nil];
    XCTAssert(fetchedData == nil);
}

- (void)testBidStoreWithValidAdSizes{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSArray<MNetAdSize *> *adSizes = [NSArray arrayWithObjects:MNetAdSizeFromCGSize(kMNetMediumAdSize),MNetAdSizeFromCGSize(kMNetBannerAdSize), nil];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId withAdSizes:adSizes andReqUrl:nil];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 3);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        [bidVals addObject:[response bidderId]];
    }
}

- (void)testBidStoreWithMultipleValidAdSizes{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    NSMutableArray<NSNumber *> *visitedBid = [[NSMutableArray<NSNumber *> alloc] init];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        if([visitedBid containsObject:[bidResponse bidderId]]){
            [bidResponse setSize:[MNetUtil getAdSizeString:kMNetBannerAdSize]];
        }else{
            [bidResponse setSize:[MNetUtil getAdSizeString:kMNetMediumAdSize]];
            [visitedBid addObject:[bidResponse bidderId]];
        }
        
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSArray<MNetAdSize *> *adSizes = [NSArray arrayWithObjects:MNetAdSizeFromCGSize(kMNetMediumAdSize),MNetAdSizeFromCGSize(kMNetBannerAdSize), nil];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId withAdSizes:adSizes andReqUrl:nil];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 6);
    
    NSMutableDictionary *visitedBidsMap = [[NSMutableDictionary<NSNumber *, NSNumber *> alloc] init];
    for(MNetBidResponse *response in fetchedData){
        if([visitedBidsMap objectForKey:[response bidderId]]){
            NSNumber *bidderCount = [visitedBidsMap objectForKey:[response bidderId]];
            NSNumber *newBidderCount = [NSNumber numberWithInteger:([bidderCount integerValue] + 1)];
            [visitedBidsMap setObject:newBidderCount forKey:[response bidderId]];
        }
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
    }
    
    for(NSNumber *bidderId in visitedBidsMap){
        NSNumber *count = [visitedBidsMap objectForKey:bidderId];
        int val = [count intValue];
        XCTAssert(val == 2);
    }
}

- (void)testBidStoreWithEmptyEntries{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:nil withAdSizes:nil andReqUrl:nil];
    XCTAssert(fetchedData == nil);
}

- (void)testBidStoreWithReqUrlAndYbncBidder{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    // Add bid-responses with ybnca entries
    NSString *reqUrlFormat = @"req-url-%lu";
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSUInteger reqUrlCounter = 0;
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter += 1;
        
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *desiredReqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId
                                                             withAdSizes:nil
                                                               andReqUrl:desiredReqUrl];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 4, @"expected 4 responses, got - %lu", (unsigned long)[fetchedData count]);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    BOOL ybncaBidderIdFound = NO;
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        // Make sure that when the bidder_id is ybnca,
        [bidVals addObject:[response bidderId]];
        
        if([[response bidderId] isEqual:YBNC_BIDDER_ID]){
            NSString *respLink = [response viewContextLink];
            ybncaBidderIdFound = YES;
            XCTAssert(respLink != nil &&
                      [respLink isEqualToString: desiredReqUrl],
                      @"Expected %@, got %@", desiredReqUrl, respLink);
        }
    }
    XCTAssert(ybncaBidderIdFound, @"No ybnca-bidder found in the fetched responses!");
}

- (void)testBidStoreWithReqUrlWithoutYbncBidder{
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    for(MNetBidResponse *bidResponse in bidResponsesList){
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    // Add bid-responses with ybnca entries
    NSString *reqUrlFormat = @"req-url-%lu";
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    
    NSString *desiredReqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId
                                                             withAdSizes:nil
                                                               andReqUrl:desiredReqUrl];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 3, @"expected 3 responses, got - %lu", (unsigned long)[fetchedData count]);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        // Make sure that when the bidder_id is ybnca,
        [bidVals addObject:[response bidderId]];
    }
}

- (void)testGetBidsForAdSizes{
    NSArray<MNetAdSize *> *adSizes = @[
                                       MNetAdSizeFromCGSize(CGSizeMake(10, 10)),
                                       MNetAdSizeFromCGSize(CGSizeMake(20, 20)),
                                       MNetAdSizeFromCGSize(CGSizeMake(30, 30)),
                                       ];
    NSUInteger numResponses = 9;
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numResponses
                                                                  withNumBidIds:numResponses];
    
    NSMutableArray<MNetBidResponse *> *bidRespList = [NSMutableArray<MNetBidResponse *> new];
    for(int i=0; i<numResponses; i++){
        NSString *adSizeStr = [MNetUtil getAdSizeString:MNetCGSizeFromAdSize([adSizes objectAtIndex:i%3])];
        MNetBidResponse *bidResponse = [bidResponsesList objectAtIndex:i];
        [bidResponse setSize:adSizeStr];
        [bidRespList addObject:bidResponse];
    }
    
    MNetBidStoreImpl *bidStoreImpl = [MNetBidStoreImpl new];
    NSArray<MNetBidResponse *> *fetchedResponses = [bidStoreImpl getBidsForAdSizes:adSizes fromList:[NSArray arrayWithArray:bidRespList]];
    XCTAssert(fetchedResponses!=nil && [fetchedResponses count] == 3,
              @"expected 3 entries, got - %lu",  (unsigned long)[fetchedResponses count]);
    
    // Make sure that all the ad-sizes are unique
    NSMutableDictionary<NSString *, NSString *> *dummyDict = [NSMutableDictionary<NSString *, NSString *> new];
    for(MNetBidResponse *response in fetchedResponses){
        [dummyDict setObject:@"" forKey:[response size]];
    }
    XCTAssert([dummyDict count] == 3, @"expected 3 unique sizes");
}

- (void)testBidStoreWithReqUrlAndYbncBidderAndAdSizes{
    NSArray<MNetAdSize *> *adSizes = @[
                                       MNetAdSizeFromCGSize(CGSizeMake(10, 10)),
                                       MNetAdSizeFromCGSize(CGSizeMake(20, 20))
                                       ];
    
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    
    NSUInteger numResponses = 6;
    NSUInteger numAdUnits = 1;
    NSUInteger numBidIds = 3;
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [self getBidResponses:numResponses
                                                                 withNumAdunits:numAdUnits
                                                                  withNumBidIds:numBidIds];
    int i = 0;
    for(MNetBidResponse *bidResponse in bidResponsesList){
        MNetAdSize *adSizeObj = [adSizes objectAtIndex:(i++)%[adSizes count]];
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    // Add bid-responses with ybnca entries
    NSString *reqUrlFormat = @"req-url-%lu";
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSUInteger reqUrlCounter = 0;
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter += 1;
        
        MNetAdSize *adSizeObj = [adSizes objectAtIndex:(i++)%[adSizes count]];
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *desiredReqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId
                                                             withAdSizes:adSizes
                                                               andReqUrl:desiredReqUrl];
    XCTAssert(fetchedData != nil);
    int expectedNumEntries = 7; // 2 each from non-ybnca and 1 from ybnca
    XCTAssert([fetchedData count] == expectedNumEntries, @"expected %d responses, got - %lu", expectedNumEntries, (unsigned long)[fetchedData count]);
    
    BOOL ybncaBidderIdFound = NO;
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        if([[response bidderId] isEqual:YBNC_BIDDER_ID]){
            NSString *respLink = [response viewContextLink];
            ybncaBidderIdFound = YES;
            XCTAssert(respLink != nil &&
                      [respLink isEqualToString: desiredReqUrl],
                      @"Expected %@, got %@", desiredReqUrl, respLink);
        }
    }
    XCTAssert(ybncaBidderIdFound, @"No ybnca-bidder found in the fetched responses!");
}

// Multiple fpd with no tpd
- (void)testBidStoreWithReqUrlAndOnlyYbncBidderAndAdSizes{
    NSArray<MNetAdSize *> *adSizes = @[
                                       MNetAdSizeFromCGSize(CGSizeMake(10, 10)),
                                       MNetAdSizeFromCGSize(CGSizeMake(20, 20))
                                       ];
    
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    // Add bid-responses with ybnca entries
    NSString *reqUrlFormat = @"req-url-%lu";
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSUInteger reqUrlCounter = 0;
    MNetAdSize *adSizeObj = [adSizes firstObject];
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter = (reqUrlCounter + 1);
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    reqUrlCounter = 0;
    adSizeObj = [adSizes lastObject];
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter = (reqUrlCounter + 1);
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *desiredReqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId
                                                             withAdSizes:adSizes
                                                               andReqUrl:desiredReqUrl];
    XCTAssert(fetchedData != nil);
    int expectedNumEntries = 2; // 2 from ybnca, 1 for each req-url
    XCTAssert([fetchedData count] == expectedNumEntries, @"expected %d responses, got - %lu", expectedNumEntries, (unsigned long)[fetchedData count]);
    
    BOOL ybncaBidderIdFound = NO;
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        if([[response bidderId] isEqual:YBNC_BIDDER_ID]){
            NSString *respLink = [response viewContextLink];
            ybncaBidderIdFound = YES;
            XCTAssert(respLink != nil &&
                      [respLink isEqualToString: desiredReqUrl],
                      @"Expected %@, got %@", desiredReqUrl, respLink);
        }
    }
    XCTAssert(ybncaBidderIdFound, @"No ybnca-bidder found in the fetched responses!");
}

// multiple fpd with no tpd and no req-urls
- (void)testBidStoreWithNoReqUrlAndOnlyYbncBidderAndAdSizes{
    NSArray<MNetAdSize *> *adSizes = @[
                                       MNetAdSizeFromCGSize(CGSizeMake(10, 10)),
                                       MNetAdSizeFromCGSize(CGSizeMake(20, 20))
                                       ];
    
    id<MNetBidStoreProtocol> bidStore = [MNetBidStore getStore];
    // Add bid-responses with ybnca entries
    NSString *reqUrlFormat = @"req-url-%lu";
    NSString *adunitId = [NSString stringWithFormat:@"%@%d", adUnitPrefix, 1];
    NSUInteger reqUrlCounter = 0;
    MNetAdSize *adSizeObj = [adSizes firstObject];
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter = (reqUrlCounter + 1);
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    reqUrlCounter = 0;
    adSizeObj = [adSizes lastObject];
    for(MNetBidResponse *bidResponse in [self getNYbncaBidResponses:5 withAdUnitId:adunitId]){
        NSString *reqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)reqUrlCounter];
        reqUrlCounter = (reqUrlCounter + 1);
        [bidResponse setSize:[MNetUtil getAdSizeString:MNetCGSizeFromAdSize(adSizeObj)]];
        [bidResponse setViewContextLink:reqUrl];
        BOOL insertStatus = [bidStore insert:bidResponse];
        XCTAssert(insertStatus);
    }
    
    NSString *desiredReqUrl = [NSString stringWithFormat:reqUrlFormat, (unsigned long)1];
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId
                                                             withAdSizes:adSizes
                                                               andReqUrl:nil];
    XCTAssert(fetchedData != nil);
    int expectedNumEntries = 2; // 1 for each req-url
    XCTAssert([fetchedData count] == expectedNumEntries, @"expected %d responses, got - %lu", expectedNumEntries, (unsigned long)[fetchedData count]);
    
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        XCTAssert([[response bidderId] isEqual:YBNC_BIDDER_ID]);
    }
}

// Helper methods

- (NSMutableArray<MNetBidResponse *> *)getNYbncaBidResponses:(NSUInteger)numResponses withAdUnitId:(NSString *)adUnitId{
    NSString *jsonString = readFile([self class], @"MNetBidResponse", @"json");
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] initWithCapacity:numResponses];
    
    for(NSUInteger i=0; i<numResponses; i++){
        MNetBidResponse *bidResponse = [[MNetBidResponse alloc] init];
        [MNJMManager fromJSONStr:jsonString toObj:bidResponse];
        
        // Changing the bid-response adunit-id
        bidResponse.creativeId = adUnitId;
        bidResponse.adCode = [NSString stringWithFormat:@"adcode_%ld", i];
        bidResponse.publisherId = [NSString stringWithFormat:@"pubId_%ld", i];
        bidResponse.bid = [NSNumber numberWithUnsignedInteger:i];
        bidResponse.bidderId = YBNC_BIDDER_ID;
        
        [bidResponsesList addObject:bidResponse];
    }
    return bidResponsesList;
}

- (NSMutableArray<MNetBidResponse *> *)getBidResponses:(NSUInteger)numResponses
                                        withNumAdunits:(NSUInteger)numAdunits
                                         withNumBidIds:(NSUInteger)numBidIds
{
    NSString *jsonString = readFile([self class], @"MNetBidResponse", @"json");
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] initWithCapacity:numResponses];
    
    for(NSUInteger i=0; i<numResponses; i++){
        MNetBidResponse *bidResponse = [[MNetBidResponse alloc] init];
        [MNJMManager fromJSONStr:jsonString toObj:bidResponse];
        
        // Changing the bid-response adunit-id
        bidResponse.creativeId = [NSString stringWithFormat:@"%@%ld", adUnitPrefix, (i % numAdunits) + 1];
        bidResponse.adCode = [NSString stringWithFormat:@"adcode_%ld", i];
        bidResponse.publisherId = [NSString stringWithFormat:@"pubId_%ld", i];
        bidResponse.bid = [NSNumber numberWithUnsignedInteger:i];
        bidResponse.bidderId = [NSNumber numberWithUnsignedInteger:((i % numBidIds) + 1)];
        
        [bidResponsesList addObject:bidResponse];
    }
    return bidResponsesList;
}

@end
