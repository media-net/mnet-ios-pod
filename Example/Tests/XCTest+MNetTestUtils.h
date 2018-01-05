//
//  XCTest+MNetTestUtils.h
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>

#define FILENAME_BANNER_320x50          @"adResponseBanner320x50"
#define FILENAME_BANNER_AD_URL_320x50   @"adResponseBannerAdUrl320x50"
#define FILENAME_BANNER_300x250         @"adResponseBanner300x250"
#define FILENAME_VIDEO_320x250          @"adResponseVideo320x250"
#define FILENAME_REWARDED_VIDEO         @"rewardedResponseVideo320x250"
#define INVALID_FILENAME_VIDEO          @"noAdResponse"
#define FILENAME_ADX_BANNER             @"MNetAdxResponse"
#define FILENAME_CONFIG_FILE            @"MNetSdkConfigResponse"
#define FILENAME_SAMPLE_REQUEST         @"MNetSampleRequest"

@interface XCTest (MNetTestUtils)

void dummyStubGoogleAds();
void dummyStubPulseRequest();
void validBannerAdRequestStub(Class classFile);
void validBannerAdUrlRequestStub(Class classFile);
void validInterstitialAdRequestStub(Class classFile);
void noAdRequestStub(Class classFile);
void noAdsStubPrefetchReq(Class className);
void validVideoAdRequestStub(Class classFile);
void invalidVideoAdRequestStub(Class classFile);
void validRewardedVideoAdRequestStub(Class classFile);
void validAdxAdRequestStub(Class classFile);
void dummyStubConfigRequest(Class classFile);
void stubPrefetchReq(Class className);
NSString* readFile(Class classFile, NSString *resourceName, NSString *resourceType);

void updateSdkInfo(Class className);
void stubifyRequests(Class className);
void customSetupWithClass(Class className);
void stubVASTRequest(Class className);
@end
