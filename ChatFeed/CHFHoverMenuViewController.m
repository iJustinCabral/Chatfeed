//
//  CHFHoverViewController.m
//  ChatStack
//
//  Created by Larry Ryan on 7/13/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHoverMenuViewController.h"
#import "CHFHoverMenuCell.h"
#import "CHFHoverMenuHeaderView.h"

#import "CHFClientManager.h"
#import <ANKClient+ANKUser.h>

#define kCell @"hoverCell"
#define kHeader @"headerView"
#define kCellSize 90
#define kPadding 10

@interface CHFHoverMenuViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) CHFHoverMenuCell *highlightedCell;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *menuOptionsArray;
@property (nonatomic, strong) CHFChatStackItem *item;

@end


@implementation CHFHoverMenuViewController

- (instancetype)initWithMenuOptions:(HoverMenuOptions)menuOptions forItem:(CHFChatStackItem *)item
{
    self = [super init];
    
    if (self)
    {
        self.menuOptionsArray = [self arrangeOptionsIntoSections:menuOptions];
        self.item = item;
        
    }
    
    return self;
}

- (void)setMenuOptions:(HoverMenuOptions)menuOptions
{
    _menuOptions = menuOptions;
    
    self.menuOptionsArray = [self arrangeOptionsIntoSections:menuOptions];
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:ChatStackManager.window.bounds
                                             collectionViewLayout:[UICollectionViewFlowLayout new]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.clipsToBounds = NO;
    self.collectionView.layer.masksToBounds = NO;
    
    [self.collectionView registerClass:[CHFHoverMenuCell class]
            forCellWithReuseIdentifier:kCell];
    
    UINib *headerNib = [UINib nibWithNibName:@"HeaderView" bundle:nil];
    [self.collectionView registerNib:headerNib
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:kHeader];
    
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView
#pragma mark DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.menuOptionsArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.menuOptionsArray objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFHoverMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    NSNumber *option = (NSNumber *)[self.menuOptionsArray[indexPath.section] objectAtIndex:indexPath.item];
    cell.menuOption = option.integerValue;
    cell.userID = self.item.userID;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        CHFHoverMenuHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeader forIndexPath:indexPath];
        
        headerView.section = indexPath.section;
        
        reusableView = headerView;
    }
    
    return reusableView;
}

#pragma mark LayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kCellSize, kCellSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return @[];
}

#pragma mark - Helpers

- (CHFHoverMenuCell *)cellAtPoint:(CGPoint)point
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    return (CHFHoverMenuCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - Methods
#pragma mark Public
- (void)performActionOnCellAtPoint:(CGPoint)point withChatStackItem:(CHFChatStackItem *)item andCompletion:(void (^)(void))completion
{
    if ([self cellAtPoint:point] != nil)
    {
        CHFHoverMenuCell *cell = [self cellAtPoint:point];
        
        [self performActionWithOption:cell.menuOption
                        chatStackItem:item
                        andCompletion:^{
                            completion();
                        }];
    }
    else
    {
        completion();
    }
}

- (void)pannedItemPoint:(CGPoint)point
{
    if (self.highlightedCell && ![self.highlightedCell isEqual:[self cellAtPoint:point]])
    {
        self.highlightedCell.highlighted = NO;
        self.highlightedCell = nil;
    }
    
    if ([self cellAtPoint:point] != nil)
    {
        self.highlightedCell = [self cellAtPoint:point];
        self.highlightedCell.highlighted = YES;
    }
}

#pragma mark Private

- (NSArray *)arrangeOptionsIntoSections:(HoverMenuOptions)menuOptions
{
    NSMutableArray *userSection = nil;
    NSMutableArray *messageSection = nil;
    NSMutableArray *chatSection = nil;
    NSMutableArray *stackSection = nil;
    
    // User Section
    if (menuOptions & HoverMenuOptionUserProfile)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserProfile)];
    }
    
    if (menuOptions & HoverMenuOptionUserFollow)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserFollow)];
    }
    
    if (menuOptions & HoverMenuOptionUserMute)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserMute)];
    }
    
    if (menuOptions & HoverMenuOptionUserBlock)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserBlock)];
    }
    
    if (menuOptions & HoverMenuOptionUserFollowers)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserFollowers)];
    }
    
    if (menuOptions & HoverMenuOptionUserMentions)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserMentions)];
    }
    
    if (menuOptions & HoverMenuOptionUserInteractions)
    {
        if (!userSection) userSection = [@[] mutableCopy];
        
        [userSection addObject:@(HoverMenuOptionUserInteractions)];
    }
    
    
    // Message Section
    if (menuOptions & HoverMenuOptionMessageReply)
    {
        if (!messageSection) messageSection = [@[] mutableCopy];
        
        [messageSection addObject:@(HoverMenuOptionMessageReply)];
    }
    
    if (menuOptions & HoverMenuOptionMessageRepost)
    {
        if (!messageSection) messageSection = [@[] mutableCopy];
        
        [messageSection addObject:@(HoverMenuOptionMessageRepost)];
    }
    
    if (menuOptions & HoverMenuOptionMessageStar)
    {
        if (!messageSection) messageSection = [@[] mutableCopy];
        
        [messageSection addObject:@(HoverMenuOptionMessageStar)];
    }
    
    if (menuOptions & HoverMenuOptionMessageShare)
    {
        if (!messageSection) messageSection = [@[] mutableCopy];
        
        [messageSection addObject:@(HoverMenuOptionMessageShare)];
    }
    
    if (menuOptions & HoverMenuOptionMessageReportSpam)
    {
        if (!messageSection) messageSection = [@[] mutableCopy];
        
        [messageSection addObject:@(HoverMenuOptionMessageReportSpam)];
    }
    
    // Chat Section
    if (menuOptions & HoverMenuOptionManageAddUser)
    {
        if (!chatSection) chatSection = [@[] mutableCopy];
        
        [chatSection addObject:@(HoverMenuOptionManageAddUser)];
    }
    
    if (menuOptions & HoverMenuOptionManageKick)
    {
        if (!chatSection) chatSection = [@[] mutableCopy];
        
        [chatSection addObject:@(HoverMenuOptionManageKick)];
    }
    
    // Stack Section
    if (menuOptions & HoverMenuOptionChatStackAddUser)
    {
        if (!stackSection) stackSection = [@[] mutableCopy];
        
        [stackSection addObject:@(HoverMenuOptionChatStackAddUser)];
    }
    
    if (menuOptions & HoverMenuOptionChatStackRemoveUser)
    {
        if (!stackSection) stackSection = [@[] mutableCopy];
        
        [stackSection addObject:@(HoverMenuOptionChatStackRemoveUser)];
    }
    
    // Add the section arrays to the returned array.
    NSMutableArray *sectionsArray = [@[] mutableCopy];
    
    if (userSection)
    {
        [sectionsArray addObject:userSection];
    }
    if (messageSection)
    {
        [sectionsArray addObject:messageSection];
    }
    if (chatSection)
    {
        [sectionsArray addObject:chatSection];
    }
    if (stackSection)
    {
        [sectionsArray addObject:stackSection];
    }
    
    return sectionsArray;
}

