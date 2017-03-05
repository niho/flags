//
//  MasterViewController.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NHARequest.h"
#import "NHACountriesDecoder.h"
#import "NHACountry.h"

@interface MasterViewController () <NHARequestDelegate>
@property NHARequest *request;
@property NSArray<NSArray<NHACountry *> *> *sections;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSURL *URL = [NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"];
    NHACountriesDecoder *decoder = [[NHACountriesDecoder alloc] init];
    self.request = [[NHARequest alloc] initWithURL:URL andDecoder:decoder];
    self.request.delegate = self;
    [self.request fetch];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


#pragma mark - NHARequestDelegate

- (void)request:(NHARequest *)request didFailWithError:(NSError *)error {
    if (error) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                message:error.localizedRecoverySuggestion
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)request:(NHARequest *)request didCompleteWithResponse:(id)response {
    self.sections = [self sectionsWithCountries:response];
    [self.tableView reloadData];
}


#pragma mark - Sections

- (NSArray<NSArray<NHACountry *> *> *)sectionsWithCountries:(NSArray<NHACountry *> *)countries {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray<NSMutableArray<NHACountry *> *> *sections = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < collation.sectionTitles.count; i++) {
        [sections addObject:[[NSMutableArray alloc] init]];
    }
    
    [[collation sortedArrayFromArray:countries collationStringSelector:@selector(name)] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger section = [collation sectionForObject:obj collationStringSelector:@selector(name)];
        [sections[section] addObject:obj];
    }];
    
    return sections;
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NHACountry *country = self.sections[indexPath.section][indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setCountry:country];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NHACountry *country = self.sections[indexPath.section][indexPath.row];
    cell.textLabel.text = country.name;
    cell.textLabel.textColor = country.flag ? [UIColor darkTextColor] : [UIColor lightGrayColor];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NHACountry *country = self.sections[indexPath.section][indexPath.row];
    return country.flag ? indexPath : nil;
}


#pragma mark - Section headers & Index

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [UILocalizedIndexedCollation currentCollation].sectionTitles[section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [UILocalizedIndexedCollation currentCollation].sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


@end
