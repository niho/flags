//
//  NHADecoder.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NHADecoder : NSObject

/**
 Decode an object. The implementation provided in this base class will
 simply pass-through the object as it is. When subclassing you should override
 this method to offer a real decode of the object.
 */
- (nonnull id)decode:(nullable id)object;

/**
 Decodes an array.
 Will throw an exception if the passed object is not an NSArray.
 */
- (nonnull NSArray *)decodeArray:(nullable id)object;

/**
 Decodes an array and executes the itemDecoder block for each item in the block.
 This method is usefull for decoding an array *and* its content in a single step.
 Will throw an exception if the passed object is not an NSArray.
 */
- (nonnull NSArray *)decodeArray:(nullable id)object itemDecoder:(_Nonnull id ( ^ _Nonnull )(_Nullable id object))block;

/**
 Decodes a dictionary.
 Will throw an exception if the passed object is not an NSDictionary.
 */
- (nonnull NSDictionary *)decodeDictionary:(nullable id)object;

/**
 Decodes a string.
 Will throw an exception if the passed object is not an NSString.
 */
- (nonnull NSString *)decodeString:(nullable id)object;

/**
 Decodes a string and checks if it is empty or not.
 Will throw an exception if the passed object is not an NSString or if the
 string is empty (when allowEmpty is NO).
 */
- (nonnull NSString *)decodeString:(nullable id)object allowEmpty:(BOOL)allowEmpty;

@end
