//
//  CHFMessagesViewController.m
//  Chatfeed
//
//  Created by Larry Ryan on 4/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMessagesViewController.h"
#import "CHFMentionsViewController.h"
#import "CHFPrivateMessagesViewController.h"
#import "CHFChatFeedsViewController.h"

#import "CHFViewPagerController.h"


@interface CHFMessagesViewController () <ViewPagerDataSource, ViewPagerDelegate>

@end

@implementation CHFMessagesViewController

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    //
    
    self.delegate = self;
    self.dataSource = self;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(CHFViewPagerController *)viewPager {
    return 3;
}
- (UIView *)viewPager:(CHFViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:
        {
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
//          label.font = [UIFont systemFontOfSize:16.0];
            label.font = [UIFont fontWithName:@"helvetica-neue" size:16.0];
            label.text = [NSString stringWithFormat:@"Mentions"];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            
            return label;
        }
            break;
            
        case 1:
        {
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"helvetica-neue" size:16.0];
            label.text = [NSString stringWithFormat:@"Messages"];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            
            return label;
        }
            break;
            
        case 2:
        {
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"helvetica-neue" size:16.0];
            label.text = [NSString stringWithFormat:@"ChatFeeds"];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [label sizeToFit];
            
            return label;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (UIViewController *)viewPager:(CHFViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    
    switch (index)
    {
        case 0:
        {
            CHFMentionsViewController *mvc = [CHFMentionsViewController new];
            return mvc;
        }
            break;
        
        case 1:
        {
            CHFPrivateMessagesViewController *pmvc = [CHFPrivateMessagesViewController new];
            return pmvc;
        }
            break;
        case 2:
        {
            CHFChatFeedsViewController *cfvc = [CHFChatFeedsViewController new];
            
            return cfvc;

        }
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(CHFViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 1.0;
            break;
        default:
            break;
    }
    
    return value;
}




@end
