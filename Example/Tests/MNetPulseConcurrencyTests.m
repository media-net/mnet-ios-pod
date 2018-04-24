//
//  MNetPulseConcurrencyTests.m
//  MNAdSdk_Tests
//
//  Created by nithin.g on 24/04/18.
//  Copyright © 2018 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MNetTestManager.h"

@interface MNetPulseConcurrencyTests : XCTestCase <MNetPulseStoreDelegate>
@property (atomic) XCTestExpectation *expectation;
@property (atomic) MNetPulseHttp *pulseHttpObj;
@end

@implementation MNetPulseConcurrencyTests

- (void)updateConfig{
    [[[MNetSdkConfig getInstance] getSdkConfigData] setPulseMaxArrLen:limitPulseEvents];
    [[[MNetSdkConfig getInstance] getSdkConfigData] setPulseMaxSize:100000];
    [[[MNetSdkConfig getInstance] getSdkConfigData] setPulseMaxTimeInterval:100000];
}

static NSUInteger limitPulseEvents = 50;
- (void)testPulseConcurrency {
    
    self.pulseHttpObj = [MNetPulseHttp getSharedInstance];
    
    MNetPulseStore *pulseStore = [MNetPulseStore getSharedInstanceWithDelegate:self];
    [pulseStore setCachedData:[[MNetPulseStoreData alloc] init]];
    
    [self.pulseHttpObj setPulseStore:pulseStore];
    
    self.expectation = [self expectationWithDescription:@""];
    // running events in async
    for(int i=0; i<limitPulseEvents; i++){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MNetPulseEvent *pulseEvent = [[MNetPulseEvent alloc] initWithType:@"sample-type"
                                     withSubType:@"sub-type"
                                     withMessage:@"message"
                                   andCustomData:@{
                                                   @"sample-key-1":@"sample-val-1",
                                                   }];
            [self.pulseHttpObj logEvent:pulseEvent];
        });
    }
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error - %@", error);
        }
        EXPECTATION_FULFILL(self.expectation);
    }];
}

- (MNetPulseStoreLimitType)comparatorWithFileSize:(NSUInteger)fileSize
                                       numEntries:(NSUInteger)numEntries
                           andTimeSinceFirstEntry:(NSTimeInterval)timestamp
{
    [self updateConfig];
    return [self.pulseHttpObj comparatorWithFileSize:fileSize
                                          numEntries:numEntries
                              andTimeSinceFirstEntry:timestamp];
}

- (void)limitExceeded:(MNetPulseStoreLimitType)limitExceededType withEntries:(NSArray<NSData *> *)entries{
    XCTAssert([entries count] == limitPulseEvents, @"Expected - %lu, got - %lu", limitPulseEvents, (unsigned long)[entries count]);
    
    // Verify that the data is not empty
    NSMutableArray<MNetPulseEvent *> *pulseEventsList = [[NSMutableArray<MNetPulseEvent *> alloc] init];
    for (NSData *pulseData in entries) {
        @try {
            MNetPulseEvent *pulseEvent = [NSKeyedUnarchiver unarchiveObjectWithData:pulseData];
            XCTAssert(pulseEvent != nil, @"pulse-event cannot be nil");
            XCTAssert([pulseEvent eventObj] != nil, @"pulse-event-obj cannot be nil");
            [pulseEventsList addObject:pulseEvent];
        } @catch (NSException *e) {
            MNLogD(@"PULSE: Exception when unarchiving data");
        }
    }
    
    EXPECTATION_FULFILL(self.expectation);
}

@end
