//
//  SWUserTableViewCell.h
//  Friends
//
//  Created by Simon Westerlund on 26/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWFacebookUserModel;

@interface SWUserTableViewCell : UITableViewCell

@property (nonatomic, strong) SWFacebookUserModel *user;

@end
