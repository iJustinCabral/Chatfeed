//
//  UICollectionView+Additions.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/10/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "UICollectionView+Additions.h"

@implementation UICollectionView (Additions)

- (CGPoint)pointForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
    CGPoint pointOfCellInView = [self convertPoint:cell.center toView:self];
    
    return pointOfCellInView;
}

- (NSArray *)allCellsFromSection:(NSUInteger)section
{
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    
    for (UICollectionViewCell *item in self.subviews)
    {
        if ([item isKindOfClass:[UICollectionViewCell class]])
        {
            [cells addObject:item];
        }
    }
    
    return cells;
}

- (UIView *)contentViewForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
    
    return cell.contentView;
}

- (CGFloat)edgeAxisValueForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section forEdge:(CellEdge)edge
{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
    CGPoint cellCenterPoint = [self pointForCellAtIndex:index inSection:section];
    
    CGFloat edgeValue;
    
    switch (edge)
    {
        case CellEdgeTop:
        {
            edgeValue = CGRectGetMinY(cell.frame);
        }
            break;
        case CellEdgeRight:
        {
            edgeValue = CGRectGetMaxX(cell.frame);
        }
            break;
        case CellEdgeBottom:
        {
            edgeValue = CGRectGetMaxY(cell.frame);
        }
            break;
        case CellEdgeLeft:
        {
            edgeValue = CGRectGetMinX(cell.frame);
        }
            break;
    }
    
    
    NSLog(@"FROM THE COLLECTION ADDITION cell = %@, cellCenterPoint = %@, edgeValue = %f", cell, NSStringFromCGPoint(cellCenterPoint), edgeValue);
    
    return edgeValue;
}

@end
