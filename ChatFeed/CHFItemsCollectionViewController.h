//
//  CHFItemsCollectionViewController.h
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHFItemCollectionViewCell.h"

@protocol ItemsCollectionViewControllerDataSource;
@protocol ItemsCollectionViewControllerDelegate;

@interface CHFItemsCollectionViewController : UIViewController

#pragma mark -
@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, weak) id <ItemsCollectionViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <ItemsCollectionViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *itemArray;

#pragma mark - Helpers
- (CHFChatStackItem *)itemForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section;

@end


@protocol ItemsCollectionViewControllerDataSource <NSObject>

// This returns the items that will be snapping to the collection view. We give these to the corrisponding cell
- (NSArray *)itemsToPassToItemsCollectionViewController:(CHFItemsCollectionViewController *)controller;

@end

@protocol ItemsCollectionViewControllerDelegate <NSObject>


- (void)passItems:(NSArray *)items toItemsCollectionViewController:(CHFItemsCollectionViewController *)controller;

@end