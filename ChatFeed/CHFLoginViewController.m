//
//  CHFLoginViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/28/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFLoginViewController.h"

#import "CHFClientManager.h"

#import <ANKClient.h>

@interface CHFLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) ANKClient *client;

//@property (nonatomic, strong) NSDictionary *authenticatedClients;

- (IBAction)login:(UIButton *)sender;

@end

@implementation CHFLoginViewController

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
    
    self.usernameTextField.text = @"justincabral";
    self.passwordTextField.text = @"300zxIntegra";
    
    [self tryAuth:nil]; // Quick login
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tryAuth:(id)sender
{
	self.loginButton.enabled = NO;
    self.usernameTextField.enabled = NO;
	self.passwordTextField.enabled = NO;
	
	if (self.authRequestDidBegin)
    {
		self.authRequestDidBegin();
	}
	
    ANKClient *client = [[ANKClient alloc] init];
    
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
         }
         else
         {
             
             NSLog(@"Failed login");
             
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
         }
         
         if (self.authRequestDidFinish)
         {
             self.authRequestDidFinish();
         }
     }];
}


- (IBAction)login:(UIButton *)sender
{
    [self tryAuth:sender];
}
@end
