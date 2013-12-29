//
//  CHFAppBarView.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/5/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppBarView.h"
#import "UIView+AutoLayout.h"

static CGFloat const kPadding = 5;

NSString * NSStringFromAppBarViewType(AppBarViewType type)
{
    switch (type) {
        case AppBarViewTypeAction:
            return @"Action";
            break;
        case AppBarViewTypeNotification:
            return @"Notification";
            break;
        case AppBarViewTypeNavigation:
            return @"Navigation";
            break;
        case AppBarViewTypeAuxiliary:
            return @"Auxiliary";
            break;
        default:
            return @"Invalid type";
            break;
    }
}


@interface CHFAppBarView ()

@property (nonatomic) NSArray *views;

@end

@implementation CHFAppBarView

#pragma mark - Lifecycle

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 320, 44)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self configureView:nil];
    }
    return self;
}

- (instancetype)initWithType:(AppBarViewType)barViewType andView:(UIView *)view
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, view.frame.size.height)];
    if (self)
    {
        self.clipsToBounds = YES;
        
        self.barViewtype = barViewType;
        [self configureView:view];
    }
    return self;
}

- (NSString *)sortKey
{
    return NSStringFromAppBarViewType(self.barViewtype);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@; %@;", [super description], NSStringFromAppBarViewType(self.barViewtype)];
}

#pragma mark - Methods

- (void)configureView:(UIView *)view
{
    if (!view) return;
    
    [self addSubview:view];
}

#pragma mark - Helpers

- (CGFloat)tallestViewsHeight:(NSArray *)views
{
    NSMutableArray *viewHeights = [NSMutableArray array];
    
    // Might have to enumerate reverse
    for (UIView *view in views)
    {
        NSNumber *viewsHeight = @(view.frame.size.height);
        
        [viewHeights addObject:viewsHeight];
    }
    
    NSNumber *maxHeight = [viewHeights valueForKeyPath:@"@max.floatValue"];
    
    return maxHeight.floatValue;
}

@end
