//
//  CHFStackViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 9/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFChatViewController.h"
#import "CHFPrivateMessagesModel.h"
#import <ANKClient+ANKUser.h>
@interface CHFChatViewController ()

@property (nonatomic) BOOL initialLoad;

@property (nonatomic) CHFPrivateMessagesModel *collectionViewModel;
@property (nonatomic) ANKUser *user;
@end

@implementation CHFChatViewController

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
    
    [[ClientManager currentClient] fetchUserWithID:self.userID completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
        if (responseObject)
        {
            self.user = responseObject;
            self.title = self.user.username;
        }
    }];
    
    self.view.backgroundColor = [UIColor colorWithRed:1.000 green:0.500 blue:0.000 alpha:0.470];
    self.view.layer.cornerRadius = 8.0f;
    
    self.title = self.user.username;
    
    UIBarButtonItem *addToStackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToStack)];
    
    self.navigationItem.rightBarButtonItem = addToStackButton;
    
    // Layout
    UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
    
    // Collection View
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
    
    // Model
//    self.collectionViewModel = [[CHFPrivateMessagesModel alloc] initWithCollectionView:collectionView];
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
