//
//  SWListFriendsViewController.m
//  Friends
//
//  Created by Simon Westerlund on 23/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWListFriendsViewController.h"
#import "SWFriendsController.h"
#import "SWFacebookUserModel.h"
#import "SWUserTableViewCell.h"
#import "SWNoAccessViewController.h"
#import "SWNoInternetViewController.h"
#import <AddressBook/AddressBook.h>

static NSString *const kSWListFriendsTableViewCellIdentifier = @"kSWListFriendsTableViewCellIdentifier";

@interface SWListFriendsViewController () <UITableViewDataSource, UITextFieldDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchDisplayController *friendsSearchDisplayController;
@property (nonatomic, strong) NSArray *chunkedFriendsArray;
@property (nonatomic, strong) NSArray *sortedTitles;
@property (nonatomic, strong) NSArray *allFriendsArray;
@property (nonatomic, strong) NSArray *sectionTitles;


@end

@implementation SWListFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setSectionTitles:[[UILocalizedIndexedCollation currentCollation] sectionTitles]];
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        [self setFriendsSearchDisplayController:[[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                           contentsController:self]];
        [self.friendsSearchDisplayController setDelegate:self];
        [self.friendsSearchDisplayController setSearchResultsDataSource:self];
        [self.friendsSearchDisplayController.searchResultsTableView registerClass:[SWUserTableViewCell class] forCellReuseIdentifier:kSWListFriendsTableViewCellIdentifier];
        
        [self setTableView:[UITableView new]];
        [self.tableView setDataSource:self];
        [self.tableView registerClass:[SWUserTableViewCell class] forCellReuseIdentifier:kSWListFriendsTableViewCellIdentifier];
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.tableView setTableHeaderView:searchBar];
        [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [self.tableView setSectionIndexTrackingBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.8]];
        [self.tableView setSectionIndexMinimumDisplayRowCount:1]; // Only display section titles when rows available
        
        [self setTitle:@"Facebook Friends"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kSWFriendsAccessToFacebookGranted
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          if ([self allFriendsArray] == nil) {
                                                              [self fetchFriendsList];
                                                          }
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kSWFriendsAccessToFacebookDenied
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self presentNoAccessViewController];
                                                      }];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewDelegate

- (void)loadView {
    [super loadView];
    
    [self.tableView setFrame:[self.view bounds]];
    [self.view addSubview:[self tableView]];
}

- (void)fetchFriendsList {
    NSError *error = nil;
    [[SWFriendsController sharedController] fetchFriendsListWithCompletionBlock:^(id operation, NSArray *friendsArray, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [self setAllFriendsArray:friendsArray];
                [self splitToSubarraysFromArray:friendsArray];
                [self.tableView reloadData];
            } else {
                SWNoInternetViewController *noInternetViewController = [SWNoInternetViewController new];
                [self presentViewController:noInternetViewController animated:YES completion:nil];
            }
        });
    } error:&error];
}

- (void)presentNoAccessViewController {
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        SWInfoViewController *noAccessViewController = [SWNoAccessViewController new];
        [self presentViewController:noAccessViewController animated:YES completion:nil];
    });
}

#pragma mark - List dividers and getters/setters

- (void)splitToSubarraysFromArray:(NSArray *)array {
    
    NSMutableArray *mutableArray = [NSMutableArray new];
    NSMutableIndexSet *removeObjectsIndexes = [NSMutableIndexSet new];
    
    [self setSectionTitles:[[UILocalizedIndexedCollation currentCollation] sectionTitles]];
    [self.sectionTitles enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
        
        NSPredicate *predicate = nil;
        if (ABPersonGetSortOrdering() == kABPersonSortByFirstName) {
            predicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@", letter];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"lastName BEGINSWITH[cd] %@", letter];
        }
        
        NSArray *chunkedArray = [array filteredArrayUsingPredicate:predicate];
        
        if ([chunkedArray count] > 0) {
            [mutableArray addObject:chunkedArray];
        } else {
            [removeObjectsIndexes addIndex:idx];
        }
        
    }];
    
    NSMutableArray *mutableSectionTitles = [[self sectionTitles] mutableCopy];
    [mutableSectionTitles removeObjectsAtIndexes:removeObjectsIndexes];
    [self setSectionTitles:[mutableSectionTitles copy]];
    
    [self setChunkedFriendsArray:[mutableArray copy]];
    
}

- (void)setChunkedFriendsArray:(NSArray *)chunkedFriendsArray {
    if (_chunkedFriendsArray != chunkedFriendsArray) {
        _chunkedFriendsArray = chunkedFriendsArray;
        
        [self setSortedTitles:[self chunkedFriendsArray]];
    }
}

- (NSString *)titleAtSection:(NSInteger)section {
    NSArray *allKeys = [self sectionTitles];
    return [allKeys objectAtIndex:section];
}

- (NSArray *)chunkedListAtSection:(NSInteger)section {
    return [self.chunkedFriendsArray objectAtIndex:section];
}

- (SWFacebookUserModel *)userAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *users = [self chunkedListAtSection:[indexPath section]];
    return [users objectAtIndex:[indexPath row]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chunkedFriendsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.chunkedFriendsArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWUserTableViewCell *cell = (SWUserTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSWListFriendsTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    [cell setUser:[self userAtIndexPath:indexPath]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleAtSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self sectionTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSArray *searchResults = nil;
    
    // If we typed something, search for it, otherwise restore list
    if ([searchString length] > 0) {
        
        NSPredicate *searchPredicate = nil;
        
        NSRange rangeOfSpace = [searchString rangeOfString:@" "];
        if (rangeOfSpace.location != NSNotFound) {
            NSString *firstHalf = [searchString substringToIndex:rangeOfSpace.location];
            NSString *secondHalf = [searchString substringFromIndex:rangeOfSpace.location + 1]; // +1 to exclude the space
            
            // If we hit space, we obviously want to separate first and last name
            // However, only search if we typed something, otherwise search for just first name
            if ([firstHalf length] > 0 && [secondHalf length] > 0) {
                searchPredicate = [NSPredicate predicateWithFormat:@"(firstName CONTAINS[cd] %@) AND (lastName CONTAINS[cd] %@)", firstHalf, secondHalf];
            } else {
                searchPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", firstHalf];
            }
        } else {
            searchPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", searchString];
        }
        searchResults = [[self allFriendsArray] filteredArrayUsingPredicate:searchPredicate];
    } else {
        searchResults = [self allFriendsArray];
    }
    
    [self splitToSubarraysFromArray:searchResults];
    return YES;
}


@end
