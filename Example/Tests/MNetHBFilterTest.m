//
//  MNetHBFilterTest.m
//  MNAdSdk
//
//  Created by nithin.g on 11/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetHBFilterTest : MNetTestManager <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *dummyTableViewEntry;
@property (nonatomic) NSUInteger rowPos;
@end

@implementation MNetHBFilterTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown{
    [super tearDown];
}

- (void)testAdUnitFilterFail {
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"";
    NSDictionary *targetingParams = @{};
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    XCTAssert(fetchedAdUnit == nil, @"Adunit is supposed to be nil");
}

- (void)testAdUnitFilterSizeFail {
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeMake(500, 600);
    NSString *adUnitId = @"d6f2811c2cb84b57bbbf3128c08a2165";
    NSDictionary *targetingParams = @{};
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    XCTAssert(fetchedAdUnit == nil, @"Adunit is supposed to be nil");
}

- (void)testAdUnitFilter {
    NSString *expectedCrid = @"328569603";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"d6f2811c2cb84b57bbbf3128c08a2165";
    NSDictionary *targetingParams = @{};
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    BOOL expectedCondn = fetchedAdUnit != nil && [fetchedAdUnit isEqualToString:expectedCrid];
    XCTAssert(expectedCondn , @"Fetched adunit is incorrect");
}

- (void)testFilterTargetingParams{
    NSString *expectedCrid = @"328569603";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"";
    NSDictionary *targetingParams = @{
                                      @"dedicated":@"false"
                                      };
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    BOOL result = fetchedAdUnit != nil && [fetchedAdUnit isEqualToString:expectedCrid];
    XCTAssert(result , @"Fetched adunit is incorrect");
}

- (void)testFilterTargetingParamsCaseSensitive{
    NSString *expectedCrid = @"caseSensitiveAdunitId";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"";
    NSDictionary *targetingParams = @{
                                      @"dedicated":@"caseSensitiveValue"
                                      };
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    BOOL result = fetchedAdUnit != nil && [fetchedAdUnit isEqualToString:expectedCrid];
    XCTAssert(result , @"Fetched adunit is incorrect");
}

- (void)testFilterTargetingParamsFailure{
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"";
    NSDictionary *targetingParams = @{
                                      @"unknown_key": @"unknown_value"
                                      };
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    XCTAssert(fetchedAdUnit == nil, @"This test case should fail. Instead it returned - %@", fetchedAdUnit);
}

- (void)testFilterTargetingParamsCasePriorityOverAdUnitFilter{
    // As compared to "123" which is the creative of "dummyAdUnitId"
    NSString *expectedCrid = @"328569603";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"dummyAdUnitId";
    NSDictionary *targetingParams = @{
                                      @"dedicated":@"false"
                                      };
    UIView *adView = nil;
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    BOOL result = fetchedAdUnit != nil && [fetchedAdUnit isEqualToString:expectedCrid];
    XCTAssert(result , @"Fetched adunit is incorrect - %@", fetchedAdUnit);
}

- (void)testFilterHbConfigFilterAdUnitId{
    NSString *expectedAdUnitId = @"expCridForHbConfigFilter";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"dummyAdUnitId";
    NSDictionary *targetingParams = @{
                                      @"dedicated":@"FALSE"
                                      };
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    NSLog(@"%@", fetchedAdUnit);
    XCTAssert([expectedAdUnitId isEqualToString:fetchedAdUnit], "The expected ad unit id is wrong - %@", fetchedAdUnit);
}

- (void)testGridViewOutput{
    NSString *expectedResult = [self getPosForXStr:GRID_LEFT andYStr:GRID_CENTER];
    
    CGRect boundsRect = [[UIScreen mainScreen] bounds];
    NSUInteger boxSize = 10;
    NSUInteger adjustedX = 0;
    NSUInteger adjustedY = boundsRect.size.height/2;
    
    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(adjustedX, adjustedY, boxSize, boxSize)];
    NSString *fetchedStr = [MNetGridPositioning getGridPositionForView:adView];
    
    XCTAssert([expectedResult isEqualToString:fetchedStr], @"The fetched str is not expected - %@", fetchedStr);
}

