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
@property NSArray<NHACountry *> *countries;
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
    self.countries = response;
    [self.tableView reloadData];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NHACountry *country = self.countries[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setCountry:country];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NHACountry *country = self.countries[indexPath.row];
    cell.textLabel.text = country.name;
    return cell;
}


@end
