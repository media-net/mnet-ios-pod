//
//  MNTestDevicesManager.h
//  MNAdSdk_Example
//
//  Created by nithin.g on 17/04/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNTestDevicesManager : NSObject

+ (instancetype)getSharedInstance;
- (void)addDeviceId:(NSString *)deviceId;
- (NSArray<NSString *> *)getTestDeviceIds;

@end
