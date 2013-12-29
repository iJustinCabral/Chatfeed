//
//  CHFCollectionView.h
//  ChatFeed
//
//  Created by Larry Ryan on 12/24/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CHFCollectionViewDelegate;

@interface CHFCollectionView : UICollectionView

@property (nonatomic, weak) id <CHFCollectionViewDelegate> collectionViewDelegate;

@end

@protocol CHFCollectionViewDelegate <NSObject>

- (void)collectionView:(UICollectionView *)collectionView didBeginPanningInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity;
- (void)collectionView:(UICollectionView *)collectionView didEndPanningInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity;

@end