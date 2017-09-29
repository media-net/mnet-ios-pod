//
//  MNetTestManager.h
//  MNAdSdk
//
//  Created by nithin.g on 28/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Nocilla/Nocilla.h>
#import "XCTest+MNetTestUtils.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>

#define EXPECTATION_FULFILL(EXPECTATION) \
if(EXPECTATION){\
[EXPECTATION fulfill];\
EXPECTATION = nil;\
}

@interface MNetTestManager : XCTestCase
- (void)setUp;
- (void)tearDown;
- (UIViewController *)getViewController;
- (UIViewController *)getVCWithRandomContents;
- (void)cacheVideoUrl:(NSString *)videoUrl;

+ (NSString *)getVideoUrl;
@end
