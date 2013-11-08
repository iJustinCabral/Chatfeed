//
//  CHFAbstractModel.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAbstractModel.h"

#define kCell @"Cell"
#define kCellMinHeight 100.0f
#define kCellWidth 320.0
#define kPostLabelMaxWidth 300.0f
#define kPadding 10.0
#define kCollectionFooterHeight 40.0

static NSString * const ContentKind = @"Content"; // Holds the response object
static NSString * const ContentTextKind = @"ContentText"; // Holds the textView
static NSString * const CellHeightKind = @"CellHeight"; // Holds the height for the cell

@interface CHFAbstractModel () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

// collectionViewInfo contains keys with indexPath which hold sub dictionaries. The sub dictionaries keys are, ContentKind, ContentTextKind, CellHeightKind. Might make immutable...
@property (nonatomic, strong) NSMutableDictionary *collectionViewInfo;

@end

@implementation CHFAbstractModel

#pragma mark - Lifecycle

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    
    if (self)
    {
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[CHFAbstractCell class] forCellWithReuseIdentifier:kCell];
        
        self.collectionViewLayout = self.collectionView.collectionViewLayout;
        
        self.collectionViewInfo = [NSMutableDictionary dictionary];
        
        // Load the data
        [self reloadData];
    }
    
    return self;
}

#pragma mark - Subclassing Methods

- (void)fetchResponseObjectWithCompletion:(FetchResponseObjectCompletionHandler)completion
{
}

- (void)configureCell:(CHFAbstractCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
   withResponseObject:(id)responseObject
          andTextView:(UITextView *)textView
{
}

- (void)performActionForCellTap
{
}

- (BOOL)showToolBarOnCellTap
{
    return NO;
}

#pragma mark - CollectionView
#pragma mark DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFAbstractCell *cell = (CHFAbstractCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self configureCell:cell
            atIndexPath:indexPath
     withResponseObject:self.collectionViewInfo[indexPath][ContentKind]
            andTextView:self.collectionViewInfo[indexPath][ContentTextKind]];
    
    return cell;
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self showToolBarOnCellTap])
    {
        CHFAbstractCell *cell = (CHFAbstractCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        CGFloat currentHeight = [self.collectionViewInfo[indexPath][CellHeightKind] floatValue];
        CGFloat collapsedHeight = [self calculatedHeightForItemAtIndexPath:indexPath];
        
        BOOL shouldExpand = currentHeight == collapsedHeight;
        
        CGFloat height = shouldExpand ? currentHeight + 44 : collapsedHeight;
        
        [collectionView performBatchUpdates:^{
            for (NSInteger index = 0; index < self.collectionViewInfo.count; index++)
            {
                if (index == indexPath.item)
                {
                    self.collectionViewInfo[indexPath][CellHeightKind] = @(height);
                    cell.state = shouldExpand ? CellStateExpanded : CellStateCollapsed;
                }
                else if ([self.collectionViewInfo[indexPath][CellHeightKind] floatValue] > [self calculatedHeightForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]])
                {
                    self.collectionViewInfo[indexPath][CellHeightKind] = @([self calculatedHeightForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]]);
                    cell.state = CellStateCollapsed;
                }
            }
        }
                                 completion:^(BOOL finished) {
                                     //                                 if (CGRectIntersectsRect(cell.frame, collectionView.frame))
                                     //                                 {
                                     //                                     [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                                     //                                 }
                                 }];
    }
    //    else
    //    {
    //        [self performActionForCellTap];
    //    }
}

#pragma mark -

- (void)reloadData
{
    [self fetchResponseObjectWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
     {
         if (responseObject)
         {
             [[self filterDeletedContent:responseObject] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop)
              {
                 NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                 self.collectionViewInfo[indexPath] = [NSMutableDictionary dictionary];
                 self.collectionViewInfo[indexPath][ContentKind] = obj;
             }];
             
             [self populateTextViewsWithCompletion:^{
                 [self updateUI];
             }];
         }
         else
         {
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
}

- (void)updateUI
{
    [self.collectionView reloadData];
}

- (void)populateTextViewsWithCompletion:(void (^)(void))completion
{
    for (NSIndexPath *indexPath in self.collectionViewInfo)
    {
        // Make an attributed string from the post text content
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:[self.collectionViewInfo[indexPath][ContentKind] text]];
        [postText addAttributes:@{
                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]}
                          range:NSMakeRange(0, postText.length)];
        
        UITextView *postTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 80, kPostLabelMaxWidth, 44)];
        postTextView.attributedText = postText;
        postTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        postTextView.backgroundColor = [UIColor whiteColor];
        postTextView.editable = NO;
        postTextView.scrollEnabled = NO;
        postTextView.clipsToBounds = NO; // So it doesn't clip the text selector
        
        CGRect textViewBounds = postTextView.bounds;
        textViewBounds.origin = CGPointMake(80, 30);
        textViewBounds.size.width = MAX(textViewBounds.size.width, kPostLabelMaxWidth);
        textViewBounds.size.height = postTextView.contentSize.height;
        
        postTextView.bounds = textViewBounds;
        
        [postTextView sizeToFit]; // Reload the content size
        
        self.collectionViewInfo[indexPath][ContentTextKind] = postTextView;
        self.collectionViewInfo[indexPath][CellHeightKind] = @([self calculatedHeightForTextView:postTextView]);
    };
    
    completion();
}


#pragma mark - Helper Methods

- (CGFloat)calculatedHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *postTextView = self.collectionViewInfo[indexPath][ContentTextKind];
    
    CGFloat calculatedHeight = postTextView.bounds.size.height + postTextView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (CGFloat)calculatedHeightForTextView:(UITextView *)textView
{
    CGFloat calculatedHeight = textView.bounds.size.height + textView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (NSArray *)filterDeletedContent:(NSArray *)posts
{
    NSMutableArray *goodPosts = [NSMutableArray array];
    
    for (id textObject in posts)
    {
        if ([textObject text]) [goodPosts addObject:textObject];
    }
    
    return goodPosts;
}

#pragma mark - CollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = [self.collectionViewInfo[indexPath][CellHeightKind] floatValue];
    
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kPadding, 0, kPadding, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

@end
