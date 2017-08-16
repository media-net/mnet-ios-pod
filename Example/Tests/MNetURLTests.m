//
//  MNetURLTests.m
//  MNAdSdk
//
//  Created by nithin.g on 26/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Nocilla/Nocilla.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetURLTests : MNetTestManager

@end

@implementation MNetURLTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testNullabilityOfAllUrls {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    MNetURL *urlObj = [MNetURL getSharedInstance];
    XCTAssert([urlObj getBaseResourceUrl] != nil, @"Url cannot be nil");
    XCTAssert([urlObj getBaseUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getBaseConfigUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getBasePulseUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getBaseResourceUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getAdLoaderUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getLatencyTestUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getConfigUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getPulseUrl] != nil, @"Url should not be nil");
    XCTAssert([urlObj getFingerPrintUrl] != nil, @"Url should not be nil");

    // Not writing tests for the contents. This might keep changing
    urlObj.isDebug = NO;
    NSLog(@"Printing all the prod urls, ");
    NSLog(@"%@",[urlObj getBaseUrl]);
    NSLog(@"%@",[urlObj getBaseConfigUrl]);
    NSLog(@"%@",[urlObj getBasePulseUrl]);
    NSLog(@"%@",[urlObj getBaseResourceUrl]);
    NSLog(@"%@",[urlObj getLatencyTestUrl]);
    NSLog(@"%@",[urlObj getAdLoaderUrl]);
    NSLog(@"%@",[urlObj getConfigUrl]);
    NSLog(@"%@",[urlObj getPulseUrl]);
    NSLog(@"%@",[urlObj getFingerPrintUrl]);
    
    urlObj.isDebug = YES;
    NSLog(@"Printing all the debug urls, ");
    NSLog(@"%@",[urlObj getBaseUrl]);
    NSLog(@"%@",[urlObj getBaseConfigUrl]);
    NSLog(@"%@",[urlObj getBasePulseUrl]);
    NSLog(@"%@",[urlObj getBaseResourceUrl]);
    NSLog(@"%@",[urlObj getLatencyTestUrl]);
    NSLog(@"%@",[urlObj getAdLoaderUrl]);
    NSLog(@"%@",[urlObj getConfigUrl]);
    NSLog(@"%@",[urlObj getPulseUrl]);
    NSLog(@"%@",[urlObj getFingerPrintUrl]);
}

- (void)testIfHttpAllowed{
    BOOL isHttpAllowed = [MNetURL checkIfHttpAllowed];
    NSLog(@"Is Http allowed - %@", isHttpAllowed? @"YES": @"NO");
}

@end
