//
//  MNetTestManager.m
//  MNAdSdk
//
//  Created by nithin.g on 28/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "MNetTestManager.h"

@implementation MNetTestManager

- (void)setUp{
    [super setUp];
    
    [[LSNocilla sharedInstance] start];
    customSetupWithClass([self class]);
}

- (void)tearDown{
    [super tearDown];
    [[LSNocilla sharedInstance] stop];
}

- (UIViewController *)getViewController{
    // Adding a window object, to fake the ad being shown on the view controller
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    window.rootViewController = viewController;
    return viewController;
}

@end
