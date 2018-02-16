//
//  MNShowAdViewController.m
//  MNAdSdk
//
//  Created by kunal.ch on 16/02/17.
//  Copyright © 2017 Nithin. All rights reserved.
//


#import <MNetAdSdk/MNet.h>
#import <MNetAdSdk/MNetError.h>
#import <MNetAdSdk/MNetAdRequest.h>
#import <MNetAdSdk/MNetInterstitialAd.h>
#import <MNetAdSdk/MNetRewardedVideo.h>
#import <MNetAdSdk/MNetReward.h>
#import <MNetAdSdk/MNetHeaderBidder.h>
#import <MNetAdSdk/MNetAdSizeConstants.h>

#import <MBProgressHUD/MBProgressHUD.h>

#import "UIView+Toast.h"
#import "MPBannerCustomEvent.h"
#import "MNShowAdViewController.h"
#import "MNDemoConstants.h"

#define LOADER_TEXT @"Loading ad"
#define TITLE_TEXT_COLOR [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.5]

@import GoogleMobileAds;

@interface MNShowAdViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loadAd;
@property (weak, nonatomic) IBOutlet UIButton *showAd;
@property (weak, nonatomic) IBOutlet UILabel *adViewTitle;

- (IBAction)back:(id)sender;
- (IBAction)loadAdAction:(id)sender;
- (IBAction)showAdAction:(id)sender;

@end

@implementation MNShowAdViewController

MNetInterstitialAd *interstitialAd;
GADBannerView *gadBannerView;
DFPBannerView *dfpBannerView;
DFPInterstitial *dfpInterstitialAd;
GADInterstitial *gadInterstitialAd;
MPInterstitialAdController *mopubInterstititalAd;
MNetRewardedVideo *rewardedVideo;

static const NSDictionary<NSNumber *, NSString *> *titleStringMap;

#pragma mark - Toast messages
static NSString *mnetBannerLoadAd = @"Ad loaded";
static NSString *mnetBannerFailAd = @"Ad failed";
static NSString *mnetBannerAdClick = @"Ad clicked";

static NSString *mnetInterstitialLoadAd = @"Ad loaded";
static NSString *mnetInterstitialClickAd = @"Ad clicked";
static NSString *mnetInterstitialFailAd = @"Ad failed";
static NSString *mnetInterstitialShowAd = @"Ad shown";
static NSString *mnetInterstitialDismissAd = @"Ad dismissed";

static NSString *mnetVideoLoadAd    = @"Video ad loaded";
static NSString *mnetVideoStartAd   = @"Video ad started";
static NSString *mnetVideoComplteAd = @"Video ad Complete";
static NSString *mnetVideoClickAd   = @"Video ad clicked";
static NSString *mnetVideoFailAd    = @"Video ad failed";

static NSString *mnetInterstitialVideoLoadAd    = @"Video ad loaded";
static NSString *mnetInterstitialVideoShowAd    = @"Video ad shown";
static NSString *mnetInterstitialVideoStartAd   = @"Video ad started";
static NSString *mnetInterstitialVideoClickAd   = @"Video ad clicked";
static NSString *mnetInterstitialVideoFailAd    = @"Video ad failed";
static NSString *mnetInterstitialVideoDismissAd = @"Video ad dismissed";
static NSString *mnetInterstitialVideoCompleteAd = @"Video ad completed";

static NSString *mnetRewardedVideoLoadAd    = @"Ad loaded";
static NSString *mnetRewardedVideoShowAd    = @"Ad shown";
static NSString *mnetRewardedVideoStartAd   = @"Ad started";
static NSString *mnetRewardedVideoClickAd   = @"Ad clicked";
static NSString *mnetRewardedVideoFailAd    = @"Ad failed";
static NSString *mnetRewardedVideoCompleteAd = @"Reward received";

static NSString *mopubLoadAd = @"Ad loaded";
static NSString *mopubFailAd = @"Ad failed";
static NSString *mopubClickAd = @"Ad clicked";

static NSString *mopubInterstitialLoadAd = @"Ad loaded";
static NSString *mopubInterstitialShowAd = @"Ad shown";
static NSString *mopubInterstitialFailAd = @"Ad failed";
static NSString *mopubInterstitialDismiss = @"Ad dismissed";

static NSString *gadLoadAd = @"Ad loaded";
static NSString *gadFailAd = @"Ad failed";
static NSString *gadClickAd = @"Ad clicked";

static NSString *gadInterstitialLoadAd = @"Ad loaded";
static NSString *gadInterstitialFailAd = @"Ad failed";
static NSString *gadInterstitialShowAd = @"Ad shown";
static NSString *gadInterstitialDismissAd = @"Ad dismissed";


