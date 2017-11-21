//
//  MNetSampleModelClass.h
//  MNAdSdk
//
//  Created by nithin.g on 02/08/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>

@interface MNetSampleModelClass : NSObject <MNJMMapperProtocol>
@property (nonatomic) NSString *simpleString;
@property (nonatomic) NSArray<MNetBidRequest *> *requestsList;
@property (nonatomic) NSDictionary<NSString *, MNetBidResponse *> *responsesMap;
@property (nonatomic) NSDictionary *extras;
@end
