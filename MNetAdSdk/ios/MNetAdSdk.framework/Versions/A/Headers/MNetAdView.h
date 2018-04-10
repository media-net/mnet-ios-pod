//
//  MNetView.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MNetAdRequest.h"
#import "MNetError.h"

@protocol MNetAdViewDelegate;
@protocol MNetVideoDelegate;

/// The view for loading banner and video ads.
@interface MNetAdView : UIView

NS_ASSUME_NONNULL_BEGIN

/// The banner ads delegate for callbacks from banner ads
@property (nonatomic, weak) id<MNetAdViewDelegate> delegate;

/// The video ads delegate for callbacks from video ads
@property (nonatomic, weak) id<MNetVideoDelegate> videoDelegate;

/// The size the of the ad. This does not reflect the size of the frame,
/// within which the MNetAdView resides, but simply the size of the ad to
/// be displayed
@property (nonatomic) CGSize size;

@property (nonatomic, nullable) MNetError *error;

/// The adunit Id of the ad to be displayed
@property (nonatomic) NSString *adUnitId;

/// Optional keywords to be sent in the ad request
@property (nonatomic, nullable) NSString *keywords;

/// The ad request object
@property (nonatomic) MNetAdRequest *adRequest;

/// The view controller on which the MNetAdView is displayed.
/// The primary purpose of this is when the adView is clicked
/// (called a click-through), a clickthrough-webview is displayed,
/// which is presented on top of this viewController.
@property (weak, nonatomic) UIViewController *_Nullable rootViewController;

// All init methods

/// Initialise instance with the MNetAdRequest
+ (id)initWithMNetAdRequest:(MNetAdRequest *)request;

/// Initialise instance with the adunit Id
+ (id)initWithAdUnitId:(NSString *)adUnitId;

// Add loader methods

/// Load the ad.
- (void)loadAd;

/// Load the ad for the ad request
- (void)loadAdForRequest:(MNetAdRequest *)request;

/// Context link for contextual ads. Optional for developers to set.
- (void)setContextLink:(NSString *)contextLink;

/// Add location for the ad, as additional context for the ad to be displayed.
- (void)setCustomLocation:(CLLocation *)customLocationArg;
- (CLLocation *_Nullable)getCustomLocation;
@end

@protocol MNetBaseAdViewDelegate <NSObject>
@end

/// Protocol for ad lifecycle
@protocol MNetAdViewDelegate <MNetBaseAdViewDelegate>
@optional

/// Callback when the ad is loaded
- (void)mnetAdDidLoad:(MNetAdView *)adView;

/// Callback when the ad has failed to load
- (void)mnetAdDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error;

/// Callback when the ad is clicked
- (void)mnetAdDidClick:(MNetAdView *)adView;
@end

/// Protocol for video-ad lifecycle
@protocol MNetVideoDelegate <MNetBaseAdViewDelegate>
@optional

/// Callback when the video has loaded
- (void)mnetVideoDidLoad:(MNetAdView *)adView;

/// Callback when the video has started to play
- (void)mnetVideoDidStart:(MNetAdView *)adView;

/// Callback when then video has finished playing
- (void)mnetVideoDidComplete:(MNetAdView *)adView;

/// Callback when the ad has failed to load
- (void)mnetVideoDidFailToLoad:(MNetAdView *)adView withError:(MNetError *)error;

/// Callback when the video ad has been clicked
- (void)mnetVideoDidClick:(MNetAdView *)adView;

NS_ASSUME_NONNULL_END
@end
