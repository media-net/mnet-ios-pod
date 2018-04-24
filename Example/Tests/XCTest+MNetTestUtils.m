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

static NSString *adUrlDummyUrl = @"http://dummy-ad-url.com";
static NSString *dummyAdCode = @"<script type='text/javascript' src='http://ad-e1.media6degrees.com/adserv/csv2?tIdx3DD2473504862069428x7CDpricex3DDAAABWkZNHj7wapKf0tO-7IYRJ4UfG0bT0gIABgx7CDdIdsx3DDChEIFhINMWliNm0wcmtxZ3hxZw==x7CDblInfox3DDEi0I8IABEBcY2wYgrlYqCTUzNzEwMDE4ODIJNTM3MTAwMTg4OgBCA1dFQkoCYWQaJQoRYWVxMTA0Mi5lcS5wbC5wdnQSBDgwODAaCjE2LjExLjEzMjMylwEItMWd1bu0sgQVAADgPxgJIhFhZXExMDQyLmVxLnBsLnB2dCo2CNwJEgwI7v4GEgYzMjB4NTAYhEYg0KUBKKfZGDCCwcwBOMHeAUIJRHN0aWxsZXJ5SOQbUIRGMiQ2NDc0MjY3NC1hNDQ4LTQ3YzktYmZiYS02YWE0OTcyMDVkN2M4AkAFSgJVU1ICTUlY-QNiBTQ4MDkzx7CD' ></script>\n<iframe src='http://us-u.openx.net/w/1.0/pd?plm=5&ph=6a16560a-f6c6-4851-b7b5-0b2c0190166a' width='0' height='0' style='display:none;'></iframe>  <div id='beacon_52792' style='position:absolute;left:0px;top:0px;visibility:hidden;'>\n    <img src='http://rtb-xv.openx.net/win/medianet?p=${AUCTION_PRICE}&t=1fHJpZD01ZDQ2MGEyMy00ZWZiLTRmMzItYmMwZC03YzQwOGE1ZGJiZjl8cnQ9MTQ4NzIzODE0M3xhdWlkPTUzODY2MjMzOXxhdW09RE1JRC5XRUJ8YXVwZj1kaXNwbGF5fHNpZD01MzczMDA3OTV8cHViPTUzNzEwMDE4OHxwYz1VU0R8cmFpZD01NjZiMGY1My0xOWFkLTQxMTMtODZlMy01NzI5ZjM5NjIxNDR8cnM9M3xtd2Y9MHxhaWQ9NTM4MjM5ODA1fHQ9MTJ8YXM9MzIweDUwfGxpZD01Mzc2OTAzMDZ8b2lkPTUzNzA5NjE2MnxwPTg5MHxwcj03Mzl8YXRiPTE3NTB8YWR2PTUzNzA3MzI2NHxhYz1VU0R8cG09UFJJQ0lORy5DUE18bT0xfGFpPTE1MmQwN2IxLWRhNDEtNGM0MC1hZDE4LWZlNzRjMjY5NTM0YXxtYz1VU0R8bXI9MTUxfHBpPTczOXxtdWk9MjhjODFmZDgtNTgxZS00YjgxLWIyZmQtZmZjMzkzZTFlYTMyfG1hPTY0NzQyNjc0LWE0NDgtNDdjOS1iZmJhLTZhYTQ5NzIwNWQ3Y3xtcnQ9MTQ4NzIzODE0M3xtcmM9U1JUX1dPTnxtd2E9NTM3MDczMjY0fG13Ymk9MTkwM3xtd2I9MTc1MHxtYXA9ODkwfGVsZz0xfG1vYz1VU0R8bW9yPTE1MXxtcGM9VVNEfG1wcj03Mzl8bXBmPTE1MHxtbWY9MTUwfG1wbmY9Mjk5fG1tbmY9Mjk5fHBjdj0yMDE2MTIwMXxtbz1PWHxlYz0xMTQ1NDJ8bXB1PTczOXxtY3A9ODkwfGFxdD1ydGJ8bXdjPTUzNzA5NjE2Mnxtd3A9NTM3NjkwMzA2fG13Y3I9NTM4MjM5ODA1fHJubj0xfG13aXM9MXxtd3B0PW9wZW5ydGJfanNvbnx1cj1SVkdRNmdzRldEfGxkPWNvc21vcG9saXRhbmxhc3ZlZ2FzLmNvbQ&c=USD&s=0'/>\n  </div>\n";

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
    stubRequest(@"POST", [[MNetURL getSharedInstance] getFingerPrintUrl]).andReturn(200).withBody(fingerPrintContents);
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
    
    stubRequest(@"GET", @".*".regex).andReturn(200);
}

void validBannerAdUrlRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_BANNER_AD_URL_320x50, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex)
    .andReturn(200)
    .withBody(respStr);
    stubRequest(@"GET", @".*".regex).andReturn(200);
}

void validVideoAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_VIDEO_320x250, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
    stubRequest(@"GET", @".*".regex).andReturn(200);
}

void validRewardedVideoAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_REWARDED_VIDEO, @"json");
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
    stubRequest(@"GET", @".*".regex).andReturn(200);
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
    stubRequest(@"GET", @".*".regex).andReturn(200);
}

void dummyStubLoader(){
    /*
     NOTE:
     Not adding a response body (in this case, an image), since we are only stubbing the unit tests
     */
    NSString *resourceUrlList = [NSString stringWithFormat:@"%@.*", [[MNetURL getSharedInstance] getBaseResourceUrl]];
    stubRequest(@"GET", resourceUrlList.regex).
    withHeaders(@{ @"Accept": @"image/*" }).andReturn(200);
}

void validAdxAdRequestStub(Class classFile){
    NSString *respStr = readFile(classFile, FILENAME_ADX_BANNER, @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPredictBidsUrl];
    NSString *regexStr = [NSString stringWithFormat:@"%@.*",url];
    stubRequest(@"GET", regexStr.regex).andReturn(200).withBody(respStr);
    
    stubRequest(@"GET", @".*".regex).andReturn(200);
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
    [[MNetSdkConfig getInstance] updateConfigExternally:mnetConfig];
}

void stubPrefetchReq(Class className){
    NSString *respStr = readFile(className, @"MNetPredictBidsRelayResponse", @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPrefetchPredictBidsUrl];
    NSString *requestUrl = [NSString stringWithFormat:@"%@.*", url];
    
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
}

void noAdsStubPrefetchReq(Class className){
    NSString *respStr = readFile(className, @"noAdResponse", @"json");
    
    NSString *url = [[MNetURL getSharedInstance] getAdLoaderPrefetchPredictBidsUrl];
    NSString *requestUrl = [NSString stringWithFormat:@"%@.*", url];
    
    stubRequest(@"GET", requestUrl.regex).andReturn(200).withBody(respStr);
}

void stubAuctionLoggerRequest(){
    NSString *auctionUrl = [[MNetURL getSharedInstance] getAuctionLoggerUrl];
    stubRequest(@"GET", [NSString stringWithFormat:@"%@.+", auctionUrl].regex).andReturn(200).withBody(@"{\"success\":true, \"data\":{}}");
}

void stubAdUrlRequest(){
    stubRequest(@"GET", adUrlDummyUrl).andReturn(200).withBody(dummyAdCode);
}

void stubVASTRequest(Class className){
    NSString *url = @"http://demo.tremormedia.com/proddev/vast/vast_inline_linear.xml";
    NSString *respStr = readFile(className, @"vast-linear-inline", @"xml");
    stubRequest(@"GET", url).andReturn(200).withBody(respStr);
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
    stubAdUrlRequest();
    stubVASTRequest(className);
}

void customSetupWithClass(Class className){
    stubifyRequests(className);
    updateSdkInfo(className);
    [[MNetPulseHttp getSharedInstance] __stopFromMakingRequestsForTests];
}

@end
