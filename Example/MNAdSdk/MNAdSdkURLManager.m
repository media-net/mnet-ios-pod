//
//  MNAdSdkURLManager.m
//  MNAdSdk_Example
//
//  Created by kunal.ch on 07/02/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import "MNAdSdkURLManager.h"
#import "MNDemoConstants.h"
#ifndef IS_FRAMEWORK
#import <MNetAdSdk/MNetURL+Internal.h>
#endif

static MNAdSdkURLManager *sInstance = nil;
static NSString *kIsProdKey = @"is_prod";

@implementation MNAdSdkURLManager

+ (MNAdSdkURLManager*)getSharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[[self class] alloc] init];
    });
    return sInstance;
}

- (void)initialSetup{
#ifndef IS_FRAMEWORK
    [[MNetURL getSharedInstance] setIsDebug:self.isDebug];
#endif
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _isDebug = [self getIsProdFromUserDefaults] ? NO : YES;
    }
    return self;
}

- (NSString *)getSdkBaseURL{
#ifndef IS_FRAMEWORK
    return [self removeHttpFromString:[[MNetURL getSharedInstance] getBaseUrlDp]];
#else
    return @"";
#endif
}

- (NSString *)getSdkPulseBaseURL{
#ifndef IS_FRAMEWORK
    return [self removeHttpFromString:[[MNetURL getSharedInstance] getBasePulseUrl]];
#else
    return @"";
#endif
}

- (NSString *)getSdkConfigBaseURL{
#ifndef IS_FRAMEWORK
    return [self removeHttpFromString:[[MNetURL getSharedInstance] getBaseConfigUrl]];
#else
    return @"";
#endif
}

- (NSString *)getSdkResourceBaseURL{
#ifndef IS_FRAMEWORK
    return [self removeHttpFromString:[[MNetURL getSharedInstance] getBaseResourceUrl]];
#else
    return @"";
#endif
}

- (void)setIsProdUserDefaults:(BOOL)isProd{
#ifndef IS_FRAMEWORK
    [[NSUserDefaults standardUserDefaults] setBool:isProd forKey:kIsProdKey];
    [[MNetURL getSharedInstance] setIsDebug:!isProd];
    self.isDebug = !isProd;
#endif
}

- (BOOL)getIsProdFromUserDefaults{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsProdKey];
}

- (NSString *)removeHttpFromString:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = url.scheme;
    NSUInteger schemeLength = scheme.length;
    return [urlString substringFromIndex:schemeLength+3];
}

@end
