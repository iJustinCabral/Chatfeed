//
//  CHFAbstractModel.h
//  ChatFeed
//
//  Created by Larry Ryan on 11/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHFAbstractCell.h"

#import <ANKClient.h>
#import <ANKUser.h>
#import <ANKImage.h>

@class CHFAbstractCell;

typedef void(^FetchResponseObjectCompletionHandler)(id responseObject, ANKAPIResponseMeta *meta, NSError *error);

@interface CHFAbstractModel : NSObject

#pragma mark - Initialization Methods
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
- (void)reloadData;

#pragma mark - Subclassing Methods
#pragma mark Required
- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion;
- (void)configureCell:(CHFAbstractCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
   withResponseObject:(id)responseObject
          andTextView:(UITextView *)textView;

#pragma mark Optional
// If enabled, when the cell is tapped it will expand and show the toolbar. Default NO.
//TODO: Maybe add an index path arugment to let certian cells have the toolbar
- (BOOL)showToolBarOnCellTap;

// When the showToolBarOnCellTap is set to NO, this method gets called when the cell is tapped
- (void)performActionForCellTap;

@end