#pragma mark -  MNShowAdVC methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTitleMap];
    
    // This should be ideally used in the appDelegate
    // [MNet initWithCustomerId: DEMO_MN_CUSTOMER_ID];
    [self handleButtonStatesForAdType];
    NSNumber *adTypeNum = ENUM_VAL(self.adType);
    NSString *adTitleStr = [titleStringMap objectForKey:adTypeNum];
    if(adTitleStr == nil){
        adTitleStr = @"";
    }
    
    self.adViewTitle.textColor = TITLE_TEXT_COLOR;
    self.adViewTitle.text = adTitleStr;
    
    CGFloat blurRadius = 4.0f;
    self.topBar.layer.shadowOpacity = 0.4f;
    self.topBar.layer.shadowOffset = CGSizeMake(0, blurRadius);
    self.topBar.layer.shadowRadius = blurRadius;
    self.topBar.layer.shadowColor = [[UIColor blackColor] CGColor];
}

- (void)initTitleMap{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titleStringMap = @{
                           ENUM_VAL(BNR): @"BANNER",
                           ENUM_VAL(BNR_INTR): @"BANNER INTERSTITIAL",
                           ENUM_VAL(MOPUB_HB): @"MOPUB BANNER",
                           ENUM_VAL(AD_MOB_HB): @"ADMOB BANNER",
                           ENUM_VAL(MOPUB_INTERSTITIAL_HB): @"MOPUB INTERSTITIAL",
                           ENUM_VAL(DFP_HB): @"DFP BANNER",
                           ENUM_VAL(DFP_INTERSTITIAL_HB): @"DFP INTERSTITIAL",
                           ENUM_VAL(BNR_VIDEO): @"VIDEO",
                           ENUM_VAL(VIDEO_INTR): @"VIDEO INTERSTITIAL",
                           ENUM_VAL(VIDEO_REWARDED): @"REWARDED VIDEO",
                           ENUM_VAL(DFP_REWARDED):@"DFP MEDIATION REWARDED VIDEO",
                           ENUM_VAL(DFP_MEDIATION): @"DFP BANNER MEDIATION",
                           ENUM_VAL(MOPUB_MEDIATION): @"MOPUB BANNER MEDIATION",
                           ENUM_VAL(ADMOB_MEDIATION): @"ADMOB BANNER MEDIATION",
                           ENUM_VAL(DFP_INTERSTITIAL_MEDIATION): @"DFP INTERSTITIAL MEDIATION",
                           ENUM_VAL(MOPUB_INTERSTITIAL_MEDIATION): @"MOPUB INTERSTITIAL MEDIATION",
                           ENUM_VAL(ADMOB_INTERSTITIAL_MEDIATION): @"ADMOB INTERSTITIAL MEDIATION",
                           ENUM_VAL(DFP_BANNER_MANUAL_HB): @"MANUAL DFP BANNER",
                           ENUM_VAL(DFP_INSTERSTITIAL_MANUAL_HB): @"MANUAL DFP INTERSTITIAL",
                           ENUM_VAL(MRAID_BANNER): @"MRAID BANNER",
                           ENUM_VAL(MRAID_INTERSTITIAL): @"MRAID INTERSTITIAL",
                        };
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void) handleButtonStatesForAdType{
    [[self loadAd] setEnabled:YES];
    [[self showAd] setHidden:YES];
}

