//
//  CHFAbstractModel.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFAbstractModel.h"
#import "CHFAppBar.h"

#define kCell @"Cell"
#define kCellMinHeight 118.0f
#define kCellWidth 320.0
#define kPostLabelMaxWidth 320.0f
#define kPadding 10.0
#define kCollectionFooterHeight 40.0

#define kContentOffsetKey @"contentOffset"
#define kHackEnabled YES

static NSString * const ContentKind = @"Content"; // Holds the response object
static NSString * const ContentTextKind = @"ContentText"; // Holds the textView
static NSString * const CellHeightKind = @"CellHeight"; // Holds the height for the cell

@interface CHFAbstractModel () <UICollectionViewDataSource, CHFCollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

// collectionViewInfo contains keys with indexPath which hold sub dictionaries. The sub dictionaries keys are, ContentKind, ContentTextKind, CellHeightKind. Might make immutable...
@property (nonatomic) NSMutableDictionary *collectionViewInfo;

@property (nonatomic) BOOL forceContentOffset;
@property (nonatomic) CGPoint originalOffset;

// Used for appbar minimalization
@property (nonatomic) CGFloat startingPointPanOffset;
@property (nonatomic) CGPoint currentPanOffset;
@property (nonatomic) PanDirection currentPanDirection;

@end

@implementation CHFAbstractModel

#pragma mark - Lifecycle

- (instancetype)init
{
    return [self initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super init];
    
    if (self)
    {
        
        [self configureCollectionViewWithLayout:layout];
        
        [self reloadData];
    }
    
    return self;
}

// Method called from the contentInsetNotification
- (void)contentInsetNotification:(NSNotification *)notification
{
    [self updateContentInset:[AppContainer.topAppBar appBarVisibleHeight]];
}

- (void)updateContentInset:(CGFloat)contentInset
{
    self.collectionView.contentInset = UIEdgeInsetsMake(contentInset, 0, 0, 0);
}

- (void)dealloc
{
    // This is the last line of defense to get rid of these observers. Should find a new home for them somewhere where they can get called earlier.
    [self removeObserver:self forKeyPath:kContentOffsetKey];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollToTop
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:YES];
}

- (void)scrollToBottom
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.collectionViewInfo.count - 1 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionBottom
                                        animated:YES];
}

#pragma mark - CollectionView

- (void)configureCollectionViewWithLayout:(UICollectionViewFlowLayout *)layout
{
    self.collectionView = [[CHFCollectionView alloc] initWithFrame:AppContainer.view.frame
                                              collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewDelegate = self;
    self.minimalizationDelegate = AppContainer;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[CHFAbstractCell class] forCellWithReuseIdentifier:kCell];
    
    self.collectionViewInfo = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentInsetNotification:)
                                                 name:@"contentInsetNotification"
                                               object:nil];
    
    NSLog(@"the appbar = %@", AppContainer.topAppBar);
//    [self updateContentInset:[AppContainer.topAppBar appBarVisibleHeight]];
    
    // Hack to fix expanding and contracting cell glitch. (Apple Error)
    if (kHackEnabled)
    {
        [self.collectionView addObserver:self
                              forKeyPath:kContentOffsetKey
                                 options:NSKeyValueObservingOptionNew
                                 context:NULL];
        
        self.forceContentOffset = NO;
    }
}

#pragma mark DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionViewInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFAbstractCell *cell = (CHFAbstractCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.delegate configureCell:cell
                     atIndexPath:indexPath
              withResponseObject:self.collectionViewInfo[indexPath][ContentKind]
                     andTextView:self.collectionViewInfo[indexPath][ContentTextKind]];
    
    return cell;
}

