//
//  NHACountriesDecoderTest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHACountriesDecoder.h"
#import "NHACountry.h"

@interface NHACountriesDecoderTest : XCTestCase
@property NHACountriesDecoder *decoder;
@end

@implementation NHACountriesDecoderTest

- (void)setUp {
    [super setUp];
    self.decoder = [[NHACountriesDecoder alloc] init];
}

- (void)tearDown {
    self.decoder = nil;
    [super tearDown];
}

- (void)testDecode {
    id data = @[ @{@"name":@"Sweden",
                   @"alpha2Code":@"SE"} ];
    NSArray<NHACountry *> *result = [self.decoder decode:data];
    XCTAssert(result);
    XCTAssertEqual(1, result.count);
    XCTAssertEqual(@"Sweden", result[0].name);
    XCTAssertEqual(@"SE", result[0].code);
}

- (void)testValidation {
    XCTAssertThrows([self.decoder decode:@{}]);
    XCTAssertThrows([self.decoder decode:@[@42]]);
    XCTAssertThrows([self.decoder decode:@[@{}]]);
    XCTAssertNoThrow([self.decoder decode:@[]]);
}

@end
