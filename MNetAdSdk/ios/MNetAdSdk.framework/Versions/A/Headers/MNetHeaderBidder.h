//
//  MNetHeaderBidder.h
//  Pods
//
//  Created by nithin.g on 02/05/17.
//
//

#import <Foundation/Foundation.h>

/// The class that describes all the Manual Header-Bidding methods
@interface MNetHeaderBidder : NSObject

/// Add bids manually to the dfp banner adview
/// This will modify the existing dfpView object and
/// return it in completion callback (completionCb)
+(void)addBidsToDfpBannerAdRequest:(NSObject *)bannerRequest
                        withAdView:(NSObject *)dfpView
                  withCompletionCb:(void(^)(NSObject *, NSError *))completionCb;

/// Add bids manually to the dfp interstitial adview
/// This will modify the existing dfpView object and
/// return it in completion callback (completionCb)
+(void)addBidsToDfpInterstitialAdRequest:(NSObject *)interstitialRequest
                              withAdView:(NSObject *)dfpView
                        withCompletionCb:(void(^)(NSObject *, NSError *))completionCb;
@end
