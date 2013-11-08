//
//  CHFTopBar.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/17/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFTopBar.h"

@implementation CHFTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)initialization
{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    [self configureBlurLayer];
}

- (void)configureBlurLayer
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:[self bounds]];
    CALayer *blurLayer = toolbar.layer;
    
    UIView *blurView = [UIView new];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.userInteractionEnabled = NO;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [blurView.layer addSublayer:blurLayer];
    
    [self insertSubview:blurView atIndex:0];
}



@end
