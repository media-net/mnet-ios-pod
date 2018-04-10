//
//  MNetErrorTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 13/02/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetErrorTests : MNetTestManager

@end

@implementation MNetErrorTests

- (void)testErrorObjectInPulse{
    NSString *type = @"error";
    NSString *message = @"";
    id customData = [[MNetError alloc] initWithError:[MNetError createErrorWithDescription:@"Sample error"]];
    
    MNetPulseEvent *errPulseEvent = [[MNetPulseEvent alloc] initWithType:type
                                                     withSubType:type
                                                     withMessage:message
                                                   andCustomData:customData];
    
    XCTAssert(errPulseEvent != nil, @"errPulseEvent cannot be nil!");
    
    NSString *jsonStr = [MNJMManager toJSONStr:errPulseEvent];
    NSLog(@"%@", jsonStr);
    
    // The contents of lg needs to be verified here
    NSDictionary *eventDict = [errPulseEvent eventObj];
    
    // The following items should alway be present
    NSArray<NSString *> *mandatoryKeys = @[
                                           @"error",
                                           @"version_code",
                                           @"version_name",
                                           @"internal_version_code",
                                           @"internal_version_name",
                                           @"package_name",
                                           @"release_stage",
                                           @"stacktrace",
                                           ];
    for(NSString *mandatoryKey in mandatoryKeys){
        id val = eventDict[mandatoryKey];
        if(val == nil){
            XCTAssert(val != nil, @"'%@' key not available in the error object", mandatoryKey);
        }
    }
}

- (void)testErrorStackTraceEvent{
    NSString *lineNumberKey = @"line_number";
    NSString *fileNameKey = @"file_name";
    NSString *methodNameKey = @"method_name";
    NSString *classNameKey = @"class_name";
    
    NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *testMap;
    testMap= @{
               @"  1   MNetAdSdk                           0x000000010be78aa8 -[MNetError initWithError:] + 72  ":
                   @{
                       lineNumberKey    :@"72",
                       fileNameKey      :@"MNetError",
                       methodNameKey    :@"-[MNetError initWithError:]",
                       classNameKey     :@"MNetAdSdk",
                   },
               @"4   CoreFoundation                      0x0000000111bb1440 -[NSInvocation invoke] + 320":
                   @{
                       lineNumberKey    :@"320",
                       fileNameKey      :@"NSInvocation",
                       methodNameKey    :@"-[NSInvocation invoke]",
                       classNameKey     :@"CoreFoundation",
                   },
               @"5   XCTest                              0x000000012ceb8949 __24-[XCTestCase invokeTest]_block_invoke + 591":
                   @{
                       lineNumberKey    :@"591",
                       fileNameKey      :@"XCTestCase",
                       methodNameKey    :@"__24-[XCTestCase invokeTest]_block_invoke",
                       classNameKey     :@"XCTest",
                   },
               @"30 UIKit                               0x000000010e749d30 UIApplicationMain + 159":
                   @{
                       lineNumberKey    :@"159",
                       fileNameKey      :@"UIApplicationMain",
                       methodNameKey    :@"UIApplicationMain",
                       classNameKey     :@"UIKit",
                   },
               @"33  ???                                 0x0000000000000007 0x0 + 7":
                   @{
                       lineNumberKey    :@"7",
                       fileNameKey      :@"0x0",
                       methodNameKey    :@"0x0",
                       classNameKey     :@"???",
                   },
               };
    for(NSString *testString in testMap){
        MNetErrorStackTraceEvent *stackTraceEvent = [MNetErrorStackTraceEvent createInstanceWithEvent:testString];
        XCTAssert(stackTraceEvent != nil, @"stackTraceEvent is empty for test string - %@", testString);
        NSDictionary<NSString *, NSString *> *expectedValuesMap = [testMap objectForKey:testString];
        NSString *expectedLineNumber = [expectedValuesMap objectForKey:lineNumberKey];
        NSString *expectedFileName  = [expectedValuesMap objectForKey:fileNameKey];
        NSString *expectedMethodName = [expectedValuesMap objectForKey:methodNameKey];
        NSString *expectedClassName = [expectedValuesMap objectForKey:classNameKey];
        
        XCTAssert([expectedLineNumber isEqualToString:[stackTraceEvent.lineNumber stringValue]], @"Expected line number - %@, actual - %@", expectedLineNumber, [stackTraceEvent.lineNumber stringValue]);
        XCTAssert([expectedFileName isEqualToString:stackTraceEvent.fileName], @"Expected filename - %@, actual - %@", expectedFileName, stackTraceEvent.fileName);
        XCTAssert([expectedMethodName isEqualToString:stackTraceEvent.methodName], @"Expected method name - %@, actual - %@", expectedMethodName, stackTraceEvent.methodName);
        XCTAssert([expectedClassName isEqualToString:stackTraceEvent.className], @"Expected class name - %@, actual - %@", expectedClassName, stackTraceEvent.className);
    }
}

