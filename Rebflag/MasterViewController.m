//
//  MasterViewController.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NHASearchResultsViewController.h"
#import "NHARequest.h"
#import "NHACountriesDecoder.h"
#import "NHACountry.h"

@interface MasterViewController () <NHARequestDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NHASearchResultsDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) NHARequest *request;
@property (nonatomic, strong) NSArray<NHACountry *> *countries;
@property (nonatomic, strong) NSArray<NSArray<NHACountry *> *> *sections;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NHASearchResultsViewController *searchResults;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPagesController];
    [self setupSearchController];
    [self setupRequest];
}

- (void)setupPagesController {
    UIPageViewController *controller = (UIPageViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    controller.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupSearchController {
    self.searchResults = [[NHASearchResultsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.searchResults.delegate = self;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResults];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)setupRequest {
    NSURL *URL = [NSURL URLWithString:@"https://restcountries.eu/rest/v2/all"];
    NHACountriesDecoder *decoder = [[NHACountriesDecoder alloc] init];
    self.request = [[NHARequest alloc] initWithURL:URL andDecoder:decoder];
    self.request.delegate = self;
    [self.request start];
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
    self.countries = [self sortedArrayWithCountries:response];
    self.sections = [self sectionsWithCountries:self.countries];
    [self.tableView reloadData];
}


#pragma mark - Sections

- (NSArray<NHACountry *> *)sortedArrayWithCountries:(NSArray<NHACountry *> *)countries {
    return [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:countries collationStringSelector:@selector(name)];
}

- (NSArray<NSArray<NHACountry *> *> *)sectionsWithCountries:(NSArray<NHACountry *> *)countries {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray<NSMutableArray<NHACountry *> *> *sections = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < collation.sectionTitles.count; i++) {
        [sections addObject:[[NSMutableArray alloc] init]];
    }
    
    [countries enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger section = [collation sectionForObject:obj collationStringSelector:@selector(name)];
        [sections[section] addObject:obj];
    }];
    
    return sections;
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        UIPageViewController *pages = (UIPageViewController *)[[segue destinationViewController] topViewController];
        pages.dataSource = self;
        pages.delegate = self;
        pages.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        pages.navigationItem.leftItemsSupplementBackButton = YES;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NHACountry *country = self.sections[indexPath.section][indexPath.row];
        DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        
        [pages setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        pages.title = controller.title;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@", query];
    self.searchResults.countries = [self.countries filteredArrayUsingPredicate:predicate];
    [self.searchResults.tableView reloadData];
}


#pragma mark - NHASearchResultsDelegate

- (void)searchResults:(NHASearchResultsViewController *)controller didSelectCountry:(NHACountry *)country {
    NSIndexPath *indexPath = [self indexPathForCountry:country];
    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self performSegueWithIdentifier:@"showDetail" sender:country];
        [self.searchController setActive:NO];
    }
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    DetailViewController *detail = (DetailViewController *)viewController;
    if (detail && detail.country) {
        NSUInteger index = [self.countries indexOfObject:detail.country];
        NHACountry *country;
        if (index == 0) {
            country = self.countries.lastObject;
        } else {
            country = self.countries[index - 1];
        }
        DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        return controller;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    DetailViewController *detail = (DetailViewController *)viewController;
    if (detail && detail.country) {
        NSUInteger index = [self.countries indexOfObject:detail.country];
        NHACountry *country;
        if (index == (self.countries.count - 1)) {
            country = self.countries.firstObject;
        } else {
            country = self.countries[index + 1];
        }
        DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        return controller;
    }
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    DetailViewController *detail = (DetailViewController *)[pageViewController viewControllers].firstObject;
    if (detail && detail.country) {
        NSIndexPath *indexPath = [self indexPathForCountry:detail.country];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            pageViewController.title = detail.title;
        }
    }
}


#pragma mark - Helpers

- (NSIndexPath *)indexPathForCountry:(NHACountry *)country {
    for (int section = 0; section < self.sections.count; section++) {
        for (int row = 0; row < self.sections[section].count; row++) {
            if (self.sections[section][row] == country) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}


@end
