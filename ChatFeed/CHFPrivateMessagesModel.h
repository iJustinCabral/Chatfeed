//
//  CHFPrivateMessagesModel.h
//  ChatFeed
//
//  Created by Justin Cabral on 8/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHFPrivateMessagesModel : NSObject

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
- (void)loadInitialData;

@end