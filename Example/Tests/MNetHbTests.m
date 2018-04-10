//
//  MNetHbTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 06/11/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"
@import GoogleMobileAds;

@interface MNetHbTests : MNetTestManager
@property (nonatomic) XCTestExpectation *hbExpectation;
@end

@implementation MNetHbTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHbTests{
    [self stubPredictWithValidResp];
    
    self.hbExpectation = [self expectationWithDescription:@"Header-bidding expectation"];
    
    DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    [dfpBannerView setAdUnitID:@"customHbAdUnit"];
    [dfpBannerView setRootViewController:[self getViewController]];
    DFPRequest *request = [DFPRequest request];
    [request setCustomTargeting:@{@"bid": @"15"}];
    
    // Manual header bidding
    [MNetHeaderBidder addBidsToDfpBannerAdRequest:request
                                       withAdView:dfpBannerView
                                 withCompletionCb:^(NSObject *modifiedRequest, NSError *error)
     {
         if(error){
             XCTFail(@"Error when adding bids to request - %@", error);
             EXPECTATION_FULFILL(self.hbExpectation);
             return;
         }
         
         XCTAssert(modifiedRequest != nil);
         EXPECTATION_FULFILL(self.hbExpectation);
     }];

    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Error - %@", error);
        }else{
            NSLog(@"Success!!");
        }
    }];
}

- (void)skip_testHbTimeTaken{
    [self stubPredictWithValidResp];
    
    [self measureBlock:^{
        self.hbExpectation = [self expectationWithDescription:@"Header-bidding expectation"];
        
        DFPBannerView *dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        [dfpBannerView setAdUnitID:@"customHbAdUnit"];
        [dfpBannerView setRootViewController:[self getViewController]];
        DFPRequest *request = [DFPRequest request];
        [request setCustomTargeting:@{@"bid": @"15"}];
        
        __block NSNumber *startTime = [MNetUtil getTimestampInMillis];
        NSLog(@"TIME_DIFF: **************************");
        
        // Manual header bidding
        [MNetHeaderBidder addBidsToDfpBannerAdRequest:request
                                           withAdView:dfpBannerView
                                     withCompletionCb:^(NSObject *modifiedRequest, NSError *error)
         {
             NSNumber *endTime = [MNetUtil getTimestampInMillis];
             NSLog(@"TIME_DIFF: FINAL : %f ms", [endTime doubleValue] - [startTime doubleValue]);
             
             if(error){
                 XCTFail(@"Error when adding bids to request - %@", error);
                 EXPECTATION_FULFILL(self.hbExpectation);
                 return;
             }
             
             XCTAssert(modifiedRequest != nil);
             EXPECTATION_FULFILL(self.hbExpectation);
         }];
        
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            if(error){
                NSLog(@"Error - %@", error);
            }else{
                NSLog(@"Success!!");
            }
        }];
        
    }];
}

- (void)stubPredictWithValidResp{
    NSString *respStr = readFile([self class], @"MNetPredictBidsRelayResponse", @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *requestUrl = [NSString stringWithFormat:@"%@.*", url];
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
    
    stubPrefetchReq([self class]);
}

- (void)testSamplingRate{
    NSNumber *samplingRate = [NSNumber numberWithInteger:0.01];
    
    NSUInteger winCount = 0;
    NSUInteger totalCount = 1000;
    for (NSUInteger i=0; i<totalCount; i++){
        BOOL result = [[MNetHB getSharedInstance] getSamplingResultForRate:samplingRate];
        if(result){
            winCount += 1;
        }
    }
    
    // Make sure that it does not win every thing
    XCTAssert(winCount < totalCount, @"not expected to win all the time with sampling rate - %@", samplingRate);
    NSLog(@"total win count - %lu", winCount);
}

- (void)testSamplingRateForPositiveVal{
    NSNumber *samplingRate = [NSNumber numberWithInteger:1];
    
    NSUInteger winCount = 0;
    NSUInteger totalCount = 1000;
    for (NSUInteger i=0; i<totalCount; i++){
        BOOL result = [[MNetHB getSharedInstance] getSamplingResultForRate:samplingRate];
        if(result){
            winCount += 1;
        }
    }
    
    // Make sure that it does not win every thing
    XCTAssert(winCount == totalCount, @"expected to win all the time with sampling rate - %@", samplingRate);
    NSLog(@"total win count - %lu", winCount);
}

- (void)testSamplingRateForInvalidValues{
    NSNumber *samplingRate = [NSNumber numberWithFloat:200.0f];
    
    NSUInteger winCount = 0;
    NSUInteger totalCount = 1000;
    for (NSUInteger i=0; i<totalCount; i++){
        BOOL result = [[MNetHB getSharedInstance] getSamplingResultForRate:samplingRate];
        if(result){
            winCount += 1;
        }
    }
    
    // Make sure that it does not win every thing
    XCTAssert(winCount == totalCount, @"expected to win all the time with sampling rate - %@", samplingRate);
    NSLog(@"total win count - %lu", winCount);
}



@end
