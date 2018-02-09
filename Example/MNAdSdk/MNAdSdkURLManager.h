//
//  MNAdSdkURLManager.h
//  MNAdSdk_Example
//
//  Created by kunal.ch on 07/02/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNAdSdkURLManager : NSObject
@property (nonatomic) BOOL isDebug;
+ (MNAdSdkURLManager *)getSharedInstance;
- (NSString *)getSdkPulseBaseURL;
- (NSString *)getSdkResourceBaseURL;
- (NSString *)getSdkConfigBaseURL;
- (NSString *)getSdkBaseURL;
- (void)setIsProdUserDefaults:(BOOL)isProd;
- (void)initialSetup;
@end
