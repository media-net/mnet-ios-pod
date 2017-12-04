//
//  MNetReward.h
//  Pods
//
//  Created by kunal.ch on 17/04/17.
//
//

#import <Foundation/Foundation.h>

/// The class that describes the reward of the rewarded video
@interface MNetReward : NSObject

/// The name of the reward
@property (nonatomic, nullable) NSString *name;

/// The currency type of the reward in string
@property (nonatomic, nullable) NSString *currency;

/// The amount of the reward
@property (nonatomic) NSNumber *amount;

/// Initialise the reward
-(instancetype _Nonnull) initWith:(NSString * _Nullable)name withCurrency:(NSString * _Nullable)currency withAmount:(NSNumber *)amount;
@end
