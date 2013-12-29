//
//  CHFHomeViewController.m
//  Chatfeed
//
//  Created by Justin Cabral on 4/20/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHomeViewController.h"
#import "CHFSpringyFlowLayout.h"
#import "CHFStreamModel.h"

@import QuartzCore;

@interface CHFHomeViewController ()

@property (nonatomic, strong) CHFStreamModel *collectionViewModel;

@end

@implementation CHFHomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Model
    self.collectionViewModel = [CHFStreamModel new];
    [self.view addSubview:self.collectionViewModel.collectionView];
}

#pragma mark - Subclassing Hooks

- (BOOL)canFetchData
{
    return YES;
}

- (BOOL)canFetchOlderData
{
    return YES;
}

- (BOOL)canScrollToTop
{
    return YES;
}

- (BOOL)canScrollToBottom
{
    return YES;
}

- (BOOL)hasAuxiliaryView
{
    return YES; // NO
}

- (UIView *)auxiliaryView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:view];
    
    UIStepper *stepper = [UIStepper new];
    stepper.center = view.center;
    stepper.minimumValue = 0;
    stepper.maximumValue = 30;
    [view addSubview:stepper];
    
    return view;
}

- (void)scrollToTop
{
    [self.collectionViewModel scrollToTop];
}

- (void)scrollToBottom
{
    [self.collectionViewModel scrollToBottom];
}

- (void)fetchDataWithCapacity:(NSInteger)capacity
{
    [self.collectionViewModel reloadData];
}

- (void)updateContentInset:(CGFloat)inset
{
    [self.collectionViewModel updateContentInset:inset];
}

#pragma mark - Background Refresh Methods

- (void)refreshWithCompletionHandler:(FetchPostsCompletionHandler)completionHandler
{
    [self.collectionViewModel reloadData];
}

@end
