//
//  MNetRewardedVideo.h
//  Pods
//
//  Created by kunal.ch on 17/04/17.
//
//

#import <Foundation/Foundation.h>
#import "MNetReward.h"
#import "MNetAdRequest.h"
#import "MNetError.h"

@protocol MNetRewardedVideoDelegate;

/// The class for loading and displaying Rewarded video ads
@interface MNetRewardedVideo : NSObject

/// The ad delegate for callbacks from rewarded video ads
@property (weak, nonatomic)id<MNetRewardedVideoDelegate> rewardedVideoDelegate;

/// Optional keywords to be sent in the ad request
@property (nonatomic) NSString *keywords;

/// Gives an instance of the rewarded video for an adunit Id
+ (MNetRewardedVideo *)getInstanceForAdUnitId:(NSString *)adUnitId;

/// Load the Rewarded video ad
- (void)loadRewardedAd;

/// Load the Rewarded video ad for adRequest
- (void)loadRewardedAdForRequest:(MNetAdRequest *)adRequest;

/// Show the rewarded video ad on top of the given view controller
- (void)showAdFromViewController:(UIViewController *)rootViewController;

/// Set the reward for the rewarded video instance
- (void)setRewardWithName:(NSString *)name forCurrency:(NSString *)currency forAmount:(int)amount;
@end

/// Protocol for Rewarded videos callback
@protocol MNetRewardedVideoDelegate <NSObject>
@optional

/// Callback when the rewarded video started
- (void)mnetRewardedVideoDidStart:(MNetRewardedVideo *)rewardedVideo;

/// Callback when the rewared video has completed.
/// This returns the reward object that is set init
- (void)mnetRewardedVideoDidComplete:(MNetRewardedVideo *)rewardedVideo withReward:(MNetReward *)reward;

/// Callback when the rewarded video has completed loading
- (void)mnetRewardedVideoDidLoad:(MNetRewardedVideo *)rewardedVideo;

/// Callback when the rewarded video failed to load
- (void)mnetRewardedVideoDidFailToLoad:(MNetRewardedVideo *)rewardedVideo withError:(MNetError *)error;

/// Callback when the rewarded video is clicked
- (void)mnetRewardedVideoDidClick:(MNetRewardedVideo *)rewardedVideo;

/// Callback when the rewarded video is shown
- (void)mnetRewardedVideoDidShow:(MNetRewardedVideo *)rewardedVideo;

@end
