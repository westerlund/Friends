//
//  SWUserTableViewCell.m
//  Friends
//
//  Created by Simon Westerlund on 26/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWUserTableViewCell.h"
#import "SWFacebookUserModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface SWUserTableViewCell ()

@property (nonatomic, strong) UIImageView *profilePictureImageView;
@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end

@implementation SWUserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self.textLabel setAdjustsFontSizeToFitWidth:YES];
        [self setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
        
        [self setProfilePictureImageView:[UIImageView new]];
        [self.contentView addSubview:[self profilePictureImageView]];
        
        CGFloat pictureWidth = 28;
        [self.profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.profilePictureImageView setFrame:CGRectMake(8,
                                                          (CGRectGetHeight([self frame]) - pictureWidth) / 2,
                                                          pictureWidth,
                                                          pictureWidth)];
        [self.profilePictureImageView setClipsToBounds:YES];
        [self.profilePictureImageView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [self.profilePictureImageView.layer setCornerRadius:pictureWidth / 2];
        [self.profilePictureImageView.layer setShouldRasterize:YES];
    }
    return self;
}

- (void)setUser:(SWFacebookUserModel *)user {
    _user = user;
    [self.textLabel setAttributedText:[user name]];

    __weak SWUserTableViewCell *weakSelf = self;
    [self.profilePictureImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[user pictureUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       __strong SWUserTableViewCell *strongSelf = weakSelf;
                                       
                                       [strongSelf.profilePictureImageView setImage:image];
                                       
                                       if ([response statusCode] != 0) { // Image wasn't cached
                                           [strongSelf.profilePictureImageView setAlpha:0];
                                           [strongSelf.borderLayer setOpacity:0];
                                           [UIView animateWithDuration:0.3 animations:^{
                                               [strongSelf.profilePictureImageView setAlpha:1];
                                           }];
                                       }
                                   } failure:nil]; // ignore error
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = [self.textLabel frame];
    // make room for profile picture
    textLabelFrame.origin.x = 45;
    // narrow the label, an extra 10px is for section index
    textLabelFrame.size.width = CGRectGetWidth([self frame]) - 55;
    [self.textLabel setFrame:textLabelFrame];
}

@end
