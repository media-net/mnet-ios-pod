//
//  MNetTestInterstitialIncomplete.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "XCTest+MNetTestUtils.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestInterstitialIncomplete : MNetTestManager <MNetInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *InterstitialIncompleteExpectation;
@end

@implementation MNetTestInterstitialIncomplete

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInterstitialAdIncomplete {
    validInterstitialAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.InterstitialIncompleteExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    MNetInterstitialAd *interstitalAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitalAd setInterstitialDelegate:self];
    [interstitalAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testInterstitialAdSansAdUnit {
    validInterstitialAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.InterstitialIncompleteExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetInterstitialAd *interstitalAd = [[MNetInterstitialAd alloc] init];
    [interstitalAd setInterstitialDelegate:self];
    [interstitalAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd{
    EXPECTATION_FULFILL(self.InterstitialIncompleteExpectation);
}

- (void)mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error{
    EXPECTATION_FULFILL(self.InterstitialIncompleteExpectation);
}

@end
