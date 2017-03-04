//
//  NHACountry.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHACountry : NSObject

/** The name of the country (in english). */
@property (nonnull, nonatomic, strong, readonly) NSString *name;

/** The ISO 3166-1 alpha-2 country code. */
@property (nonnull, nonatomic, strong, readonly) NSString *code;

/** Initialize a country object by specifing a name and country code. */
- (nullable instancetype)initWithName:(nonnull NSString *)name
                              andCode:(nonnull NSString *)code NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
