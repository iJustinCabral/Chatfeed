//
//  CHFPostViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 11/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPostViewController.h"

@interface CHFPostViewController ()

@end

@implementation CHFPostViewController

+ (instancetype)postForClient:(ANKClient *)client
{
    CHFPostViewController *postViewController = [[CHFPostViewController alloc] initWithNibName:nil bundle:nil];
    return postViewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
