//
//  MNetTestWebViewSelection.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 28/05/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetTestWebViewSelection : MNetTestManager
@property (nullable) MNetBannerWebView *bannerWebView;
@end

@implementation MNetTestWebViewSelection

- (void)setUp{
    [super setUp];
    [self setBannerWebView:[[MNetBannerWebView alloc] init]];
}

- (void)tearDown{
    [super tearDown];
    [self setBannerWebView:nil];
}

- (void)testCanUseWkWebviewWithoutWildcards {
    NSArray *supportedVersions = @[
                                   @"10.0.0",
                                   @"11.0.0",
                                   @"12.0.0",
                                   ];
    BOOL canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.0.0"
                                                fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - 11.0.0");
    
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.1.0"
                                                fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == NO, @"Expected false, got true For input - 11.1.0");
}

- (void)testCanUseWkWebviewWithWildcards {
    NSArray *supportedVersions = @[
                                   @"11.0.*",
                                   ];
    BOOL canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.0.100"
                                                fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - 11.0.100");
    
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.1.0"
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == NO, @"Expected false, got true For input - 11.1.0");
}

- (void)testCanUseWkWebviewWithIncompleteWildcards {
    NSArray *supportedVersions = @[
                                   @"11.*",
                                   @"12.1.*",
                                   ];
    BOOL canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.0.100"
                                                fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - 11.0.0");
    
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:@"11.1.0"
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == YES, @"Expected true, got false For input - 11.1.0");
    
    NSString *currVersion = @"12.1.100";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == YES, @"Expected true, got false For input - %@", currVersion);
    
    currVersion = @"12.2.0";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == NO, @"Expected false, got true For input - %@", currVersion);

    // Testing catch-all scenario
    currVersion = @"112.3.0";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:@[@"*"]];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
    
    // Incomplete current version
    currVersion = @"112.3";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:@[@"*"]];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
}

- (void)testCanUseWkWebviewForPrecedence {
    NSArray *supportedVersions = @[
                                   @"11.2.1",
                                   @"11.1.*",
                                   ];
    NSString *currVersion = @"11.2.1";
    BOOL canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
    
    currVersion = @"11.1.1";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
    
    currVersion = @"11.2.2";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview == NO, @"Expected false, got true For input - %@", currVersion);
}


- (void)testCanUseWkWebviewForCatchAllPrecedence {
    // This is utterly meaningless, since it's going to match everything
    NSArray *supportedVersions = @[
                                   @"*",
                                   @"11.2.1",
                                   @"11.1.*",
                                   ];
    NSString *currVersion = @"11.2.1";
    BOOL canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                                fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
    
    currVersion = @"11.2.2";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
    
    currVersion = @"10.2.2";
    canUseWkWbview = [[self bannerWebView] canUseWkwebviewForVersion:currVersion
                                           fromSupportedVersionsList:supportedVersions];
    XCTAssert(canUseWkWbview, @"Expected true, got false For input - %@", currVersion);
}

@end
