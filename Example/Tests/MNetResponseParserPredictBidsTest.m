//
//  MNetResponseParserPredictBidsTest.m
//  MNAdSdk
//
//  Created by nithin.g on 15/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetResponseParserPredictBidsTest : MNetTestManager

@end

@implementation MNetResponseParserPredictBidsTest

- (void)setUp{
    [super setUp];
    [[MNetResponseTransformerStore getSharedInstance] intializeTransformers];
}

- (void)testPredictBidsResponse {
    NSDictionary *responseDict = [self getPredictBidsResponseDict];
    id<MNetResponseParserProtocol> parser = [MNetResponseParser getParser];
    NSError *parserErr;
    NSArray<MNetBidResponse *> *bidResponsesArr = [parser parseResponse:responseDict
                                                 exclusivelyForAdUnitId:nil
                                                        withExtraParams:nil
                                                               outError:&parserErr];
    XCTAssert(bidResponsesArr != nil);
}

- (void)testPredictBidsResponseWithParams {
    NSDictionary *responseDict = [self getPredictBidsResponseDict];
    
    NSString *adCycleId = @"dummy-ad-cycle-id";
    NSString *visitId = @"dummy-visit-id";
    NSString *contextUrl = @"dummy-context-url";
    NSString *vcTitle = @"dummy-vc-title";
    NSString *keywords = @"dummy-keywords";
    
    MNetResponseParserExtras *params = [MNetResponseParserExtras getInstanceWithAdCycleId:adCycleId
                                                                                  visitId:visitId
                                                                               contextUrl:contextUrl
                                                                      viewControllerTitle:vcTitle
                                                                           viewController:[self getViewController]
                                                                                 keywords:keywords
                                        ];
    
    id<MNetResponseParserProtocol> parser = [MNetResponseParser getParser];
    NSError *parserErr;
    NSArray<MNetBidResponse *> *bidResponsesArr = [parser parseResponse:responseDict
                                                   exclusivelyForAdUnitId:nil
                                                        withExtraParams:params
                                                               outError:&parserErr];
    XCTAssert(bidResponsesArr != nil);
    XCTAssert([bidResponsesArr count] > 0);
    
    for(MNetBidResponse *bidResponse in bidResponsesArr){
        XCTAssert([[bidResponse getVisitId] isEqualToString:visitId]);
        XCTAssert([[bidResponse getAdCycleId] isEqualToString:adCycleId]);
        XCTAssert([[bidResponse viewContextLink] isEqualToString:contextUrl]);
        
        MNetBidResponseExtension *extension = [bidResponse extension];
        XCTAssert(extension != nil);
        
        NSArray *videoLogs = [extension videoLogsTemplate];
        XCTAssert(videoLogs != nil);
        XCTAssert([videoLogs count] > 0);
        
        if([bidResponse.adType isEqualToString:BID_TYPE_ADX]){
            XCTAssert(extension.adxAdUnitId != nil);
            XCTAssert(extension.awlog != nil);
            XCTAssert(extension.prlog != nil);
            XCTAssert(extension.prflog != nil);
        }
    }
    
    NSLog(@"%@", [MNJMManager toJSONStr:bidResponsesArr]);
}

- (void)testExclusiveAdUnits{
    NSString *expectedAdUnit = @"test_ad_unit_1";
    NSDictionary *responseDict = [self getPredictBidsResponseDict];
    
    NSString *adCycleId = @"dummy-ad-cycle-id";
    NSString *visitId = @"dummy-visit-id";
    NSString *contextUrl = @"dummy-context-url";
    NSString *vcTitle = @"dummy-vc-title";
    NSString *keywords = @"keywords";
    
    MNetResponseParserExtras *params = [MNetResponseParserExtras getInstanceWithAdCycleId:adCycleId
                                                                                  visitId:visitId
                                                                               contextUrl:contextUrl
                                                                      viewControllerTitle:vcTitle
                                                                           viewController:[self getViewController]
                                                                                 keywords:keywords
                                        ];
    
    
    id<MNetResponseParserProtocol> parser = [MNetResponseParser getParser];
    NSError *parserErr;
    NSArray<MNetBidResponse *> *bidResponsesArr = [parser parseResponse:responseDict
                                                 exclusivelyForAdUnitId:expectedAdUnit
                                                        withExtraParams:params
                                                               outError:&parserErr];
    XCTAssert(bidResponsesArr != nil);
    XCTAssert([bidResponsesArr count] > 0);
    
    for(MNetBidResponse *bidResponse in bidResponsesArr){
        XCTAssert(bidResponse.creativeId != nil);
        XCTAssert([bidResponse.creativeId isEqualToString:expectedAdUnit]);
        XCTAssert([[bidResponse viewContextLink] isEqualToString:contextUrl]);
    }
}

- (void)testNonExclusivityOfAdUnits{
    NSString *adUnit1 = @"test_ad_unit_1";
    NSString *adUnit2 = @"test_ad_unit_2";
    
    NSDictionary *responseDict = [self getPredictBidsResponseDict];
    
    NSString *adCycleId = @"dummy-ad-cycle-id";
    NSString *visitId = @"dummy-visit-id";
    NSString *contextUrl = @"dummy-context-url";
    NSString *vcTitle = @"dummy-vc-title";
    NSString *keywords = @"dummy-keywords";
    
    MNetResponseParserExtras *params = [MNetResponseParserExtras getInstanceWithAdCycleId:adCycleId
                                                                                  visitId:visitId
                                                                               contextUrl:contextUrl
                                                                      viewControllerTitle:vcTitle
                                                                           viewController:[self getViewController]
                                                                                 keywords:keywords
                                        ];
    
    
    id<MNetResponseParserProtocol> parser = [MNetResponseParser getParser];
    NSError *parserErr;
    NSArray<MNetBidResponse *> *bidResponsesArr = [parser parseResponse:responseDict
                                                 exclusivelyForAdUnitId:nil
                                                        withExtraParams:params
                                                               outError:&parserErr];
    XCTAssert(bidResponsesArr != nil);
    XCTAssert([bidResponsesArr count] > 0);
    
    NSUInteger adUnit1Count = 0;
    NSUInteger adUnit2Count = 0;
    for(MNetBidResponse *bidResponse in bidResponsesArr){
        XCTAssert(bidResponse.creativeId != nil);
        if([bidResponse.creativeId isEqualToString:adUnit2]){
            adUnit2Count += 1;
        }else if([bidResponse.creativeId isEqualToString:adUnit1]){
            adUnit1Count += 1;
        }
    }
    
    XCTAssert(adUnit1Count == 2);
    XCTAssert(adUnit1Count == adUnit2Count);
}

- (NSDictionary *)getPredictBidsResponseDict{
    NSString *jsonString = readFile([self class], @"MNetPredictBidsRelayResponse", @"json");
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if(error != nil || jsonResponse == nil){
        NSLog(@"Error Parsing json");
        NSLog(@"%@", error);
        abort();
    }
    
    NSDictionary *dataContents = [jsonResponse objectForKey:@"data"];
    return dataContents;
}

@end
