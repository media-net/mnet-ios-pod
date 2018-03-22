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

- (void)testRegexStrMatch{
    NSString *ipStr = @"AAAAAAAAAAAAAAAAAAAAAAAAAAAAC";
    NSString *regexStr = @"^(A+)*B";
    BOOL matchStatus = [MNetUtil doesStrMatch:ipStr regexStr:regexStr];
    XCTAssert(matchStatus == NO, @"Regex does not match!");
}

- (void)testURLParser{
    NSArray *urlsWithoutParams = @[
                                    @"mnet://ybnca/adfailed",
                                    @"mraid://close",
                                    ];
    NSArray *urlsWithParams = @[
                      @"mnet://ybnca/adloaded?width=5&height=9",
                      @"mraid://expand?shouldUseCustomClose=true",
                      @"mraid://open?url=http%3A%2F%2Foperamediaworks.com%2F",
                      @"mraid://playVideo?url=http%3A%2F%2Fadmarvel.s3.amazonaws.com%2Fdemo%2Fmraid%2FOMW_SOUND_VIDEO_RENEW.iPhoneSmall.mp4",
                      @"mraid://createCalendarEvent?eventJSON=%7B%22description%22%3A%22Mayan%20Apocalypse%2FEnd%20of%20World%22%2C%22location%22%3A%22everywhere%22%2C%22start%22%3A%222013-12-21T00%3A00-05%3A00%22%2C%22end%22%3A%222013-12-22T00%3A00-05%3A00%22%7D",
                      ];
    MNetURLParser *urlParser = [[MNetURLParser alloc] init];
    for(NSString *url in urlsWithParams){
        NSDictionary *params = [urlParser parseURL:url];
        XCTAssertNotNil(params);
    }
    
    for(NSString *url in urlsWithoutParams){
        NSDictionary *params = [urlParser parseURL:url];
        XCTAssertNil(params);
    }
}

- (void)testURLParserUtil{
    NSArray *urls = @[
                      @"http://google.com?s=tom&q=and&t=jerry",
                      @"mnet://ybnca/adloaded?width=5&height=9",
                      @"mnet://ybnca/adfailed",
                      @"mraid://expand?shouldUseCustomClose=true",
                      @"mnet://ybnca?query"
                      ];
    NSArray *expectedDictArray = @[
                                   @{
                                       @"s" : @"tom",
                                       @"q" : @"and",
                                       @"t" : @"jerry",
                                       },
                                   @{
                                       @"width" : @"5",
                                       @"height" : @"9",
                                       },
                                   @{},
                                   @{
                                       @"shouldUseCustomClose" : @"true"
                                       },
                                   @{},
                                   ];
    NSInteger count = 0;
    for(NSString *urlString in urls){
        NSURL *url = [NSURL URLWithString:urlString];
        NSDictionary *paramsDict = [MNetUtil parseURL:url];
        NSDictionary *expectedDict = expectedDictArray[count];
        
        if([[expectedDict allKeys] count] == 0){
            XCTAssertTrue([[paramsDict allKeys] count] == 0);
        }
        
        for(NSString *key in [paramsDict allKeys]){
            NSString *expectedVal = [expectedDict valueForKey:key];
            NSString *paramsVal = [paramsDict valueForKey:key];
            XCTAssertTrue([expectedVal isEqualToString:paramsVal]);
        }
        count+=1;
    }
}

- (void)testResourceURLForResourceName{
    NSString *resourceName = @"shimmer-banner.png";
    NSString *baseResourceURL = [[MNetURL getSharedInstance] getBaseResourceUrl];
    NSString *expectedResourceURLFromName = [baseResourceURL stringByAppendingString:[NSString stringWithFormat:@"/%@",resourceName]];
    NSString *resourceNameURL = @"https://example.com/simmer-banner.png";
    
    NSString *resourceURL = [MNetUtil getResourceURLForResourceName:resourceName];
    XCTAssert([expectedResourceURLFromName isEqualToString:resourceURL]);
    
    resourceURL = [MNetUtil getResourceURLForResourceName:resourceNameURL];
    XCTAssert([resourceNameURL isEqualToString:resourceURL]);
}
@end
