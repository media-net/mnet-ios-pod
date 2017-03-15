//
//  MNShowAdViewController.m
//  MNAdSdk
//
//  Created by kunal.ch on 16/02/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "MNShowAdViewController.h"
#import <MNAdSdk/MNet.h>
//#import <MNAdSdk/MNetHB.h>
#import <MNAdSdk/MNetAdRequest.h>
//#import <MNAdSdk/MNetAdType.h>
#import <MNAdSdk/MNetInterstitialAd.h>
//#import <MNAdSdk/MNetAdSize.h>
#import "MPBannerCustomEvent.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIView+Toast.h"
#import "MNDemoConstants.h"

@import GoogleMobileAds;

@interface MNShowAdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loadAd;
@property (weak, nonatomic) IBOutlet UIButton *showAd;
- (IBAction)back:(id)sender;
- (IBAction)loadAdAction:(id)sender;
- (IBAction)showAdAction:(id)sender;

@end

@implementation MNShowAdViewController


MNetInterstitialAd *interstitialAd;
GADBannerView *gadBannerView;
DFPBannerView *dfpBannerView;

- (void)viewDidLoad {
    NSString *customerId = DEMO_MN_CUSTOMER_ID;
    
    [super viewDidLoad];
    [MNet initWithCustomerId: customerId];
    
    switch ([self adType]) {
        case BNR:{
            [[self showAd]setHidden:YES];
            break;
        }
        case BNR_INTR:{
            [self btnStateEnabled:NO forBtn:self.showAd];
            [[self loadAd] setEnabled:YES];
            break;
        }
        case DFP_HB:{
            [[self showAd]setEnabled:NO];
            [[self showAd]setHidden:YES];
            break;
        }
        case MOPUB_HB:{
            [[self showAd]setEnabled:NO];
            [[self showAd]setHidden:YES];
            break;
        }
        case AD_MOB_HB:{
            [[self showAd]setEnabled:NO];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loadAdAction:(id)sender {
    [self clearAdView];
    
    switch ([self adType]) {
        case BNR:{
            MNetAdRequest *request = [MNetAdRequest newRequest];
            [request setAdUnitId:DEMO_MN_AD_UNIT_ID];
            [request setAdType:BANNER];
            [request setWidth:MN_300x250.width andHeight:MN_300x250.height];
            
            MNetAdView *mnetAdView = [[MNetAdView alloc]init];
            [mnetAdView setDelegate:self];
            [mnetAdView setSize:CGSizeMake(MN_300x250.width, MN_300x250.height)];
            
            // Initializing with lat-long
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            [mnetAdView setCustomLocation:customLocation];
            
            // NOTE: The frame coords is required.
            // Without it, although MnetAdView will be visible (because it's added to the subview),
            // it won't respond to touch events, because while
            // drawing the view, the size of this view appears is 0 eventhough
            // it's childrens' dimensions are greater than 0.
            // The touch events are generally bubbled upto the nested views,
            // so it messes up the gestures for the webview.
            // size (set by using the setSize method, used above) is a property of the ad,
            // and does not in anyway contribute to the placement of the ad as
            // a subview.
            CGRect adFrame = CGRectMake(0, 0, mnetAdView.size.width, mnetAdView.size.height);
            [mnetAdView setFrame:adFrame];
            [_adView addSubview:mnetAdView];
            [mnetAdView loadAdForRequest:request];
            
            MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:[[self viewControllerForMNetAd]view] animated:true];
            [[loader label]setText:@"Loading AD"];
            break;
        }
        case MOPUB_HB:{
            MPAdView *mpAdView = [[MPAdView alloc]initWithAdUnitId:DEMO_MOPUB_AD_UNIT_ID size:MOPUB_MEDIUM_RECT_SIZE];
            [_adView addSubview:mpAdView];            
            mpAdView.delegate = self;            
            [mpAdView stopAutomaticallyRefreshingContents];
            [mpAdView loadAd];
            
            MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:[[self viewControllerForMNetAd]view] animated:true];
            [[loader label]setText:@"Loading AD"];
            break;
        }
        case BNR_INTR:{
            [self loadInterstitial];
            break;
        }
        case DFP_HB:{
            NSLog(@"creating banner ad view for dfp");
            dfpBannerView = [[DFPBannerView alloc]initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
            [[self adView]addSubview:dfpBannerView];
            [dfpBannerView setAdUnitID:DEMO_DFP_AD_UNIT_ID];
            [dfpBannerView setRootViewController:self];
            [dfpBannerView setDelegate:self];
            DFPRequest *request = [DFPRequest request];            
            [dfpBannerView loadRequest:request];
                        
            MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:[[self viewControllerForMNetAd]view] animated:true];
            [[loader label]setText:@"Loading AD"];
            break;
        }
        case AD_MOB_HB:{
            NSLog(@"creating banner ad view for admob");
            gadBannerView = [[GADBannerView alloc]initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
            [[self adView]addSubview:gadBannerView];
            [gadBannerView setAdUnitID:DEMO_AD_MOB_AD_UNIT_ID];
            [gadBannerView setRootViewController:self];
            GADRequest *request = [GADRequest request];
            [request setTestDevices:@[kGADSimulatorID]];
            [gadBannerView loadRequest:request];
            break;
        }
    }
}

-(void)clearAdView{
    for(UIView *subview in [[self adView]subviews]){
        [subview removeFromSuperview];
    }
}

- (IBAction)showAdAction:(id)sender {
    switch ([self adType]) {
        case BNR:{
           //nothing
            break;
        }
        case MOPUB_HB:{
            //nothing
            break;
        }
        case BNR_INTR:{
            [interstitialAd show];
            break;
        }
        case DFP_HB:{
            break;
        }
        case AD_MOB_HB:{
            break;
        }
    }
}

-(void) loadInterstitial {
    CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
    
    interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_ID];
    
    [interstitialAd setAdSize:CGSizeMake(MN_300x250.width, MN_300x250.height)];
    [interstitialAd setDelegate:self];
    [interstitialAd setAdType:BANNER];
    [interstitialAd setCustomLocation:customLocation];

    [interstitialAd load];
    
    MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:[[self viewControllerForMNetAd]view] animated:true];
    [[loader label]setText:@"Loading AD"];

}
#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}


- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ad Failed to Load!" message:@"Error while getting Ad for admob" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    [MBProgressHUD hideHUDForView:[[self viewControllerForMNetAd]view] animated:YES];
}

#pragma mark - MNetAdViewDelegate
- (UIViewController *)viewControllerForMNetAd{
    return self;
}

- (void)adViewDidLoadAd:(MNetAdView *)adView{
    if(BNR_INTR){
        [self btnStateEnabled:YES forBtn:self.showAd];
    }
    
    NSString *displayStr = @"Ad did load";
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
    
    [MBProgressHUD hideHUDForView:[[self viewControllerForMNetAd]view] animated:YES];    
}

- (void)adViewDidFailToLoad:(MNetError *)error for:(MNetAdView *)adView{
    NSLog(@"DEMO: View did fail to load");
    [MBProgressHUD hideHUDForView:[[self viewControllerForMNetAd]view] animated:YES];
    NSString *errorStr = [NSString stringWithFormat:@"Error - %@", error];
    
    NSLog(@"DEMO: %@", errorStr);
    [self.view makeToast:errorStr];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ad Failed to Load!" message:@"Error while fetching response" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)adViewDidClick:(MNetAdView *)adView{
    NSString *displayStr = @"Ad Did Click";
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
}

- (void)didDismissModalForAdView:(MNetAdView *)adView{
    NSString *displayStr = @"AdModal did Dismiss";
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
}

- (void)didPresentModalViewForAd:(MNetAdView *)adView{
    NSString *displayStr = @"AdModal did present view";
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
}

- (void) btnStateEnabled:(BOOL) isEnabled forBtn:(UIButton*)btnVal {
    UIColor *bgColor;
    
    if(isEnabled){
        bgColor = [UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:10/255.0 alpha:1];
    }else{
        bgColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];;
    }    
    [btnVal setBackgroundColor:bgColor];
    [btnVal setEnabled:isEnabled];
}

#pragma mark 
- (void)adViewDidReceiveAd:(DFPBannerView *)bannerView{
    NSString *displayStr = @"DFP: Banner view loaded";
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
    
    [MBProgressHUD hideHUDForView:[[self viewControllerForMNetAd]view] animated:YES];
}

-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    NSString *displayStr = [NSString stringWithFormat:@"GAD: banner view error %@",error];
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
    
    [MBProgressHUD hideHUDForView:[[self viewControllerForMNetAd]view] animated:YES];
}

@end
