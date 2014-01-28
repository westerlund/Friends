//
//  SWFriendsController.h
//  Friends
//
//  Created by Simon Westerlund on 24/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWFriendsController : NSObject

+ (instancetype)sharedController;
- (void)checkAccessToFacebook:(void (^)(BOOL accessGranted, NSError *error))block;
- (void)fetchFriendsListWithCompletionBlock:(void (^)(id operation, NSArray *friendsArray, NSError *error))block error:(NSError **)error;

@end
