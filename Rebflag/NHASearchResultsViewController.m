//
//  NHASearchResultsViewController.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-06.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHASearchResultsViewController.h"
#import "NHACountry.h"

@interface NHASearchResultsViewController ()

@end

@implementation NHASearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countries ? self.countries.count : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Search results";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NHACountry *country = self.countries[indexPath.row];
    cell.textLabel.text = country.name;
    cell.textLabel.textColor = country.flag ? [UIColor darkTextColor] : [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NHACountry *country = self.countries[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchResults:didSelectCountry:)]) {
        [self.delegate searchResults:self didSelectCountry:country];
    }
}

@end
