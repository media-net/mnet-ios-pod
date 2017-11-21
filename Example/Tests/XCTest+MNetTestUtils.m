//
//  XCTest+MNetTestUtils.m
//  MNAdSdk
//
//  Created by nithin.g on 25/04/17.
//  Copyright © 2017 Nithin. All rights reserved.
//

#import "XCTest+MNetTestUtils.h"
#import "Nocilla.h"
#import "MNDemoConstants.h"
#import <MNetAdSdk/MNetAdSdk-umbrella.h>

@implementation XCTest (MNetTestUtils)

void dummyStubGoogleAds() {
    stubRequest(@"GET", @"https://.*?google.*".regex).andReturn(200);
}

void dummyStubPulseRequest() {
    NSString *pulseResp = @"{\"data\": {},\"message\": \"\",\"success\": true}";
    stubRequest(@"POST", [[MNetURL getSharedInstance] getPulseUrl]).andReturn(200).withBody(pulseResp);
}

void dummyBugsnagRequest(){
    stubRequest(@"POST", @"https://.*?bugsnag.*".regex).andReturn(200);
}

void dummyStubQSearch(){
    stubRequest(@"GET", @"http://qsearch.media.net.*".regex).andReturn(200);
    stubRequest(@"POST", @"http://qsearch.media.net.*".regex).andReturn(200);
}

void dummyStubFingerPrint(){
    NSString *fingerPrintContents = @"{\"uid\":\"dummy-finger-print\"}";
    stubRequest(@"POST", @"http://.*?fingerprint".regex).andReturn(200).withBody(fingerPrintContents);
}

void dummyStubConfigRequest(Class classFile){
    NSString *configContents = readFile(classFile, FILENAME_CONFIG_FILE, @"json");
    
    NSString *configUrl = [NSString stringWithFormat:@"%@.*", [[MNetURL getSharedInstance] getConfigUrl]];
    stubRequest(@"GET", configUrl.regex).andReturn(200).withBody(configContents);
}

void validBannerAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_BANNER_320x50, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
}

void validVideoAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_VIDEO_320x250, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
}

void validRewardedVideoAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_REWARDED_VIDEO, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
}

void invalidVideoAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, INVALID_FILENAME_VIDEO, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);    
}

void validInterstitialAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_BANNER_300x250, @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
}

void dummyStubLoader(){
    /*
     NOTE:
     Not adding a response body (in this case, an image), since we are only stubbing the unit tests
     */
    stubRequest(@"GET", @"https://s3-us-west-2\\.amazonaws\\.com/mnet-((android)|(ios))-resources/.*\\.png".regex).
    withHeaders(@{ @"Accept": @"image/*" }).andReturn(200);
}

void validAdxAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_ADX_BANNER, @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
}

void noAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, @"noAdResponse", @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
}

NSString* readFile(Class classFile, NSString *resourceName, NSString *resourceType) {
    NSString *file = [[NSBundle bundleForClass:classFile]
                      pathForResource:resourceName 
                      ofType:resourceType];
    
    if(!file || [file isEqualToString:@""]){
        return @"";
    }
    
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSString *respStr= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return respStr;
}

void updateSdkInfo(Class className){
    [MNet getInstance].customerId = DEMO_MN_CUSTOMER_ID;
    
    MNetConfig *mnetConfig = [[MNetConfig alloc] init];
    NSString *resourceName = @"MNetSdkConfigResponse";
    NSString *responseDataStr = readFile(className, resourceName, @"json");
    
    NSData *data = [responseDataStr dataUsingEncoding:NSUTF8StringEncoding];
    id responseDataObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSDictionary *responseData = [responseDataObj objectForKey:@"data"];
    
    [MNJMManager fromDict:responseData toObject:mnetConfig];
    
    NSDictionary *extConfig = [mnetConfig getConfig];
    [[MNetSdkConfig getInstance] __updateConfigExternally:extConfig];
}

void stubPrefetchReq(Class className){
    NSString *respStr = readFile(className, @"MNetPredictBidsRelayResponse", @"json");
    
    NSString *requestUrl = @"http://.*?prefetch_predicted_bids.*";
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
}

void stubAuctionLoggerRequest(){
    stubRequest(@"GET", @"http://staging.d.msas.media.net/api/v2/rtb/logs.+".regex).andReturn(200).withBody(@"{\"success\":true, \"data\":{}}");
}


void stubifyRequests(Class className){
    dummyStubGoogleAds();
    dummyStubLoader();
    dummyBugsnagRequest();
    dummyStubPulseRequest();
    dummyStubQSearch();
    dummyStubConfigRequest(className);
    dummyStubFingerPrint();
    stubAuctionLoggerRequest();
    stubPrefetchReq(className);
}

void customSetupWithClass(Class className){
    stubifyRequests(className);
    updateSdkInfo(className);
}

@end