- (IBAction)back:(id)sender {
    interstitialAd = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loadAdAction:(id)sender {
    [self clearAdView];
    
    switch ([self adType]) {
        case BNR:{
            MNetAdRequest *request = [MNetAdRequest newRequest];
            [request setKeywords:@"lion, king, disney"];
            
            MNetAdView *mnetAdView = [[MNetAdView alloc] init];
            [mnetAdView setAdUnitId:DEMO_MN_AD_UNIT_320x50];
            [mnetAdView setDelegate:self];
            [mnetAdView setSize:MNET_BANNER_AD_SIZE];
            [mnetAdView setRootViewController:self];
            // Initializing with lat-long
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            [mnetAdView setCustomLocation:customLocation];
            [_adView addSubview:mnetAdView];
            [self applyAdViewContraints:mnetAdView height:mnetAdView.size.height width:mnetAdView.size.width];
            [mnetAdView loadAdForRequest:request];
            break;
        }
            
        case BNR_VIDEO:{
            MNetAdRequest *request = [MNetAdRequest newRequest];
            [request setKeywords:@"coconut, peanut, cashewnut"];
            
            MNetAdView *mnetAdView = [[MNetAdView alloc]init];
            [mnetAdView setAdUnitId:DEMO_MN_AD_UNIT_300x250_VIDEO];
            [mnetAdView setSize:MNET_MEDIUM_AD_SIZE];
            [mnetAdView setRootViewController:self];
            [mnetAdView setVideoDelegate:self];
            
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            [mnetAdView setCustomLocation:customLocation];
            [_adView addSubview:mnetAdView];
            [self applyAdViewContraints:mnetAdView height:mnetAdView.size.height width:mnetAdView.size.width];
            [mnetAdView loadAdForRequest:request];
            break;
        }
            
        case BNR_INTR:{
            [self addLoaderToScreen];
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            
            interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250];
            [interstitialAd setInterstitialDelegate:self];
            [interstitialAd setCustomLocation:customLocation];
            [interstitialAd setKeywords:@"banana, mango, strawberry"];
            [interstitialAd loadAd];
            break;
        }
            
        case VIDEO_INTR:{
            [self addLoaderToScreen];
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            
            interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MN_AD_UNIT_300x250_VIDEO];
            [interstitialAd setInterstitialVideoDelegate:self];
            [interstitialAd setKeywords:@"oranges, potato, almonds"];
            [interstitialAd setCustomLocation:customLocation];
            [interstitialAd loadAd];
            break;
        }
            
        case VIDEO_REWARDED : {
            [self addLoaderToScreen];
            MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId: DEMO_MN_AD_UNIT_REWARDED];
            [rewardedVideo setRewardedVideoDelegate:self];
            [rewardedVideo setRewardWithName : @"NEW_REWARD" forCurrency :@"INR" forAmount : [NSNumber numberWithInt:100]];
            [rewardedVideo setKeywords:@"bugs, bunny, warner"];
            [rewardedVideo loadRewardedAd];
            break;
        }
        
        case DFP_REWARDED : {
            [self addLoaderToScreen];
            GADRewardBasedVideoAd *rewardBasedVideoAd = [GADRewardBasedVideoAd sharedInstance];
            [rewardBasedVideoAd setDelegate:self];
            GADRequest *gadRequest = [GADRequest request];
            [rewardBasedVideoAd loadRequest:gadRequest withAdUnitID:DEMO_AD_MOB_REWARDED_VIDEO_MEDIATION_AD_UNIT_ID];
            break;
        }
            
        case DFP_HB:{
            [self addLoaderToScreen];
            
            NSLog(@"creating banner ad view for dfp");
            dfpBannerView = [[DFPBannerView alloc]initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
            [[self adView]addSubview:dfpBannerView];
            [self applyAdViewContraints:dfpBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];
            [dfpBannerView setAdUnitID:DEMO_DFP_AD_UNIT_ID];
            [dfpBannerView setRootViewController:self];
            [dfpBannerView setDelegate:self];
            DFPRequest *request = [DFPRequest request];
            [request setCustomTargeting:@{@"bid": @"15"}];
            [dfpBannerView loadRequest:request];
            break;
        }
        
        case MOPUB_HB:{
            [self addLoaderToScreen];
            
            CGSize adSize = MOPUB_BANNER_SIZE;
            MPAdView *mpAdView = [[MPAdView alloc]initWithAdUnitId:DEMO_MOPUB_AD_UNIT_ID size:adSize];
            [_adView addSubview:mpAdView];
            [self applyAdViewContraints:mpAdView height:adSize.height width:adSize.width];
            mpAdView.delegate = self;
            [mpAdView stopAutomaticallyRefreshingContents];
            [mpAdView setKeywords:@"bid:1"];
            [mpAdView loadAd];
            
            [mpAdView setFrame:CGRectMake((_adView.frame.size.width - adSize.width)/2.0, 0, adSize.width, adSize.height)];
            break;
        }
            
        case AD_MOB_HB:{
            [self addLoaderToScreen];
            
            NSLog(@"creating banner ad view for admob");
            [[self adView]addSubview:gadBannerView];
            [self applyAdViewContraints:gadBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];
            [gadBannerView setAdUnitID:DEMO_AD_MOB_AD_UNIT_ID];
            [gadBannerView setRootViewController:self];
            GADRequest *request = [GADRequest request];
            //[request setTestDevices:@[kGADSimulatorID]];
            [gadBannerView loadRequest:request];
            break;
        }
            
        case DFP_INTERSTITIAL_HB:{
            [self addLoaderToScreen];
            dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
            DFPRequest *request = [DFPRequest request];
            [dfpInterstitialAd setDelegate:self];
            [dfpInterstitialAd loadRequest:request];
            break;
        }
        case MOPUB_INTERSTITIAL_HB:{
            [self addLoaderToScreen];
            mopubInterstititalAd = [MPInterstitialAdController
                                    interstitialAdControllerForAdUnitId:DEMO_MOPUB_INTERSTITIAL_HB_AD_UNIT_ID];
            [mopubInterstititalAd setKeywords:@"mnetbidPrice:7.00"];
            [mopubInterstititalAd setDelegate:self];
            [mopubInterstititalAd loadAd];
            break;
        }
            
        case DFP_MEDIATION:{
            [self addLoaderToScreen];
            
            NSLog(@"creating banner ad view for dfp");
            dfpBannerView = [[DFPBannerView alloc]initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
            [[self adView]addSubview:dfpBannerView];
            [dfpBannerView setAdUnitID:DEMO_DFP_MEDIATION_AD_UNIT_ID];
            [dfpBannerView setRootViewController:self];
            [dfpBannerView setDelegate:self];
            
            DFPRequest *request = [DFPRequest request];
            [request setCustomTargeting:@{@"bid": @"15"}];
            
            // User-defined stuff
            [request setGender:kGADGenderFemale];
            [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
            [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
            
            /*
            [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
            GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
            NSString *label = DFP_CUSTOM_EVENT_LABEL;
            [customEventExtras setExtras:@{
                                           @"author":       @"hawking",
                                           @"shape":        @"saddle",
                                           @"element":      @"universe",
                                           @"content_link": @"https://my-custom-link.com/additional_params",
                                       }
                                forLabel:DFP_CUSTOM_EVENT_LABEL];
            NSLog(@"%@", [customEventExtras extrasForLabel:DFP_CUSTOM_EVENT_LABEL]);
            [request registerAdNetworkExtras:customEventExtras];
             */
            
            [dfpBannerView loadRequest:request];
            
            [dfpBannerView setFrame:CGRectMake((_adView.frame.size.width - GAD_SIZE_320x50.width)/2.0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
            break;
        }
        case MOPUB_MEDIATION:{
            [self addLoaderToScreen];
            
            CGSize adSize = MOPUB_BANNER_SIZE;
            MPAdView *mpAdView = [[MPAdView alloc]initWithAdUnitId:DEMO_MOPUB_MEDIATION_AD_UNIT_ID size:adSize];
            [_adView addSubview:mpAdView];
            mpAdView.delegate = self;
            [mpAdView stopAutomaticallyRefreshingContents];
            [mpAdView setKeywords:@"bid:1"];
            [mpAdView loadAd];
            
            [self applyAdViewContraints:mpAdView height:adSize.height width:adSize.width];
            [mpAdView setFrame:CGRectMake((_adView.frame.size.width - adSize.width)/2.0, 0, adSize.width, adSize.height)];
            break;
        }
        case ADMOB_MEDIATION:{
            [self addLoaderToScreen];
            
            NSLog(@"creating banner ad view for admob");
            gadBannerView = [[GADBannerView alloc]initWithAdSize:GADAdSizeFromCGSize(CGSizeMake(GAD_SIZE_320x50.width, GAD_SIZE_320x50.height))];
            [[self adView]addSubview:gadBannerView];
            [gadBannerView setAdUnitID:DEMO_AD_MOB_MEDIATION_AD_UNIT_ID];
            [gadBannerView setRootViewController:self];
            [gadBannerView setDelegate:self];
            
            GADRequest *request = [GADRequest request];
            //[request setTestDevices:@[kGADSimulatorID]];
            
            // custom user settings
            [request setGender:kGADGenderFemale];
            [request setBirthday:[NSDate dateWithTimeIntervalSince1970:0]];
            [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
            
            /*
            [request setKeywords:@[@"sports", @"scores", @"content_link:https://my-custom-link.com/keywords"]];
            GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
            NSString *label = AD_MOB_CUSTOM_EVENT_LABEL;
            [customEventExtras setExtras:@{
                                           @"author":       @"hawking",
                                           @"shape":        @"saddle",
                                           @"element":      @"universe",
                                           @"content_link": @"https://my-custom-link.com/additional_params",
                                           }
                                forLabel:label];
            NSLog(@"%@", [customEventExtras extrasForLabel:label]);
            [request registerAdNetworkExtras:customEventExtras];
             */
            
            [gadBannerView loadRequest:request];
            
            [gadBannerView setFrame:CGRectMake((_adView.frame.size.width - GAD_SIZE_320x50.width)/2.0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
            break;
        }
        case DFP_INTERSTITIAL_MEDIATION:{
            [self addLoaderToScreen];
            dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_MEDIATION_INTERSTITIAL_AD_UNIT_ID];
            DFPRequest *request = [DFPRequest request];
            //[request setTestDevices:@[kGADSimulatorID]];
            
            // User-defined stuff
            [request setGender:kGADGenderFemale];
            [request setBirthday:[NSDate dateWithTimeIntervalSince1970:3]];
            [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
            /*
            [request setKeywords:@[@"sports", @"scores", @"content_link:https://dfp-intersitial-my-custom-link.com/keywords"]];
            NSString *label = DFP_CUSTOM_EVENT_LABEL;
            GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
            [customEventExtras setExtras:@{
                                           @"author":       @"hawking",
                                           @"shape":        @"saddle",
                                           @"element":      @"universe",
                                           @"content_link": @"https://dfp-intersitial-my-custom-link.com/additional_params",
                                           }
                                forLabel:label];
            NSLog(@"%@", [customEventExtras extrasForLabel:label]);
            [request registerAdNetworkExtras:customEventExtras];
             */
            
            [dfpInterstitialAd setDelegate:self];
            [dfpInterstitialAd loadRequest:request];
            break;
        }
        case MOPUB_INTERSTITIAL_MEDIATION:{
            [self addLoaderToScreen];
            mopubInterstititalAd = [MPInterstitialAdController
        interstitialAdControllerForAdUnitId:DEMO_MOPUB_MEDIATION_INTERSTITIAL_AD_UNIT_ID];
            [mopubInterstititalAd setDelegate:self];
            [mopubInterstititalAd loadAd];
            break;
        }
        case ADMOB_INTERSTITIAL_MEDIATION:{
            [self addLoaderToScreen];
            gadInterstitialAd = [[GADInterstitial alloc] initWithAdUnitID:DEMO_AD_MOB_MEDIATION_INTERSTITIAL_AD_UNIT_ID];
            [gadInterstitialAd setDelegate:self];
            
            GADRequest *request = [GADRequest request];
            
            // User-defined stuff
            [request setGender:kGADGenderFemale];
            [request setBirthday:[NSDate dateWithTimeIntervalSince1970:4]];
            [request setLocationWithLatitude:LATITUDE longitude:LONGITUDE accuracy:5];
            /*
            [request setKeywords:@[@"sports", @"scores", @"content_link:https://admob-intersitial-my-custom-link.com/keywords"]];
            
            NSString *label = AD_MOB_CUSTOM_EVENT_LABEL;
            GADCustomEventExtras *customEventExtras = [[GADCustomEventExtras alloc] init];
            [customEventExtras setExtras:@{
                                           @"author":       @"hawking",
                                           @"shape":        @"saddle",
                                           @"element":      @"universe",
                                           @"content_link": @"https://admob-intersitial-my-custom-link.com/additional_params",
                                           }
                                forLabel:label];
            NSLog(@"%@", [customEventExtras extrasForLabel:label]);
            [request registerAdNetworkExtras:customEventExtras];
             */
            
            [gadInterstitialAd loadRequest:request];
            break;
        }
            
        case DFP_BANNER_MANUAL_HB:{
            [self addLoaderToScreen];
            
            dfpBannerView = [[DFPBannerView alloc] initWithAdSize:kGADAdSizeBanner];
            
            [[self adView]addSubview:dfpBannerView];
            [self applyAdViewContraints:dfpBannerView height:GAD_SIZE_320x50.height width:GAD_SIZE_320x50.width];
            
            [dfpBannerView setAdUnitID:DEMO_DFP_AD_UNIT_ID];
            [dfpBannerView setRootViewController:self];
            [dfpBannerView setDelegate:self];
            DFPRequest *request = [DFPRequest request];
            [request setCustomTargeting:@{@"bid": @"15"}];
            
            // Manual header bidding
            [MNetHeaderBidder addBidsToDfpBannerAdRequest:request
                                               withAdView:dfpBannerView
                                         withCompletionCb:^(NSObject *modifiedRequest, NSError *error)
             {
                 if(error){
                     NSLog(@"Error when adding bids to request - %@", error);
                 }
                 
                 GADRequest *dfpRequestObject = (GADRequest *)modifiedRequest;
                 [dfpBannerView loadRequest:dfpRequestObject];
             }];
            
            break;
        }
        case DFP_INSTERSTITIAL_MANUAL_HB:{
            [self addLoaderToScreen];
            dfpInterstitialAd = [[DFPInterstitial alloc] initWithAdUnitID:DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID];
            [dfpInterstitialAd setDelegate:self];
            
            DFPRequest *request = [DFPRequest request];
            
            [MNetHeaderBidder addBidsToDfpInterstitialAdRequest:request
                                                     withAdView:dfpInterstitialAd
                                               withCompletionCb:^(NSObject *modifiedRequest, NSError *error)
             {
                 if(error){
                     NSLog(@"Error when adding bids to request - %@", error);
                 }
                 
                 GADRequest *dfpRequestObject = (GADRequest *)modifiedRequest;
                 [dfpInterstitialAd loadRequest:dfpRequestObject];
             }];
            break;
        }
            
        case MRAID_BANNER:{
            MNetAdRequest *request = [MNetAdRequest newRequest];
            [request setKeywords:@"lion, king, disney"];
            
            MNetAdView *mnetAdView = [[MNetAdView alloc]init];
            [mnetAdView setAdUnitId:DEMO_MRAID_AD_UNIT_320x50];
            [mnetAdView setDelegate:self];
            [mnetAdView setSize:MNET_MEDIUM_AD_SIZE];
            [mnetAdView setRootViewController:self];
            
            // Initializing with lat-long
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            [mnetAdView setCustomLocation:customLocation];
            
            [_adView addSubview:mnetAdView];
            [self applyAdViewContraints:mnetAdView height:mnetAdView.size.height width:mnetAdView.size.width];
            [mnetAdView loadAdForRequest:request];
            break;

        }
            
        case MRAID_INTERSTITIAL:{
            [self addLoaderToScreen];
            CLLocation *customLocation = [[CLLocation alloc]initWithLatitude:LATITUDE longitude:LONGITUDE];
            
            interstitialAd = [[MNetInterstitialAd alloc]initWithAdUnitId:DEMO_MRAID_AD_UNIT_320x50];
            [interstitialAd setInterstitialDelegate:self];
            [interstitialAd setCustomLocation:customLocation];
            [interstitialAd setKeywords:@"banana, mango, strawberry"];
            [interstitialAd loadAd];
            break;
        }
    }
}

-(void) applyAdViewContraints : (UIView *) mnetAdView height : (CGFloat) h width : (CGFloat) w{
    mnetAdView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.adView addConstraints:@[
                                  [NSLayoutConstraint constraintWithItem:mnetAdView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.adView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0],
                                  [NSLayoutConstraint constraintWithItem:mnetAdView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.adView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                  [NSLayoutConstraint constraintWithItem:mnetAdView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:w],
                                  [NSLayoutConstraint constraintWithItem:mnetAdView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:h]
                                  
                                  ]];
    
}

-(void)clearAdView{
    for(UIView *subview in [[self adView]subviews]){
        [subview removeFromSuperview];
    }
}

-(void)showErrorAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) btnStateEnabled:(BOOL) isEnabled forBtn:(UIButton*)btnVal {
    UIColor *bgColor;
    
    if(isEnabled){
        bgColor = [UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:10/255.0 alpha:1];
        
    }else{
        bgColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];
    }
    [btnVal setHidden:!isEnabled];
    [btnVal setBackgroundColor:bgColor];
    [btnVal setEnabled:isEnabled];
}

- (IBAction)showAdAction:(id)sender {
    switch ([self adType]) {
        case BNR_INTR:{
            [interstitialAd showAdFromViewController:self];
            break;
        }
        
        case VIDEO_INTR: {
            [self addLoaderToScreen];
            [interstitialAd showAdFromViewController:self];
            break;
        }
        
        case VIDEO_REWARDED : {
            [self addLoaderToScreen];
            MNetRewardedVideo *rewardedVideo = [MNetRewardedVideo getInstanceForAdUnitId:DEMO_MN_AD_UNIT_REWARDED];
            [rewardedVideo showAdFromViewController:self];
            break;
        }
        
        case DFP_REWARDED : {
            [self addLoaderToScreen];
            GADRewardBasedVideoAd *rewardBasedVideoAd = [GADRewardBasedVideoAd sharedInstance];
            if([rewardBasedVideoAd isReady]){
                [rewardBasedVideoAd presentFromRootViewController:self];
            }
            break;
        }
            
        case DFP_INTERSTITIAL_HB:{
            [dfpInterstitialAd presentFromRootViewController:self];
            break;
        }
        case MOPUB_INTERSTITIAL_HB:{
            [mopubInterstititalAd showFromViewController:self];
            break;
        }
        case DFP_INTERSTITIAL_MEDIATION:{
            [dfpInterstitialAd presentFromRootViewController:self];
            break;
        }
        case MOPUB_INTERSTITIAL_MEDIATION:{
            [mopubInterstititalAd showFromViewController:self];
            break;
        }
        case ADMOB_INTERSTITIAL_MEDIATION:{
            [gadInterstitialAd presentFromRootViewController:self];
            break;
        }
        case DFP_INSTERSTITIAL_MANUAL_HB:{
            [dfpInterstitialAd presentFromRootViewController:self];
            break;
        }
        
        case MRAID_INTERSTITIAL:{
            [interstitialAd showAdFromViewController:self];
            break;
        }
        default:
            //Nothing
            break;
    }
}

#pragma mark - Loader helpers
static NSProgress *progressObject;
static NSTimer *loaderTimerObj;
static const NSUInteger totalLoaderUnits = 100;
static const NSUInteger maxUnitsWhileLoading = 80;

- (void)addLoaderToScreen{
    __block NSUInteger currentUnit = 0;
    
    MBProgressHUD *loader = [MBProgressHUD showHUDAddedTo:self.view animated:true];
    [loader.label setText:LOADER_TEXT];
    loader.mode = MBProgressHUDModeAnnularDeterminate;
    
    progressObject = [NSProgress progressWithTotalUnitCount:totalLoaderUnits];
    loader.progressObject = progressObject;
    
    NSBlockOperation *handleProgressViewCallback = [NSBlockOperation blockOperationWithBlock:^{
        if(currentUnit < maxUnitsWhileLoading){
            currentUnit += 1;
            progressObject.completedUnitCount = currentUnit;
        }
    }];
    
    NSTimeInterval timerInterval = 1/60.0;
    loaderTimerObj = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                      target:handleProgressViewCallback
                                                    selector:@selector(main)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)hideLoaderFromScreen{
    progressObject.completedUnitCount = totalLoaderUnits;
    if(loaderTimerObj){
        [loaderTimerObj invalidate];
        loaderTimerObj = nil;
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - MNetAdView
- (void)mnetAdDidLoad:(MNetAdView *)adView{
    NSLog(@"DEMO: %@", mnetBannerLoadAd);
    [self.view makeToast:mnetBannerLoadAd];
    
    [self hideLoaderFromScreen];
}

- (void)mnetAdDidFailToLoad:(MNetAdView *) adView withError : (MNetError *)error {
    NSLog(@"DEMO: View did fail to load");
    [self hideLoaderFromScreen];
    
    NSLog(@"DEMO: %@", error);
    [self.view makeToast:mnetBannerFailAd];
    [self.view makeToast:[error getErrorString]];
    
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching response"];
}

- (void)mnetAdDidClick:(MNetAdView *)adView{
    NSLog(@"DEMO: %@", mnetBannerAdClick);
    [self.view makeToast:mnetBannerAdClick];
}

#pragma mark - MNetVideo
-(void) mnetVideoDidStart : (MNetAdView *) adView {
    NSLog(@"DEMO: %@", mnetVideoStartAd);
    [self.view makeToast:mnetVideoStartAd];
    [self hideLoaderFromScreen];
}

-(void) mnetVideoDidLoad:(MNetAdView *)adView {
    NSLog(@"DEMO: %@", mnetVideoLoadAd);
    [self.view makeToast:mnetVideoLoadAd];
    [self hideLoaderFromScreen];
}

-(void) mnetVideoDidComplete : (MNetAdView *) adView {
    NSLog(@"DEMO: %@", mnetVideoComplteAd);
    [self hideLoaderFromScreen];
}

-(void) mnetVideoDidFailToLoad:(MNetAdView *) adView withError : (MNetError *) error{
    [self hideLoaderFromScreen];
    
    NSLog(@"DEMO: %@", error);
    [self.view makeToast:mnetVideoFailAd];
    [self.view makeToast:[error getErrorString]];
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching Video Ad!"];
}

-(void) mnetVideoDidClick : (MNetAdView *) adView {
    [self.view makeToast:mnetVideoClickAd];
}

#pragma mark : MNetInterstitialAd

-(void) mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"DEMO: interstitial banner ad load");
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self.view makeToast:mnetInterstitialLoadAd];
    [self hideLoaderFromScreen];
}

-(void) mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error {
    NSLog(@"DEMO : interstital banner ad load failed");
    [self hideLoaderFromScreen];
    [self.view makeToast:mnetInterstitialFailAd];
    [self.view makeToast:[error getErrorString]];
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching Interstitial Ad!"];
}

-(void) mnetInterstitialAdDidShow:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"DEMO : interstitial banner ad shown");
    [self.view makeToast:mnetInterstitialShowAd];
    
    [self hideLoaderFromScreen];
}

-(void) mnetInterstitialAdDidDismiss:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"interstitial banner ad dismissed");
    [self.view makeToast:mnetInterstitialDismissAd];
    [self btnStateEnabled:NO forBtn:self.showAd];
}

