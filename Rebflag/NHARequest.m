//
//  NHARequest.m
//  Rebflag
//
//  Created by Niklas Holmgren on 2017-03-04.
//  Copyright © 2017 Niklas Holmgren & Associates AB. All rights reserved.
//

#import "NHARequest.h"
#import "NHADecoder.h"
#import <SystemConfiguration/SystemConfiguration.h>

const NSErrorDomain NHARequestErrorDomain = @"NHARequestErrorDomain";
const int NHARequestDeserializationError = -1;

@interface NHARequest () {
    SCNetworkReachabilityRef _reachability;
}
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NHADecoder *decoder;
@end

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [NHARequest class]], @"info was wrong class in ReachabilityCallback");
    
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        NHARequest *request = (__bridge NHARequest *)info;
        [request fetch];
    }
}

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

- (void)dealloc {
    [self stopReachability];
}

- (void)start {
    [self startReachability];
}

- (void)fetch {
    [[self.session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self notifyDelegateOnMainQueue:^{
                [self.delegate request:self didFailWithError:error];
            }];
        } else {
            @try {
                id object = [self deserialize:data];
                if (object) {
                    id response = [self.decoder decode:object];
                    [self notifyDelegateOnMainQueue:^{
                        [self.delegate request:self didCompleteWithResponse:response];
                    }];
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
        [self notifyDelegateOnMainQueue:^{
            [self.delegate request:self didFailWithError:error];
        }];
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
    [self notifyDelegateOnMainQueue:^{
        [self.delegate request:self didFailWithError:error];
    }];
}

- (void)notifyDelegateOnMainQueue:(void (^)())block {
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (BOOL)startReachability {
    _reachability = SCNetworkReachabilityCreateWithName(NULL, [self.request.URL.host UTF8String]);
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachability, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            return YES;
        }
    }
    
    return NO;
}

- (void)stopReachability {
    if (_reachability) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(_reachability);
    }
}

@end
