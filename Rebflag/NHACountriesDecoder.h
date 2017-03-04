//
//  NHACountriesDecoder.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHADecoder.h"

@class NHACountry;

@interface NHACountriesDecoder : NHADecoder

/**
 Decodes a list of NHACountry objects.
 Will throw an exception if the passed object is not an array of countries or
 is mallformed in some way.
 */
- (NSArray<NHACountry *> *)decode:(id)object;

@end
