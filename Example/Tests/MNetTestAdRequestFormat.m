//
//  MNetTestAdRequestFormat.m
//  MNAdSdk
//
//  Created by nithin.g on 26/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNDemoConstants.h"
#import "MNetTestManager.h"

@interface MNetTestAdRequestFormat : MNetTestManager

@end

@implementation MNetTestAdRequestFormat

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

-(void) commonTesterWithAdUnit:(NSString *)adUnitId
                      withSize:(CGSize)size
               withIntersitial:(BOOL)isInterstitial {
    
    MNetAdRequest *request = [[MNetAdRequest alloc] init];
    [request setAdUnitId:adUnitId];
    [request setIsInterstitial:isInterstitial];
    [request setAdSizes:@[MNetAdSizeFromCGSize(size)]];
    
    MNetBidRequest *bidRequest = [MNetBidRequest create:request];
    id reqDict = [MNJMManager getCollectionFromObj:bidRequest];
    
    // Assert for correctness here
    XCTAssert(reqDict != nil, @"Parsed object shouldn't be nil");
    
    // Only checking the ad related stuff here
    NSArray *bidRequestKeys = [reqDict allKeys];
    NSArray *expectedKeysList = @[
                          @"app",
                          @"capabilities",
                          @"device",
                          @"imp"
                        ];
    for(NSString *expectedKey in expectedKeysList){
        if(![bidRequestKeys containsObject:expectedKey]){
            XCTFail(@"The request does not contain the following key - %@ in the list of keys %@", expectedKey, expectedKeysList);
        }
    }
    
    // app.publisher.id - NSString
    id publisher = [[reqDict objectForKey:@"app"] objectForKey:@"publisher"];
    if(!publisher){
        XCTFail(@"Request does not contain the publisher key");
    }
    
    NSString *publisherId = [publisher objectForKey:@"id"];
    XCTAssert([DEMO_MN_CUSTOMER_ID isEqualToString:publisherId],
              @"Request format: Publisher id is not equal to the customer id in the demo app");
    
    // imp.tagid        - NSString
    id imp = [reqDict objectForKey:@"imp"];
    
    if([imp count] == 0){
        XCTFail(@"Request format: The impressions array is empty");
    }
    
    id impObj = [imp objectAtIndex:0];
    
    NSString *tagId = [impObj objectForKey:@"tagid"];
    XCTAssert([adUnitId isEqualToString:tagId],
              @"Request format: Ad unit id does not match the tag id");
    
    // imp.instl        - int
    NSNumber *instl = [impObj objectForKey:@"instl"];
    if(instl == nil){
        XCTFail(@"Request format: instl should not be empty");
    }
    
    int instlVal = [instl intValue];
    if(instlVal > 1 || instlVal < 0){
        XCTFail(@"Request format: instlVal should not be > 1 and < 0. It's currenly - %d", instlVal);
    }
    
    BOOL instlBoolVal = (instlVal == 1);
    XCTAssert(instlBoolVal == isInterstitial, @"Request format: Interstitial values do not match!");
    
}

- (void)testBannerRequest{
    [self commonTesterWithAdUnit:DEMO_MN_AD_UNIT_320x50
                        withSize:kMNetBannerAdSize
                 withIntersitial:NO];
}

- (void)testInterstitialRequest{
    [self commonTesterWithAdUnit:DEMO_MN_AD_UNIT_300x250
                        withSize:kMNetMediumAdSize
                 withIntersitial:YES];
}

- (void)testBannerVideoRequest{
    [self commonTesterWithAdUnit:DEMO_MN_AD_UNIT_450x300
                        withSize:kMNetMediumAdSize
                 withIntersitial:NO];
}

- (void)testInterstitialVideoRequest{
    [self commonTesterWithAdUnit:DEMO_MN_AD_UNIT_450x300
                        withSize:kMNetMediumAdSize
                 withIntersitial:YES];
}

- (void)testRewardedVideoRequest{
    [self commonTesterWithAdUnit:DEMO_MN_AD_UNIT_450x300
                        withSize:kMNetMediumAdSize
                 withIntersitial:NO];
}

