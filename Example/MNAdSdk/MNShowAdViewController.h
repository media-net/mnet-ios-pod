//
//  MNShowAdViewController.h
//  MNAdSdk
//
//  Created by kunal.ch on 16/02/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MNetAdSdk/MNetAdView.h>
#import <MNetAdSdk/MNetInterstitialAd.h>
#import <MNetAdSdk/MNetRewardedVideo.h>
#import "MPAdView.h"
#import "MPInterstitialAdController.h"

#define ENUM_VAL(enum) [NSNumber numberWithInt:enum]

@import GoogleMobileAds;

@interface MNShowAdViewController : UIViewController<MPAdViewDelegate, MPInterstitialAdControllerDelegate, MNetAdViewDelegate,GADBannerViewDelegate, GADInterstitialDelegate, MNetVideoDelegate, MNetInterstitialAdDelegate, MNetInterstitialVideoAdDelegate, MNetRewardedVideoDelegate>

typedef enum{
    BNR,
    BNR_INTR,
    MOPUB_HB,
    AD_MOB_HB,
    MOPUB_INTERSTITIAL_HB,
    DFP_HB,
    DFP_INTERSTITIAL_HB,
    BNR_VIDEO,
    VIDEO_INTR,
    VIDEO_REWARDED,
    DFP_MEDIATION,
    MOPUB_MEDIATION,
    ADMOB_MEDIATION,
    DFP_INTERSTITIAL_MEDIATION,
    MOPUB_INTERSTITIAL_MEDIATION,
    ADMOB_INTERSTITIAL_MEDIATION,
    DFP_BANNER_MANUAL_HB,
    DFP_INSTERSTITIAL_MANUAL_HB,
    MRAID_BANNER,
    MRAID_INTERSTITIAL,
}AdType;


@property (nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *topBar;

@property (nonatomic) AdType adType;
@property BOOL isInterstital;

@end
