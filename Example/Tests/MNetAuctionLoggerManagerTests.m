//
//  MNetAuctionLoggerManagerTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 24/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetAuctionLoggerManagerTests : MNetTestManager
@property (nonatomic) XCTestExpectation *auctionLoggerTestExpectation;
@end

@implementation MNetAuctionLoggerManagerTests

- (void)testLoggerRequestFailure1{
    self.auctionLoggerTestExpectation = [self expectationWithDescription:@"Request failure expectation"];
    
    MNetAuctionLoggerManager *manager = [MNetAuctionLoggerManager getSharedInstance];
    [manager makeAuctionLoggerRequestFromResponsesContainer:nil
                                      withAuctionLogsStatus:[MNetAuctionLogsStatus new]
                                              withSuccessCb:^{
                                                  XCTFail(@"Logger should fail!");
                                                  EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                              }
                                                   andErrCb:^(NSError * _Nonnull error) {
                                                       EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                                   }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (void)testLoggerRequestFailure2{
    self.auctionLoggerTestExpectation = [self expectationWithDescription:@"Request failure expectation"];
    MNetBidResponse *response = [self getTestBidResponse];
    MNetBidResponsesContainer *responsesContainer = [MNetBidResponsesContainer getInstanceWithBidResponses:@[response]];
    
    MNetAuctionLoggerManager *manager = [MNetAuctionLoggerManager getSharedInstance];
    [manager makeAuctionLoggerRequestFromResponsesContainer:responsesContainer
                                      withAuctionLogsStatus:[MNetAuctionLogsStatus new]
                                              withSuccessCb:^{
                                                  EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                              }
                                                   andErrCb:^(NSError * _Nonnull error) {
                                                       XCTFail(@"Logger should fail!");
                                                       EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                                   }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

- (MNetBidResponsesContainer *)getPreparedBidResponseContainer{
    // Creating a royal bid-request, befitting a king!
    NSString *contextLink = @"dummy-context-link";
    NSString *VCTitle = @"dummy-title";
    NSString *adUnitId = @"dummy-adunit-id";
    NSString *adCycleId = [MNetUtil createId];
    
    MNetAdRequest *adRequest = [MNetAdRequest newRequest];
    adRequest.rootViewController = [self getViewController];
    adRequest.contextLink = contextLink;
    adRequest.viewControllerTitle = VCTitle;
    adRequest.adSizes = @[MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    
    adRequest.adUnitId = adUnitId;
    adRequest.adCycleId = adCycleId;
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:adRequest];
    
    MNetBidResponse *response = [self getTestBidResponse];
    MNetBidResponsesContainer *responsesContainer = [MNetBidResponsesContainer getInstanceWithBidResponses:@[response]];
    
    MNetAuctionDetails *auctionDetails = [MNetAuctionDetails new];
    [auctionDetails setFailedBidRequest:bidRequest];
    
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
    return responsesContainer;
}

- (void)testLoggerRequestSuccess{
    self.auctionLoggerTestExpectation = [self expectationWithDescription:@"Auction request pass expectation"];
    MNetBidResponsesContainer *responsesContainer = [self getPreparedBidResponseContainer];
    
    MNetAuctionLoggerManager *manager = [MNetAuctionLoggerManager getSharedInstance];
    [manager makeAuctionLoggerRequestFromResponsesContainer:responsesContainer
                                      withAuctionLogsStatus:[MNetAuctionLogsStatus new]
                                              withSuccessCb:^{
                                                  EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                              } andErrCb:^(NSError * _Nonnull error) {
                                                  XCTFail(@"Logger should not fail! - %@", error);
                                                  EXPECTATION_FULFILL(self.auctionLoggerTestExpectation);
                                              }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"%@", error);
        }
    }];
}

@end
