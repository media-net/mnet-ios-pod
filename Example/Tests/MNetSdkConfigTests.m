//
//  MNetSdkConfigTests.m
//  MNAdSdk
//
//  Created by nithin.g on 13/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Nocilla/Nocilla.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetSdkConfigTests : MNetTestManager
@end

@implementation MNetSdkConfigTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testSdkConfigImport {
    id hbConfig = [[MNetSdkConfig getInstance] getHbConfigData];
    XCTAssertNotNil(hbConfig, @"HbConfig cannot be nil");
}

- (void)testSdkHbConfig{
    NSDictionary *config = [[MNetSdkConfig getInstance] getConfig];
    MNetHbConfigData *hbConfig = [MNetHbConfigData getInstanceFromConfigData:config];
    XCTAssertNotNil(hbConfig, @"HbConfig cannot be nil");
    XCTAssertNotNil(hbConfig.adUnitConfigDataList, @"AdUnitConfigDataLIst cannot be nil");
    XCTAssert([hbConfig.adUnitConfigDataList count] > 0, @"AdUnitConfigDataLIst cannot be empty");
}

- (void)testSdkConfigAutoRefreshPositive{
    NSString *adUnitId = @"dummyAdUnitId";
    MNetSdkConfig *sdkConfig = [MNetSdkConfig getInstance];
    
    BOOL isRefreshEnabled = [sdkConfig getAutoRefreshStatusForAdUnitId:adUnitId];
    NSNumber *refreshInterval = [sdkConfig getAutoRefreshIntervalForAdUnitId:adUnitId];
    
    long expectedInterval = 120;
    
    XCTAssert(isRefreshEnabled == YES, @"Auto refresh should've been YES");
    XCTAssert(refreshInterval != nil && [refreshInterval longValue] == expectedInterval, @"Auto refresh Interval should not be nil");
}

- (void)testSdkConfigAutoRefreshNegative{
    NSString *adUnitId = @"invalidAdUnitId";
    
    BOOL isRefreshEnabled = [[MNetSdkConfig getInstance] getAutoRefreshStatusForAdUnitId:adUnitId];
    NSNumber *refreshInterval = [[MNetSdkConfig getInstance] getAutoRefreshIntervalForAdUnitId:adUnitId];
    
    XCTAssert(isRefreshEnabled == NO, @"Auto refresh should've been NO");
    XCTAssert(refreshInterval == nil, @"Auto refresh Interval should've been nil");
}

- (void)testSdkConfigData{
    MNetSdkConfig *instance = [MNetSdkConfig getInstance];
    MNetSdkConfigData *configData = [instance getSdkConfigData];
    MNetSdkConfigVCLinks *sdkConfigLinks = [configData viewControllerLinks];
    XCTAssert(sdkConfigLinks != nil, @"sdkConfigLinks shouldn't be nil");
    XCTAssert([sdkConfigLinks isEnabled] == YES, @"sdkConfigLinks should be enabled!");
    XCTAssert([sdkConfigLinks linkMap] != nil, @"linkMap should not be nil");
    XCTAssert([[sdkConfigLinks linkMap] count] == 2, @"linkMap should have 2 entries");
    
    NSDictionary *linkMap = [sdkConfigLinks linkMap];
    
    NSString *key = @"dummyVC2";
    NSString *value = @"http://dummyVC2Link.com";
    
    XCTAssert([[linkMap objectForKey:key] isEqualToString:value], @"The values  from the linkMap do not match! Got - %@", [linkMap objectForKey:key]);
}

- (void)testDefaultValues{
    // Just printing all the values right now. No assertions
    MNetSdkConfig *instance = [MNetSdkConfig getInstance];
    NSString *adUnitId = @"dummyAdUnitId";
    NSLog(@"getAutoRefreshStatusForAdUnitId- %@", [instance getAutoRefreshStatusForAdUnitId:adUnitId]?@"YES": @"NO");
    NSLog(@"getAutoRefreshIntervalForAdUnitId- %@", [instance getAutoRefreshIntervalForAdUnitId:adUnitId]);
    NSLog(@"getIsAutorefresh- %@", [instance getIsAutorefresh]?@"YES": @"NO");
    NSLog(@"getIsAdxEnabledForThirdParty- %@", [instance getIsAdxEnabledForThirdParty]?@"YES": @"NO");
    NSLog(@"getIsVideoFireEvents- %@", [instance getIsVideoFireEvents]?@"YES": @"NO");
    NSLog(@"getPrfDelay- %@", [instance getPrfDelay]);
    NSLog(@"getGptDelay- %@", [instance getGptDelay]);
    NSLog(@"getRefreshRate- %@", [instance getRefreshRate]);
    NSLog(@"getPulseMaxArrLen- %@", [instance getPulseMaxArrLen]);
    NSLog(@"getPulseMaxSize- %@", [instance getPulseMaxSize]);
    NSLog(@"getPulseMaxTimeInterval- %@", [instance getPulseMaxTimeInterval]);
    NSLog(@"getLocationUpdateInterval- %@", [instance getLocationUpdateInterval]);
    NSLog(@"getAppTrackerTimerInterval- %@", [instance getAppTrackerTimerInterval]);
    NSLog(@"getAppStoreUpdateInterval- %@", [instance getAppStoreUpdateInterval]);
    NSLog(@"getAppStoreMinEntries- %@", [instance getAppStoreMinEntries]);
    NSLog(@"getAppStoreMaxNumerOfEntries- %@", [instance getAppStoreMaxNumerOfEntries]);
    NSLog(@"getMaxDfpVersionSupport- %@", [instance getMaxDfpVersionSupport]);
    NSLog(@"getAdViewCacheCleanInterval- %@", [instance getAdViewCacheCleanInterval]);
    NSLog(@"getAdViewCacheDuration- %@", [instance getAdViewCacheDuration]);
    NSLog(@"getRewardedInstanceMaxAge- %f", [instance getRewardedInstanceMaxAge]);
    NSLog(@"getCacheMaxAge- %f", [instance getCacheMaxAge]);
    NSLog(@"getCacheFileMaxSize- %f", [instance getCacheFileMaxSize]);
}

- (void)testVCMapLinks{
    NSString *VCName = @"dummyVC2";
    NSString *expectedUrl = @"http://dummyVC2Link.com";
    NSString *url = [[MNetSdkConfig getInstance] getLinkFromSdkConfigForVCName:VCName];
    XCTAssert([expectedUrl isEqualToString:url], @"Incorrect url! Got - %@", url);
}

@end
