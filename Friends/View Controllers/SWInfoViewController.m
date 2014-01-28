//
//  SWNoAccessViewController.m
//  Friends
//
//  Created by Simon Westerlund on 27/01/14.
//  Copyright (c) 2014 Simon Westerlund. All rights reserved.
//

#import "SWInfoViewController.h"

@interface SWInfoViewController ()

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SWInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self setErrorLabel:[UILabel new]];
        [self setTitleLabel:[UILabel new]];
        
        [self.errorLabel setTextAlignment:NSTextAlignmentCenter];
        [self.errorLabel setNumberOfLines:0];
        [self.errorLabel setAttributedText:[self attributedStringFrom:[self infoString] and:[self infoTipString]]];
        [self.errorLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        NSDictionary *dictionary = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                     NSForegroundColorAttributeName: [UIColor colorWithWhite:0.3 alpha:1]};
        [self.titleLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Facebook Friends"
                                                                           attributes:dictionary]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kSWFriendsAccessToFacebookGranted
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
    }
    return self;
}

- (NSAttributedString *)attributedStringFrom:(NSString *)firstString and:(NSString *)secondString {
    
    NSString *newLines = @"\r\r";
    NSString *string = [NSString stringWithFormat:@"%@%@%@", firstString, newLines, secondString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string
                                                                                         attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:22],
                                                                                                      NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1]}];
    NSDictionary *smallFontAttributes = @{NSFontAttributeName: [UIFont italicSystemFontOfSize:14],
                                          NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1]};
    
    NSRange rangeOfNewLine = [string rangeOfString:newLines]; // find location of newLines
    rangeOfNewLine.location += [newLines length]; // but exclude them from range
    rangeOfNewLine.length = [string length] - rangeOfNewLine.location; // apply to the rest of the string
    
    [attributedString setAttributes:smallFontAttributes range:rangeOfNewLine];
    return attributedString;
}

- (void)loadView {
    [super loadView];
    
    CGFloat errorLabelMargin = 40.0f;
    [self.errorLabel setFrame:CGRectMake(errorLabelMargin,
                                         CGRectGetHeight([self.view frame]),
                                         CGRectGetWidth([self.view frame]) - (errorLabelMargin*2),
                                         300)];
    [self.view addSubview:[self errorLabel]];
    
    [self.titleLabel setFrame:CGRectMake(0,
                                         20,
                                         CGRectGetWidth([self.view frame]),
                                         44)];
    [self.titleLabel setAlpha:0.4];
    [self.view addSubview:[self titleLabel]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.6
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             [self.errorLabel setCenter:[self.view center]];
                         }
                         completion:nil];
        
    });
}

- (NSString *)infoString {
    return nil;
}

- (NSString *)infoTipString {
    return nil;
}

@end
