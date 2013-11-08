//
//  CHFMainDeckViewController.m
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFMainDeckController.h"

#import "CHFMessagesViewController.h"
#import "CHFHomeViewController.h"
#import "CHFExploreViewController.h"


typedef NS_ENUM (NSUInteger, Deck)
{
    DeckMessages = 0,
    DeckHome = 1,
    DeckExplore = 2
};

@interface CHFMainDeckController ()

@property (strong, nonatomic) CHFMessagesViewController *messagesViewController;
@property (strong, nonatomic) CHFHomeViewController *homeViewController;
@property (strong, nonatomic) CHFExploreViewController *exploreViewController;

@end

@implementation CHFMainDeckController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.cardVerticalOrigin = 0.0f; // Was 69
        self.initialDeckPage = DeckHome;
        self.cardGestureOptions = CardGestureOptionNavigationPan | CardGestureOptionNavigationPinch | CardGestureOptionNavigationTap | CardGestureOptionViewPinch | CardGestureOptionViewTap;
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

#pragma mark - Deck Controller DataSource

- (NSUInteger)numberOfDecksInDeckController:(CHFDeckController *)deckController
{
    return 3;
}

- (NSInteger)deckController:(CHFDeckController *)deckController numberOfControllerCardsInDeckAtIndex:(NSUInteger)deckIndex
{
    switch (deckIndex)
    {
        case DeckMessages:
            return 1;
            break;
        case DeckHome:
            return 1;
            break;
        case DeckExplore:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UIViewController *)deckController:(CHFDeckController *)deckController viewControllerForDeckAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case DeckMessages:
        {
            switch (indexPath.row)
            {
                default:
                    return self.messagesViewController = [CHFMessagesViewController new];
                    break;
            }
        }
            break;
        case DeckHome:
        {
            switch (indexPath.row)
            {
                default:
                    return self.homeViewController = [CHFHomeViewController new];
                    break;
            }
        }
            break;
        case DeckExplore:
        {
            switch (indexPath.row)
            {
                case 0:
                    return self.exploreViewController = [CHFExploreViewController new];
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (BOOL)deckController:(CHFDeckController *)deckController embedCardInNavigationControllerAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DeckMessages)
    {
        return YES;
    }
    
    return NO;
}


@end