-(void) mnetInterstitialAdDidClick:(MNetInterstitialAd *)interstialAd {
    [self.view makeToast:mnetInterstitialClickAd];
}

#pragma mark : MNetInterstitialVideo

-(void) mnetInterstitialVideoDidLoad:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"DEMO : interstitial video ad load");
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self.view makeToast:mnetInterstitialVideoLoadAd];
    [self hideLoaderFromScreen];
}

-(void) mnetInterstitialVideoDidShow:(MNetInterstitialAd *)interstitialAd{
    [self.view makeToast:mnetInterstitialVideoShowAd];
}

-(void) mnetInterstitialVideoDidStart:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"DEMO : interstitial video ad started");
    [self.view makeToast:mnetInterstitialVideoStartAd];
    [self hideLoaderFromScreen];
}

-(void) mnetInterstitialVideoDidComplete:(MNetInterstitialAd *)interstitialAd {
    NSLog(@"DEMO : interstitial video ad completed");
    [self.view makeToast:mnetInterstitialVideoCompleteAd];
}

-(void) mnetInterstitialVideoDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error {
    NSLog(@"DEMO : interstitial video ad load failed");
    [self hideLoaderFromScreen];
    [self.view makeToast:mnetInterstitialVideoFailAd];
    [self.view makeToast:[error getErrorString]];
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching Interstitial Video Ad!"];
}

