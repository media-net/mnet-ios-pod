//
//  MNetUserTests.m
//  MNAdSdk
//
//  Created by nithin.g on 04/08/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"


@interface MNetUserTests : MNetTestManager

@end

@implementation MNetUserTests

- (void)testUninitializedGender{
    NSDictionary *genderToStrMap = [MNetUser getGenderToStrMap];
    
    MNetUserGender ununitialisedGender;
    NSString *uninitializedStr = [genderToStrMap objectForKey:[NSNumber numberWithInt:ununitialisedGender]];
    
    MNetUser *user = [[MNetUser alloc] init];
    [user addGender:nil];
    
    XCTAssert([user.gender isEqualToString:uninitializedStr], @"Default gender is incorrect!");
}

- (void)testGender{
    NSDictionary *genderToStrMap = [MNetUser getGenderToStrMap];
    MNetUserGender gender = MNetGenderFemale;
    
    MNetUser *user = [[MNetUser alloc] init];
    [user addGender:gender];
    
    NSString *genderStr = [genderToStrMap objectForKey:[NSNumber numberWithInt:gender]];
    XCTAssert([user.gender isEqualToString:genderStr], @"Default gender is incorrect!");
}

- (void)testYearOfBirth{
    MNetUser *user = [[MNetUser alloc] init];
    
    NSArray<NSString *> *invalidYears = @[
                                          @"1200",
                                          @"1300",
                                          @"2020",
                                          @"abcd",
                                          @"01as",
                                          @"",
                                          @"--11",
                                          @"++1.1",
                                          @"12345678"
                                          ];
    for(NSString *invalidYear in invalidYears){
        BOOL isValid = [user addYearOfBirth:invalidYear];
        XCTAssert(isValid == NO, @"The yob - %@ should be invalid", invalidYear);
    }
    
    NSArray<NSString *> *validYears = @[
                                        @"1900",
                                        @"2001",
                                        @"2016",
                                        @"2017",
                                        @"2000",
                                        ];
    for(NSString *validYear in validYears){
        BOOL isValid = [user addYearOfBirth:validYear];
        XCTAssert(isValid == YES, @"The yob - %@ should be valid", validYear);
    }
    
}

@end
