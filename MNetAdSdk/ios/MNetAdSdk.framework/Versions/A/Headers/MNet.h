//
//  MNet.h
//  Pods
//
//  Created by nithin.g on 15/02/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MNetUser.h"

/// The class that initializes all MNetAdSdk, for a customer Id
@interface MNet: NSObject

/// The customer Id of the MNetAdSdk
@property (nonatomic) NSString *customerId;

/// Setting this parameter will send the test requests to the servers.
/// It can be used for testing purposes.
@property (nonatomic) BOOL isTest;

@property (nonatomic) MNetUser *user;

/// Initialises the MNetAdSdk for a given customer Id.
/// This can be run only once in a session.
+ (instancetype)initWithCustomerId:(NSString *)customerId;

/// The current instance of MNet
+ (MNet*)getInstance;

/// This color is set to the top bar, on the webview ViewController
/// that's displayed when clickThrough occurs.
/// This is purely optional, and is for customization purposes only.
+ (void)setAdClickThroughVCNavColor:(UIColor *)bgColor;

-(instancetype) init __attribute__((unavailable("Please use +initWithCustomerId:")));

@end

