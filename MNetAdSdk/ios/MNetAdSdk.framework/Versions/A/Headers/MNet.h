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

NS_ASSUME_NONNULL_BEGIN

/// The customer Id of the MNetAdSdk
@property (nonatomic) NSString *customerId;

/// Setting this parameter will send the test requests to the servers.
/// It can be used for testing purposes.
@property (nonatomic) BOOL isTest;

@property (nonatomic, nullable) MNetUser *user;

/// Initialises the MNetAdSdk for a given customer Id.
/// This can be run only once in a session.
/// NOTE: Use the other intializer `initWithCustomerId:appContainsChildDirectedContent`
/// to specify if the app contains child directed content.
/// It defaults to NO in this call.
+ (instancetype)initWithCustomerId:(NSString *)customerId;

/// Initialises the MNetAdSdk for a given customer Id along with
/// specifying if the app contains child directed content.
+ (instancetype)initWithCustomerId:(NSString *)customerId
   appContainsChildDirectedContent:(BOOL)containsChildDirectedContent;

/// Logs all MNet ad related logs.
/// It is NO by default.
/// *** Do NOT enable logs in production apps ***
+ (void)enableLogs:(BOOL)enabled;

/// The current instance of MNet
+ (MNet*)getInstance;

/// This color is set to the top bar, on the webview ViewController
/// that's displayed when clickThrough occurs.
/// This is purely optional, and is for customization purposes only.
+ (void)setAdClickThroughVCNavColor:(UIColor * _Nullable)bgColor;

-(instancetype) init __attribute__((unavailable("Please use +initWithCustomerId:")));

NS_ASSUME_NONNULL_END
@end

