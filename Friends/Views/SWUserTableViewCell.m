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
        
        [self setProfilePictureImageView:[UIImageView new]];
        [self.contentView addSubview:[self profilePictureImageView]];
        
        [self.profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.profilePictureImageView setFrame:CGRectMake(6, (44-30)/2, 30, 30)];
        [self.profilePictureImageView setClipsToBounds:YES];
        [self.profilePictureImageView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [self.profilePictureImageView.layer setCornerRadius:CGRectGetHeight([self.profilePictureImageView frame]) / 2];
        [self.profilePictureImageView.layer setShouldRasterize:YES];
    }
    return self;
}

- (void)setUser:(SWFacebookUserModel *)user {
    _user = user;
    [self.textLabel setAttributedText:[user name]];
    
//    if ([self borderLayer] == nil) {
//        [self setBorderLayer:[CAShapeLayer layer]];
//    }

    
    
        
//        [self.borderLayer setFrame:[self.profilePictureImageView frame]];
//        [self.borderLayer setPath:[shapeLayer path]];
//        [self.borderLayer setFillColor:[UIColor clearColor].CGColor];
//        [self.borderLayer setStrokeColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
//        [self.borderLayer setStrokeStart:0.0];
//        [self.borderLayer setStrokeEnd:0.95];
//        [self.contentView.layer addSublayer:self.borderLayer];
    
//        CAKeyframeAnimation *rotate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//        [rotate setValues:@[(id)[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 2, 0, 0, 1)],
//                            (id)[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1)],
//                            (id)[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)]]];
//        [rotate setDuration:0.8];
//        [rotate setRepeatCount:10000];
        //    [self.borderLayer addAnimation:rotate forKey:@"jl"];
    
    __weak SWUserTableViewCell *weakSelf = self;
    [self.profilePictureImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[user pictureUrl]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       __strong SWUserTableViewCell *strongSelf = weakSelf;
                                       
                                       [strongSelf.profilePictureImageView setImage:image];
                                       
                                       if ([response statusCode] != 0) {
                                           
                                           [strongSelf.profilePictureImageView setAlpha:0];
                                           
                                           [strongSelf.borderLayer setOpacity:0];
                                           
                                           [UIView animateWithDuration:0.3 animations:^{
                                               [strongSelf.profilePictureImageView setAlpha:1];
                                           }];
                                       } else {
//                                           [strongSelf.borderLayer removeFromSuperlayer];
                                       }
                                       
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];


}

- (void)prepareForReuse {
    [super prepareForReuse];
//    [self.borderLayer removeFromSuperlayer];
//    [self.imageView cancelImageRequestOperation];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
    
    CGRect textLabelFrame = [self.textLabel frame];
    textLabelFrame.origin.x = 45;
    textLabelFrame.size.width = CGRectGetWidth([self frame]) - 45;
    [self.textLabel setFrame:textLabelFrame];
    
}

@end
