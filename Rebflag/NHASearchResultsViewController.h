//
//  NHASearchResultsViewController.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-06.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NHACountry;
@class NHASearchResultsViewController;

@protocol NHASearchResultsDelegate <NSObject>

- (void)searchResults:(NHASearchResultsViewController *)controller
     didSelectCountry:(NHACountry *)country;

@end

@interface NHASearchResultsViewController : UITableViewController

@property (nonatomic, weak) id<NHASearchResultsDelegate> delegate;
@property (nonatomic, strong) NSArray<NHACountry *> *countries;

@end
