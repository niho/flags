//
//  NHACountryTest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHACountry.h"

@interface NHACountryTest : XCTestCase
@property NHACountry *country;
@end

@implementation NHACountryTest

- (void)setUp {
    [super setUp];
    self.country = [[NHACountry alloc] initWithName:@"Sweden"
                                            andCode:@"SE"];
}

- (void)tearDown {
    self.country = nil;
    [super tearDown];
}

- (void)testCountryWithNameAndCode {
    XCTAssertEqual(@"Sweden", self.country.name);
    XCTAssertEqual(@"SE", self.country.code);
}

- (void)testFlag {
    XCTAssert(self.country.flag);
}

@end
