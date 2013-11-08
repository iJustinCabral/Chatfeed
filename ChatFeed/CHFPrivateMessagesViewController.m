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

@property (nonatomic,strong) CHFPrivateMessagesModel *pmCollectionViewModel;

@end

@implementation CHFPrivateMessagesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    //Add the collectionView
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    
    // Model
    self.pmCollectionViewModel = [[CHFPrivateMessagesModel alloc] initWithCollectionView:collectionView];
    [self.pmCollectionViewModel loadInitialData];
    
    [self.view addSubview:collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
