//
//  RebflagUITests.m
//  RebflagUITests
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface RebflagUITests : XCTestCase

@end

@implementation RebflagUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRussianFederation {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    [self expectationForPredicate:[NSPredicate predicateWithFormat:@"self.count > 0"]
              evaluatedWithObject:app.tables.cells
                          handler:nil];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    [app.tables.cells.staticTexts[@"Russian Federation"] tap];
    
    XCUIElement *russianFederationNavigationBar = app.navigationBars[@"Russian Federation"];
    [russianFederationNavigationBar.buttons[@"Countries"] tap];
}

@end
