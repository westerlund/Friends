//
//  SWFriendsController.m
//  Friends
//
//  Created by Simon Westerlund on 24/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWFriendsController.h"
#import "SWFacebookUserModel.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <AFNetworking/AFNetworking.h>

@interface SWFriendsController ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;
@property (nonatomic, strong) ACAccountCredential *accountCredential;

@end

@implementation SWFriendsController

- (id)init {
    self = [super init];
    if (self) {
        
        // Setup store and type
        [self setAccountStore:[ACAccountStore new]];
        [self setAccountType:[self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
    }
    return self;
}

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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([self accountCredential] == nil) {
        NSError *error = nil;
        
        __weak SWFriendsController *weakSelf = self;
        [self requestCredentialsWithCompletionBlock:^(ACAccountCredential *crendentials, NSError *error) {
            
            if (error) {
                NSLog(@"%@", error);
            } else {
                __strong SWFriendsController *strongSelf = weakSelf;
                [strongSelf setAccountCredential:crendentials];
                
                [self fetchListWithCompletionBlock:^(id operation,NSArray *array) {
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    block(operation, array, nil);
                }];
            }
            
        } error:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
    } else {
        [self fetchListWithCompletionBlock:^(id operation,NSArray *array) {
            block(operation, array, nil);
        }];
    }
}

- (void)fetchListWithCompletionBlock:(void (^)(id operation, NSArray *array))block {
    
    // Create request to /me
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:@"https://graph.facebook.com/me/friends"]
                                               parameters:@{@"access_token":[self.accountCredential oauthToken],
                                                            @"fields":@"picture.type(normal),last_name,first_name"}];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSError *jsonError = nil;
        NSDictionary *friendsList = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:0
                                                                      error:&jsonError];
        
        NSMutableArray *list = [NSMutableArray new];
        
        [[friendsList objectForKey:@"data"] enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
            
            NSError *modelError = nil;
            SWFacebookUserModel *model = [[SWFacebookUserModel alloc] initWithDictionary:dictionary error:&modelError];
            
            [list addObject:model];
        }];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                     ascending:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            block(nil, [list sortedArrayUsingDescriptors:@[sortDescriptor]]);
        });
        
    }];
    
}

- (NSDictionary *)accountAccessOptions {
    return @{
             @"ACFacebookAppIdKey" : kACFacebookAppIdKey,
             @"ACFacebookPermissionsKey" : @[@"email"],
             @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone};
}

- (void)requestCredentialsWithCompletionBlock:(void (^)(ACAccountCredential *crendentials, NSError *error))block error:(NSError **)error {
    
    if (error == nil) {
        [NSException raise:NSInvalidArgumentException format:@"An error pointer has to be provided"];
    }
    
    if (block == nil) {
        *error = [NSError errorWithDomain:@"com.simonwesterlund.friends"
                                     code:160
                                 userInfo:@{NSLocalizedDescriptionKey: @"No block was provided"}];
        return;
    }
    
    [self.accountStore requestAccessToAccountsWithType:[self accountType]
                                               options:[self accountAccessOptions]
                                            completion:^(BOOL granted, NSError *error) {
                                                
                                                if (error) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        block(nil, error);
                                                    });
                                                } else if (granted) {
                                                    // We were granted, now extract the credentials
                                                    ACAccount *account = [[self.accountStore accountsWithAccountType:[self accountType]] firstObject];
                                                    
                                                    // If we got an account, proceed
                                                    if (account) {
                                                        
                                                        ACAccountCredential *credentials = [account credential];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            block(credentials, nil);
                                                        });
                                                        
                                                    } else {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            block(nil, [NSError errorWithDomain:@"com.simonwesterlund.friends"
                                                                                           code:13
                                                                                       userInfo:@{NSLocalizedDescriptionKey: @"Couldn't create an account"}]);
                                                        });
                                                        
                                                    }
                                                    
                                                } else {
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        block(nil, [NSError errorWithDomain:@"com.simonwesterlund.friends"
                                                                                       code:5
                                                                                   userInfo:@{NSLocalizedDescriptionKey: @"Access not granted for Facebook account"}]);
                                                    });
                                                    
                                                }
                                            }];
}

@end
