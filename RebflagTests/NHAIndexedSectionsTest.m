//
//  NHAIndexedSectionsTest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-15.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHAIndexedSections.h"

@interface NHAIndexedSectionsTest : XCTestCase
@property NHAIndexedSections *sections;
@end

@implementation NHAIndexedSectionsTest

- (void)setUp {
    [super setUp];
    self.sections = [[NHAIndexedSections alloc] initWithArray:@[@"Btest",@"Atest",@"Atest2"]
                                      collationStringSelector:@selector(uppercaseString)
                                                  indexSearch:YES];
}

- (void)tearDown {
    self.sections = nil;
    [super tearDown];
}

- (void)testIndexPathForObject {
    XCTAssertNil([self.sections indexPathForObject:@"X"]);
    XCTAssertEqual([self.sections indexPathForObject:@"Atest"].section, 0);
    XCTAssertEqual([self.sections indexPathForObject:@"Atest2"].section, 0);
    XCTAssertEqual([self.sections indexPathForObject:@"Atest2"].row, 1);
    XCTAssertEqual([self.sections indexPathForObject:@"Btest"].section, 1);
}

- (void)testObjectAtIndexPath {
    XCTAssertEqual([self.sections objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"Atest");
    XCTAssertEqual([self.sections objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"Btest");
}

@end
