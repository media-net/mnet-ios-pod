//
//  MNetHttpClientTests.m
//  MNAdSdk
//
//  Created by nithin.g on 27/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>


#import <Nocilla/Nocilla.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetHttpClientTests : MNetTestManager
@property (nonatomic) XCTestExpectation *headRequestExpectation;
@end

@implementation MNetHttpClientTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testUrlReachability{
    NSString *url = @"http://google.com";
    
    stubRequest(@"HEAD", url).andReturn(200);
    self.headRequestExpectation = [self expectationWithDescription:@"isUrlReachable expectation"];
    
    [MNetHttpClient isUrlReachable:url withStatus:^(BOOL isReachable){
        NSLog(@"isReachable : %@", isReachable? @"YES" : @"NO");
        XCTAssert(isReachable, @"The url must be reachable");
        EXPECTATION_FULFILL(self.headRequestExpectation);
    }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout
                                 handler:^(NSError * _Nullable error)
    {
        NSLog(@"Request timed out!");
    }];
}

- (void)testDoGetOnWithParams{
    NSDictionary *headers = @{};
    NSDictionary *params = @{@"trail":@"sample"};
    
    NSString *url = @"http://google.com";
    NSString *rawResp = @"{\"data\":{}, \"success\":\"true\"}";
    
    stubRequest(@"GET", @"http://google.com?trail=sample").andReturnRawResponse([rawResp data]);
    self.headRequestExpectation = [self expectationWithDescription:@"isUrlReachable expectation"];
    
    [MNetHttpClient doGetOn:url headers:headers params:params success:^(NSDictionary * _Nonnull responseDict) {
        XCTAssert(responseDict != nil, @"The url must be reachable");
        EXPECTATION_FULFILL(self.headRequestExpectation);
    } error:^(NSError * _Nonnull error) {
        XCTFail(@"GET request shouldn't fail! - %@", error);
        EXPECTATION_FULFILL(self.headRequestExpectation);
    }];
    
    NSTimeInterval timeout = 10;
    [self waitForExpectationsWithTimeout:timeout
                                 handler:^(NSError * _Nullable error)
     {
         NSLog(@"Request timed out!");
     }];
}

@end