-(void) mnetInterstitialVideoDidClick:(MNetInterstitialAd *)interstialAd {
    [self.view makeToast:mnetInterstitialVideoClickAd];
}

-(void) mnetInterstitialVideoDidDismiss:(MNetInterstitialAd *)interstitialAd {
    [self.view makeToast:mnetInterstitialVideoDismissAd];
    [self btnStateEnabled:NO forBtn:self.showAd];
}

#pragma mark : MNetRewardedVideo

-(void) mnetRewardedVideoDidLoad:(MNetRewardedVideo *)rewardedVideo {
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self.view makeToast:mnetRewardedVideoLoadAd];
    [self hideLoaderFromScreen];
}

-(void) mnetRewardedVideoDidStart:(MNetRewardedVideo *)rewardedVideo {
    NSLog(@"DEMO : rewarded video ad started");
    [self.view makeToast:mnetRewardedVideoStartAd];
    [self hideLoaderFromScreen];
}

-(void) mnetRewardedVideoDidComplete:(MNetRewardedVideo *)rewardedVideo withReward : (MNetReward *) reward {
    [self.view makeToast:mnetRewardedVideoCompleteAd];
    [self btnStateEnabled:NO forBtn:self.showAd];
}

-(void) mnetRewardedVideoDidFailToLoad:(MNetRewardedVideo *)rewardedVideo withError:(MNetError *)error {
    [self hideLoaderFromScreen];
    [self.view makeToast:mnetRewardedVideoFailAd];
    [self.view makeToast:[error getErrorString]];
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching Ad!"];
}

