//
//  CHFBarViewScrollView.m
//  ChatFeed
//
//  Created by Larry Ryan on 12/25/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppBarScrollView.h"
#import "UIView+Hierarchy.h"

@interface CHFAppBarScrollView () <UIScrollViewDelegate>
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSArray *barViewArray;
@end

@implementation CHFAppBarScrollView

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithType:(AppBarViewType)barViewType
                     andView:(UIView *)view
{
    self = [super initWithType:barViewType andView:view];
    if (self)
    {
        [self initializer];
        
        CHFAppBarView *barView = [[CHFAppBarView alloc] initWithType:barViewType
                                                             andView:view];
        [self addBarView:barView
              onPageSide:DestinationSideLeft];
        
    }
    return self;
}

- (void)initializer
{
    self.barViewtype = AppBarViewTypeAuxiliary;
    self.barViewArray = @[];
}

#pragma mark - AppBar Management

- (void)addBarView:(CHFAppBarView *)barView onPageSide:(DestinationSide)side
{
    NSMutableArray *barViews = [self.barViewArray mutableCopy];
    
    if (barViews.count == 0)
    {
        [barViews addObject:barView];
    }
    else
    {
        switch (side)
        {
            case DestinationSideLeft:
            {
                [barViews insertObject:barView atIndex:0];
            }
                break;
            case DestinationSideRight:
            {
                [barViews addObject:barView];
            }
                break;
            default:
                break;
        }
    }

    self.barViewArray = [barViews copy];
    
    [self updateBarViews];
}

- (void)updateBarViews
{
    self.scrollView.contentSizeWidth = self.width * self.barViewArray.count;
    
    [self.barViewArray enumerateObjectsUsingBlock:^(CHFAppBarView *barView, NSUInteger index, BOOL *stop)
     {
         barView.x = self.width * index;
         
         [self.scrollView addSubview:barView];
     }];
    
    NSLog(@"THE updates aux barview %@", self.barViewArray);
}

- (void)clearBarViews
{
    for (UIView *view in self.scrollView.subviews)
    {
        [view removeFromSuperview];
        
        NSMutableArray *barViews = [self.barViewArray mutableCopy];
        [barViews removeObject:view];
        
        self.barViewArray = barViews;
    }
}

#pragma mark - Transitions

- (void)interactiveTransitionToPage:(NSUInteger)index withPercentage:(CGFloat)percentage
{
    if (index >= self.barViewArray.count) return;
    
    
}

#pragma mark - ScrollView

// Called from the supers init, override it to make the scrollView
- (void)configureView:(UIView *)view
{
    [self configureScrollView];
}

- (void)configureScrollView
{
    if (!self.scrollView)
    {
        NSUInteger numberOfIndexs = self.barViewArray.count;
        CGRect frame = self.bounds;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
//        self.scrollView.scrollEnabled = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfIndexs, self.scrollView.frame.size.height);
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        for (NSUInteger index = 0; index < 5; index++)
        {
            CGFloat marginMass = index;
            CGPoint offsetOrigin = CGPointMake((frame.size.width * index), frame.origin.y);
            frame.origin = offsetOrigin;
            
            UIView *view = [self generateRandomViewWithMinSize:frame.size andMaxSize:frame.size];
            
            view.frame = frame;
        }
        
        [self addSubview:self.scrollView];
    }
}

- (UIView *)generateRandomViewWithMinSize:(CGSize)minSize andMaxSize:(CGSize)maxSize
{
    //** Random Size
    CGFloat minWidth = minSize.width;
    CGFloat maxWidth = maxSize.width;
    
    CGFloat randomWidth = (((float)arc4random() / 0x100000000) * (maxWidth - minWidth) + minWidth);
    
    // Random Height
    CGFloat minHeight = minSize.height;
    CGFloat maxHeight = maxSize.height;
    
    CGFloat randomHeight = (((float)arc4random() / 0x100000000) * (maxHeight - minHeight) + minHeight);
    
    CGRect randomFrame = CGRectMake(0, 0, randomWidth, randomHeight);
    
    //** Random point
    CGFloat randomX = (((float)arc4random() / 0x100000000) * CGRectGetMaxX(self.bounds));
    CGFloat randomY = (((float)arc4random() / 0x100000000) * CGRectGetMaxY(self.bounds));
    
    CGPoint randomPoint = CGPointMake(randomX, randomY);
    
    //** Random Color
    CGFloat hue = (arc4random() % 256 / 256.0);  //  0.0 to 1.0
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;  //  0.5 to 1.0, away from black
    
    UIColor *randomColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    //** Make the view
    UIView *view = [[UIView alloc] initWithFrame:randomFrame];
    view.center = randomPoint;
    view.backgroundColor = randomColor;
    
    return view;
}


@end
