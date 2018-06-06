//
//  MNetAdSizeConstants.h
//  Pods
//
//  Created by nithin.g on 23/06/17.
//
//

#import "MNetAdSize.h"
#import <Foundation/Foundation.h>

/// The banner ad size - 320x50
extern CGSize const kMNetBannerAdSize;

/// The medium ad size - 300x250
extern CGSize const kMNetMediumAdSize;

/// Helper function to get MNetAdSize from CGSize
extern MNetAdSize *_Nonnull MNetAdSizeFromCGSize(CGSize size);

/// Helper function to to CGSize from MNetAdSize
extern CGSize MNetCGSizeFromAdSize(MNetAdSize *_Nonnull adSize);
