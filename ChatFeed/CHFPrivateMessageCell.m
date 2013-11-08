//
//  CHFPrivateMessageCell.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPrivateMessageCell.h"


#import <ANKChannel.h>
#import <ANKUser.h>
#import <ANKMessage.h>
#import <ANKClient+ANKMessage.h>
#import <ANKImage.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface CHFPrivateMessageCell () <UITextViewDelegate>

@property (nonatomic, strong) ANKChannel *channel;
@property (nonatomic, strong) ANKUser *user;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextView *postTextView;

@end

@implementation CHFPrivateMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        // View
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // Name Label
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, self.contentView.bounds.size.width - 80 , 20)];
        self.nameLabel.textColor = [UIColor darkTextColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.shadowColor = [UIColor whiteColor];
        self.nameLabel.shadowOffset = CGSizeMake(0, 1);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        [self.contentView addSubview:self.nameLabel];
        
        // Avatar Image
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        self.avatarImageView.backgroundColor = [UIColor clearColor];
        self.avatarImageView.contentMode = UIViewContentModeScaleToFill;
        self.avatarImageView.userInteractionEnabled = YES;
        [self maskView:self.avatarImageView withCornerRadius:self.frame.size.width / 2];
        
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedAvatar:)];
        avatarTap.numberOfTapsRequired = 1;
        [self.avatarImageView addGestureRecognizer:avatarTap];
        
        [self.contentView addSubview:self.avatarImageView];
        
    }
    return self;
}

- (void)setChannel:(ANKChannel *)channel withPostTextView:(UITextView *)textView
{
    self.channel = channel;
    self.nameLabel.text = channel.owner.username;
    self.user = channel.owner;
    
    self.postTextView = textView;
    self.postTextView.delegate = self;
    
    [self.contentView addSubview:self.postTextView];
    
    UIImage *placeHolderImage = nil;
    
    //    if ([ImageCache hasKey:post.user.userID])
    //    {
    //        placeHolderImage = [ImageCache imageForUserID:post.user.userID];
    //    }
    //    else
    {
        placeHolderImage = [UIImage imageNamed:@"avatarPlaceholder.png"];
    }
    
    [self.avatarImageView setImageWithURL:self.user.avatarImage.URL
                         placeholderImage:placeHolderImage];
}

- (void)prepareForReuse
{
    self.nameLabel.text = @"";
    
    // Post text was not clearing when I set the string to @"" for reusing the cell. This fixed it;
    [self.postTextView removeFromSuperview];
    self.postTextView = nil;
}

#pragma mark - Clipping ImageView Helper

- (void)maskView:(UIView *)originalView withCornerRadius:(CGFloat)cornerRadius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:originalView.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = originalView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    originalView.layer.mask = maskLayer;
}

@end
