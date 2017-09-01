//
//  MNetInterstitialAd.h
//  Pods
//
//  Created by kunal.ch on 20/02/17.
//
//

#import <Foundation/Foundation.h>

#import "MNetAdView.h"

@protocol MNetInterstitialVideoAdDelegate;
@protocol MNetInterstitialAdDelegate;

/// The class that load and displays interstitial banner and video ads
@interface MNetInterstitialAd : NSObject

/// The interstitial ads delegate for callbacks on banner ads
@property (nonatomic,weak) id<MNetInterstitialAdDelegate> interstitialDelegate;

/// The interstitial video ads delegate for callbacks on video ads
@property (nonatomic,weak) id<MNetInterstitialVideoAdDelegate> interstitialVideoDelegate;

/// The adunit Id of the ad to be displayed
@property (nonatomic) NSString *adUnitId;

/// Optional keywords to be sent in the ad request
@property (nonatomic) NSString *keywords;

/// The ad request object
@property (nonatomic) MNetAdRequest *adRequest;

/// Initialise the interstitial ad with the adunit Id
- (id)initWithAdUnitId:(NSString *)adUnitId;

/// Load the interstitial ad
- (void)loadAd;

/// Load the intersitital ad with the ad request
- (void)loadAdForRequest:(MNetAdRequest*)request;

/// Present the ad on top of the given rootViewController.
/// This needs to be called only after the ad has finished loading,
/// otherwise it'll raise an error
- (void)showAdFromViewController:(UIViewController *)rootViewController;

/// Add location for the ad, as additional context for the ad to be displayed.
- (void)setCustomLocation:(CLLocation *)customLocationArg;
@end

@protocol MNetInterstitialBaseDelegate <NSObject>
@end

/// Protocol for the Interstitial ad life cycle
@protocol MNetInterstitialAdDelegate <MNetInterstitialBaseDelegate>
@optional
/// Callback when the ad has loaded
- (void)mnetInterstitialAdDidLoad:(MNetInterstitialAd *)interstitialAd;

/// Callback when the ad failed to load
- (void)mnetInterstitialAdDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error;

/// Callback when the ad is clicked
- (void)mnetInterstitialAdDidClick:(MNetInterstitialAd *)interstialAd;

/// Callback when the ad is shown
- (void)mnetInterstitialAdDidShow:(MNetInterstitialAd *)interstitialAd;

/// Callback when the ad is dismissed
- (void)mnetInterstitialAdDidDismiss:(MNetInterstitialAd *)interstitialAd;
@end

/// Protocol for the Interstitial video ad life cycle
@protocol MNetInterstitialVideoAdDelegate <MNetInterstitialBaseDelegate>
@optional

/// Callback when the video ad has loaded
- (void)mnetInterstitialVideoDidLoad:(MNetInterstitialAd *)interstitialAd;

/// Callback when the video ad failed to load
- (void)mnetInterstitialVideoDidFailToLoad:(MNetInterstitialAd *)interstitialAd withError:(MNetError *)error;

/// Callback when the video ad finished playing the video
- (void)mnetInterstitialVideoDidComplete:(MNetInterstitialAd *)interstitialAd;

/// Callback when the video starts playing
- (void)mnetInterstitialVideoDidStart:(MNetInterstitialAd *)interstitialAd;

/// Callback when the video ad is clicked
- (void)mnetInterstitialVideoDidClick:(MNetInterstitialAd *)interstitialAd;

/// Callback when the video ad is shown
- (void)mnetInterstitialVideoDidShow:(MNetInterstitialAd *)interstitialAd;

/// Callback when the interstitial ad is dismissed
- (void)mnetInterstitialVideoDidDismiss:(MNetInterstitialAd *)interstitialAd;
@end