-(void) mnetRewardedVideoDidShow:(MNetRewardedVideo *)rewardedVideo{
    [self.view makeToast:mnetRewardedVideoShowAd];
}

-(void)mnetRewardedVideoDidClick:(MNetRewardedVideo *)rewardedVideo{
    [self.view makeToast:mnetRewardedVideoClickAd];
}

#pragma mark - MPAdViewDelegate
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view{
    NSLog(@"DEMO: %@", mopubLoadAd);
    [self.view makeToast:mopubLoadAd];
    [self hideLoaderFromScreen];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view{
    [self.view makeToast:mopubFailAd];
    
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while getting Ad for mopub!"];
    [self hideLoaderFromScreen];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view{
    NSLog(@"DEMO: %@", mopubClickAd);
    [self.view makeToast:mopubClickAd];
}


#pragma mark - MPInterstitialAdDelegate
- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial{
    [self.view makeToast:mopubInterstitialShowAd];
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial{
    [self.view makeToast:mopubInterstitialLoadAd];
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self hideLoaderFromScreen];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial{
    [self.view makeToast:mopubInterstitialFailAd];
    [self hideLoaderFromScreen];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial{
    [self.view makeToast:mopubInterstitialDismiss];
    [self btnStateEnabled:NO forBtn:self.showAd];
}

#pragma mark - GADBannerView
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSLog(@"DEMO: %@", gadLoadAd);
    [self.view makeToast:gadLoadAd];
    
    [self hideLoaderFromScreen];
}

-(void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    [self.view makeToast:gadFailAd];
    
    NSString *displayStr = [NSString stringWithFormat:@"GAD: banner view error %@",error];
    NSLog(@"DEMO: %@", displayStr);
    [self.view makeToast:displayStr];
    
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching GADBannerView"];
    
    [self hideLoaderFromScreen];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
    NSLog(@"DEMO: %@", gadClickAd);
    [self.view makeToast:gadClickAd];
}

#pragma mark - GADInterstitial

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    NSLog(@"Interstitial DFP ad received");
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadInterstitialLoadAd];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"Failed!");
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching DFP Interstitial ad!"];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadFailAd];
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad{
    NSLog(@"Fail to present to screen");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    [self btnStateEnabled:NO forBtn:self.showAd];
    [self.view makeToast:gadInterstitialDismissAd];
}

#pragma mark GADRewardBasedVideo

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    [self btnStateEnabled:YES forBtn:self.showAd];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadInterstitialLoadAd];
    NSLog(@"GAD: Rewarded video received");
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    NSLog(@"GAD: Rewarded video open");
    [self btnStateEnabled:NO forBtn:self.showAd];
    [self hideLoaderFromScreen];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    NSLog(@"GAD: Rewarded video start playing");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error{
    NSLog(@"GAD: Rewarded video load failed");
    [self showErrorAlertViewWithTitle:@"Ad Failed to Load!" andMessage:@"Error while fetching DFP Mediation Rewarded Video ad!"];
    [self hideLoaderFromScreen];
    [self.view makeToast:gadFailAd];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward{
    NSLog(@"GAD: Reward received type:%@ amount:%@", reward.type,reward.amount);
    [self btnStateEnabled:NO forBtn:self.showAd];
    [self hideLoaderFromScreen];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd{
    NSLog(@"GAD: RewardedVideo closed");
    [self btnStateEnabled:NO forBtn:self.showAd];
    [self hideLoaderFromScreen];
}
#pragma mark - Error
- (void)dealloc{
    NSLog(@"DEALLOC: MNShowAdViewController");
}


@end
