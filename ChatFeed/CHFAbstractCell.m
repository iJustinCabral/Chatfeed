//
//  CHFAbstractCell.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAbstractCell.h"

@interface FrontView : UIView
@end

@implementation FrontView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[(CHFAbstractCell *)self.superview drawFrontView:rect];
}

@end


@implementation CHFAbstractCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect frame = [self bounds];
        
        // BackView
        self.backView = [[UIView alloc] initWithFrame:frame];
        self.backView.opaque = YES;
        
        [self addSubview:self.backView];
        
        // ContentView
        self.frontView = [[FrontView alloc] initWithFrame:frame];
        self.contentView.opaque = YES;
        
        [self addSubview:self.contentView];
    }
    
    return self;
}

- (void)dealloc
{
	[self.backView removeFromSuperview];
    
	[self.contentView removeFromSuperview];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	CGRect rect = [self bounds];
    
    [self.backView setFrame:rect];
	[self.contentView setFrame:rect];
    [self setNeedsDisplay];
}

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
    
    [self.backView setNeedsDisplay];
	[self.contentView setNeedsDisplay];
}

- (void)drawFrontView:(CGRect)rect
{
	// subclasses should implement this
}

@end
