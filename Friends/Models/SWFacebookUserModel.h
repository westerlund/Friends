//
//  SWFacebookUserModel.h
//  Friends
//
//  Created by Simon Westerlund on 23/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWFacebookUserModel : NSObject

/// first name and last name combined with display order as address book
@property (nonatomic, readonly) NSAttributedString *name;
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSURL *pictureUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

@end
