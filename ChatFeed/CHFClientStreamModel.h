//
//  CHFClientStreamModel.h
//  ChatFeed
//
//  Created by Larry Ryan on 8/2/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHFClientStreamModel : NSObject

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
- (void)loadInitialData;

@end
