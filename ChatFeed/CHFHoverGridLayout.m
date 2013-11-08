//
//  CHFHoverGridLayout.m
//  ChatFeed
//
//  Created by Larry Ryan on 10/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHoverGridLayout.h"

#define ITEM_SIZE 70

@interface CHFHoverGridLayout()

@property (nonatomic) NSUInteger cellCount;
@property (nonatomic) CGPoint center;

@end

@implementation CHFHoverGridLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.cellCount = [self.collectionView numberOfItemsInSection:0];
    self.center = CGPointMake(CGRectGetWidth(self.collectionView.frame) / 2.0, CGRectGetWidth(self.collectionView.frame) / 2.0);
}

- (CGPoint)positionForItemAtIndexPath:(NSIndexPath *)path
{
    int screenWidth = [self collectionViewContentSize].width;
    int screenHeight = [self collectionViewContentSize].height;
    
    int margin = 10;
    int numberOfMarginsX = [self numberOfRows] - 1;
    int numberOfMarginsY = [self numberOfColumns] - 1;
    
    int itemMassX = [self numberOfRows] * ITEM_SIZE;
    int itemMassY = [self numberOfColumns] * ITEM_SIZE;
    int marginMassX = margin * numberOfMarginsX;
    int marginMassY = margin * numberOfMarginsY;
    int totalMassX = itemMassX + marginMassX;
    int totalMassY = itemMassY + marginMassY;
    
    float radius = ITEM_SIZE / 2;
    
    int oddStartValue = 0;
    int evenStartValue = (margin / 2) + radius;
    int segmentValue = margin + ITEM_SIZE;
    
    
    return CGPointZero;
//    return CGPointMake(<#CGFloat x#>, <#CGFloat y#>)
    
}


- (CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}

- (NSUInteger)numberOfColumns
{
    return [self collectionViewContentSize].width / ITEM_SIZE;
}

- (NSUInteger)numberOfRows
{
    return ceil(self.cellCount / [self numberOfColumns]);
}

- (CGFloat)offsetForIndex:(NSUInteger)index
{
    // Give the offest a default value
    CGFloat offsetForIndex = 0;
    
    // Get the item count and calculate the total mass the item takes up
    NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    CGFloat itemMassX = itemCount * self.itemSize.width;
    
    // Get the number of margins, calculate the total margin mass to find the width of the margins
    NSInteger numberOfMarginsX = itemCount + 1;
    CGFloat marginMass = self.collectionView.frame.size.width - itemMassX;
    CGFloat margin = marginMass / numberOfMarginsX;
    
    // The segment value is the space for each center point for the cells
    CGFloat segmentValue = margin + self.itemSize.width;
    
    // Get the middle item count
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


//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
//{
//    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
//    attributes.size = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
//    attributes.center = CGPointMake(_center.x + _radius * cosf(2 * path.item * M_PI / _cellCount),
//                                    _center.y + _radius * sinf(2 * path.item * M_PI / _cellCount));
//    return attributes;
//}
//
//- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    NSMutableArray* attributes = [NSMutableArray array];
//    for (NSInteger i=0 ; i < self.cellCount; i++) {
//        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
//    }
//    return attributes;
//}
//
//- (void)finalizeCollectionViewUpdates
//{
//    [super finalizeCollectionViewUpdates];
//    
//}
//
//// Note: name of method changed
//// Also this gets called for all visible cells (not just the inserted ones) and
//// even gets called when deleting cells!
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    // Must call super
//    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    
//    if ([self.insertIndexPaths containsObject:itemIndexPath])
//    {
//        // only change attributes on inserted cells
//        if (!attributes)
//            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        
//        // Configure attributes ...
//        attributes.alpha = 0.0;
//        attributes.center = CGPointMake(_center.x, _center.y);
//    }
//    
//    return attributes;
//}

@end
