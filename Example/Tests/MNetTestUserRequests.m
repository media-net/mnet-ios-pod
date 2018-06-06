//
//  MNetTestUserRequests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 15/02/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

@interface MNetTestUserRequests : MNetTestManager <MNetAdViewDelegate>
@property (nonatomic) XCTestExpectation *bannerNoAdExpectation;
@end

@implementation MNetTestUserRequests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBannerRequestWithUser{
    MNetUser *user1 = [MNetUser new];
    [user1 setName:@"user1"];
    [[MNet getInstance] setUser:user1];
    
    // Mock the request
    NSString *respStr = readFile([self class], @"noAdResponse", @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    
    // Making sure that user1's name exists in the get request
    NSString *regexStr = [NSString stringWithFormat:@"%@.*?%@%%22%%7D.+", url, user1.name];
    
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
    
    // normal request
    self.bannerNoAdExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    //[bannerAd addRequestSpecificUser:user2];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testBannerRequestWithRequestSpecificUser{
    MNetUser *user1 = [MNetUser new];
    [user1 setName:@"user1"];
    
    MNetUser *user2 = [MNetUser new];
    [user2 setName:@"user2"];
    
    [[MNet getInstance] setUser:user1];
    
    // Mock the request
    NSString *respStr = readFile([self class], @"noAdResponse", @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    
    // Making sure that user2's name exists in the get request
    NSString *regexStr = [NSString stringWithFormat:@"%@.*?%@%%22%%7D.+", url, user2.name];
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
    
    // normal request
    self.bannerNoAdExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    MNetAdView *bannerAd = [[MNetAdView alloc] init];
    [bannerAd setAdSize:MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    [bannerAd setAdUnitId:DEMO_MN_AD_UNIT_320x50];
    [bannerAd setRootViewController:[self getViewController]];
    [bannerAd setDelegate:self];
    [bannerAd addRequestSpecificUser:user2];
    [bannerAd loadAd];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

-(void)mnetAdDidLoad:(MNetAdView *)adView{
    XCTFail(@"Adview should not have rendered!");
    EXPECTATION_FULFILL(self.bannerNoAdExpectation);
}

- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error{
    EXPECTATION_FULFILL(self.bannerNoAdExpectation);
}

@end