#pragma mark Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // !!!: Temp object to test the notification bar
    CHFNotificationBarObject *object = [[CHFNotificationBarObject alloc] initWithNotification:[NSString stringWithFormat:@"Did select index %i", indexPath.item] wantsToBeDisplayedNext:NO andIsProgressType:NO];
    [[CHFNotificationBar sharedTopNotificationBar] addNotification:object];
    
    if ([self.dataSource respondsToSelector:@selector(showControlBarForCellAtIndexPath:)] &&
        [self.dataSource respondsToSelector:@selector(controlBarViewForIndexPath:)])
    {
        if ([self.dataSource showControlBarForCellAtIndexPath:indexPath])
        {
            CGFloat currentHeight = [self.collectionViewInfo[indexPath][CellHeightKind] floatValue];
            CGFloat collapsedHeight = [self calculatedHeightForItemAtIndexPath:indexPath];
            BOOL shouldExpand = currentHeight == collapsedHeight;
            CGFloat height = shouldExpand ? currentHeight + 44: collapsedHeight;
            
            __block CGRect frameUpdate = collectionView.frame;
            _originalOffset = collectionView.contentOffset;
            
            if (kHackEnabled)
            {
                [collectionView setHeightWithAdditive:collapsedHeight + 44];
                collectionView.contentOffset = _originalOffset;
                _forceContentOffset = YES;
            }
            
            [collectionView performBatchUpdates:^{
                // Loop through all indexPaths and update their height.
                for (NSIndexPath *key in self.collectionViewInfo)
                {
                    CHFAbstractCell *cell = (CHFAbstractCell *)[collectionView cellForItemAtIndexPath:key];
                    NSUInteger index = key.item;
                    
                    // This is the cell we tapped
                    if (index == indexPath.item)
                    {
                        self.collectionViewInfo[indexPath][CellHeightKind] = @(height);
                        cell.state = shouldExpand ? CellStateExpanded : CellStateCollapsed;
                        
                        [cell showControlBar:shouldExpand withView:[self.dataSource controlBarViewForIndexPath:key]];
                    }
                    // Looping through the other cells, if the current height of the cell if greater than its normal calculatedHeight we need to collapse that cell to normal.
                    else if (cell.state == CellStateExpanded)
                    {
                        self.collectionViewInfo[key][CellHeightKind] = @([self calculatedHeightForItemAtIndexPath:key]);
                        cell.state = CellStateCollapsed;
                    }
                }
            }
                                     completion:^(BOOL finished) {
                                         
                                         if (kHackEnabled)
                                         {
                                             frameUpdate.size.height -= collapsedHeight + 44;
                                             collectionView.frame = frameUpdate;
                                             self.forceContentOffset = NO;
                                         }
                                         
                                         /*
                                          CHFAbstractCell *selectedCell = (CHFAbstractCell *)[collectionView cellForItemAtIndexPath:indexPath];
                                          
                                          if (CGRectIntersectsRect(selectedCell.frame, collectionView.frame))
                                          {
                                          [collectionView scrollToItemAtIndexPath:indexPath
                                          atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                          animated:YES];
                                          }
                                          //*/
                                         
                                     }];
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(performActionForCellAtIndexPath:)])
            {
                [self.delegate performActionForCellAtIndexPath:indexPath];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didBeginPanningInDirection:(PanDirection)direction
          withVelocity:(CGPoint)velocity
{
    if ([self.minimalizationDelegate respondsToSelector:@selector(didBeginDraggingCollectionViewModel:inDirection:withVelocity:)])
    {
        [self.minimalizationDelegate didBeginDraggingCollectionViewModel:self
                                                             inDirection:direction
                                                            withVelocity:velocity];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didEndPanningInDirection:(PanDirection)direction
          withVelocity:(CGPoint)velocity
{
    if ([self.minimalizationDelegate respondsToSelector:@selector(didEndDraggingCollectionViewModel:inDirection:withVelocity:)])
    {
        [self.minimalizationDelegate didEndDraggingCollectionViewModel:self
                                                           inDirection:direction
                                                          withVelocity:velocity];
    }
}

#pragma mark -

- (void)reloadData
{
    [self.delegate fetchResponseObjectWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
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
        CGFloat cellTopViewHeight = 80;
        
        // Make an attributed string from the post text content
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:[self.collectionViewInfo[indexPath][ContentKind] text]];
        [postText addAttributes:@{
                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]}
                          range:NSMakeRange(0, postText.length)];
        
        UITextView *postTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kPostLabelMaxWidth, 38)];
        postTextView.attributedText = postText;
        postTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        postTextView.backgroundColor = [UIColor whiteColor];
        postTextView.editable = NO;
        postTextView.scrollEnabled = NO;
        postTextView.clipsToBounds = NO; // So it doesn't clip the text selector
        [postTextView setTextContainerInset:UIEdgeInsetsMake(5, 5, 5, 0)];
        
        // Reset the bounds since the text view now has the text.
        CGRect textViewBounds = postTextView.bounds;
        textViewBounds.size.width = MAX(textViewBounds.size.width, kPostLabelMaxWidth);
        textViewBounds.size.height = postTextView.contentSize.height;
        
        postTextView.bounds = textViewBounds;
        
        [postTextView sizeToFit]; // Reload the content size
        
        
        self.collectionViewInfo[indexPath][ContentTextKind] = postTextView;
        self.collectionViewInfo[indexPath][CellHeightKind] = @(MAX(kCellMinHeight, postTextView.bounds.size.height + cellTopViewHeight));
    };
    
    completion();
}


