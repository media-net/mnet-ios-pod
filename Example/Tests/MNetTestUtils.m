//
//  MNetTestUtils.m
//  MNAdSdk
//
//  Created by nithin.g on 05/05/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetTestUtils : MNetTestManager

@end

@implementation MNetTestUtils

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetValueFromParamStr1 {
    NSString *testKey = ADAPTER_PARAMS_BIDDER_ID_KEY;
    NSString *testValue = @"10";
    NSString *testStr = [NSString stringWithFormat:@"%@:%@,customer:90", testKey, testValue];
    
    NSString *value = [MNetUtil getValueFromParamStr:testStr forKey:testKey];
    NSLog(@"%@", value);
    XCTAssert([value isEqualToString:testValue], "Values for getValueFromParamStr do not match");
}

- (void)testGetValueFromParamStr2 {
    NSString *testKey = ADAPTER_PARAMS_BIDDER_ID_KEY;
    NSString *testValue = @"10:1212:212";
    NSString *testStr = [NSString stringWithFormat:@"%@:%@,customer:90", testKey, testValue];
    
    NSString *value = [MNetUtil getValueFromParamStr:testStr forKey:testKey];
    NSLog(@"%@", value);
    XCTAssert([value isEqualToString:testValue], "Values for getValueFromParamStr do not match");
}

- (void)testGetValueFromParamStr3 {
    NSString *testKey = ADAPTER_PARAMS_BIDDER_ID_KEY;
    NSString *testValue = @"dummy";
    NSString *testStr = [NSString stringWithFormat:@"%@:%@,customer:90", @"dummy", testValue];
    
    NSString *value = [MNetUtil getValueFromParamStr:testStr forKey:testKey];
    NSLog(@"%@", value);
    XCTAssert([value isEqualToString:@""], "Values for getValueFromParamStr do not match");
}

- (void)testGetValueFromParamStr4 {
    NSString *testKey = ADAPTER_PARAMS_BIDDER_ID_KEY;
    NSString *testStr = nil;
    
    NSString *value = [MNetUtil getValueFromParamStr:testStr forKey:testKey];
    NSLog(@"%@", value);
    XCTAssert([value isEqualToString:@""], "Values for getValueFromParamStr do not match");
}

- (void)testGetValueFromParamStr5 {
    NSString *testKey = ADAPTER_PARAMS_BIDDER_ID_KEY;
    NSString *testStr = @"";
    
    NSString *value = [MNetUtil getValueFromParamStr:testStr forKey:testKey];
    NSLog(@"%@", value);
    XCTAssert([value isEqualToString:@""], "Values for getValueFromParamStr do not match");
}

- (void)testGetAdSizeString{
    CGSize adSize = MNET_BANNER_AD_SIZE;
    NSString *adSizeStr = [MNetUtil getAdSizeString:adSize];
    
    NSString *expectedStr = @"320x50";
    XCTAssert([adSizeStr isEqualToString:expectedStr], "Values for adSizeStr and expectedStr do not match!. The adSizeStr is - %@", adSizeStr);
}

- (void)testReplaceItemsInUrlsList{
    NSArray *urlsList = @[
                          @"123 ABC XYZ 890",
                          @"123 432 345 ABC",
                          @"123 XXXXXXX ABC",
                        ];
    NSArray *replacementList = @[
                                 @{@"123": @"AAA"},
                                 @{@"ABC": @"ZZZ"}
                                 ];
    
    NSArray *updatedUrlsList = [MNetUtil replaceItemsInUrlsList:urlsList withReplacementList:replacementList];
    
    NSArray *expectedOutput = @[
                                @"AAA ZZZ XYZ 890",
                                @"AAA 432 345 ZZZ",
                                @"AAA XXXXXXX ZZZ",
                                ];
    
    XCTAssert([updatedUrlsList isEqualToArray:expectedOutput], @"UpdatedUrlsList does not match the expectedOutput!");
}

- (void)testReplaceItemsInUrlsListWithUrls{
    NSArray *urlsList = @[
                          @"http://sample.com?key1=value1&key2=value2&id=%24%7Bid%7D",
                          @"http://sample.com?id=%24%7Bid%7D&event=%7Bevent%7D"
                          ];
    NSArray *replacementList = @[
                                 @{@"${id}": @"AAA"},
                                 @{@"{event}": @"{new_event}"}
                                 ];
    
    NSArray *updatedUrlsList = [MNetUtil replaceItemsInUrlsList:urlsList withReplacementList:replacementList];
    
    NSArray *expectedOutput = @[
                                @"http://sample.com?key1=value1&key2=value2&id=AAA",
                                @"http://sample.com?id=AAA&event=%7Bnew_event%7D"
                                ];
    
    XCTAssert([updatedUrlsList isEqualToArray:expectedOutput], @"UpdatedUrlsList does not match the expectedOutput!");
}

- (void)testFormattedTimeDuration{
    NSTimeInterval timeVal = 20.0;
    NSString *output = [MNetUtil getFormattedTimeDurationStr:timeVal];
    NSString *expectedOutput = @"00:00:20.000";
    XCTAssert([output isEqualToString:expectedOutput], @"The actual output Str:%@ does not match the output: %@", output, expectedOutput);
}

@end
