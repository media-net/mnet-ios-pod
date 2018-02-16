//
//  MNDemoConstants.h
//  MNAdSdk
//
//  Created by nithin.g on 10/03/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEMO_MN_CUSTOMER_ID             @"<custom_id>"
#define DEMO_MN_MRAID_CUSTOMER_ID       @"<custom_id>"
#define DEMO_MN_AD_UNIT_300x250         @"<custom_id>"
#define DEMO_MN_AD_UNIT_300x250_VIDEO   @"<custom_id>"
#define DEMO_MN_AD_UNIT_320x50          @"<custom_id>"
#define DEMO_MN_AD_UNIT_450x300         @"<custom_id>"
#define DEMO_MN_AD_UNIT_REWARDED        @"<custom_id>"
#define DEMO_MOPUB_AD_UNIT_ID           @"<custom_id>"
#define DEMO_DFP_AD_UNIT_ID             @"<custom_id>"
#define DEMO_MRAID_AD_UNIT_320x50       @"<custom_id>"

#define DEMO_DFP_MEDIATION_AD_UNIT_ID           @"<custom_id>"
#define DEMO_MOPUB_MEDIATION_AD_UNIT_ID         @"<custom_id>"
#define DEMO_AD_MOB_MEDIATION_AD_UNIT_ID        @"<custom_id>"
#define DEMO_AD_MOB_REWARDED_VIDEO_MEDIATION_AD_UNIT_ID @"<custom_id>"

#define DEMO_AD_MOB_HB_AD_UNIT_ID               @"<custom_id>"
#define DEMO_MOPUB_INTERSTITIAL_HB_AD_UNIT_ID   @"<custom_id>"
#define DEMO_DFP_HB_INTERSTITIAL_AD_UNIT_ID     @"<custom_id>"

#define DEMO_DFP_MEDIATION_INTERSTITIAL_AD_UNIT_ID           @"<custom_id>"
#define DEMO_MOPUB_MEDIATION_INTERSTITIAL_AD_UNIT_ID         @"<custom_id>"
#define DEMO_AD_MOB_MEDIATION_INTERSTITIAL_AD_UNIT_ID        @"<custom_id>"

#define DEMO_AD_MOB_AD_UNIT_ID  @"<custom_id>"

#define LONGITUDE 72.8561644
#define LATITUDE  19.0176147

// Custom event labels
#define AD_MOB_CUSTOM_EVENT_LABEL   @"<custom_id>"
#define DFP_CUSTOM_EVENT_LABEL      @"<custom_id>"

// If has_include contains the import, the pod is not a framework
#if ! __has_include(<MNetAdSdk/MNetURL.h>)
#define IS_FRAMEWORK 1
#endif

@interface MNDemoConstants : NSObject

@end
