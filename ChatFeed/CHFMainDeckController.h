//
//  CHFMainDeckViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPageViewController.h"

@protocol MainDeckControllerDelegate;

@interface CHFMainDeckController : CHFPageViewController

@property (nonatomic, assign) id <MainDeckControllerDelegate> controllerDelegate;

@end


@protocol MainDeckControllerDelegate <NSObject>



@end