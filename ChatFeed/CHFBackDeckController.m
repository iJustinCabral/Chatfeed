//
//  CHFBackDeckController.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/14/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFBackDeckController.h"

#import "CHFStoreViewController.h"
#import "CHFProfileViewController.h"
#import "CHFSettingsViewController.h"

typedef NS_ENUM (NSUInteger, Deck)
{
    DeckStore = 0,
    DeckProfile = 1,
    DeckSettings = 2
};

@interface CHFBackDeckController ()

@property (strong, nonatomic) CHFStoreViewController *storeViewController;
@property (strong, nonatomic) CHFProfileViewController *profileViewController;
@property (strong, nonatomic) CHFSettingsViewController *settingsViewController;

@end

@implementation CHFBackDeckController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cardVerticalOrigin = 0.0f; // Was 69
        self.initialDeckPage = DeckProfile;
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
        case DeckStore:
            return 1;
            break;
        case DeckProfile:
            return 1;
            break;
        case DeckSettings:
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
        case DeckStore:
        {
            switch (indexPath.row)
            {
                default:
                    return self.storeViewController = [CHFStoreViewController new];
                    break;
            }
        }
            break;
        case DeckProfile:
        {
            switch (indexPath.row)
            {
                default:
                    return self.profileViewController = [CHFProfileViewController new];
                    break;
            }
        }
            break;
        case DeckSettings:
        {
            switch (indexPath.row)
            {
                case 0:
                    return self.settingsViewController = [CHFSettingsViewController new];
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
    return NO;
}

@end
