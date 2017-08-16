//
//  MNetTestInterstitialVideo.m
//  MNAdSdk
//
//  Created by kunal.ch on 26/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestInterstitialVideo : MNetTestManager<MNetInterstitialVideoAdDelegate>
@property (nonatomic) XCTestExpectation *interstitialTestExpectation;
@end

@implementation MNetTestInterstitialVideo

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

-(void) testInterstitialVideoAdLoad {
    validVideoAdRequestStub([self class]);
    self.interstitialTestExpectation = [self expectationWithDescription:@"interstitial video load"];
    MNetInterstitialAd *interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitialAd setInterstitialVideoDelegate:self];
    [interstitialAd loadAd];

    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];

}


-(void) testInvalidInterstitialVideoAdLoad {
    
    invalidVideoAdRequestStub([self class]);
    self.interstitialTestExpectation = [self expectationWithDescription:@"interstitial video load"];
    MNetInterstitialAd *interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitialAd setInterstitialVideoDelegate:self];
    [interstitialAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
    
}

- (void)mnetInterstitialVideoDidLoad:(MNetInterstitialAd *)interstitialAd{
    EXPECTATION_FULFILL(self.interstitialTestExpectation);
}

- (void)mnetInterstitialVideoDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error{
    XCTAssert(error != nil);
    EXPECTATION_FULFILL(self.interstitialTestExpectation);
}
@end
