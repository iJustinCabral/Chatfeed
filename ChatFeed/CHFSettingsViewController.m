//
//  CHFSettingsViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFSettingsViewController.h"

NSString * const kCell = @"Cell";

@interface CHFSettingsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readwrite) AppTheme appTheme;
@end

@implementation CHFSettingsViewController

#pragma mark - Lifecycle

+ (instancetype)sharedSettings
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.appTheme = AppThemeDark;
    
    [self configureTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers (Public)

- (UIBarStyle)barStyle
{
    return self.appTheme == AppThemeDark ? UIBarStyleBlack : UIBarStyleDefault;
}

- (BOOL)isStatusBarEnabled
{
    return YES;
}

- (BOOL)isDynamicsEnabled
{
    return [self isDynamicsSupported];
}

- (BOOL)isDynamicsSupported
{
    NSString *minVersion = @"7.0";
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    if (([version compare:minVersion options:NSNumericSearch] != NSOrderedAscending)) //&& self.isSpringsEnabled
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMotionEffectsEnabled
{
    return NO;
}

- (BOOL)isAppBarMinimalizationEnabled
{
    return NO;
}

#pragma mark - UITableView

- (void)configureTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCell];
    [self.view addSubview:tableView];
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    
    cell.backgroundColor = [UIColor randomColor];
    
    return cell;
}

@end
