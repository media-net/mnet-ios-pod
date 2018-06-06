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
@property (nonatomic) BOOL testingValidCase;
@end

@implementation MNetTestRewardedVideo

- (void)setUp {
    [self cacheVideoUrl:[[self class] getVideoUrl]];
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testRewardedVideoAdLoad {
    self.testingValidCase = YES;
    validRewardedVideoAdRequestStub([self class]);
    self.rewardedTestExpectation = [self expectationWithDescription:@"rewarded video loaded"];
    MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
    [rewardedVideo setRewardedVideoDelegate:self];
    [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : [NSNumber numberWithInt:100]];
    [rewardedVideo loadRewardedAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void) testInvalidRewardedVideoAdLoad {
    self.testingValidCase = NO;
    invalidVideoAdRequestStub([self class]);
    self.rewardedTestExpectation = [self expectationWithDescription:@"rewarded video loaded"];
    MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
    [rewardedVideo setRewardedVideoDelegate:self];
    [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : [NSNumber numberWithInt:100]];
    [rewardedVideo loadRewardedAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void) testInvalidTypeRewardedVideoAdLoad {
    self.testingValidCase = NO;
    invalidRewardedVideoAdRequestStub([self class]);
    self.rewardedTestExpectation = [self expectationWithDescription:@"rewarded video loaded"];
    MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
    [rewardedVideo setRewardedVideoDelegate:self];
    [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : [NSNumber numberWithInt:100]];
    [rewardedVideo loadRewardedAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)mnetRewardedVideoDidLoad:(MNetRewardedVideo *)rewardedVideo{
    if(self.testingValidCase){
        EXPECTATION_FULFILL(self.rewardedTestExpectation);
    }else{
        XCTFail(@"Expected to rewarded-video to fail!");
        EXPECTATION_FULFILL(self.rewardedTestExpectation);
    }
}

- (void)mnetRewardedVideoDidFailToLoad:(MNetRewardedVideo *)rewardedVideo withError:(MNetError *)error{
    if(NO == self.testingValidCase){
        EXPECTATION_FULFILL(self.rewardedTestExpectation);
    }else{
        XCTFail(@"Expected rewarded-video to pass - %@", error);
        EXPECTATION_FULFILL(self.rewardedTestExpectation);
    }
}

@end
