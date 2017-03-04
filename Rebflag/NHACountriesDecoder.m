//
//  NHACountriesDecoder.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHACountriesDecoder.h"
#import "NHACountry.h"

@implementation NHACountriesDecoder

- (NSArray<NHACountry *> *)decode:(id)object {
    return [self decodeArray:object itemDecoder:^id(id object) {
        return [self decodeCountry:object];
    }];
}

- (NHACountry *)decodeCountry:(id)object {
    NSDictionary *dict = [self decodeDictionary:object];
    NSString *name = [self decodeString:[dict valueForKey:@"name"] allowEmpty:NO];
    NSString *code = [self decodeString:[dict valueForKey:@"alpha2Code"] allowEmpty:NO];
    NHACountry *country = [[NHACountry alloc] initWithName:name
                                                   andCode:code];
    if (country) {
        return country;
    } else {
        NSException* e = [NSException
                          exceptionWithName:@"NHADecodeCountryException"
                          reason:@"Failed to decode country."
                          userInfo:nil];
        @throw e;
    }
}

@end
