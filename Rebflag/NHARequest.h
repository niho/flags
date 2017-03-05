//
//  NHARequest.h
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NHARequest;
@class NHADecoder;


#pragma mark - NHARequestDelegate

@protocol NHARequestDelegate <NSObject>

/** Called when a fetch operation completes successfully. */
- (void)request:(nonnull NHARequest *)request didCompleteWithResponse:(nonnull id)response;

/** Called when a fetch operation fails. */
- (void)request:(nonnull NHARequest *)request didFailWithError:(nullable NSError *)error;

@end


#pragma mark - NHARequest

@interface NHARequest : NSObject

/** The object that acts as the delegate for the request.  */
@property (nullable, nonatomic, weak) id<NHARequestDelegate> delegate;

/**
 The designated initializer. Initializes and returns a request object that
 will fetch an object from the provided URL and use the specified decoder
 to materialize a data structure from the response.
 */
- (nullable instancetype)initWithURL:(nonnull NSURL *)URL
                          andDecoder:(nonnull NHADecoder *)decoder NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Perform the request.
 */
- (void)fetch;

@end
