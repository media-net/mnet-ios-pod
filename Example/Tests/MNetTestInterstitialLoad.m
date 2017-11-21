//
//  MNetTestInterstitialLoadAd.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestInterstitialLoadAd : MNetTestManager <MNetInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *interstitialAdViewExpectation;
@end

@implementation MNetTestInterstitialLoadAd

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInterstitialAdLoad {
    validInterstitialAdRequestStub([self class]);
    stubPrefetchReq([self class]);
    
    self.interstitialAdViewExpectation = [self expectationWithDescription:@"Ad view loaded"];
    
    MNetInterstitialAd *interstitalAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
    [interstitalAd setInterstitialDelegate:self];
    [interstitalAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd{
    EXPECTATION_FULFILL(self.interstitialAdViewExpectation);
}

- (void)mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error{
    XCTFail(@"Ad view failed! - %@", error);
    EXPECTATION_FULFILL(self.interstitialAdViewExpectation);
}
@end
