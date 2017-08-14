//
//  MNetTestVideoLoad.m
//  MNAdSdk
//
//  Created by kunal.ch on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestVideoLoad : MNetTestManager <MNetVideoDelegate, MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *videoAdViewExpectation;
@end

@implementation MNetTestVideoLoad

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testVideoAdLoad {
    validVideoAdRequestStub([self class]);
    self.videoAdViewExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setSize:MNET_BANNER_AD_SIZE];
    [adView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [adView setRootViewController:[self getViewController]];
    [adView setVideoDelegate:self];
    [adView setDelegate:self];
    [adView loadAd];
   
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
    
}

-(void) testVideoAdLoadFail {
    invalidVideoAdRequestStub([self class]);
    self.videoAdViewExpectation = [self expectationWithDescription:@"video view loaded"];
    
    MNetAdView *adView = [[MNetAdView alloc] init];
    [adView setSize:MNET_BANNER_AD_SIZE];
    [adView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [adView setVideoDelegate:self];
    [adView setDelegate:self];
    [adView loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetVideoDidLoad:(MNetAdView *)adView{
    EXPECTATION_FULFILL(self.videoAdViewExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    XCTAssert(error != nil);
    EXPECTATION_FULFILL(self.videoAdViewExpectation);
}

@end
