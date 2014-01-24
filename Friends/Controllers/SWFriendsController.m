//
//  SWFriendsController.m
//  Friends
//
//  Created by Simon Westerlund on 24/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWFriendsController.h"
#import "SWFacebookUserModel.h"

@implementation SWFriendsController

- (void)fetchFriendsListWithCompletionBlock:(void (^)(id, NSArray *, NSError *))block error:(NSError *__autoreleasing *)error {
    
    if (error == nil) {
        [NSException raise:NSInvalidArgumentException format:@"An error pointer has to be provided"];
    }
    
    if (block == nil) {
        *error = [NSError errorWithDomain:@"com.simonwesterlund.friends"
                                     code:160
                                 userInfo:@{NSLocalizedDescriptionKey: @"No block was provided"}];
        return;
    }
    
}

@end
