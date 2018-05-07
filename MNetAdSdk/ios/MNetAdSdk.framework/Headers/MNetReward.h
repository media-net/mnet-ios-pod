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
@property (atomic, nonnull) NSString *name;

/// The currency type of the reward in string
@property (atomic, nonnull) NSString *currency;

/// The amount of the reward
@property (atomic, nonnull) NSNumber *amount;

/// Initialise the reward
- (instancetype _Nonnull)initWith:(NSString *_Nonnull)name
                     withCurrency:(NSString *_Nonnull)currency
                       withAmount:(NSNumber *_Nonnull)amount;
@end
