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

@interface MasterViewController () <NHARequestDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NHARequest *request;
@property (nonatomic, strong) NSArray<NHACountry *> *countries;
@property (nonatomic, strong) NSArray<NSArray<NHACountry *> *> *sections;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self setupSearchController];
    [self setupRequest];
}

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)setupRequest {
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
    self.countries = response;
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
    return self.sections ? self.sections.count : 0;
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
    NSMutableArray<NSString *> *titles = [[NSMutableArray alloc] init];
    [titles addObject:UITableViewIndexSearch];
    [titles addObjectsFromArray:[UILocalizedIndexedCollation currentCollation].sectionIndexTitles];
    return titles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if ([title isEqualToString:UITableViewIndexSearch]) {
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return -1;
    }
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *query = searchController.searchBar.text;
    if (query == nil || [query isEqualToString:@""]) {
        self.sections = [self sectionsWithCountries:self.countries];
        [self.tableView reloadData];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@", query];
        NSArray<NHACountry *> *countries = [self.countries filteredArrayUsingPredicate:predicate];
        self.sections = [self sectionsWithCountries:countries];
        [self.tableView reloadData];
    }
}


@end
