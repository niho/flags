//
//  NHADecoderTest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHADecoder.h"

@interface NHADecoderTest : XCTestCase
@property NHADecoder *decoder;
@end

@implementation NHADecoderTest

- (void)setUp {
    [super setUp];
    self.decoder = [[NHADecoder alloc] init];
}

- (void)tearDown {
    self.decoder = nil;
    [super tearDown];
}

- (void)testArray {
    XCTAssertNoThrow([self.decoder decodeArray:@[]]);
    XCTAssertThrows([self.decoder decodeArray:nil]);
}

- (void)testDictionary {
    XCTAssertNoThrow([self.decoder decodeDictionary:@{}]);
    XCTAssertThrows([self.decoder decodeDictionary:nil]);
}

- (void)testString {
    XCTAssertNoThrow([self.decoder decodeString:@""]);
    XCTAssertNoThrow([self.decoder decodeString:@"" allowEmpty:YES]);
    XCTAssertNoThrow([self.decoder decodeString:@"x" allowEmpty:NO]);
    XCTAssertThrows([self.decoder decodeString:nil]);
    XCTAssertThrows([self.decoder decodeString:@"" allowEmpty:NO]);
}

@end
