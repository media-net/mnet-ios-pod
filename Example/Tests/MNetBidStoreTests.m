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
        NSArray<MNetBidResponse *> *poppedResponseList = [bidStore fetchForAdUnitId:adUnitId];
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
    NSArray<MNetBidResponse *> *fetchedData = [bidStore fetchForAdUnitId:adunitId];
    XCTAssert(fetchedData != nil);
    XCTAssert([fetchedData count] == 3);
    
    NSMutableArray *bidVals = [[NSMutableArray alloc] init];
    for(MNetBidResponse *response in fetchedData){
        XCTAssert([[response creativeId] isEqualToString:adunitId]);
        
        XCTAssert([bidVals containsObject:[response bidderId]] == NO, @"All the bidder ids must be unique");
        [bidVals addObject:[response bidderId]];
    }
}


// Helper methods
- (NSMutableArray<MNetBidResponse *> *)getBidResponses:(NSUInteger)numResponses
                                        withNumAdunits:(NSUInteger)numAdunits
                                         withNumBidIds:(NSUInteger)numBidIds
{
    NSString *jsonString = readFile([self class], @"MNetBidResponse", @"json");
    
    NSMutableArray<MNetBidResponse *> *bidResponsesList = [[NSMutableArray alloc] initWithCapacity:numResponses];
    
    for(NSUInteger i=0; i<numResponses; i++){
        MNetBidResponse *bidResponse = [[MNetBidResponse alloc] init];
        FromJSON(jsonString, bidResponse);
        
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
