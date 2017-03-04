//
//  DetailViewController.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-02.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NHACountry;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NHACountry *country;

@end

