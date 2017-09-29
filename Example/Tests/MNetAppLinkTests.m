//
//  MNetAppLinkTests.m
//  MNAdSdk
//
//  Created by nithin.g on 05/09/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNALAppLink/MNALAppLink.h>

#import "MNetTestManager.h"

@interface MNetAppLinkTests : MNetTestManager

@end

@implementation MNetAppLinkTests

- (void)testAppLink {
    UIViewController *vc = [self getVCWithRandomContents];
    
    MNALAppLink *applinkWithoutContent = [MNALAppLink getInstanceWithVC:vc withContentEnabled:NO];
    NSString *linkWithoutContent = [applinkWithoutContent getLink];
    NSString *emptyContent = [applinkWithoutContent getContent];
    
    MNALAppLink *applinkWithContent = [MNALAppLink getInstanceWithVC:vc withContentEnabled:YES];
    NSString *linkWithContent = [applinkWithContent getLink];
    NSString *nonEmptyContent = [applinkWithContent getContent];
    
    XCTAssert(linkWithContent != nil, @"Link:linkWithContent is nil!");
    XCTAssert([linkWithContent isEqualToString:@""] == NO, @"Link:linkWithContent is empty!");
    
    XCTAssert(linkWithoutContent != nil, @"Link:linkWithContent is nil");
    XCTAssert([linkWithoutContent isEqualToString:@""] == NO, @"Link:linkWithContent is empty!");
    
    XCTAssert(emptyContent == nil, @"Content has to be empty, since it was initialised that way");
    XCTAssert(nonEmptyContent != nil, @"Content cannot be empty");
    
    XCTAssert([linkWithoutContent isEqualToString:linkWithContent], @"Both the generated links do not match!");
}

@end
