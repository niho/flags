//
//  NHACountriesTest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHARequest.h"
#import "NHACountriesDecoder.h"

@interface NHARequestTest : XCTestCase <NHARequestDelegate>
{
    NHARequest *_request;
    id _response;
    XCTestExpectation *_fetchExpectation;
}
@end

@implementation NHARequestTest

- (void)setUp {
    [super setUp];
    NSURL *URL = [NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"];
    NHADecoder *decoder = [[NHADecoder alloc] init];
    _request = [[NHARequest alloc] initWithURL:URL andDecoder:decoder];
    _request.delegate = self;
}

- (void)tearDown {
    _request.delegate = nil;
    _request = nil;
    [super tearDown];
}

- (void)testFetch {
    _fetchExpectation = [self expectationWithDescription:@"- fetch"];
    [_request fetch];
    [self waitForExpectationsWithTimeout:5.0f handler:^(NSError * _Nullable error) {
        XCTAssert(_response);
    }];
}

#pragma mark - NHARequestDelegate

- (void)request:(NHARequest *)request didCompleteWithResponse:(id)response {
    _response = response;
    [_fetchExpectation fulfill];
}

- (void)request:(NHARequest *)request didFailWithError:(NSError *)error {
    XCTFail(@"%@", error ? error.localizedDescription :
            @"Failed to fetch request. Unkown error.");
}

@end