- (void)testRealStacktrace{
    NSArray<NSString *> *actualStackTrace = @[
      @"0   CoreFoundation                      0x000000018d6a2ff8 <redacted> + 148",
      @"1   libobjc.A.dylib                     0x000000018c104538 objc_exception_throw + 56",
      @"2   CoreFoundation                      0x000000018d6a2ca8 <redacted> + 0",
      @"3   Foundation                          0x000000018e0b764c <redacted> + 272",
      @"4   MNAdSDKDemo                         0x00000001002beb48 -[MNetBannerAdController renderAd] + 108",
      @"5   MNAdSDKDemo                         0x00000001002be788 -[MNetBannerAdController processResponse] + 168",
      @"6   MNAdSDKDemo                         0x000000010030b2a0 -[MNetResponsiveBannerAdController processResponse] + 44",
      @"7   MNAdSDKDemo                         0x000000010029ec2c -[MNetAdBaseCommon createAdControllerForClassStr:withInstanceMethodName:forResponse:] + 908",
      @"8   MNAdSDKDemo                         0x000000010029e780 __111-[MNetAdBaseCommon createAdControllerForClassStr:withInstanceMethodName:forResponse:withSuccessCb:withErrorCb:]_block_invoke + 316",
      @"9   MNAdSDKDemo                         0x000000010029edb4 -[MNetAdBaseCommon fetchAdCodeFromResponseAsync:withCompletionCb:] + 320",
      @"10  MNAdSDKDemo                         0x000000010029e5a0 -[MNetAdBaseCommon createAdControllerForClassStr:withInstanceMethodName:forResponse:withSuccessCb:withErrorCb:] + 312",
      @"11  MNAdSDKDemo                         0x000000010029e338 -[MNetAdBaseCommon initializeAdControllerForBidResponse:outError:withSuccessCb:withErrorCb:] + 488",
      @"12  MNAdSDKDemo                         0x000000010029e084 -[MNetAdBaseCommon selectAndInitializeAdWithSuccess:andError:] + 612",
      @"13  MNAdSDKDemo                         0x000000010029dde4 -[MNetAdBaseCommon handleAdControllerWithSuccess:andError:] + 216",
      @"14  MNAdSDKDemo                         0x000000010029b6e8 __63-[MNetAdBaseCommon loadAdForRequest:withSuccessCb:withErrorCb:]_block_invoke + 324",
      @"15  MNAdSDKDemo                         0x00000001002a5324 __68-[MNetAdLoader loadAdFor:withOptions:onViewController:success:fail:]_block_invoke + 124",
      @"16  MNAdSDKDemo                         0x00000001002a6134 -[MNetAdLoaderPredictBids loadAdFor:withOptions:onViewController:success:fail:] + 856",
      @"17  MNAdSDKDemo                         0x00000001002a51bc -[MNetAdLoader loadAdFor:withOptions:onViewController:success:fail:] + 704",
      @"18  MNAdSDKDemo                         0x000000010029b4d4 -[MNetAdBaseCommon loadAdForRequest:withSuccessCb:withErrorCb:] + 564",
      @"19  MNAdSDKDemo                         0x000000010029b270 -[MNetAdBaseCommon loadAdWithSuccessResp:withErrorCb:] + 444",
      @"20  MNAdSDKDemo                         0x00000001002af3b0 -[MNetAdView internalLoadAd] + 744",
      @"21  MNAdSDKDemo                         0x00000001000c318c -[MNShowAdViewController loadAdAction:] + 668",
      @"22  UIKit                               0x0000000193809010 <redacted> + 96",
      @"23  UIKit                               0x0000000193808f90 <redacted> + 80",
      @"24  UIKit                               0x00000001937f3504 <redacted> + 440",
      @"25  UIKit                               0x0000000193808874 <redacted> + 576",
      @"26  UIKit                               0x0000000193808390 <redacted> + 2480",
      @"27  UIKit                               0x0000000193803728 <redacted> + 3192",
      @"28  UIKit                               0x00000001937d433c <redacted> + 340",
      @"29  UIKit                               0x0000000193fce014 <redacted> + 2400",
      @"30  UIKit                               0x0000000193fc8770 <redacted> + 4268",
      @"31  UIKit                               0x0000000193fc8b9c <redacted> + 148",
      @"32  CoreFoundation                      0x000000018d65142c <redacted> + 24",
      @"33  CoreFoundation                      0x000000018d650d9c <redacted> + 540",
      @"34  CoreFoundation                      0x000000018d64e9a8 <redacted> + 744",
      @"35  CoreFoundation                      0x000000018d57eda4 CFRunLoopRunSpecific + 424",
      @"36  GraphicsServices                    0x000000018efe8074 GSEventRunModal + 100",
      @"37  UIKit                               0x0000000193839058 UIApplicationMain + 208",
      @"38  MNAdSDKDemo                         0x00000001000c207c main + 164",
      @"39  libdyld.dylib                       0x000000018c58d59c <redacted> + 4",
      @"40  XCTest                              0x0000000124555c4b +[XCTContext runInContextForTestCase:block:] + 163",
    ];
    
    for(NSString *stacktraceEntry in actualStackTrace){
        MNetErrorStackTraceEvent *errStEntry  = [MNetErrorStackTraceEvent createInstanceWithEvent:stacktraceEntry];
        NSNumber *lineNumber = [errStEntry lineNumber];
        XCTAssert(
                  lineNumber != nil && [lineNumber integerValue] != -1,
                  @"Line number cannot be empty for entry - %@", stacktraceEntry
                  );
        
        NSString *className = [errStEntry className];
        XCTAssert(
                  className != nil && ![className isEqualToString:@""],
                  @"ClassName cannot be empty for entry - %@", stacktraceEntry
                  );
        
        NSString *fileName = [errStEntry fileName];
        XCTAssert(
                  fileName != nil && ![fileName isEqualToString:@""],
                  @"FileName cannot be empty for entry - %@", stacktraceEntry
                  );
        
        NSString *methodName = [errStEntry methodName];
        XCTAssert(
                  methodName != nil && ![methodName isEqualToString:@""],
                  @"MethodName cannot be empty for entry - %@", stacktraceEntry
                  );
    }
}

