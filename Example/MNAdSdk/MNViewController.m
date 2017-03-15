//
//  MNViewController.m
//  MNAdSdk
//
//  Created by Nithin on 02/15/2017.
//  Copyright (c) 2017 Nithin. All rights reserved.
//

#import "MNViewController.h"
#import "MNShowAdViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import <MNAdSdk/MNetVastAdXmlManager.h>
//#import <MNAdSdk/MNetVast.h>

@interface MNViewController ()

- (IBAction)bannerClick:(id)sender;
- (IBAction)bannerVideoClick:(id)sender;
- (IBAction)interstitialClick:(id)sender;
- (IBAction)interstitialVideoClick:(id)sender;
- (IBAction)interstitialPerformanceClick:(id)sender;
- (IBAction)mopubHBClick:(id)sender;
- (IBAction)dfpHBClick:(id)sender;

@end

@implementation MNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // NOTE: Just remove the required entry from the disableButtons to enable it.
    
    NSArray <UIButton *> *allButtons = @[
                                         self.btnBanner,
                                         self.btnBannerVideo,
                                         self.btnIntersitital,
                                         self.btnInterstitialVideo,
                                         self.btnInterstitialVideoPerformance,
                                         self.btnRewardedVideo,
                                         self.btnDFP,
                                         self.btnMoPub,
                                         ];
    
    
    // Disable the following buttons
    NSArray<UIButton *> *disableButtons = @[
                                            self.btnBannerVideo,
                                            self.btnInterstitialVideo,
                                            self.btnInterstitialVideoPerformance,
                                            self.btnRewardedVideo,
                                            ];
    
    // Adding custom properties to all the buttons
    for(UIButton *btnHandler in allButtons){
        [btnHandler setShowsTouchWhenHighlighted:YES];
    }
    
    // Disabling the selected buttons
    for(UIButton *btnHandler in disableButtons){
        [btnHandler setEnabled:NO];
        [btnHandler setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

- (IBAction)bannerClick:(id)sender {
    [self showAdForType:BNR];
}

- (IBAction)bannerVideoClick:(id)sender {
    
}

- (IBAction)interstitialClick:(id)sender {
    [self showAdForType:BNR_INTR];
    
}

- (IBAction)dfpHBClick:(id)sender{
    NSLog(@"DFP Clicked!");
    [self showAdForType:DFP_HB];
}

- (IBAction)interstitialVideoClick:(id)sender {
}

- (IBAction)interstitialPerformanceClick:(id)sender {
    
}

- (IBAction)mopubHBClick:(id)sender{
    [self showAdForType:MOPUB_HB];
}

- (void)showAdForType:(AdType)adType{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MNShowAdViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"showad_controller"];
    [controller setAdType:adType];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
