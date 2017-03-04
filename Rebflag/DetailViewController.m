//
//  DetailViewController.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "DetailViewController.h"
#import "NHACountry.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagView;
@end

@implementation DetailViewController

- (void)configureView {
    if (self.country) {
        self.nameLabel.text = self.country.name;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

#pragma mark - Managing the country

- (void)setCountry:(NHACountry *)country {
    if (_country != country) {
        _country = country;
        
        // Update the view.
        [self configureView];
    }
}

@end
