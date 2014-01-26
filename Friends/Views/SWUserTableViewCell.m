//
//  SWUserTableViewCell.m
//  Friends
//
//  Created by Simon Westerlund on 26/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWUserTableViewCell.h"

@implementation SWUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
