//
//  MNetInvokerTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 16/05/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"
#import "MNDemoConstants.h"

#define DUMMY_STR @"dummy-str"
#define FUNC_WITH_ARGS_AND_RET_SEL_STR @"funcWithArgsAndRet:andAnother:"
#define FUNC_WITH_ARG_AND_RET_SEL_STR @"funcWithArgAndRet:"
#define FUNC_WITH_ARG_SEL_STR @"funcWithArg:"
#define FUNC_WITH_NO_ARG_SEL_STR @"funcWithNoArg"
#define FUNC_WITH_DICT_ARG_SEL_STR @"funcWithDictArgsAndRet:"

@interface MNetInvokerTestClass : NSObject
@property (nonatomic) NSString *strProp;
@property (nonatomic) NSString *noArgProp;
@end

@implementation MNetInvokerTestClass
- (NSString *)funcWithDictArgsAndRet:(NSDictionary *)dict{
    return [NSString stringWithFormat:@"%@", dict];
}

- (NSString *)funcWithArgsAndRet:(NSString *)strA andAnother:(NSString *)strB{
    if(strA == nil || strB == nil){
        return DUMMY_STR;
    }
    return [NSString stringWithFormat:@"%@-%@", strA, strB];
}

- (NSString *)funcWithArgAndRet:(NSString *)str{
    return [NSString stringWithFormat:@"#%@#", str];
}

- (void)funcWithArg:(NSString *)str{
    self.strProp = str;
}

- (void)funcWithNoArg{
    self.noArgProp = DUMMY_STR;
}

@end

@interface MNetInvokerTests : MNetTestManager
@property (nonatomic) MNetInvokerTestClass *controlObj;
@end

@implementation MNetInvokerTests

- (void)setUp{
    [super setUp];
    self.controlObj = [[MNetInvokerTestClass alloc] init];
}

- (void)testInvokerRetValWithRef {
    NSString *expectedVal = [self.controlObj funcWithArgsAndRet:@"A" andAnother:@"B"];
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARGS_AND_RET_SEL_STR) on:self.controlObj returns:&weakRetVal with:@[@"A", @"B"]];
    XCTAssert(invokeErr == nil, @"Invoke error cannot be nil! - %@", invokeErr);
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal != nil, @"Strong val cannot be nil");
    XCTAssert([strongVal isEqualToString:expectedVal], @"Expected val - %@, got - %@", expectedVal, strongVal);
}

- (void)testInvokerWithReturnVal{
    NSString *expectedVal = [self.controlObj funcWithArgAndRet:@"A"];
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARG_AND_RET_SEL_STR) on:self.controlObj returns:&weakRetVal with:@[@"A"]];
    XCTAssert(invokeErr == nil, @"Invoke error cannot be nil! - %@", invokeErr);
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal != nil, @"Strong val cannot be nil");
    XCTAssert([strongVal isEqualToString:expectedVal], @"Expected val - %@, got - %@", expectedVal, strongVal);
}

- (void)testInvokerWithDictParams{
    NSDictionary *ipDict = @{@"something" : @"here"};
    NSString *expectedVal = [self.controlObj funcWithDictArgsAndRet:ipDict];
    __unsafe_unretained NSString *weakRetVal = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_DICT_ARG_SEL_STR) on:self.controlObj withDictParam:ipDict];
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal != nil, @"Strong val cannot be nil");
    XCTAssert([strongVal isEqualToString:expectedVal], @"Expected val - %@, got - %@", expectedVal, strongVal);
}

- (void)testInvokerWithoutReturnValWithArg{
    NSString *arg = @"A";
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARG_SEL_STR) on:self.controlObj returns:&weakRetVal with:@[arg]];
    XCTAssert(invokeErr == nil, @"Invoke error cannot be nil! - %@", invokeErr);
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal == nil, @"Strong val should be nil");
    XCTAssert([[self.controlObj strProp] isEqualToString: arg], @"Expected val - %@, got - %@", arg, [self.controlObj strProp]);
}

- (void)testInvokerWithoutReturnValWithArg2{
    NSString *arg = @"A";
    __unsafe_unretained NSString *weakRetVal;
    weakRetVal = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARG_SEL_STR) on:self.controlObj with:@[arg]];
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal == nil, @"Strong val should be nil");
    XCTAssert([[self.controlObj strProp] isEqualToString: arg], @"Expected val - %@, got - %@", arg, [self.controlObj strProp]);
}

- (void)testInvokerWithNoArgs{
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_NO_ARG_SEL_STR) on:self.controlObj returns:&weakRetVal with:nil];
    XCTAssert(invokeErr == nil, @"Invoke error cannot be nil! - %@", invokeErr);
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal == nil, @"Strong val should be nil");
    XCTAssert([[self.controlObj noArgProp] isEqualToString: DUMMY_STR], @"Expected val - %@, got - %@", DUMMY_STR, [self.controlObj strProp]);
}

- (void)testTooManyArgumentsException{
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARGS_AND_RET_SEL_STR) on:self.controlObj returns:&weakRetVal with:@[@"A", @"B", @"C", @"D"]];
    XCTAssert(invokeErr != nil, @"Invoke error should be nil! - %@", invokeErr);
}

- (void)testEmptyArgs{
    NSString *expectedVal = [self.controlObj funcWithArgsAndRet:nil andAnother:nil];
    __unsafe_unretained NSString *weakRetVal;
    NSError *invokeErr = [MNetInvoker invoke:NSSelectorFromString(FUNC_WITH_ARGS_AND_RET_SEL_STR) on:self.controlObj returns:&weakRetVal with:@[]];
    XCTAssert(invokeErr == nil, @"Invoke error cannot be nil! - %@", invokeErr);
    NSString *strongVal = weakRetVal;
    XCTAssert(strongVal != nil, @"Strong val cannot be nil");
    XCTAssert([strongVal isEqualToString:expectedVal], @"Expected val - %@, got - %@", expectedVal, strongVal);
}

@end
