//
//  CHFChatStackItemBase.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/6/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFChatStackItemBase.h"

@interface CHFChatStackItemBase ()

@end

@implementation CHFChatStackItemBase

#pragma mark - Lifecylce

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Methods
- (void)spawnItemAnimated:(BOOL)animated
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    CHFChatStackItem *item = [self.dataSource itemBaseWantsChatStackItem:self];
    item.base = self;
    [self addSubview:item];
    
    if (animated)
    {
        // Get the item at the right state to be aniamted in
        [self hideItem:item animated:NO];
        
        // Animate in the item
        [self showItem:item animated:animated];
    }
}

#pragma mark - Show/Hide Item

- (void)showItem:(CHFChatStackItem *)item animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.6
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self showItem:item animated:NO];
                         }
                         completion:^(BOOL finished) {
                             item.hidden = NO;
                         }];
    }
    else
    {
        item.layer.transform = CATransform3DIdentity;
        item.alpha = 1.0;
        item.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0f);
    }
    
}

- (void)hideItem:(CHFChatStackItem *)item animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self hideItem:item animated:NO];
                         }
                         completion:^(BOOL finished) {
                             item.hidden = YES;
                         }];
    }
    else
    {
        item.layer.transform = CATransform3DIdentity;
        item.alpha = 0.0;
        item.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0f);
    }
    
}

@end
