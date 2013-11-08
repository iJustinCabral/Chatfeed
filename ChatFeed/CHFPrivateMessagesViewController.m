//
//  CHFPrivateMessagesViewController.m
//  ChatFeed
//
//  Created by Justin Cabral on 9/7/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPrivateMessagesViewController.h"
#import "CHFPrivateMessagesModel.h"

@interface CHFPrivateMessagesViewController ()

@property (nonatomic,strong) CHFPrivateMessagesModel *collectionViewModel;

@end

@implementation CHFPrivateMessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    //Add the collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                          collectionViewLayout:[UICollectionViewFlowLayout new]];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    // Model
    self.collectionViewModel = [[CHFPrivateMessagesModel alloc] initWithCollectionView:collectionView];
}

@end
