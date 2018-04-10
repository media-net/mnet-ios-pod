//
//  MNetAdRequest.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import "MNetAdSize.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

/// The class that describes the ad request object
@interface MNetAdRequest : NSObject

/// Keywords for the ad
@property (nonatomic, nullable) NSString *keywords;

/// The website link for the current screen. This is for better context.
@property (nonatomic, nullable) NSString *contextLink;

/// Get a new request object
+ (MNetAdRequest *_Nonnull)newRequest;

@end
