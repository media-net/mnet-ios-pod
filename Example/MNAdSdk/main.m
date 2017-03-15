//
//  main.m
//  MNAdSdk
//
//  Created by Nithin on 02/15/2017.
//  Copyright (c) 2017 Nithin. All rights reserved.
//

@import UIKit;
#import "MNAppDelegate.h"


int main(int argc, char * argv[])
{
    @autoreleasepool {
        @try{
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([MNAppDelegate class]));
        }@catch(NSException *error){
            NSLog(@"Error in the app %@",error);
        }
    }
}
