//
//  NHARequest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHARequest.h"
#import "NHADecoder.h"

const NSErrorDomain NHARequestErrorDomain = @"NHARequestErrorDomain";
const int NHARequestDeserializationError = -1;

@interface NHARequest ()
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NHADecoder *decoder;
@end

@implementation NHARequest

- (instancetype)initWithURL:(NSURL *)URL andDecoder:(NHADecoder *)decoder {
    assert(URL);
    assert(decoder);
    if (self = [super init]) {
        _request = [NSURLRequest requestWithURL:URL];
        _session = [NSURLSession sharedSession];
        _decoder = decoder;
    }
    return self;
}

- (void)fetch {
    [[self.session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                [self.delegate request:self didFailWithError:error];
            }
        } else {
            @try {
                id object = [self deserialize:data];
                if (object) {
                    id response = [self.decoder decode:object];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
                        [self.delegate request:self didCompleteWithResponse:response];
                    }
                }
            } @catch (NSException *e) {
                [self handleException:e];
            }
        }
    }] resume];
}

- (id)deserialize:(NSData *)data {
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (object == nil || error != nil) {
        [self.delegate request:self didFailWithError:error];
    }
    return object;
}

- (void)handleException:(NSException *)e {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: @"Failed to deserialize response from server.",
        NSLocalizedFailureReasonErrorKey: e.reason
    };
    NSError *error = [NSError errorWithDomain:NHARequestErrorDomain
                                         code:NHARequestDeserializationError
                                     userInfo:userInfo];
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.delegate request:self didFailWithError:error];
    }
}

@end
