//
//  MNViewController.h
//  MNAdSdk
//
//  Created by Nithin on 02/15/2017.
//  Copyright (c) 2017 Nithin. All rights reserved.
//


@import UIKit;


@interface MNViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *interstitialView;

@property (weak, nonatomic) IBOutlet UIView *rewardedView;

@property (weak, nonatomic) IBOutlet UIView *headerBidderView;

#pragma mark - All buttons

@property (weak, nonatomic) IBOutlet UIButton *btnBanner;
@property (weak, nonatomic) IBOutlet UIButton *btnBannerVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnIntersitital;
@property (weak, nonatomic) IBOutlet UIButton *btnInterstitialVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnInterstitialVideoPerformance;
@property (weak, nonatomic) IBOutlet UIButton *btnRewardedVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnDFP;
@property (weak, nonatomic) IBOutlet UIButton *btnMoPub;


@end