/*
- (void) testGetRequestForRawResponse{
    NSString *adCode = @"https://xch-global.media.net/AdExchange/admCache?token=4A5E64973EECC58F858BE2D5C1B56584-0002&region=east";
    
    XCTestExpectation *adViewExpectation = [self expectationWithDescription:@"Ad view not loaded"];
    
    [MNetHttpClient doGetWithStrResponseOn:adCode headers:@{
                                                            @"Accept":@"application/xml"
                                                            } success:^(NSString * _Nonnull responseStr) {
        NSLog(@"Win - %@", responseStr);
        EXPECTATION_FULFILL(adViewExpectation);
    } error:^(NSError * _Nonnull error) {
        NSLog(@"Error raised!");
        EXPECTATION_FULFILL(adViewExpectation);
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}
*/

-(void) testBoolTypeInCapabilty{
    MNetAdCapability *adCapability = [[MNetAdCapability alloc] init];
    [adCapability setAudio:[MNJMBoolean createWithBool:YES]];
    [adCapability setVideo:[MNJMBoolean createWithBool:YES]];
    [adCapability setBanner:[MNJMBoolean createWithBool:YES]];
    [adCapability setNative:[MNJMBoolean createWithBool:NO]];
    [adCapability setRewardedVideo:[MNJMBoolean createWithBool:NO]];
    
    NSString *jsonStrVal = [MNJMManager toJSONStr:adCapability];
    
    // This will just be for debugging purposes,
    // since the order of the capability string will never be known,
    // hence no assertion will be made for the actual value
    NSLog(@"%@", jsonStrVal);
    
    // Asserting that there is no numbers in the string
    NSString *pattern = @"[0-9]";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:nil error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:jsonStrVal options:nil range:NSMakeRange(0, [jsonStrVal length])];
    
    BOOL hasNumbers = NO;
    if(matches && [matches count] > 0){
        hasNumbers = YES;
    }
    
    XCTAssert(!hasNumbers, @"The jsonStr:%@ is incorrect!", jsonStrVal);
    NSLog(@"");
}

- (void)skip_testBidRequestCreationTime{
    NSString *adUnitId = DEMO_MN_AD_UNIT_320x50;
    CGSize size = kMNetBannerAdSize;
    BOOL isInterstitial = NO;
    
    MNetAdRequest *request = [[MNetAdRequest alloc] init];
    [request setAdUnitId:adUnitId];
    [request setIsInterstitial:isInterstitial];
    [request setAdSizes:@[MNetAdSizeFromCGSize(size)]];
    [request setRootViewController:[self getViewController]];
    
    [self measureBlock:^{
        [MNetBidRequest create:request];
    }];
}

- (void)testUniqueAdSizesMethod{
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    NSArray<MNetAdSize *> *adSizes = @[MNetAdSizeFromCGSize(kMNetBannerAdSize), MNetAdSizeFromCGSize(kMNetMediumAdSize), MNetAdSizeFromCGSize(kMNetBannerAdSize)];
    NSArray<MNetAdSize *> *uniqueAdSizes = nil;
    
    NSUInteger expectedArrayCount = 2;
    uniqueAdSizes = [adBaseCommon getUniqueAdSizes:adSizes];
    XCTAssertNotNil(uniqueAdSizes);
    XCTAssertEqual([uniqueAdSizes count], expectedArrayCount);

    expectedArrayCount = 0;
    
    adSizes = [[NSArray alloc] init];
    uniqueAdSizes = [adBaseCommon getUniqueAdSizes:adSizes];
    XCTAssertNotNil(uniqueAdSizes);
    XCTAssertEqual([uniqueAdSizes count], expectedArrayCount);

    adSizes = nil;
    uniqueAdSizes = [adBaseCommon getUniqueAdSizes:adSizes];
    XCTAssertNotNil(uniqueAdSizes);
    XCTAssertEqual([uniqueAdSizes count], expectedArrayCount);
}
@end
