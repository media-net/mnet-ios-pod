//
//  MNetTestRewardedVideo.m
//  MNAdSdk
//
//  Created by kunal.ch on 26/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestRewardedVideo : MNetTestManager <MNetRewardedVideoDelegate>
@property (nonatomic) XCTestExpectation *rewardedTestExpectation;
@end

@implementation MNetTestRewardedVideo

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testRewardedVideoAdLoad {
   
    validRewardedVideoAdRequestStub([self class]);
    self.rewardedTestExpectation = [self expectationWithDescription:@"rewarded video loaded"];
    MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
    [rewardedVideo setRewardedVideoDelegate:self];
    [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : 100];
    [rewardedVideo loadRewardedAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void) testInvalidRewardedVideoAdLoad {
    
    invalidVideoAdRequestStub([self class]);
    self.rewardedTestExpectation = [self expectationWithDescription:@"rewarded video loaded"];
    MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
    [rewardedVideo setRewardedVideoDelegate:self];
    [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : 100];
    [rewardedVideo loadRewardedAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetRewardedVideoDidLoad:(MNetRewardedVideo *)rewardedVideo{
    EXPECTATION_FULFILL(self.rewardedTestExpectation);
}

- (void)mnetRewardedVideoDidFailToLoad:(MNetRewardedVideo *)rewardedVideo withError:(MNetError *)error{
    XCTAssert(error != nil);
    EXPECTATION_FULFILL(self.rewardedTestExpectation);
}

@end
