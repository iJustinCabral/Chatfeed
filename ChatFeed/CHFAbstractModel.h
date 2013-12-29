//
//  CHFAbstractModel.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHFAbstractCell.h"
#import "CHFCollectionView.h"

#import <ANKClient.h>
#import <ANKUser.h>
#import <ANKImage.h>

@class CHFAbstractCell;

@protocol CHFModelDelegate, CHFModelDataSource, CHFModelMinimalizationDelegate;

typedef void(^FetchResponseObjectCompletionHandler)(id responseObject, ANKAPIResponseMeta *meta, NSError *error);

#pragma mark - Interface
@interface CHFAbstractModel : NSObject

@property (nonatomic, weak) id <CHFModelDelegate> delegate;
@property (nonatomic, weak) id <CHFModelDataSource> dataSource;
@property (nonatomic, weak) id <CHFModelMinimalizationDelegate> minimalizationDelegate;

@property (nonatomic) CHFCollectionView *collectionView;

#pragma mark - Initialization Methods
- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout;

- (void)reloadData;

#pragma mark - Methods
- (void)scrollToTop;
- (void)scrollToBottom;
- (void)updateContentInset:(CGFloat)contentInset;

@end

#pragma mark - DataSource
@protocol CHFModelDataSource <NSObject>

@optional
// If enabled, when the cell is tapped it will expand and show the toolbar. Default NO.
- (BOOL)showControlBarForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)controlBarViewForIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Delegate
@protocol CHFModelDelegate <NSObject>

- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion;
- (void)configureCell:(CHFAbstractCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
   withResponseObject:(id)responseObject
          andTextView:(UITextView *)textView;

@optional
// When the showToolBarOnCellTap is set to NO, this method gets called when the cell is tapped
- (void)performActionForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark - Minimalization Delegate

// This method return which direction the collectionView is panning. Used for minimalizing the navigation bar when scrolling
@protocol CHFModelMinimalizationDelegate <NSObject>

// AppBar Minimalization
- (void)didScrollForCollectionViewModel:(CHFAbstractModel *)model
                            inDirection:(PanDirection)direction
                             withOffset:(CGFloat)offset
                            andVelocity:(CGPoint)velocity;

@optional
- (void)didBeginDraggingCollectionViewModel:(CHFAbstractModel *)model
                                inDirection:(PanDirection)direction
                               withVelocity:(CGPoint)velocity;

- (void)didEndDraggingCollectionViewModel:(CHFAbstractModel *)model
                              inDirection:(PanDirection)direction
                             withVelocity:(CGPoint)velocity;

@end

