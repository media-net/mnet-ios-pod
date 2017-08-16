//
//  MNetAdRequest.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MNetAdSize.h"

/// The class that describes the ad request object
@interface MNetAdRequest: NSObject

/// Keywords for the ad
@property (nonatomic) NSString *keywords;

/// The website link for the current screen. This is for better context. 
@property (nonatomic) NSString *contextLink;

/// Get a new request object
+ (MNetAdRequest *)newRequest;

@end

