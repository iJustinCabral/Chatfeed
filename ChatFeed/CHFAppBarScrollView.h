//
//  CHFBarViewScrollView.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/25/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAppBarView.h"

typedef NS_ENUM (NSUInteger, DestinationSide)
{
    DestinationSideLeft = 0,
    DestinationSideRight
};

@interface CHFAppBarScrollView : CHFAppBarView

- (void)addBarView:(CHFAppBarView *)barView onPageSide:(DestinationSide)side;

- (void)interactiveTransitionToPage:(NSUInteger)index withPercentage:(CGFloat)percentage;

- (void)clearBarViews;

@end
