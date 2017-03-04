//
//  NHACountry.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHACountry.h"

@implementation NHACountry

- (instancetype)initWithName:(NSString *)name andCode:(NSString *)code {
    assert(name);
    assert(code);
    if (self = [super init]) {
        _name = name;
        _code = code;
    }
    return self;
}

- (UIImage *)flag {
    return [UIImage imageNamed:[self.code lowercaseString]];
}

@end
