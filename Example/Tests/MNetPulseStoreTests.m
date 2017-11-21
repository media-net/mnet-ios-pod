//
//  MNetPulseStoreTests.m
//  MNAdSdk
//
//  Created by nithin.g on 25/07/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Nocilla/Nocilla.h>
#import <MNetAdSdk/MNetAdSdk-umbrella.h>
#import "MNetTestManager.h"

@interface MNetPulseStoreTests : MNetTestManager<MNetPulseStoreDelegate>
@property MNetPulseStore *pulseStore;
@property MNetPulseStoreLimitType testingType;
@property (nonatomic) XCTestExpectation *pulseStoreLimitExceededExpectation;
@end

@implementation MNetPulseStoreTests
static NSUInteger maxFileSize = 100000;
static NSUInteger maxNumEntries = 3;
static NSUInteger maxTimeInterval = 1800;
static NSUInteger currentNumEntries = 0;

- (void)setUp {
    [super setUp];
    
    self.pulseStore = [MNetPulseStore getSharedInstanceWithDelegate:self];
    [self.pulseStore flushCachedData];
}

- (void)tearDown{
    [MNetPulseStore getSharedInstanceWithDelegate:nil];
    [super tearDown];
}

/*
- (void)testNumEntriesLimit{
    maxFileSize = 100000;
    maxTimeInterval = 1800;
    maxNumEntries = 5;
    currentNumEntries = 10;
    
    self.testingType = kMNetPulseNumEntriesLimit;
    self.pulseStoreLimitExceededExpectation = [self expectationWithDescription:@"Limit exceeded"];
    
    NSUInteger eventCount = currentNumEntries;
    NSArray *rawPulseEvents = [self getEventsListWithSize:eventCount];
    [self.pulseStore addEntries:rawPulseEvents];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testSizeLimit{
    maxFileSize = 20;
    maxTimeInterval = 1800;
    maxNumEntries = 100;
    currentNumEntries = 10;
    
    self.testingType = kMNetPulseFileSizeLimit;
    self.pulseStoreLimitExceededExpectation = [self expectationWithDescription:@"Limit exceeded"];
    
    NSUInteger eventCount = currentNumEntries;
    NSArray *rawPulseEvents = [self getEventsListWithSize:eventCount];
    [self.pulseStore addEntries:rawPulseEvents];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}

- (void)testTimeIntervalLimit{
    maxFileSize = 10000;
    maxTimeInterval = 5;
    maxNumEntries = 100;
    currentNumEntries = 10;
    
    self.testingType = kMNetPulseTimeLimit;
    self.pulseStoreLimitExceededExpectation = [self expectationWithDescription:@"Limit exceeded"];
    
    NSUInteger eventCount = currentNumEntries/2;
    NSArray *rawPulseEvents = [self getEventsListWithSize:eventCount];
    
    [self.pulseStore addEntries:rawPulseEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(maxTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pulseStore addEntries:rawPulseEvents];
    });
    
    [self waitForExpectationsWithTimeout:2*maxTimeInterval handler:^(NSError * _Nullable error) {
        NSLog(@"SAMPLE: testTimeIntervalLimit");
        if(error){
            NSLog(@"Test timed out! - %@", error);
        }
    }];
}
 */

#pragma mark - PulseStore delegates
- (void)limitExceeded:(MNetPulseStoreLimitType)limitExceededType
          withEntries:(NSArray *)entries
{
    NSString *expectedStr = [MNetPulseStore getStringForPulseStoreLimitType:self.testingType];
    NSString *actualStr = [MNetPulseStore getStringForPulseStoreLimitType:limitExceededType];
    
    XCTAssert(limitExceededType == self.testingType, "Expected: %@, Actual: %@", expectedStr, actualStr);
    
    // Testing out the flush method
    NSUInteger actualNumEntries = [self.pulseStore getNumEntries];
    XCTAssert(actualNumEntries == currentNumEntries, @"Expected: %lu, Actual: %lu", (unsigned long)currentNumEntries, (unsigned long)actualNumEntries);
    
    if(self.pulseStoreLimitExceededExpectation){
        EXPECTATION_FULFILL(self.pulseStoreLimitExceededExpectation);
    }
}

- (MNetPulseStoreLimitType)comparatorWithFileSize:(NSUInteger)fileSize
                                       numEntries:(NSUInteger)numEntries
                           andTimeSinceFirstEntry:(NSTimeInterval)timestamp{
    if(fileSize >= maxFileSize){
        return kMNetPulseFileSizeLimit;
    }else if(numEntries >= maxNumEntries){
        return kMNetPulseNumEntriesLimit;
    }else if(timestamp >= maxTimeInterval){
        return kMNetPulseTimeLimit;
    }
    
    return kMNetPulseNone;
}

#pragma mark - Test helpers 
- (NSArray *)getEventsListWithSize:(NSUInteger)eventCount{
    MNetPulseEvent *pulseEvent = [[MNetPulseEvent alloc] initWithMessage:@"Sample message"];
    NSMutableArray<MNetPulseEvent *> *eventsList = [[NSMutableArray alloc] initWithCapacity:eventCount];
    
    for(NSUInteger i=0; i<eventCount; i++){
        [eventsList addObject:pulseEvent];
    }
    
    NSObject *pulseEventsObj = [MNJMManager getCollectionFromObj:eventsList];
    XCTAssert(pulseEventsObj != nil && [pulseEventsObj isKindOfClass:[NSArray class]], @"pulseEventsObj is nil or is not an array");
    NSArray *rawPulseEvents = (NSArray *)pulseEventsObj;
    return rawPulseEvents;
}

@end
