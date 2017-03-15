//
//  NHAIndexedSections.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-15.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHAIndexedSections.h"

@interface NHAIndexedSections ()
@property (nonatomic, strong) NSArray<NSArray<NSObject *> *> *sections;
@property (nonatomic, assign) SEL collationSelector;
@property (nonatomic, assign) BOOL indexSearch;
@end

@implementation NHAIndexedSections

- (instancetype)initWithArray:(NSArray *)array
      collationStringSelector:(SEL)selector
                  indexSearch:(BOOL)search {
    if (self = [super init]) {
        _sections = [self sectionsFromArray:array
                    collationStringSelector:selector];
        _collationSelector = selector;
        _indexSearch = search;
    }
    return self;
}

#pragma mark - Sections

- (NSArray *)sortedArrayFromArray:(NSArray *)countries
          collationStringSelector:(SEL)selector {
    return [[UILocalizedIndexedCollation currentCollation]
            sortedArrayFromArray:countries
            collationStringSelector:selector];
}

- (NSArray<NSArray *> *)sectionsFromArray:(NSArray *)array
                  collationStringSelector:(SEL)selector {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray<NSMutableArray *> *sections = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < collation.sectionTitles.count; i++) {
        [sections addObject:[[NSMutableArray alloc] init]];
    }
    
    [[self sortedArrayFromArray:array collationStringSelector:selector]
     enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger section = [collation sectionForObject:obj
                                collationStringSelector:selector];
        [sections[section] addObject:obj];
    }];
    
    return sections;
}

#pragma mark - Helpers

- (NSIndexPath *)indexPathForObject:(NSObject *)object {
    for (int section = 0; section < self.sections.count; section++) {
        for (int row = 0; row < self.sections[section].count; row++) {
            if (self.sections[section][row] == object) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

- (NSObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.sections[indexPath.section][indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections ? self.sections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSObject *object = [self objectAtIndexPath:indexPath];
    cell.textLabel.text = (NSString *)[object performSelector:self.collationSelector];
    //cell.textLabel.textColor = country.flag ? [UIColor darkTextColor] : [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Section headers & Index

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [UILocalizedIndexedCollation currentCollation].sectionTitles[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray<NSString *> *titles = [[NSMutableArray alloc] init];
    if (self.indexSearch) {
        [titles addObject:UITableViewIndexSearch];
    }
    [titles addObjectsFromArray:[UILocalizedIndexedCollation currentCollation].sectionIndexTitles];
    return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.indexSearch && [title isEqualToString:UITableViewIndexSearch]) {
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return -1;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

@end
