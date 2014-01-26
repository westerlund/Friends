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
#import <AddressBook/AddressBook.h>

@interface SWListFriendsViewController () {
    NSArray *_chunkedFriendsArray;
}

@property (nonatomic, readonly) NSArray *chunkedFriendsArray;
@property (nonatomic, strong) NSArray *sortedTitles;
@property (nonatomic, strong) NSArray *allFriendsArray;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) UITextField *searchTextField;

@end

static NSString *const kSWListFriendsTableViewCellIdentifier = @"kSWListFriendsTableViewCellIdentifier";

@interface SWListFriendsViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SWListFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setTableView:[UITableView new]];
        [self.tableView setDataSource:self];
        [self.tableView registerClass:[SWUserTableViewCell class] forCellReuseIdentifier:kSWListFriendsTableViewCellIdentifier];
        
        [self setSectionTitles:[[UILocalizedIndexedCollation currentCollation] sectionTitles]];
        
        [self setSearchTextField:[UITextField new]];
        [self.searchTextField setDelegate:self];
        [self.searchTextField setPlaceholder:@"Search"];
        [self.searchTextField setReturnKeyType:UIReturnKeyDone];

    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.tableView setFrame:[self.view bounds]];
    [self.tableView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.view addSubview:[self tableView]];
    
    [self.searchTextField setFrame:CGRectMake(0, 44+20, 320, 44)];
    [self.searchTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:[self searchTextField]];
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    NSArray *searchResults = nil;
    
    // If we typed something, search for it, otherwise restore list
    if ([textField.text length] > 0) {
        
        NSPredicate *searchPredicate = nil;
        
        NSRange rangeOfSpace = [[textField text] rangeOfString:@" "];
        if (rangeOfSpace.location != NSNotFound) {
            NSString *firstHalf = [[textField text] substringToIndex:rangeOfSpace.location];
            NSString *secondHalf = [[textField text] substringFromIndex:rangeOfSpace.location + 1]; // +1 to exclude the space
            
            // If we hit space, we obviously want to separate first and last name
            // However, only search if we typed something, otherwise search for just first name
            if ([firstHalf length] > 0 && [secondHalf length] > 0) {
                searchPredicate = [NSPredicate predicateWithFormat:@"(firstName CONTAINS[cd] %@) AND (lastName CONTAINS[cd] %@)", firstHalf, secondHalf];
            } else {
                searchPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", firstHalf];
            }
        } else {
            searchPredicate = [NSPredicate predicateWithFormat:@"fullName CONTAINS[cd] %@", [textField text]];
        }
        searchResults = [[self allFriendsArray] filteredArrayUsingPredicate:searchPredicate];
    } else {
        searchResults = [self allFriendsArray];
    }

    [self splitToSubarraysFromArray:searchResults];
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SWFriendsController *controller = [SWFriendsController new];
    NSError *error = nil;
    [controller fetchFriendsListWithCompletionBlock:^(id operation, NSArray *friendsArray, NSError *error) {
        [self setAllFriendsArray:friendsArray];
        [self.tableView reloadData];
        
        [self chunkedFriendsArray];
    } error:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)splitToSubarraysFromArray:(NSArray *)array {
    
    NSMutableArray *mutableDictionary = [NSMutableArray new];
    NSMutableIndexSet *keysToDeleteArray = [NSMutableIndexSet new];
    
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
            [mutableDictionary addObject:chunkedArray];
        } else {
            [keysToDeleteArray addIndex:idx];
        }
        
    }];
    
    NSMutableArray *mutableSectionTitles = [[self sectionTitles] mutableCopy];
    [mutableSectionTitles removeObjectsAtIndexes:keysToDeleteArray];
    [self setSectionTitles:[mutableSectionTitles copy]];
    
    [self setChunkedFriendsArray:[mutableDictionary copy]];
    
}

- (void)setChunkedFriendsArray:(NSArray *)chunkedFriendsArray {
    if (_chunkedFriendsArray != chunkedFriendsArray) {
        _chunkedFriendsArray = chunkedFriendsArray;
        
        [self setSortedTitles:self.chunkedFriendsArray];
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

@end
