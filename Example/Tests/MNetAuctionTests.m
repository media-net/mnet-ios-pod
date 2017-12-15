//
//  MNetAuctionTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 18/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetAuctionTests : MNetTestManager

@end

@implementation MNetAuctionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFpdAuctionList{
    NSMutableArray<MNetBidResponse *> *fpdBidResponses = [self getBidResponsesForAuction];
    NSUInteger counter = 0;
    for(MNetBidResponse *bidResponse in fpdBidResponses){
        bidResponse.bidType = BID_TYPE_FIRST_PARTY;
        bidResponse.auctionBid = [NSNumber numberWithUnsignedInteger:counter];
        bidResponse.originalBidMultiplier1 = [NSNumber numberWithDouble:1];
        bidResponse.originalBidMultiplier2 = [NSNumber numberWithDouble:2];
        bidResponse.dfpBidMultiplier1 = [NSNumber numberWithDouble:10];
        bidResponse.dfpBidMultiplier2 = [NSNumber numberWithDouble:20];
        counter += 1;
    }
    counter -= 1;
    
    MNetAuctionManager *auctionManager = [MNetAuctionManager getInstance];
    MNetBidResponse *bidResponse = [auctionManager getAuctionWinnerWithFpdResponses:fpdBidResponses];
    XCTAssert(bidResponse != nil);
    XCTAssert(bidResponse.auctionBid != nil && [bidResponse.auctionBid isEqual:[NSNumber numberWithUnsignedInteger:counter]]);
    XCTAssert([bidResponse.auctionBid isEqual: [NSNumber numberWithDouble:3]]);
    XCTAssert([bidResponse.dfpbid isEqual: [NSNumber numberWithDouble:17]]);
    
}

- (void)testCompleteAuctionFlow{
    NSMutableArray<MNetBidResponse *> *fpdBidResponses = [self getBidResponsesForAuction];
    
    NSUInteger auctionParticipantsCount = [fpdBidResponses count];
    NSUInteger expectedParticipantsCount = [fpdBidResponses count] - 1;
    
    NSUInteger counter = 0;
    for(MNetBidResponse *bidResponse in fpdBidResponses){
        bidResponse.auctionBid = [NSNumber numberWithUnsignedInteger:counter];
        bidResponse.originalBidMultiplier1 = [NSNumber numberWithDouble:10];
        bidResponse.originalBidMultiplier2 = [NSNumber numberWithDouble:20];
        bidResponse.dfpBidMultiplier1 = [NSNumber numberWithDouble:10];
        bidResponse.dfpBidMultiplier2 = [NSNumber numberWithDouble:20];
        bidResponse.mainBid = [NSNumber numberWithDouble:10];
        bidResponse.dfpbid = [NSNumber numberWithDouble:20];
        
        NSString *dfpMacroKey = @"${DFPBD}";
        NSString *macroStr = [NSString stringWithFormat:@"%@", dfpMacroKey];
        bidResponse.serverExtras = @{@"macro_entry": macroStr};
        
        counter += 1;
    }
    counter -= 1;
    
    MNetAuctionManager *auctionManager = [MNetAuctionManager getInstance];
    MNetBidResponsesContainer *responsesContainer = [auctionManager performAuctionForResponses:fpdBidResponses];
    NSArray<MNetBidResponse *> *auctionedResponses = [responsesContainer bidResponsesArr];
    XCTAssert([auctionedResponses count] == expectedParticipantsCount);
    NSNumber *winningBidderId = nil;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
    
    for(MNetBidResponse *bidResponse in auctionedResponses){
        if([bidResponse.bidType isEqualToString: BID_TYPE_FIRST_PARTY]){
            XCTAssert(bidResponse.ogBid != nil);
            XCTAssert(bidResponse.dfpbid != nil);
            XCTAssert([bidResponse.auctionBid isEqual:[NSNumber numberWithUnsignedInteger:1]]);
            XCTAssert([bidResponse.ogBid isEqual:[NSNumber numberWithDouble:302]]);
            XCTAssert([bidResponse.dfpbid isEqual:[NSNumber numberWithDouble:302]]);
            winningBidderId = bidResponse.bidderId;
        }
        
        NSDictionary *serverExtras = bidResponse.serverExtras;
        XCTAssert(serverExtras != nil);
        NSString *dfpBid = [formatter stringFromNumber:bidResponse.dfpbid];
        XCTAssert([[serverExtras objectForKey:@"macro_entry"] isEqualToString:dfpBid]);
    }
    
    XCTAssert(winningBidderId != nil);
    MNetAuctionDetails *auctionDetails = [responsesContainer auctionDetails];
    XCTAssert(auctionDetails != nil);
    XCTAssert([auctionDetails didAuctionHappen] == YES);
    NSArray <MNetBidderInfo *> *participantBidderInfo = [auctionDetails participantsBidderInfoArr];
    XCTAssert([participantBidderInfo count] == auctionParticipantsCount);
    for(MNetBidderInfo *bidderInfo in participantBidderInfo){
        if([[[bidderInfo bidInfoDetails] winner] isYes]){
            XCTAssert([[bidderInfo bidderId] isEqualToValue:winningBidderId]);
        }
    }
}

- (NSMutableArray<MNetBidResponse *> *)getBidResponsesForAuction{
    NSMutableArray<MNetBidResponse *> *responsesList = [[NSMutableArray alloc] init];
    MNetBidResponse *fpdResponse1 = [self getTestBidResponse];
    fpdResponse1.bidType = BID_TYPE_FIRST_PARTY;
    fpdResponse1.bidderId = [NSNumber numberWithInteger:1];
    [responsesList addObject:fpdResponse1];
    
    MNetBidResponse *fpdResponse2 = [self getTestBidResponse];
    fpdResponse2.bidType = BID_TYPE_FIRST_PARTY;
    fpdResponse2.bidderId = [NSNumber numberWithInteger:2];
    [responsesList addObject:fpdResponse2];
    
    MNetBidResponse *tpdResponse1 = [self getTestBidResponse];
    tpdResponse1.bidType = BID_TYPE_THIRD_PARTY;
    tpdResponse1.bidderId = [NSNumber numberWithInteger:3];
    [responsesList addObject:tpdResponse1];
    
    MNetBidResponse *tpdResponse2 = [self getTestBidResponse];
    tpdResponse2.bidType = BID_TYPE_THIRD_PARTY;
    tpdResponse2.bidderId = [NSNumber numberWithInteger:4];
    [responsesList addObject:tpdResponse2];
    
    return responsesList;
}

@end
