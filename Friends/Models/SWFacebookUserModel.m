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
@property (nonatomic) float systemFontSize;

@end

@implementation SWFacebookUserModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
    self = [super init];
    if (self) {
        
        [self setSystemFontSize:[[UIFont preferredFontForTextStyle:UIFontTextStyleBody] pointSize]];
        
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

- (NSAttributedString *)name {
    
    NSString *attributedName = nil;
    NSRange range;
    
    if ([self isDisplayFormatFirstNameFirst]) {
        attributedName = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        range = NSMakeRange([self.firstName length],[attributedName length]-[self.firstName length]);
    } else {
        attributedName = [NSString stringWithFormat:@"%@ %@", self.lastName, self.firstName];
        range = NSMakeRange(0,[self.lastName length]);
    }
    
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[self systemFontSize]];
    UIFont *regularFont = [UIFont systemFontOfSize:[self systemFontSize]];
    
    NSDictionary *boldFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, nil];
    NSDictionary *normalFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, nil];

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attributedName
                                                                                       attributes:normalFontAttributes];
    [attributedText setAttributes:boldFontAttributes range:range];
    
    return attributedText;
}

- (NSString *)fullName {
    return [[self name] string];
}

@end
