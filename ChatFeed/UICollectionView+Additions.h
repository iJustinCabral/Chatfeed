//
//  UICollectionView+Additions.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/10/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellEdge)
{
    CellEdgeTop = 0,
    CellEdgeRight,
    CellEdgeBottom,
    CellEdgeLeft
};

@interface UICollectionView (Additions)

- (CGPoint)pointForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
- (NSArray *)allCellsFromSection:(NSUInteger)section;
- (UIView *)contentViewForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section;
- (CGFloat)edgeAxisValueForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section forEdge:(CellEdge)edge;

@end
