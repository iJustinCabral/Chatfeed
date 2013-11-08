//
//  CHFMainDeckViewController.h
//  ChatFeed
//
//  Created by Larry Ryan on 7/27/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFDeckController.h"

@protocol MainDeckControllerDelegate;

@interface CHFMainDeckController : CHFDeckController

@property (nonatomic, assign) id <MainDeckControllerDelegate> controllerDelegate;

@end


@protocol MainDeckControllerDelegate <NSObject>



@end