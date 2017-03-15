//
//  MNShowAdViewController.h
//  MNAdSdk
//
//  Created by kunal.ch on 16/02/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MNAdSdk/MNetAdView.h>
#import <MoPub/MPAdView.h>
@import GoogleMobileAds;

@interface MNShowAdViewController : UIViewController<MPAdViewDelegate, MNetAdViewDelegate,GADBannerViewDelegate>

typedef enum{
    BNR,
    BNR_INTR,
    MOPUB_HB,
    AD_MOB_HB,
    DFP_HB
}AdType;

@property ( nonatomic) IBOutlet UIView *adView;
@property (nonatomic) AdType adType;
@property BOOL isInterstital;

@end
