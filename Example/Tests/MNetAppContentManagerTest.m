//
//  MNetAppContentManagerTest.m
//  MNAdSdk
//
//  Created by nithin.g on 02/08/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetAppContentManagerTest : MNetTestManager

@end

@implementation MNetAppContentManagerTest

- (void)setUp{
    [super setUp];
    
    [[MNetAppContentCache getSharedInstance] flushCache];
}

- (void)testAppContentCache {
    NSString *key = @"randomKey";
    MNetAppContentCache *cache = [MNetAppContentCache getSharedInstance];
    
    XCTAssert([cache hasKey:key] == NO, @"The cache shouldn't have the key");
    [cache addKey:key];
    XCTAssert([cache hasKey:key] == YES, @"The cache should have the key");
    XCTAssert([cache addKey:key] == YES, @"Multiple inserts should be possible");
}

- (void)testAppContentManager{
    NSString *adUnitId = @"Sample Adunit";
    NSString *adCycleId = @"Sample Adcycle";
    UIViewController *viewController = [self getViewController];
    
    MNetViewTree *viewTree = [[MNetViewTree alloc] initWithViewController:viewController withContentEnabled:NO];
    NSString *crawlingLink = [viewTree getViewTreeLink];
    
    MNetAppContentCache *cache = [MNetAppContentCache getSharedInstance];
    XCTAssert([cache hasKey:crawlingLink] == NO, @"The cache shouldn't contain the crawling link");
    
    MNetAppContentManager *appContentManager = [[MNetAppContentManager alloc] initWithAdUnitId:adUnitId andAdCycleId:adCycleId];
    
    BOOL didFetchData = [appContentManager sendContentForLink:crawlingLink andViewController:viewController];
    
    XCTAssert(didFetchData == YES, @"The data should be fetched. It shouldn't be false.");
    XCTAssert([cache hasKey:crawlingLink] == YES, @"The cache shouldn't contain the crawling link");
}

@end
