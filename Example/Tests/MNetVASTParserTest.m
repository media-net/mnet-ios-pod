//
//  MNetVASTParserTest.m
//  MNAdSdk
//
//  Created by kunal.ch on 24/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MNetAdSdk/MNetVast.h>
#import <MNetAdSdk/MNetVastAdXMLManager.h>
#import <MNetAdSdk/MNetVASTVideoConfig.h>
#import "MNetTestManager.h"

static const NSTimeInterval mDefaultTimeout = 1;

@interface MNetVASTParserTest : MNetTestManager

@end

@implementation MNetVASTParserTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testMediaFileFromWrapper {
    XCTestExpectation *expectaion = [self expectationWithDescription:@"fetching data from XML"];
    
    __block NSData *vastData = [self dataFromXMLFileNamed:@"vast-linear" class:[self class]];
    __block MNetVast *vastResponse;
    
    MNetVastAdXmlManager *xmlManager = [[MNetVastAdXmlManager alloc] init];
    [xmlManager parseXMLFromDataWithCompletion:vastData completion:^(MNetVast *response,NSError *error){
        XCTAssert(error == nil);
        vastResponse = response;
        [expectaion fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:mDefaultTimeout handler:^(NSError * _Nullable error){
        XCTAssert(error == nil);
    }];
    
    MNetVASTVideoConfig *videoConfig = [[MNetVASTVideoConfig alloc] initWithVASTResponse:vastResponse];
    XCTAssertTrue([videoConfig.mediaURL.absoluteString isEqualToString:[MNetTestManager getVideoUrl]]);
}

- (void)testVastLinearInlineMediafile{
    XCTestExpectation *expectaion = [self expectationWithDescription:@"fetching data from XML"];
    
    __block NSData *vastData = [self dataFromXMLFileNamed:@"vast-linear-inline" class:[self class]];
    __block MNetVast *vastResponse;
    
    MNetVastAdXmlManager *xmlManager = [[MNetVastAdXmlManager alloc] init];
    [xmlManager parseXMLFromDataWithCompletion:vastData completion:^(MNetVast *response,NSError *error){
        XCTAssert(error == nil);
        vastResponse = response;
        [expectaion fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:mDefaultTimeout handler:^(NSError * _Nullable error){
        XCTAssert(error == nil);
    }];
    
    MNetVASTVideoConfig *videoConfig = [[MNetVASTVideoConfig alloc] initWithVASTResponse:vastResponse];
    XCTAssertTrue([videoConfig.mediaURL.absoluteString isEqualToString:@"http://cdnp.tremormedia.com/video/acudeo/Carrot_400x300_500kb.flv"]);
}

- (void)testVASTWrapperLinear{
    XCTestExpectation *expectaion = [self expectationWithDescription:@"fetching data from XML"];
    
    __block NSData *vastData = [self dataFromXMLFileNamed:@"vast-wrapper-linear" class:[self class]];
    __block MNetVast *vastResponse;
    
    MNetVastAdXmlManager *xmlManager = [[MNetVastAdXmlManager alloc] init];
    //[[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding]
    [xmlManager parseXMLFromStringWithCompletion:[[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding] completion:^(MNetVast *response,NSError *error){
        XCTAssert(error == nil);
        vastResponse = response;
        [expectaion fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error){
        XCTAssert(error == nil);
    }];
    
    MNetVASTVideoConfig *videoConfig = [[MNetVASTVideoConfig alloc] initWithVASTResponse:vastResponse];
    XCTAssertTrue([videoConfig.mediaURL.absoluteString isEqualToString:@"http://cdnp.tremormedia.com/video/acudeo/Carrot_400x300_500kb.flv"]);
}

- (void)testVASTMultipleWrappers{
    stubVASTRequest([self class]);
    XCTestExpectation *expectaion = [self expectationWithDescription:@"fetching data from XML"];
    
    __block NSData *vastData = [self dataFromXMLFileNamed:@"vast-multi-wrapper" class:[self class]];
    __block MNetVast *vastResponse;
    
    MNetVastAdXmlManager *xmlManager = [[MNetVastAdXmlManager alloc] init];
    [xmlManager parseXMLFromStringWithCompletion:[[NSString alloc] initWithData:vastData encoding:NSUTF8StringEncoding] completion:^(MNetVast *response,NSError *error){
        XCTAssert(error == nil);
        vastResponse = response;
        [expectaion fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError * _Nullable error){
        XCTAssert(error == nil);
    }];
    
    MNetVASTVideoConfig *videoConfig = [[MNetVASTVideoConfig alloc] initWithVASTResponse:vastResponse];
    XCTAssertTrue([videoConfig.mediaURL.absoluteString isEqualToString:@"http://cdnp.tremormedia.com/video/acudeo/Carrot_400x300_500kb.flv"]);
}

-(NSData *) dataFromXMLFileNamed : (NSString *) name class : (Class) aClass {
    NSString *file = [[NSBundle bundleForClass:[aClass class]] pathForResource:name ofType:@"xml"];
    return [NSData dataWithContentsOfFile:file];
}
@end
