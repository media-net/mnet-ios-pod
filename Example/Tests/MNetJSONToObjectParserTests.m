//
//  MNetJSONToObjectParserTests.m
//  MNAdSdk
//
//  Created by nithin.g on 28/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetSampleModelClass.h"
#import <objc/runtime.h>

@interface MNetJSONToObjectParserTests : MNetTestManager

@end

@implementation MNetJSONToObjectParserTests

- (void)testSingleLevelResponse {
    NSString *requestStr = readFile([self class], FILENAME_SAMPLE_REQUEST, @"json");
    MNetBidRequest *bidRequest = [[MNetBidRequest alloc] init];
    
    FromJSON(requestStr, bidRequest);
    
    // Test the response
    XCTAssert(bidRequest != nil, @"Bid request should not be nil");
    
    BOOL hostAppInfoType = [bidRequest.hostAppInfo isKindOfClass:[MNetHostAppInfo class]];
    XCTAssert(hostAppInfoType, @"HostAppInfo type is incorrect");
    
    BOOL deviceInfoType = [bidRequest.deviceInfo isKindOfClass:[MNetDeviceInfo class]];
    XCTAssert(deviceInfoType, @"deviceInfoType type is incorrect");
    
    BOOL adCapabilityType = [bidRequest.adCapability isKindOfClass:[MNetAdCapability class]];
    XCTAssert(adCapabilityType, @"adCapabilityType type is incorrect");
    
    NSArray<MNetAdImpression *> *adImpressionsList = bidRequest.adImpressions;
    XCTAssert(adImpressionsList != nil, @"ad impressions cannot be nil");
    XCTAssert([adImpressionsList count] > 0, @"ad impressions count cannot be 0");
    
    NSObject *adImpr = [adImpressionsList firstObject];
    XCTAssert([adImpr isKindOfClass:[MNetAdImpression class]], @"adImpr needs to be a kind of MNetAdImpression class");
}

- (void)testSampleJSONContent{
    NSString *jsonStr = readFile([self class], @"MNetSampleJSONContent", @"json");
    
    MNetSampleModelClass *sample = [[MNetSampleModelClass alloc] init];
    FromJSON(jsonStr, sample);
    
    XCTAssert(sample != nil, @"Sample cannot be nil");
    XCTAssert([sample.simpleString isEqualToString:@"testing"]);
    XCTAssert(sample.requestsList != nil);
    XCTAssert(sample.responsesMap != nil);
    XCTAssert([sample.requestsList count] == 2, @"There must only be 2 elements");
    XCTAssert([sample.responsesMap count] == 3, @"There must only be 3 elements");

    MNetBidResponse *bidResponse = (MNetBidResponse *)[sample.responsesMap objectForKey:@"1"];
    XCTAssert(bidResponse.adCode != nil, @"Adcode can't be empty");
    [self assertBidResponse:bidResponse];
}

- (void)assertBidResponse:(MNetBidResponse *)bidResponse{
    XCTAssert(bidResponse != nil, @"BidResponse cannot be nil");
    XCTAssert([bidResponse.bidderId integerValue] == 1000);
    XCTAssert([bidResponse.creativeId isEqualToString:@"sample_creative_id"]);
    XCTAssert([bidResponse.adType isEqualToString:@"banner"]);
    XCTAssert([bidResponse.dfpbid integerValue] == 1000);
    XCTAssert([bidResponse.publisherId isEqualToString:@"samplepublisher_id"]);
    XCTAssert([[bidResponse size] isEqualToString:@"320x50"]);
    XCTAssert(bidResponse.height == 50);
    XCTAssert(bidResponse.width == 320);
    XCTAssert(bidResponse.serverExtras != nil);
    XCTAssert([bidResponse.creativeType isEqualToString:@"html"]);
    XCTAssert(bidResponse.skippable == YES);
    
    // Check every field hereafter
    /*
     "bidder_id": 1000,
     "creative_id": "sample_creative_id",
     "adtype": "banner",
     "adcode": "sample_adcode",
     "dfpbid": 1000,
     "publisher_id": "samplepublisher_id",
     "tp": "sample_tp",
     "size": "320x50",
     "h": 50,
     "w": 320,
     "server_extras": {
     "bidder_id": 1000,
     "mnetSize": "320x50",
     "mnetbidPrice": "7.00"
     },
     "instl": 0,
     "creative_type": "html",
     "bidderInfoBean": {
     "responseTime": 1000
     },
     "skippable": true
     */
}

- (void)testSimpleBidResponse{
    NSString *jsonString = readFile([self class], @"MNetBidResponse", @"json");
    MNetBidResponse *bidResponse = [[MNetBidResponse alloc] init];
    FromJSON(jsonString, bidResponse);
    
    [self assertBidResponse:bidResponse];
}

@end
