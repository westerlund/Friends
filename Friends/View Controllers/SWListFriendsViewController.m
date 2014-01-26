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

@interface SWListFriendsViewController () {
    NSArray *_chunkedFriendsArray;
}

@property (nonatomic, readonly) NSArray *chunkedFriendsArray;
@property (nonatomic, strong) NSArray *sortedTitles;
@property (nonatomic, strong) NSArray *allFriendsArray;
@property (nonatomic, strong) NSArray *sectionTitles;

@end

static NSString *const kSWListFriendsTableViewCellIdentifier = @"kSWListFriendsTableViewCellIdentifier";

@interface SWListFriendsViewController () <UITableViewDataSource>

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
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSWListFriendsTableViewCellIdentifier];
        
        [self setSectionTitles:[[UILocalizedIndexedCollation currentCollation] sectionTitles]];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.tableView setFrame:[self.view bounds]];
    [self.view addSubview:[self tableView]];
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

- (NSArray *)chunkedFriendsArray {
    if (_chunkedFriendsArray == nil && [self allFriendsArray]) {
        
        NSMutableArray *mutableDictionary = [NSMutableArray new];
        NSMutableIndexSet *keysToDeleteArray = [NSMutableIndexSet new];
        
        [self.sectionTitles enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@", letter];
            NSArray *chunkedArray = [self.allFriendsArray filteredArrayUsingPredicate:predicate];
            
            if ([chunkedArray count] > 0) {
//                [mutableDictionary setObject:chunkedArray forKey:letter];
                [mutableDictionary addObject:chunkedArray];
            } else {
                [keysToDeleteArray addIndex:idx];
            }
            
        }];
        
//        [mutableDictionary removeObjectsAtIndexes:keysToDeleteArray];
        
        [self setChunkedFriendsArray:[mutableDictionary copy]];
        
    }
    return _chunkedFriendsArray;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSWListFriendsTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    SWFacebookUserModel *user = [self userAtIndexPath:indexPath];
    [cell.textLabel setAttributedText:[user name]];
    
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
