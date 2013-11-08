//
//  CHFStackViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 9/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFStackViewController.h"
#import "CHFPrivateMessagesModel.h"

@interface CHFStackViewController ()

@property (nonatomic, assign) BOOL initialLoad;

@property (nonatomic, strong) CHFPrivateMessagesModel *collectionViewModel;

@end

@implementation CHFStackViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.view.layer.cornerRadius = 8.0f;
    
    self.title = self.userID;
    
    UIBarButtonItem *addToStackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(addToStack)];
    
    self.navigationItem.rightBarButtonItem = addToStackButton;
    
    // Layout
    UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
    
    // Collection View
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    // Model
    self.collectionViewModel = [[CHFPrivateMessagesModel alloc] initWithCollectionView:collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addToStack
{
    
}

@end
