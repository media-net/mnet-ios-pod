//
//  MNetSampleModelClass.m
//  MNAdSdk
//
//  Created by nithin.g on 02/08/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "MNetSampleModelClass.h"

@implementation MNetSampleModelClass

- (NSDictionary *)propertyKeyMap{
    return @{
             @"requestsList" : @"requests",
             @"responsesMap" : @"responses"
            };
}

- (NSDictionary<NSString *,MNJMCollectionsInfo *> *)collectionDetailsMap{
    return @{
             @"requestsList": [MNJMCollectionsInfo instanceOfArrayWithClassType:[MNetBidRequest class]],
             @"responsesMap": [MNJMCollectionsInfo instanceOfDictionaryWithKeyType:[NSMutableString class] andValueType:[MNetBidResponse class]],
             };
}

- (NSArray *)directMapForKeys{
    return @[
             @"extras"
             ];
}

@end
