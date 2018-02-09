//
//  MNetURL.h
//  Pods
//
//  Created by nithin.g on 26/07/17.
//
//

#import <Foundation/Foundation.h>

@interface MNetURL : NSObject
@property (nonatomic) BOOL isHttpAllowed;

+ (instancetype)getSharedInstance;

- (NSString *)getBaseUrl;
- (NSString *)getBaseConfigUrl;
- (NSString *)getBasePulseUrl;
- (NSString *)getBaseResourceUrl;

- (NSString *)getLatencyTestUrl;
- (NSString *)getAdLoaderPredictBidsUrl;
- (NSString *)getAdLoaderPrefetchPredictBidsUrl;

- (NSString *)getConfigUrl;
- (NSString *)getPulseUrl;
- (NSString *)getFingerPrintUrl;
- (NSString *)getAuctionLoggerUrl;

@end
