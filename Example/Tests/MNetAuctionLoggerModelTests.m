//
//  MNetAuctionLoggerModelTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 24/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetAuctionLoggerModelTests : MNetTestManager
@end

@implementation MNetAuctionLoggerModelTests

- (void)testJsonCreation{
    MNetAuctionLoggerRequest *loggerReq = [MNetAuctionLoggerRequest new];
    NSDictionary *loggerReqDict = (NSDictionary *)[MNJMManager getCollectionFromObj:loggerReq];
    
    NSLog(@"%@", loggerReqDict);
    NSLog(@"%@", [MNJMManager toJSONStr:loggerReq]);
    
    XCTAssert([loggerReqDict isKindOfClass:[NSDictionary class]]);
    XCTAssert(loggerReqDict != nil);
    
    NSArray<NSString *> *reqdKeys = @[@"device",
                                      @"f_logs",
                                      @"visit_id"];
    
    for(NSString *reqdKey in reqdKeys){
        XCTAssert([loggerReqDict objectForKey:reqdKey] != nil, @"Expected key : %@, not found in auction-logger request", reqdKey);
    }
}

- (void)testReqCreationFromResponse{
    // Creating a royal bid-request, befitting a king!
    NSString *contextLink = @"dummy-context-link";
    NSString *VCTitle = @"dummy-title";
    NSString *adUnitId = @"dummy-adunit-id";
    NSString *adCycleId = [MNetUtil createId];
    NSString *expectedAdCycleId = @"dummy-ad-cycle-id";
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.rootViewController = [self getViewController];
    adRequest.contextLink = contextLink;
    adRequest.viewControllerTitle = VCTitle;
    
    MNetAdSize *adSize = [MNetAdSize new];
    adSize.h = MNET_BANNER_AD_SIZE.height;
    adSize.w = MNET_BANNER_AD_SIZE.width;
    adRequest.size = adSize;
    
    adRequest.adUnitId = adUnitId;
    adRequest.adCycleId = adCycleId;
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    
    MNetBidResponse *response = [self getTestBidResponse];
    MNetBidResponsesContainer *responsesContainer = [MNetBidResponsesContainer getInstanceWithBidResponses:@[response]];

    MNetAuctionDetails *auctionDetails = [MNetAuctionDetails new];
    [auctionDetails setFailedBidRequest:bidRequest];
    [auctionDetails setUpdatedAdCycleId:expectedAdCycleId];
    
    double timestampVal = [[MNetUtil getTimestampInMillis] doubleValue] - 20;
    [auctionDetails setAuctionTimestamp:[NSNumber numberWithDouble:timestampVal]];
    
    NSMutableArray<MNetBidderInfo *> *bidderInfoList = [[NSMutableArray alloc] init];
    for(int i=0; i<4; i++){
        MNetBidderInfo *dummyBidderInfo = [MNetBidderInfo createInstanceFromBidResponse:response];
        dummyBidderInfo.bidderId = [NSNumber numberWithInteger:i];
        [bidderInfoList addObject:dummyBidderInfo];
    }
    [auctionDetails setParticipantsBidderInfoArr:[NSArray arrayWithArray:bidderInfoList]];
    
    [responsesContainer setAuctionDetails:auctionDetails];
    
    MNetAuctionLoggerRequest *loggerReq = [[MNetAuctionLoggerRequest alloc] initFromBidResponseContainer:responsesContainer];
    NSDictionary *loggerReqDict = (NSDictionary *)[MNJMManager getCollectionFromObj:loggerReq];
    
    NSLog(@"%@", loggerReqDict);
    NSLog(@"%@", [MNJMManager toJSONStr:loggerReq]);
    
    XCTAssert([loggerReqDict isKindOfClass:[NSDictionary class]]);
    XCTAssert(loggerReqDict != nil);
    
    NSArray<NSString *> *reqdKeys = @[
                                      @"app",
                                      @"imp",
                                      @"acttime",
                                      @"device",
                                      @"f_logs",
                                      @"visit_id",
                                      @"activity_name",
                                      @"acttime",
                                      @"ad_cycle_id",
                                      @"visit_id",
                                      @"bidders",
                                  ];
    
    for(NSString *reqdKey in reqdKeys){
        XCTAssert([loggerReqDict objectForKey:reqdKey] != nil, @"Expected key : %@, not found in auction-logger request", reqdKey);
    }
    NSNumber *acttime = [loggerReqDict objectForKey:@"acttime"];
    double acttimeVal = [acttime doubleValue];
    XCTAssert(acttimeVal != 0);
    
    NSString *actualAdCycleId = [loggerReqDict objectForKey:@"ad_cycle_id"];
    XCTAssert(actualAdCycleId != nil);
    XCTAssert([actualAdCycleId isEqualToString:expectedAdCycleId]);
}

@end
