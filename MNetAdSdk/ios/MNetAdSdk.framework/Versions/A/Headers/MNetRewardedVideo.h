//
//  MNetRewardedVideo.h
//  Pods
//
//  Created by kunal.ch on 17/04/17.
//
//

#import "MNetAdRequest.h"
#import "MNetError.h"
#import "MNetReward.h"
#import <Foundation/Foundation.h>

@protocol MNetRewardedVideoDelegate;

/// The class for loading and displaying Rewarded video ads
@interface MNetRewardedVideo : NSObject

NS_ASSUME_NONNULL_BEGIN

/// The ad delegate for callbacks from rewarded video ads
@property (weak, atomic) id<MNetRewardedVideoDelegate> rewardedVideoDelegate;

NS_ASSUME_NONNULL_END

/// Optional keywords to be sent in the ad request
@property (atomic, nullable) NSString *keywords;

/// Gives an instance of the rewarded video for an adunit Id
+ (MNetRewardedVideo *_Nullable)getInstanceForAdUnitId:(NSString *_Nonnull)adUnitId;

/// Load the Rewarded video ad
- (void)loadRewardedAd;

/// Load the Rewarded video ad for adRequest
- (void)loadRewardedAdForRequest:(MNetAdRequest *_Nonnull)adRequest;

/// Show the rewarded video ad on top of the given view controller
- (void)showAdFromViewController:(UIViewController *_Nonnull)rootViewController;

/// Set the reward for the rewarded video instance
- (void)setRewardWithName:(NSString *_Nonnull)name
              forCurrency:(NSString *_Nonnull)currency
                forAmount:(NSNumber *_Nonnull)amount;
@end

/// Protocol for Rewarded videos callback
@protocol MNetRewardedVideoDelegate <NSObject>
@optional

/// Callback when the rewarded video started
- (void)mnetRewardedVideoDidStart:(MNetRewardedVideo *_Nonnull)rewardedVideo;

/// Callback when the rewared video has completed.
/// This returns the reward object that is set init
- (void)mnetRewardedVideoDidComplete:(MNetRewardedVideo *_Nonnull)rewardedVideo
                          withReward:(MNetReward *_Nullable)reward;

/// Callback when the rewarded video has completed loading
- (void)mnetRewardedVideoDidLoad:(MNetRewardedVideo *_Nonnull)rewardedVideo;

/// Callback when the rewarded video failed to load
- (void)mnetRewardedVideoDidFailToLoad:(MNetRewardedVideo *_Nonnull)rewardedVideo withError:(MNetError *_Nonnull)error;

/// Callback when the rewarded video is clicked
- (void)mnetRewardedVideoDidClick:(MNetRewardedVideo *_Nonnull)rewardedVideo;

/// Callback when the rewarded video is shown
- (void)mnetRewardedVideoDidShow:(MNetRewardedVideo *_Nonnull)rewardedVideo;

@end
