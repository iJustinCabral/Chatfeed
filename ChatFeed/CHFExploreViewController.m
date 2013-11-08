//
//  CHFExplorViewController.m
//  Chatfeed
//
//  Created by Larry Ryan on 4/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFExploreViewController.h"

@interface CHFExploreViewController () <UISearchBarDelegate>

@property (nonatomic,strong) UISearchBar *searchBar;

@end

@implementation CHFExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor clearColor];
    
    //Add the search bar to the view
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    self.searchBar.placeholder = @"Search for Users, and Posts";
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor clearColor];
    self.searchBar.barStyle = UISearchBarStyleMinimal;
    
    [self.view addSubview:self.searchBar];
}

#pragma mark
#pragma mark - SearchBar Delegate
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    // The user clicked the [X] button or otherwise cleared the text, resigns first responder
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
}

-(BOOL) searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [searchBar resignFirstResponder];
        return NO;
    }
    return YES;
    
}

@end
