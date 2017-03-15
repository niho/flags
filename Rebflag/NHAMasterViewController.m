//
//  NHAMasterViewController.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHAMasterViewController.h"
#import "NHADetailViewController.h"
#import "NHASearchResultsViewController.h"
#import "NHARequest.h"
#import "NHACountriesDecoder.h"
#import "NHACountry.h"
#import "NHAIndexedSections.h"

@interface NHAMasterViewController () <NHARequestDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NHASearchResultsDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) NHARequest *request;
@property (nonatomic, strong) NSArray<NHACountry *> *countries;
@property (nonatomic, strong) NHAIndexedSections *sections;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NHASearchResultsViewController *searchResults;
@end

@implementation NHAMasterViewController

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

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
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
    self.sections = [[NHAIndexedSections alloc] initWithArray:response
                                      collationStringSelector:@selector(name)
                                                  indexSearch:YES];
    self.tableView.dataSource = self.sections;
    [self.tableView reloadData];
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
        NHACountry *country = (NHACountry *)[self.sections objectAtIndexPath:indexPath];
        NHADetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        
        [pages setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        pages.title = controller.title;
    }
}


#pragma mark - Table View

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NHACountry *country = (NHACountry *)[self.sections objectAtIndexPath:indexPath];
    return country && country.flag ? indexPath : nil;
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
    [self selectAndShowCountry:country];
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NHADetailViewController *detail = (NHADetailViewController *)viewController;
    if (detail && detail.country) {
        NSUInteger index = [self.countries indexOfObject:detail.country];
        NHACountry *country;
        if (index == 0) {
            country = self.countries.lastObject;
        } else {
            country = self.countries[index - 1];
        }
        NHADetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        return controller;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NHADetailViewController *detail = (NHADetailViewController *)viewController;
    if (detail && detail.country) {
        NSUInteger index = [self.countries indexOfObject:detail.country];
        NHACountry *country;
        if (index == (self.countries.count - 1)) {
            country = self.countries.firstObject;
        } else {
            country = self.countries[index + 1];
        }
        NHADetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Country"];
        [controller setCountry:country];
        return controller;
    }
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    NHADetailViewController *detail = (NHADetailViewController *)[pageViewController viewControllers].firstObject;
    if (detail && detail.country) {
        NSIndexPath *indexPath = [self.sections indexPathForObject:detail.country];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            pageViewController.title = detail.title;
        }
    }
}


#pragma mark - Helpers

- (void)selectAndShowCountry:(NHACountry *)country {
    NSIndexPath *indexPath = [self.sections indexPathForObject:country];
    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self performSegueWithIdentifier:@"showDetail" sender:country];
        [self.searchController setActive:NO];
    }
}


#pragma mark - Motion events

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if (self.countries.count > 0) {
            NSUInteger index = arc4random() % (self.countries.count - 1);
            NHACountry *country = self.countries[index];
            [self selectAndShowCountry:country];
        }
    }
}


@end
