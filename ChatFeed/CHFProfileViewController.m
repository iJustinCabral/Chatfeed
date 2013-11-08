//
//  CHFProfileViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFProfileViewController.h"
#import "CHFProfileUserCountsCell.h"
#import "CHFClientManager.h"

#import <ANKImage.h>
#import <ANKUser.h>
#import <ANKClient+ANKUser.h>
#import <ANKUserDescription.h>
#import <ANKClient.h>
#import <ANKClient+ANKPostStreams.h>

#import <UIImageView+AFNetworking.h>

#import <QuartzCore/QuartzCore.h>

@interface CHFProfileViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong) UIButton *accountsButton;
@property (nonatomic, strong) UIButton *editProfileButton;
@property (nonatomic, strong) UIButton *followButton;

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *verifiedDomainLabel;
@property (nonatomic, strong) UILabel *userNumberLabel;
@property (nonatomic, strong) UILabel *userJoinDateLabel;

@property (nonatomic, strong) UITextView *bioTextView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property  CGPoint lastContentPoint;


@end

@implementation CHFProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    //TODO: Set the ScrollView for the pulling UIImageView scaling
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.scrollView.contentSize = CGSizeMake(320, 660);
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    // Set the Cover Image
    self.coverImageView = [UIImageView new];
    self.coverImageView.frame = CGRectMake(0, -40, 320, 200);
    [self.scrollView addSubview:self.coverImageView];
    
    CAGradientLayer *opacityGradient = [CAGradientLayer layer];
    opacityGradient.frame = self.coverImageView.bounds;
    opacityGradient.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
    opacityGradient.startPoint = CGPointMake(0.5, 0);
    opacityGradient.endPoint = CGPointMake(0.5, 1.0);
    self.coverImageView.layer.mask = opacityGradient;
    
    
    
    //Set the Avatar
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.frame = CGRectMake(0, 0, 80, 80);
    self.avatarImageView.center = CGPointMake(160, 150);
    self.avatarImageView.layer.cornerRadius = 40;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.avatarImageView.layer.shadowOpacity = .8;
    [self.scrollView addSubview:self.avatarImageView];
    
    //Set the Name Label
    self.nameLabel = [UILabel new];
    self.nameLabel.frame = CGRectMake(0, 0, 320, 44);
    self.nameLabel.center = CGPointMake(160, 206);
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont fontWithName:@"helveticaneue" size:24];
    [self.scrollView addSubview:self.nameLabel];
    
    //Set the Username Label
    self.usernameLabel = [UILabel new];
    self.usernameLabel.frame = CGRectMake(0, 0, 320, 44);
    self.usernameLabel.center = CGPointMake(160, 226);
    self.usernameLabel.textColor = [UIColor whiteColor];
    self.usernameLabel.textAlignment = NSTextAlignmentCenter;
    self.usernameLabel.font = [UIFont fontWithName:@"helveticaneue" size:16];
    [self.scrollView addSubview:self.usernameLabel];
    
    //Set the Verified Domain Label if available
    self.verifiedDomainLabel = [UILabel new];
    self.verifiedDomainLabel.frame = CGRectMake(0, 0, 320, 44);
    self.verifiedDomainLabel.center = CGPointMake(162, 248);
    self.verifiedDomainLabel.textColor = [UIColor whiteColor];
    self.verifiedDomainLabel.textAlignment = NSTextAlignmentCenter;
    self.verifiedDomainLabel.font = [UIFont fontWithName:@"helveticaneue" size:14];
    [self.scrollView addSubview:self.verifiedDomainLabel];
    
    //Set the Bio Text View
    self.bioTextView = [UITextView new];
    self.bioTextView.frame = CGRectMake(0, 0, 320, 60);
    self.bioTextView.center = CGPointMake(160, 300);
    self.bioTextView.backgroundColor = [UIColor clearColor];
    self.bioTextView.textColor = [UIColor whiteColor];
    self.bioTextView.textAlignment = NSTextAlignmentCenter;
    self.bioTextView.userInteractionEnabled = NO;
    self.bioTextView.font = [UIFont fontWithName:@"helveticaneue" size:16];
    [self.scrollView addSubview:self.bioTextView];
    
    //Set the Edit Profile Button
    self.editProfileButton = [UIButton new];
    self.editProfileButton.frame = CGRectMake(0,0, 100, 36);
    self.editProfileButton.center = CGPointMake(100, 340);
    self.editProfileButton.layer.borderWidth = 1;
    self.editProfileButton.layer.cornerRadius = 18;
    self.editProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.editProfileButton.titleLabel.font = [UIFont fontWithName:@"helveticaneue" size:16];
    self.editProfileButton.titleLabel.textColor = [UIColor whiteColor];
    [self.editProfileButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    [self.scrollView addSubview:self.editProfileButton];
    
    //Set the Accounts Button
    self.accountsButton = [UIButton new];
    self.accountsButton.frame = CGRectMake(0,0, 100, 36);
    self.accountsButton.center = CGPointMake(220, 340);
    self.accountsButton.layer.borderWidth = 1;
    self.accountsButton.layer.cornerRadius = 18;
    self.accountsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.accountsButton.titleLabel.font = [UIFont fontWithName:@"helveticaneue" size:16];
    self.accountsButton.titleLabel.textColor = [UIColor whiteColor];
    [self.accountsButton setTitle:@"Accounts" forState:UIControlStateNormal];
    [self.scrollView addSubview:self.accountsButton];
    
    //Set the TableView that holds user follow, following, mentions, stars, and posts
    self.tableView = [UITableView new];
    self.tableView.frame = CGRectMake(0, 0, 320, 220);
    self.tableView.center = CGPointMake(160, 480);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[CHFProfileUserCountsCell class] forCellReuseIdentifier:@"countCell"];
    [self.scrollView addSubview:self.tableView];
    
    //Set the User Number label
    self.userNumberLabel = [UILabel new];
    self.userNumberLabel.frame = CGRectMake(0, 0, 320, 44);
    self.userNumberLabel.center = CGPointMake(60, 640);
    self.userNumberLabel.textColor = [UIColor whiteColor];
    self.userNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.userNumberLabel.font = [UIFont fontWithName:@"helveticaneue" size:14];
    [self.scrollView addSubview:self.userNumberLabel];
    
    
    //Set the Joined Date Label
    self.userJoinDateLabel = [UILabel new];
    self.userJoinDateLabel.frame = CGRectMake(0, 0, 320, 44);
    self.userJoinDateLabel.center = CGPointMake(230, 640);
    self.userJoinDateLabel.textColor = [UIColor whiteColor];
    self.userJoinDateLabel.textAlignment = NSTextAlignmentCenter;
    self.userJoinDateLabel.font = [UIFont fontWithName:@"helveticaneue" size:14];
    [self.scrollView addSubview:self.userJoinDateLabel];
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = @"MMMM dd, yyyy";
    
    
    // Assign the user to the current user
    //TODO: If not personal profile, load different user
    
    [[ClientManager currentClient] fetchCurrentUserWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error) {
        
        self.user = responseObject;
        NSString *stringToBeAppendedToUsername = @"@";
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.user.verifiedDomain];
        [attributeString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:1] range:(NSRange) {0, [attributeString length]}];
        
        NSString *stringToBeAppendedToUserNumber = @"User #";
        NSString *stringToBeAppendedToJoinDate = @"Joined ";
        
        dispatch_async(dispatch_get_main_queue(), ^{
         
            [self.coverImageView setImageWithURL:self.user.coverImage.URL placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
            [self.avatarImageView setImageWithURL:self.user.avatarImage.URL placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
            [self.usernameLabel setText:[stringToBeAppendedToUsername stringByAppendingString:self.user.username]];
            [self.nameLabel setText:self.user.name];
            self.verifiedDomainLabel.attributedText = [attributeString copy];
            [self.bioTextView setText:self.user.bio.text];
            [self.userNumberLabel setText:[stringToBeAppendedToUserNumber stringByAppendingString:self.user.userID]];
            [self.userJoinDateLabel setText:[stringToBeAppendedToJoinDate stringByAppendingString:[self.dateFormatter stringFromDate:self.user.createdAt]]];
            


                                                  });
     
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.lastContentPoint = scrollView.contentOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView.contentOffset.y < self.lastContentPoint.y)
    {
        // this is just a demo method on how to compute the scale factor based on the current contentOffset
        float scale = 1.0f + fabsf(scrollView.contentOffset.y)  / scrollView.frame.size.height;
        
        //Cap the scaling between zero and 1
        scale = MAX(0.0f, scale);
        
        // Set the scale to the imageView
        self.coverImageView.transform = CGAffineTransformMakeScale(scale, scale);
    }
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHFProfileUserCountsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countCell" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Posts";
            break;
            
        case 1:
            cell.textLabel.text = @"Following";
            break;
            
        case 2:
            cell.textLabel.text = @"Followers";
            break;
            
        case 3:
            cell.textLabel.text = @"Mentions";
            break;
            
        case 4:
            cell.textLabel.text = @"Stars";
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //TO:DO Push to correct controller for index selected
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