#pragma mark - Helper Methods

- (CGFloat)calculatedHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *postTextView = self.collectionViewInfo[indexPath][ContentTextKind];
    
    CGFloat calculatedHeight = postTextView.bounds.size.height + 80;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (CGFloat)calculatedHeightForTextView:(UITextView *)textView indexPath:(NSIndexPath *)indexPath
{
    CGFloat calculatedHeight = textView.bounds.size.height + textView.frame.origin.y + kPadding;
    CGFloat height = MAX(kCellMinHeight, calculatedHeight);
    
    return height;
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:self.collectionView]) return;
    
    NSLog(@"HAHAHAHA content offset = %f, class = %@", scrollView.contentOffset.y, self.class);
    
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView.panGestureRecognizer.view];
    
    if (!self.startingPointPanOffset) self.startingPointPanOffset = self.collectionView.contentOffset.y;
    
    CGFloat offset = self.startingPointPanOffset - self.collectionView.contentOffset.y;
    
    // Trying to get the collectionView to inset when scrolling the scrollViewController
    PanDirection direction = self.collectionView.contentOffsetY < self.startingPointPanOffset ? PanDirectionDown: PanDirectionUp;
    NSLog(@"THE DIRECTION = %@", NSStringFromPanDirection(direction));
    if (velocity.y > 0 && self.currentPanDirection != PanDirectionDown)
    {
        self.currentPanDirection = PanDirectionDown;
        
    }
    else if (velocity.y < 0 && self.currentPanDirection != PanDirectionUp)
    {
        self.currentPanDirection = PanDirectionUp;
    }
    
    
    if ([self.minimalizationDelegate respondsToSelector:@selector(didScrollForCollectionViewModel:inDirection:withOffset:andVelocity:)])
    {
        [self.minimalizationDelegate didScrollForCollectionViewModel:self
                                                         inDirection:direction
                                                          withOffset:offset
                                                         andVelocity:velocity];
    }
    
    self.startingPointPanOffset = self.collectionView.contentOffset.y;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kContentOffsetKey] && self.forceContentOffset && [(UIScrollView *)object contentOffset].y != self.originalOffset.y)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UICollectionView *collectionView = object;
            if (collectionView.contentSize.height < (collectionView.contentOffset.y + collectionView.bounds.size.height))
            {
                self.forceContentOffset = NO;
                [collectionView scrollRectToVisible:CGRectMake(self.originalOffset.x, collectionView.contentSize.height - collectionView.bounds.size.height, 1, 1) animated:YES];
            }
            else
            {
                collectionView.contentOffset = self.originalOffset;
            }
        });
    }
}

@end
