//
//  MNetContextLinkTests.m
//  MNAdSdk_Tests
//
//  Created by kunal.ch on 19/12/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetContextLinkTests : MNetTestManager

@end

@implementation MNetContextLinkTests

- (void)testSetContextLink{
    NSString *contextLink = @"https://media.net";
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    adBaseCommon.rootViewController = [self getViewController];
    adBaseCommon.contextLink = contextLink;
    XCTAssertTrue([adBaseCommon.fetchVCLink isEqualToString:contextLink]);
}

- (void)testContextLinkNotSet{
    UIViewController *vc = [self getViewController];
    NSString *contextLink = [MNetUtil getLinkForVC:vc];
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    adBaseCommon.rootViewController = vc;
    XCTAssertTrue([adBaseCommon.fetchVCLink isEqualToString:contextLink], @"Adbase common value - %@ and context link - %@", adBaseCommon.fetchVCLink, contextLink);
}

- (void)testWhenRootViewControllerAndContextLinkSet{
    NSString *contextLink = @"https://media.net";
    NSString *vcLink = [MNetUtil getLinkForVC:[self getViewController]];
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    adBaseCommon.rootViewController = [self getViewController];
    adBaseCommon.contextLink = contextLink;
    XCTAssertFalse([adBaseCommon.fetchVCLink isEqualToString:vcLink]);
    XCTAssertTrue([adBaseCommon.fetchVCLink isEqualToString:contextLink]);
}

- (void)testContextLinkValidity{
    NSString *validcontextLink = @"http://media.net";
    NSString *invalidContextLink = @"media.net";
    NSString *emptyContextLink = @"";
    
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    adBaseCommon.rootViewController = [self getViewController];
    
    adBaseCommon.contextLink = validcontextLink;
    XCTAssertTrue([adBaseCommon.fetchVCLink isEqualToString:validcontextLink]);
    
    adBaseCommon.contextLink = invalidContextLink;
    XCTAssertFalse([adBaseCommon.fetchVCLink isEqualToString:invalidContextLink]);
    
    adBaseCommon.contextLink = emptyContextLink;
    XCTAssertFalse([adBaseCommon.fetchVCLink isEqualToString:emptyContextLink]);
}

- (void)testContextLinkNil{
    MNetAdBaseCommon *adBaseCommon = [[MNetAdBaseCommon alloc] init];
    XCTAssert(adBaseCommon.fetchVCLink != nil);
}
@end
