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
    
    [[MNet getInstance] setAppContainsChildDirectedContent:NO];
    [MNetAdLoaderPredictBids disablePostAdLoadPrefetch];
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

- (UIViewController *)getVCWithRandomContents{
    // Creating a bunch of views and adding it to the view-controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"showad_controller"];
    [vc viewDidLoad];
    
    [vc viewWillAppear:NO];
    [vc viewDidAppear:NO];
    
    return vc;
}

- (MNetBidResponse *)getTestBidResponse{
    NSString *jsonString = readFile([self class], @"MNetBidResponse", @"json");
    MNetBidResponse *bidResponse = [[MNetBidResponse alloc] init];
    [MNJMManager fromJSONStr:jsonString toObj:bidResponse];
    return bidResponse;
}

- (void)cacheVideoUrl:(NSString *)videoUrlStr{
    NSURL *videoUrl = [NSURL URLWithString:videoUrlStr];
    
    if(![[MNetDiskLRUCache sharedLRUCache] hasCacheForKey:videoUrlStr]){
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:videoUrl] returningResponse:&response error:&error];
        
        [[MNetDiskLRUCache sharedLRUCache] saveData:data forKey:videoUrlStr];
    }
}

static NSString *videoUrl = @"http://adservex-staging.media.net/static/videos/videotest.mp4";
+ (NSString *)getVideoUrl{
    return videoUrl;
}

@end
