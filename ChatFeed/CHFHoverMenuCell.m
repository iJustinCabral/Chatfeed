//
//  CHFChatStackHoverCell.m
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHoverMenuCell.h"
#import "CHFClientManager.h"
#import <ANKClient+ANKUser.h>

@interface CHFHoverMenuCell ()

@property (nonatomic, strong) UIView *highlightView;

@end

@implementation CHFHoverMenuCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Label
        self.optionLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.optionLabel.textColor = [UIColor whiteColor];
        self.optionLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.optionLabel];
        
        // Add stroke
        CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) / 2;
        CGSize radiiSize = CGSizeMake(radius, radius);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:radiiSize];
        
        // Mask the container view’s layer to round the corners.
        CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
        [cornerMaskLayer setPath:path.CGPath];
        self.layer.mask = cornerMaskLayer;
        
        // Make a transparent, stroked layer which will dispay the stroke.
        CAShapeLayer *strokeLayer = [CAShapeLayer layer];
        strokeLayer.path = path.CGPath;
        strokeLayer.fillColor = [UIColor clearColor].CGColor;
        strokeLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        strokeLayer.lineWidth = 4; // the stroke splits the width evenly inside and outside,
        // but the outside part will be clipped by the containerView’s mask.
        
        // Transparent view that will contain the stroke layer
        UIView *strokeView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [strokeView.layer addSublayer:strokeLayer];
        
        // stroke view goes in last, above all the subviews
        [self.contentView addSubview:strokeView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    NSLog(@"in hightlighted");
    if (!self.highlightView)
    {
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.backgroundColor = [UIColor whiteColor];
        self.highlightView.layer.opacity = 0.0;
        [self.contentView addSubview:self.highlightView];
    }
    
    if (highlighted)
    {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.highlightView.layer.opacity = 0.3;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
    }
    else
    {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.highlightView.layer.opacity = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
}

- (void)setMenuOption:(HoverMenuOptions)menuOption
{
    _menuOption = menuOption;
    
    // User
    if (menuOption == HoverMenuOptionUserProfile) // 1
    {
        self.optionLabel.text = @"UserProfile";
    }
    if (menuOption == HoverMenuOptionUserFollow) // 2
    {
        self.optionLabel.text = @"Unfollow";
    }
    if (menuOption == HoverMenuOptionUserMute) //4
    {
        self.optionLabel.text = @"Mute";
    }
    if (menuOption == HoverMenuOptionUserBlock) // 8
    {
        self.optionLabel.text = @"Block";
    }
    if (menuOption == HoverMenuOptionUserFollowers) // 16
    {
        self.optionLabel.text = @"Followers";
    }
    if (menuOption == HoverMenuOptionUserMentions) // 32
    {
        self.optionLabel.text = @"Mentions";
    }
    if (menuOption == HoverMenuOptionUserInteractions) // 64...
    {
        self.optionLabel.text = @"Interactions";
    }
    
    // Message
    if (menuOption == HoverMenuOptionMessageReply)
    {
        self.optionLabel.text = @"Reply";
    }
    if (menuOption == HoverMenuOptionMessageRepost)
    {
        self.optionLabel.text = @"Repost";
    }
    if (menuOption == HoverMenuOptionMessageStar)
    {
        self.optionLabel.text = @"Star";
    }
    if (menuOption == HoverMenuOptionMessageShare)
    {
        self.optionLabel.text = @"Share";
    }
    if (menuOption == HoverMenuOptionMessageReportSpam)
    {
        self.optionLabel.text = @"ReportSpam";
    }
    
    // Chat
    if (menuOption == HoverMenuOptionManageAddUser)
    {
        self.optionLabel.text = @"AddUser";
    }
    if (menuOption == HoverMenuOptionManageKick)
    {
        self.optionLabel.text = @"Kick";
    }
    
    // Stack
    if (menuOption == HoverMenuOptionChatStackAddUser)
    {
        self.optionLabel.text = @"AddUser";
    }
    if (menuOption == HoverMenuOptionChatStackRemoveUser)
    {
        self.optionLabel.text = @"RemoveUser";
    }
}

@end
