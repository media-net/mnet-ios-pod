//
//  MNetAdAnalyticsLoggingTests.m
//  MNAdSdk
//
//  Created by nithin.g on 03/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdAnalytics.h>
#import "MNetTestManager.h"

@interface MNetAdAnalyticsLoggingTests : MNetTestManager
@property (nonatomic) XCTestExpectation *analyticsExpectation;
@end

@implementation MNetAdAnalyticsLoggingTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDpResponse {
    NSString *adCycleId = @"12345";
    
    [[MNetAdAnalytics getSharedInstance] logStartTimeForEvent:MnetAdAnalyticsTypeDpResponse withAdCycleId:adCycleId];
    [[MNetAdAnalytics getSharedInstance] logEndTimeForEvent:MnetAdAnalyticsTypeDpResponse withAdCycleId:adCycleId];
    [[MNetAdAnalytics getSharedInstance] logTimeDuration:20 forEvent:MnetAdAnalyticsTypeAdRendering withAdCycleId:adCycleId];
    
    [[MNetAdAnalytics getSharedInstance] writeToPulseForAdCycleId:adCycleId];
}

@end
