//
//  CHFLoginViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFLoginViewController.h"

#import "CHFItemsCollectionViewController.h"
#import "CHFClientManager.h"
#import "UIView+AutoLayout.h"
#import <ANKClient.h>
#import "CHFChatStackItem.h"

@interface CHFLoginViewController () <UITextFieldDelegate, ItemsCollectionViewControllerDataSource, ItemsCollectionViewControllerDelegate>

@property (nonatomic, strong) CHFItemsCollectionViewController *avatarCollectionView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) ANKClient *client;

@property (nonatomic, getter = isShowingAvatar) BOOL showingAvatar;

//@property (nonatomic, strong) NSDictionary *authenticatedClients;

@end

@implementation CHFLoginViewController

#pragma mark - Lifecycle

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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Avatar ImageView
//    self.avatarCollectionView = [[CHFItemsCollectionViewController alloc] init];
//    self.avatarCollectionView.view.translatesAutoresizingMaskIntoConstraints = NO;
//    self.avatarCollectionView.view.backgroundColor = [UIColor orangeColor];
//    self.avatarCollectionView.dataSource = self;
//    self.avatarCollectionView.delegate = self;
//    [self.view addSubview:self.avatarCollectionView.view];
    
    // Username textfield
    self.usernameTextField = [UITextField autoLayoutView];
    self.usernameTextField.delegate = self;
    self.usernameTextField.placeholder = @"Username";
    self.usernameTextField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.usernameTextField.textColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.usernameTextField.layer.cornerRadius = 8.0;
    self.usernameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    [self.view addSubview:self.usernameTextField];
    
    // Password textfield
    self.passwordTextField = [UITextField autoLayoutView];
    self.passwordTextField.delegate = self;
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.passwordTextField.textColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.passwordTextField.layer.cornerRadius = 8.0;
    self.passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    [self.view addSubview:self.passwordTextField];
    
    // Login Button
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor: [UIColor colorWithWhite:1.0 alpha:0.4] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(tryAuthentication) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    //** Constraints
    // Avatar CollectionView
//    [self.avatarCollectionView.view constrainToSize:CGSizeMake(60, 60)];
//    [self.avatarCollectionView.view centerInContainerOnAxis:NSLayoutAttributeCenterX];
//    [self.avatarCollectionView.view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge
//                                          inset:0];
    
    // Username TextField
    [self.usernameTextField constrainToSize:CGSizeMake(0, 50)];
    [self.usernameTextField centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [self.usernameTextField pinEdge:NSLayoutAttributeTop
                             toEdge:NSLayoutAttributeBottom
                             ofItem:self.avatarImageView
                              inset:10];
    [self.usernameTextField pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge
                                          inset:10];
    
    // Password TextField
    [self.passwordTextField constrainToSize:CGSizeMake(0, 50)];
    [self.passwordTextField centerInContainerOnAxis:NSLayoutAttributeCenterX];
    [self.passwordTextField pinEdge:NSLayoutAttributeTop
                             toEdge:NSLayoutAttributeBottom
                             ofItem:self.usernameTextField
                              inset:10];
    [self.passwordTextField pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge
                                          inset:10];
    
    // Login Button
    [self.loginButton constrainToSize:CGSizeMake(100, 50)];
    [self.loginButton pinEdge:NSLayoutAttributeTop
                       toEdge:NSLayoutAttributeBottom
                       ofItem:self.passwordTextField
                        inset:10];
    [self.loginButton pinToSuperviewEdges:JRTViewPinRightEdge
                                    inset:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"in delegate");
    if (string.length == 0)
    {
        
//        if (self.showingAvatar)
        {
            // hide avatar
            NSLog(@"hide avatar");
            self.avatarImageView.image = nil;
        }
    }
    else
    {
        if (!self.showingAvatar)
        {
            // show avatar
            NSLog(@"show avatar");
            self.avatarImageView.image = [UIImage imageNamed:@"backgroundImage1.jpg"];
        }
    }
    
    return YES;
}

#pragma mark - ItemsCollectionView DataSource
- (NSArray *)itemsToPassToItemsCollectionViewController:(CHFItemsCollectionViewController *)controller
{
    return @[[CHFChatStackItem testItem:ItemTypeStandAlone], [CHFChatStackItem testItem:ItemTypeStandAlone], [CHFChatStackItem testItem:ItemTypeStandAlone], [CHFChatStackItem testItem:ItemTypeStandAlone]];
}

#pragma mark - Login Methods

- (void)tryAuthentication
{
    self.loginButton.enabled = NO;
    self.usernameTextField.enabled = NO;
    self.passwordTextField.enabled = NO;
    
    if ([self.delegate respondsToSelector:@selector(loginDidBeginRequest)])
    {
        [self.delegate loginDidBeginRequest];
    }
    
    ANKClient *client = [ANKClient new];
    
    [client authenticateUsername:self.usernameTextField.text
                        password:self.passwordTextField.text
                        clientID:@"qsNTrSCdNXVjjLTNUsWfP59gYfen33fr"
             passwordGrantSecret:@"VmLTUYbmXvbEKVgTxZTrd6ddfKSwcMGP"
                      authScopes:ANKAuthScopeBasic | ANKAuthScopeWritePost | ANKAuthScopeStream | ANKAuthScopeEmail | ANKAuthScopeExport | ANKAuthScopeFiles| ANKAuthScopeFollow | ANKAuthScopeMessages | ANKAuthScopePublicMessages | ANKAuthScopeUpdateProfile
               completionHandler:^(BOOL success, NSError *error)
     {
         if (success)
         {
             NSLog(@"Success");
             
             [ClientManager addClient:client];
             
             // Tell Delegate
             [self.delegate loginDidSucceedForClient:client];         }
         else
         {
             UIAlertView *loginFailedAV = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                     message:@"Wrong username or password"
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
             
             [loginFailedAV show];
             
             self.loginButton.enabled = YES;
             self.usernameTextField.enabled = YES;
             self.passwordTextField.enabled = YES;
             
             // Tell delegate
             [self.delegate loginDidFailWithError:error];
         }
         
         if ([self.delegate respondsToSelector:@selector(loginDidFinishRequest)])
         {
             [self.delegate loginDidFinishRequest];
         }
     }];
}

#pragma mark - Avatar CollectionView




@end
