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

@interface SWListFriendsViewController ()

@property (nonatomic, strong) NSArray *friendsArray;
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
        [self setFriendsArray:friendsArray];
        [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@", [self.sectionTitles objectAtIndex:section]];
    NSArray *aElements = [self.friendsArray filteredArrayUsingPredicate:predicate];
    return [aElements count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSWListFriendsTableViewCellIdentifier
                                                            forIndexPath:indexPath];
    
    if (self.friendsArray) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[cd] %@", [self.sectionTitles objectAtIndex:[indexPath section]]];
        NSArray *aElements = [self.friendsArray filteredArrayUsingPredicate:predicate];
        
        SWFacebookUserModel *user = [aElements objectAtIndex:[indexPath row]];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", [user firstName], [user lastName]]];
    }
    return cell;
}

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return[NSArray arrayWithObjects:@"A", @"●", @"C", @"●", @"E", @"●", @"G", @"●", @"I", @"●", @"K", @"●", @"M", @"●", @"O", @"●", @"Q", @"●", @"S", @"●", @"U", @"●", @"W", @"●", @"Y", @"●", @"Å", @"●", @"Ö", nil];
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

@end