- (void)testNegativeScenario{
    NSArray<NSString *> *invalidStackTraces = @[
                                                @"sample",
                                                @"@something range dome21  MNAdSDKDemo -[MNShowAdViewController loadAdAction:] +++ 668",
                                                @"",
                                                @"                              ",
                                                ];
    for(NSString *stacktraceEntry in invalidStackTraces){
        MNetErrorStackTraceEvent *errStEntry  = [MNetErrorStackTraceEvent createInstanceWithEvent:stacktraceEntry];
        NSNumber *lineNumber = [errStEntry lineNumber];
        XCTAssert(
                  lineNumber != nil && [lineNumber integerValue] == -1,
                  @"Line number cannot be nil for entry - %@", stacktraceEntry
                  );
        
        NSString *className = [errStEntry className];
        XCTAssert(
                  className != nil && [className isEqualToString:@""],
                  @"ClassName cannot be nil for entry - %@", stacktraceEntry
                  );
        
        NSString *fileName = [errStEntry fileName];
        XCTAssert(
                  fileName != nil && [fileName isEqualToString:@""],
                  @"FileName cannot be nil for entry - %@", stacktraceEntry
                  );
        
        NSString *methodName = [errStEntry methodName];
        XCTAssert(
                  methodName != nil && [methodName isEqualToString:@""],
                  @"MethodName cannot be nil for entry - %@", stacktraceEntry
                  );
    }
}

// In secs
// [0.000174, 0.000064, 0.000022, 0.000020, 0.000018, 0.000012, 0.000010, 0.000009, 0.000009, 0.000009]
- (void)skip_testPerformanceForStacktrace{
    NSString *stEntry = @"15  MNAdSDKDemo                         0x00000001002a5324 __68-[MNetAdLoader loadAdFor:withOptions:onViewController:success:fail:]_block_invoke + 124";
    [self measureBlock:^{
        [MNetErrorStackTraceEvent createInstanceWithEvent:stEntry];
    }];
}

@end
