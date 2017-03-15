//
//  NHAIndexedSections.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-15.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NHAIndexedSections : NSObject <UITableViewDataSource>

- (nullable instancetype)initWithArray:(nonnull NSArray *)array
               collationStringSelector:(nonnull SEL)selector
                           indexSearch:(BOOL)search NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable NSIndexPath *)indexPathForObject:(nonnull NSObject *)object;
- (nonnull NSObject *)objectAtIndexPath:(nonnull NSIndexPath *)indexPath;


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(nullable UITableView *)tableView;
- (NSInteger)tableView:(nullable UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (nonnull UITableViewCell *)tableView:(nullable UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nullable NSString *)tableView:(nullable UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(nullable UITableView *)tableView;
- (NSInteger)tableView:(nullable UITableView *)tableView sectionForSectionIndexTitle:(nonnull NSString *)title atIndex:(NSInteger)index;

@end
