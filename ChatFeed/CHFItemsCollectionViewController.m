//
//  CHFItemsCollectionViewController
//  ChatStack
//
//  Created by Larry Ryan on 7/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFItemsCollectionViewController.h"
#import "CHFCenterFlowLayout.h"
#import "CHFChatStackItem.h"

#import "CHFChatStackManager.h"

#define kCell @"Cell"

@interface CHFItemsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readwrite) UICollectionView *collectionView;

@end

@implementation CHFItemsCollectionViewController

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
//        self.itemArray = items;
//        NSLog(@"the items = %@,", self.itemArray);
        
        self.view.backgroundColor = [UIColor clearColor];
        
        [self.collectionView registerClass:[CHFItemCollectionViewCell class]
                forCellWithReuseIdentifier:kCell];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureCollectionView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // This is called here since we need the collectionview to be populated, then we can get the cells position.
    [self.delegate passItems:[self.dataSource itemsToPassToItemsCollectionViewController:self] toItemsCollectionViewController:self];
}

- (void)viewWillLayoutSubviews
{
//    self.collectionView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Properties

//- (void)setItemArray:(NSArray *)itemArray
//{
//    _itemArray = itemArray;
//    
//    //    [self.collectionView reloadData];
//}

#pragma mark - Collection View

- (void)configureCollectionView
{
    // Layout
    CGFloat itemSize = ChatStackManager.stackItemSize;
    CGFloat margin = 10.0f;
    
    
    CHFCenterFlowLayout *layout = [[CHFCenterFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemSize, itemSize);
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    //    layout.sectionInset = UIEdgeInsetsMake(CGRectGetHeight(self.view.frame) - ( itemSize + (margin * 2)), margin, margin, margin);
    
    // CollectionView
    // Had the frame set to the views frame. Something messes up so its hard coded for now
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 80) collectionViewLayout:layout];
    NSLog(@"self frame = %@, self bounds = %@, collection frame = %@, collection bounds = %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.view.bounds), NSStringFromCGRect(self.collectionView.frame), NSStringFromCGRect(self.collectionView.bounds));
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.clipsToBounds = NO;
    self.collectionView.layer.masksToBounds = NO;
    
    [self.view addSubview:self.collectionView];
}

#pragma mark DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [self.dataSource itemsToPassToItemsCollectionViewController:self].count;
            break;
        default:
            return 1;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    cell.clipsToBounds = NO;
    cell.item = [self.dataSource itemsToPassToItemsCollectionViewController:self][indexPath.item];
    
    NSLog(@"making cell with item %@", cell.item);
    
    return cell;
}


#pragma mark - Helpers

- (CHFChatStackItem *)itemForCellAtIndex:(NSUInteger)index inSection:(NSUInteger)section
{
    CHFItemCollectionViewCell *cell = (CHFItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
    
    for (CHFChatStackItem *item in cell.contentView.subviews)
    {
        if ([item isKindOfClass:[CHFChatStackItem class]])
        {
            return item;
        }
    }
    
    return nil;
}

@end
