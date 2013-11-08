//
//  CHFCenterFlowLayout.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/19/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFCenterFlowLayout.h"

@implementation CHFCenterFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // If the item count is greater than what can fit on the screen we go back to using the springy flow.
    if ([self itemCountGoesBeyondView]) return [super layoutAttributesForElementsInRect:rect];
    
    // Since the item count isn't greater than what can fit on the screen we position the items so they are centered
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *modifiedLayoutAttributesArray = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger index, BOOL *stop) {
        layoutAttributes.center = CGPointMake([self offsetForIndex:index], self.collectionView.center.y);
        [modifiedLayoutAttributesArray addObject:layoutAttributes];
    }];
    
    
    return modifiedLayoutAttributesArray;
}

- (CGFloat)offsetForIndex:(NSUInteger)index
{
    CGFloat offsetForIndex = 0;
    
    NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat itemMassX = itemCount * self.itemSize.width;
    
    NSInteger numberOfMarginsX = itemCount + 1;
    CGFloat marginMass = self.collectionView.frame.size.width - itemMassX;
    CGFloat margin = marginMass / numberOfMarginsX;
    
    CGFloat segmentValue = margin + self.itemSize.width;
    
    CGFloat middleValue = itemCount / 2;
    if (![self itemCountIsOddNumber]) middleValue -= 0.5;
    
    CGFloat difference = index - middleValue;
    CGFloat offsetValue = difference * segmentValue;
    
    offsetForIndex = self.collectionView.center.x + offsetValue;
    
    return offsetForIndex;
}

- (BOOL)itemCountIsOddNumber
{
    NSUInteger countOfItems = [self.collectionView numberOfItemsInSection:0];
    
    if ((countOfItems % 2) == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)itemCountGoesBeyondView
{
    NSUInteger countOfItems = [self.collectionView numberOfItemsInSection:0];
    
    return countOfItems > [self maxAmountOfItemsInRect];
}

- (NSUInteger)maxAmountOfItemsInRect
{
    CGFloat marginAndItemWidth = self.itemSize.width + self.minimumLineSpacing;
    NSUInteger maxAmountOfItemsInRect = floor((CGRectGetWidth(self.collectionView.frame) - self.minimumLineSpacing) / marginAndItemWidth);
    
    return maxAmountOfItemsInRect;
}

@end
