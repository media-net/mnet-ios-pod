//
//  MNetPrefetchObject.m
//  MNAdSdk
//
//  Created by nithin.g on 10/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

#define AD_CYCLE_ID_VALUE @"dummyAdCycleId"

@interface MNetPrefetchObjectTest : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *prefetchObjectExpectation;
@end

@implementation MNetPrefetchObjectTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPrefetchObj {
    validBannerAdRequestStub([self class]);
    prefetchObjStub([self class]);
    
    self.prefetchObjectExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setSize:MNET_BANNER_AD_SIZE];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetAdDidLoad:(MNetAdView *)adView{
    NSString *prefetchObj = (NSString *)[[adView.adBaseObj class] getValueForKey:DEMO_MN_AD_UNIT_320x50];
    
    if(!prefetchObj){
        XCTFail(@"Expected to store the prefetch object!");
    } else{
        XCTAssert([prefetchObj isEqualToString:AD_CYCLE_ID_VALUE],
                  @"The ad cycle id of the stored entry does not match!"
                  );
    }
    EXPECTATION_FULFILL(self.prefetchObjectExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTFail(@"Adview failed to render! - %@", [error getErrorString]);
    EXPECTATION_FULFILL(self.prefetchObjectExpectation);
}

@end
