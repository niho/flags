//
//  NHADecoder.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHADecoder.h"

@implementation NHADecoder

- (id)decode:(id)object {
    return object;
}

- (NSArray *)decodeArray:(id)object {
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    } else {
        NSException* e = [NSException
                          exceptionWithName:@"NHADecodeArrayException"
                          reason:@"Failed to decode array."
                          userInfo:nil];
        @throw e;
    }
}

- (NSArray *)decodeArray:(id)object itemDecoder:(id (^)(id object))block {
    NSArray *array = [self decodeArray:object];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [newArray addObject:block(obj)];
    }];
    return newArray;
}

- (NSDictionary *)decodeDictionary:(id)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        return object;
    } else {
        NSException* e = [NSException
                          exceptionWithName:@"NHADecodeDictionaryException"
                          reason:@"Failed to decode dictionary."
                          userInfo:nil];
        @throw e;
    }
}

- (NSString *)decodeString:(id)object {
    return [self decodeString:object allowEmpty:YES];
}

- (NSString *)decodeString:(id)object allowEmpty:(BOOL)allowEmpty {
    if ([object isKindOfClass:[NSString class]] && (allowEmpty == YES || [object length] != 0)) {
        return object;
    } else {
        NSException* e = [NSException
                          exceptionWithName:@"NHADecodeStringException"
                          reason:@"Failed to decode string."
                          userInfo:nil];
        @throw e;
    }
}

@end
