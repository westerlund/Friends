//
//  SWFacebookUserModel.m
//  Friends
//
//  Created by Simon Westerlund on 23/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWFacebookUserModel.h"
#import <AddressBook/AddressBook.h>

static NSString *const kFacebookAPIFirstName = @"first_name";
static NSString *const kFacebookAPILastName = @"last_name";
static NSString *const kFacebookAPIPictureUrl = @"last_name";

@interface SWFacebookUserModel ()

@property (nonatomic, strong, readwrite) NSString *firstName;
@property (nonatomic, strong, readwrite) NSString *lastName;
@property (nonatomic, strong, readwrite) NSURL *pictureUrl;
@property (nonatomic, getter = isDisplayFormatFirstNameFirst) BOOL displayFormatFirstNameFirst;

@end

@implementation SWFacebookUserModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
    self = [super init];
    if (self) {
        
        ABAddressBookCreateWithOptions(NULL, NULL);
        [self setDisplayFormatFirstNameFirst:ABPersonGetCompositeNameFormatForRecord(NULL) == kABPersonCompositeNameFormatFirstNameFirst];
        
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            if ([dictionary objectForKey:kFacebookAPIFirstName]) {
                [self setFirstName:[dictionary objectForKey:kFacebookAPIFirstName]];
            }
            if ([dictionary objectForKey:kFacebookAPILastName]) {
                [self setLastName:[dictionary objectForKey:kFacebookAPILastName]];
            }
            if ([[[dictionary objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]) {
                [self setPictureUrl:[NSURL URLWithString:[[[dictionary objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"]]];
            }
        } else {
            *error = [NSError errorWithDomain:@"com.simonwesterlund.friends" code:160 userInfo:@{NSLocalizedDescriptionKey: @"no/invalid dictionary was provided"}];
            return nil; // return nil if other than NSDictionary was provided
        }
    }
    return self;
}

@end
