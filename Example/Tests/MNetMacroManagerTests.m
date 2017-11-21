//
//  MNetMacroManagerTests.m
//  MNAdSdk
//
//  Created by nithin.g on 09/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetMacroManagerTests : MNetTestManager

@end

@implementation MNetMacroManagerTests

- (void)testLoggingPixelsForMacroSubs {
    MNetBidResponse *response = [self getTestBidResponse];
    response.bid = [NSNumber numberWithInteger:10];
    response.ogBid = [NSNumber numberWithInteger:20];
    response.creativeId = @"sample-adunit";
    response.viewContextLink = @"view-context-url";
    [response setAdCycleId:@"sample-adcycle-id"];
    
    XCTAssert(response.loggingBeacons != nil);
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForLoggingPixels:response.loggingBeacons
                                   withResponse:response];
    XCTAssert(modifiedLogs != nil);
    XCTAssert([modifiedLogs count] == [response.loggingBeacons count]);
    
    // Have the expected response here
    NSArray *expectedResponse = @[
                                  @"http://example.com/nurl1?price=20",
                                  @"http://example.com/nurl2?id=sample-adcycle-id",
                                  @"http://example.com/nurl3?crawler_url=view-context-url",
                                  @"http://example.com/nurl4?creative_id=sample-adunit",
                                  @"http://example.com/nurl4?creative_id=sample-adunit&crawler_url=view-context-url&id=sample-adcycle-id&price=20"
                                  ];
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
        
    }
}

- (void)testFailureLoggingPixels{
    MNetBidResponse *response = [self getTestBidResponse];
    response.bid = nil;
    response.ogBid = nil;
    response.creativeId = nil;
    response.viewContextLink = nil;
    [response setAdCycleId:nil];
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForLoggingPixels:response.loggingBeacons
                                                           withResponse:response];
    
    for(int i=0; i< [modifiedLogs count]; i++){
        NSString *expectedStr = response.loggingBeacons[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testApLogsForBiddersMacroSubs {
    MNetBidResponse *response = [self getTestBidResponse];
    response.bid = [NSNumber numberWithInteger:10];
    response.adCode = @"something - example.com/?auction_id=${ACID}&url=${REQ_URL}&price=${AUCTION_PRICE}";
    response.ogBid = [NSNumber numberWithInteger:20];
    response.creativeId = @"sample-adunit";
    response.viewContextLink = @"view-context-url";
    [response setAdCycleId:@"sample-adcycle-id"];
    response.responseType = @"headerBid";
    NSArray<NSString *> *inputLogs = @[
                         @"example.com/?adcode=${ADCODE}",
                         @"example.com/",
                         ];
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForApLogsForBidders:inputLogs
                                                              withResponse:response];
    
    NSArray *expectedResponse = @[
                                  @"example.com/?adcode=something - example.com/?auction_id=sample-adcycle-id&url=view-context-url&price=20",
                                  @"example.com/"
                                  ];
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testApLogsForBiddersMacroSubsEmpty{
    NSArray<NSString *> *inputLogs = @[
                                       @"example.com/?adcode=${ADCODE}",
                                       @"example.com/",
                                       ];
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForApLogsForBidders:inputLogs
                                                              withResponse:nil];
    
    NSArray *expectedResponse = @[
                                  @"example.com/?adcode=",
                                  @"example.com/",
                                  ];
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testExpiredBidLogsMacroSubs {
    MNetBidResponse *response = [self getTestBidResponse];
    response.bid = [NSNumber numberWithInteger:10];
    response.ogBid = [NSNumber numberWithInteger:20];
    response.creativeId = @"sample-adunit";
    response.viewContextLink = @"view-context-url";
    [response setAdCycleId:@"sample-adcycle-id"];
    response.adCode = @"sample-adcode";
    response.bidderId = [NSNumber numberWithInteger:100];
    response.bidderName = @"sample-bidder-name";
    response.cbdp = [NSNumber numberWithInteger:2000];
    response.clsprc = [NSNumber numberWithInteger:3000];
    
    response.elogs = @[
                       @"example.com/?prov_id=${PID}&prov_name=${PN}&ogbid=${OGBDP}&bdp=${BDP}&cbdp=${CBDP}&adcode=${RT}&clsprc=${CLSPRC}&url=${REQ_URL}",
                         ];
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForExpiryLogs:response.elogs
                                                        withResponse:response];
    
    NSArray *expectedResponse = @[
                                  @"example.com/?prov_id=100&prov_name=sample-bidder-name&ogbid=20&bdp=10&cbdp=2000&adcode=sample-adcode&clsprc=3000&url=view-context-url",
                                  ];
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

@end