- (void)performActionWithOption:(HoverMenuOptions)menuOption
                  chatStackItem:(CHFChatStackItem *)item
                  andCompletion:(void (^)(void))completion
{
    // User
    if (menuOption & HoverMenuOptionUserProfile)
    {
        
        NSLog(@"HoverMenuOptionUserProfile");
    }
    if (menuOption & HoverMenuOptionUserFollow)
    {
        [[ClientManager currentClient] fetchUserWithID:item.userID completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
            if (responseObject)
            {
                
                [[ClientManager currentClient] followUser:responseObject completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
                    
                }];
            }
        }];
        
        NSLog(@"HoverMenuOptionUserFollow %@", item.username);
    }
    if (menuOption & HoverMenuOptionUserMute)
    {
        NSLog(@"HoverMenuOptionUserMute");
    }
    if (menuOption & HoverMenuOptionUserBlock)
    {
        NSLog(@"HoverMenuOptionUserBlock");
    }
    if (menuOption & HoverMenuOptionUserFollowers)
    {
        NSLog(@"HoverMenuOptionUserFollowers");
    }
    if (menuOption & HoverMenuOptionUserMentions)
    {
        NSLog(@"HoverMenuOptionUserMentions");
    }
    if (menuOption & HoverMenuOptionUserInteractions)
    {
        NSLog(@"HoverMenuOptionUserInteractions");
    }
    
    // Message
    if (menuOption & HoverMenuOptionMessageReply)
    {
        NSLog(@"HoverMenuOptionMessageReply");
    }
    if (menuOption & HoverMenuOptionMessageRepost)
    {
        NSLog(@"HoverMenuOptionMessageRepost");
    }
    if (menuOption & HoverMenuOptionMessageStar)
    {
        NSLog(@"HoverMenuOptionMessageStar");
    }
    if (menuOption & HoverMenuOptionMessageShare)
    {
        NSLog(@"HoverMenuOptionMessageShare");
    }
    if (menuOption & HoverMenuOptionMessageReportSpam)
    {
        NSLog(@"HoverMenuOptionMessageReportSpam");
    }
    
    // Chat
    if (menuOption & HoverMenuOptionManageAddUser)
    {
        NSLog(@"HoverMenuOptionManageAddUser");
    }
    if (menuOption & HoverMenuOptionManageKick)
    {
        NSLog(@"HoverMenuOptionManageKick");
    }
    
    // Stack
    if (menuOption & HoverMenuOptionChatStackAddUser)
    {
        NSLog(@"HoverMenuOptionChatStackAddUser");
        self.item.itemtype = ItemTypeStack;
        [ChatStackManager addItem:self.item fromPoint:self.item.center animated:YES withCompletionBlock:^(BOOL finished) {
            
        }];
    }
    if (menuOption & HoverMenuOptionChatStackRemoveUser)
    {
        // Have the item kick out behavior
        NSLog(@"HoverMenuOptionChatStackRemoveUser");
    }
    
    completion();
}

#pragma mark - Show / Hide methods

- (void)showAnimated:(BOOL)animated
{
    if (animated)
    {
        self.view.layer.opacity = 0.0;
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self showAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    self.view.layer.opacity = 1.0;
}

- (void)dismissAnimated:(BOOL)animated
{
    if (animated)
    {
        self.view.layer.opacity = 1.0;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent |
         UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self dismissAnimated:NO];
                         }
                         completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                         }];
    }
    
    self.view.layer.opacity = 0.0;
}

@end