- (void)testGridViewOutput2{
    NSString *expectedResult = [self getPosForXStr:GRID_RIGHT andYStr:GRID_BOTTOM];
    
    NSUInteger boxSize = 10;
    CGRect boundsRect = [[UIScreen mainScreen] bounds];
    NSUInteger adjustedX = boundsRect.size.width - boxSize;
    NSUInteger adjustedY = boundsRect.size.height - boxSize;
    
    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(adjustedX, adjustedY, boxSize, boxSize)];
    NSString *fetchedStr = [MNetGridPositioning getGridPositionForView:adView];
    
    XCTAssert([expectedResult isEqualToString:fetchedStr], @"The fetched str is not expected - %@", fetchedStr);
}


- (NSString *)getPosForXStr:(NSString *)xstr andYStr:(NSString *)ystr{
    return [NSString stringWithFormat:@"%@%@%@", xstr, @"-", ystr];
}

- (void)testFilterHbConfigFilterGridPos{
    NSString *expectedAdUnitId = @"expCridForHbConfigFilterForGrid";
    
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    UIView *adView = [[UIView alloc] initWithFrame:CGRectMake(50, 200, 10, 10)];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"dummyAdUnitIdForGrid";
    NSDictionary *targetingParams = @{
                                      @"grid":@"test"
                                      };
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:adView];
    
    NSLog(@"%@", fetchedAdUnit);
    XCTAssert([expectedAdUnitId isEqualToString:fetchedAdUnit], "The expected ad unit id is wrong - %@", fetchedAdUnit);
}

- (void)testFilterHbConfigFilterListViewPos{
    // Making the view Left-Center
    self.dummyTableViewEntry = [[UIView alloc] initWithFrame:CGRectMake(50, 200, 10, 10)];
    
    // Create a listview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.tableView.delegate = self;
    self.tableView.dataSource= self;
    
    // Forcing the tableview to load the cells
    self.rowPos = 5;
    NSInteger limit = [self.tableView numberOfRowsInSection:0];
    for(int i=0; i<limit; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView cellForRowAtIndexPath:indexPath];
    }
    
    sleep(5);
    
    // Assertions
    NSString *expectedAdUnitId = @"filterTestListViewPos";
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"dummyAdUnitIdForGrid";
    NSDictionary *targetingParams = @{
                                      @"grid":@"test"
                                      };
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:self.dummyTableViewEntry];
    
    NSLog(@"%@", fetchedAdUnit);
    XCTAssert([expectedAdUnitId isEqualToString:fetchedAdUnit], "The expected ad unit id is wrong - %@", fetchedAdUnit);
}

- (void)testFilterHbConfigFilterListViewPosFailureWithGrid{
    // Making the view Left-Left
    self.dummyTableViewEntry = [[UIView alloc] initWithFrame:CGRectMake(50, 10, 10, 10)];
    
    // Create a listview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.tableView.delegate = self;
    self.tableView.dataSource= self;
    
    // Forcing the tableview to load the cells
    self.rowPos = 5;
    NSInteger limit = [self.tableView numberOfRowsInSection:0];
    for(int i=0; i<limit; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView cellForRowAtIndexPath:indexPath];
    }
    
    sleep(5);
    
    // Assertions
    MNetAdUnitFilterManager *filterManager = [MNetAdUnitFilterManager getSharedInstance];
    CGSize adSize = CGSizeZero;
    NSString *adUnitId = @"";
    NSDictionary *targetingParams = @{
                                      @"grid":@"test"
                                      };
    
    NSString *fetchedAdUnit = [filterManager fetchAdUnitIdFromConfig:adUnitId forAdSize:adSize withTargetingParams:targetingParams andAdView:self.dummyTableViewEntry];
    
    NSLog(@"%@", fetchedAdUnit);
    XCTAssert(!fetchedAdUnit, "The expected ad unit id is nil. Got this instead - %@", fetchedAdUnit);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 400, 500)];
    if(indexPath.row == self.rowPos){
        [tableViewCell addSubview:self.dummyTableViewEntry];
    }
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
@end
