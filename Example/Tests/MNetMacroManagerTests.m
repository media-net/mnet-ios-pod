//
//  MNetMacroManagerTests.m
//  MNAdSdk
//
//  Created by nithin.g on 09/10/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNetAdIdManager.h"
#import "NSString+MNetStringCrypto.h"

#define NUM_OBJ(val) [NSNumber numberWithDouble:val]

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
    NSUInteger initialCount = [response.loggingBeacons count];
    
    // Calling loggingBeacons getter automatically should perform macro-replacement
    NSArray *modifiedLogs = response.loggingBeacons;
    XCTAssert(modifiedLogs != nil);
    XCTAssert([modifiedLogs count] == initialCount);
    
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
    
    // Calling loggingBeacons getter automatically should perform macro-replacement
    NSArray *modifiedLogs = response.loggingBeacons;
    
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
    response.clsprc = [NSNumber numberWithInteger:3000];
    
    NSArray<NSString *> *inputLogs = @[
                         @"example.com/?adcode=${ADCODE}",
                         @"example.com/",
                         @"example.com/clsprc=${CLSPRC}",
                         ];
    
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForApLogsForBidders:inputLogs
                                                              withResponse:response];
    
    NSArray *expectedResponse = @[
                                  @"example.com/?adcode=something - example.com/?auction_id=sample-adcycle-id&url=view-context-url&price=20",
                                  @"example.com/",
                                  @"example.com/clsprc=3000",
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
    // Calling elogs getter automatically should perform macro-replacement
    NSArray *modifiedLogs = response.elogs;
    
    NSArray *expectedResponse = @[
                                  @"example.com/?prov_id=100&prov_name=sample-bidder-name&ogbid=20&bdp=10&cbdp=2000&adcode=sample-adcode&clsprc=3000&url=view-context-url",
                                  ];
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testServerExtrasReplacement{
    MNetBidResponse *response = [self getTestBidResponse];
    response.bid = [NSNumber numberWithInteger:10];
    response.ogBid = [NSNumber numberWithInteger:20];
    response.creativeId = @"sample-adunit";
    response.viewContextLink = @"view-context-url";
    [response setAdCycleId:@"sample-adcycle-id"];
    
    NSDictionary<NSNumber *, NSString *> *floatValToExpectedMap = @{
                                                                    NUM_OBJ(10.025) :   @"10.03",
                                                                    NUM_OBJ(10.00001) : @"10.00",
                                                                    NUM_OBJ(10.0) :     @"10.00",
                                                                    NUM_OBJ(10.10) :    @"10.10",
                                                                    NUM_OBJ(1) :        @"1.00",
                                                                    NUM_OBJ(-20):       @"-20.00"
                                                               };
    
    for(NSNumber *floatVal in floatValToExpectedMap){
        NSString *counterStr = [floatVal stringValue];
        NSString *macroStr = @"${DFPBD}";
        response.dfpbid = floatVal;
        response.serverExtras = @{
                                  @"key1": counterStr,
                                  @"macro_key": macroStr
                                  };
        
        NSDictionary *serverExtras = response.serverExtras;
        XCTAssert([[serverExtras objectForKey:@"key1"] isEqualToString:counterStr]);
        NSString *actualMacroVal = [serverExtras objectForKey:@"macro_key"];
        NSString *expectedMacroString = floatValToExpectedMap[floatVal];
        XCTAssert([actualMacroVal isEqualToString:expectedMacroString], @"ACTUAL: %@ EXPECTED: %@", actualMacroVal, expectedMacroString);
        NSLog(@"SAMPLE - %@", actualMacroVal);
    }
}

- (void)testADIDMacroReplacement{
    MNetBidResponse *response = [self getTestBidResponse];
    NSArray<NSString *> *inputLogs = @[
                                       @"example.com/?advertId=${ADID}",
                                       @"example.com/?advertId_hash=${ADID_HASH}",
                                       @"example.com/?advertId=%24%7BADID%7D",
                                       ];

    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSString *advertId = [[MNetAdIdManager getSharedInstance] getAdvertId];
    NSString *advertIdHash = [[[MNetAdIdManager getSharedInstance] getAdvertId] MD5];
    
    NSArray<NSString *> *expectedResponse = @[
                                              [NSString stringWithFormat:@"example.com/?advertId=%@", advertId],
                                              [NSString stringWithFormat:@"example.com/?advertId_hash=%@", advertIdHash],
                                              [NSString stringWithFormat:@"example.com/?advertId=%@", advertId],
                                              ];
    
    NSArray *modifiedLogs = [macroManager processMacrosForApLogsForBidders:inputLogs
                                                              withResponse:response];
    
    for(int i=0; i< [expectedResponse count]; i++){
        NSString *expectedStr = expectedResponse[i];
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testEmptyMacroReplacement{
    MNetBidResponse *response = [[MNetBidResponse alloc] init];
    NSArray<NSString *> *inputLogs = @[
                                       @"example.com/?macro=${CRID}",
                                       @"example.com/?macro=${ACID}",
                                       @"example.com/?macro=${REQ_URL}",
                                       @"example.com/?macro=${AUCTION_PRICE}",
                                       @"example.com/?macro=${PID}",
                                       @"example.com/?macro=${PN}",
                                       @"example.com/?macro=${BDP}",
                                       @"example.com/?macro=${CBDP}",
                                       @"example.com/?macro=${CLSPRC}",
                                       @"example.com/?macro=${OGBDP}",
                                       @"example.com/?macro=${ADCODE}",
                                       @"example.com/?macro=${DFPBD}",
                                       ];
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSArray *modifiedLogs = [macroManager processMacrosForApLogsForBidders:inputLogs withResponse:response];
    NSString *expectedStr = @"example.com/?macro=";
    for(int i=0;i< [inputLogs count]; i++){
        NSString *actualStr = modifiedLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}

- (void)testNilBidResponseMacroReplacement{
    MNetBidResponse *response = nil;
    NSArray<NSString *> *inputLogs = @[
                                       @"example.com/?macro=${CRID}",
                                       @"example.com/?macro=${ACID}",
                                       @"example.com/?macro=${REQ_URL}",
                                       @"example.com/?macro=${AUCTION_PRICE}",
                                       @"example.com/?macro=${PID}",
                                       @"example.com/?macro=${PN}",
                                       @"example.com/?macro=${BDP}",
                                       @"example.com/?macro=${CBDP}",
                                       @"example.com/?macro=${CLSPRC}",
                                       @"example.com/?macro=${OGBDP}",
                                       @"example.com/?macro=${DFPBD}",
                                       @"example.com/?macro=${RT}",
                                       @"example.com/?macro=${ADCODE}",
                                       ];
    MNetMacroManager *macroManager = [MNetMacroManager getSharedInstance];
    NSString *expectedStr = @"example.com/?macro=";
    
    // Test ApLogs For Bidders
    NSArray *modifiedApLogs = [macroManager processMacrosForApLogsForBidders:inputLogs withResponse:response];
    for(int i=0;i< [inputLogs count]; i++){
        NSString *actualStr = modifiedApLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
    
    // Test Loggin Pixels
    NSArray *modifiedLogginPixelsLogs = [macroManager processMacrosForLoggingPixels:inputLogs withResponse:response];
    for(int i=0;i< [inputLogs count]; i++){
        NSString *actualStr = modifiedLogginPixelsLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
    
    //Test expiry logs
    NSArray *modifiedExpiryLogs = [macroManager processMacrosForExpiryLogs:inputLogs withResponse:response];
    for(int i=0;i< [inputLogs count]; i++){
        NSString *actualStr = modifiedExpiryLogs[i];
        XCTAssert([expectedStr isEqualToString:actualStr], @"Expected = %@ | Got = %@", expectedStr, actualStr);
    }
}
@end
