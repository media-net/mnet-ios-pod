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
@property (nonatomic) NSString *name;

/// The currency type of the reward in string
@property (nonatomic) NSString *currency;

/// The amount of the reward
@property (nonatomic) int amount;

/// Initialise the reward
-(instancetype) initWith:(NSString *)name withCurrency:(NSString *)currency withAmount:(int)amount;
@end
