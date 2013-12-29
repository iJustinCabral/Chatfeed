//
//  CHFExplorViewController.m
//  Chatfeed
//
//  Created by Larry Ryan on 4/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFExploreViewController.h"

@interface CHFExploreViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation CHFExploreViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor randomColor];
}

#pragma mark - Subclassing Hooks

- (BOOL)hasAuxiliaryView
{
    return YES;
}

- (UIView *)auxiliaryView
{
    NSLog(@"MAKING AUXILIARY VIEW");
    if (!self.searchBar)
    {
        [self configureSearchBar];
    }
    
    return self.searchBar;
}

- (void)clearAuxiliaryView
{
    self.searchBar = nil;
}

- (void)updateContentInset:(CGFloat)inset
{
    
}

#pragma mark - SearchBar

- (void)configureSearchBar
{
    if (!self.searchBar)
    {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.searchBar.placeholder = @"Search for Users, and Posts";
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = [UIColor clearColor];
        self.searchBar.barStyle = UISearchBarStyleMinimal;
    }
}

#pragma mark Delegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // The user clicked the [X] button or otherwise cleared the text, resigns first responder
    if ([searchText length] == 0)
    {
        [searchBar performSelector:@selector(resignFirstResponder)
                        withObject:nil
                        afterDelay:0.1];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [searchBar resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
