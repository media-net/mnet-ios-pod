//
//  MNAppDelegate.m
//  MNAdSdk
//
//  Created by Nithin on 02/15/2017.
//  Copyright (c) 2017 Nithin. All rights reserved.
//

#import "MNAppDelegate.h"
@import GoogleMobileAds;
#import <MNetAdSdk/MNet.h>
#import <MNetAdSdk/MNetUser.h>
#import "MNDemoConstants.h"
#import "MNAdSdkURLManager.h"

@implementation MNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    BOOL isTesting = [[NSUserDefaults standardUserDefaults] boolForKey:@"TESTING"];
    if(!isTesting){
        MNet *mnetObj = [MNet initWithCustomerId: DEMO_MN_CUSTOMER_ID];
        
        // Adding user details
        MNetUser *user = [MNetUser new];
        [user addGender:MNetGenderFemale];
        [user addKeywords:@"fruits, health, energy"];
        [user addYearOfBirth:@"1985"];
        [user addName:@"Demo User"];
        [user addUserId:@"test-id"];
        [mnetObj setUser:user];
        
        //[[MNet getInstance] setIsTest:YES];
    }
#ifdef DEBUG
    [[MNAdSdkURLManager getSharedInstance] initialSetup];
#endif
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-6365858186554077~2677656745"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
