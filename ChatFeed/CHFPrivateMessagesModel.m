//
//  CHFPrivateMessagesModel.m
//  ChatFeed
//
//  Created by Justin Cabral on 8/23/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFPrivateMessagesModel.h"
#import "CHFPrivateMessageCell.h"
#import "CHFClientManager.h"

#import <ANKChannel.h>
#import <ANKMessage.h>
#import <ANKClient+ANKMessage.h>
#import <ANKClient+ANKChannel.h>

#define kCell @"PrivateMessageCell"
#define kCellMinHeight 100.0f
#define kCellWidth 320.0
#define kPostLabelMaxWidth 210.0f
#define kPadding 10.0
#define kCollectionFooterHeight 40.0

typedef void(^FetchPrivateMessagesCompletionHandler)(BOOL success, NSError *error);
typedef void(^FetchLastPrivateMessageInChannelCompletionHandler)(BOOL success, NSError *error);
typedef NSString (^StringBlockType)(NSString *);




@interface CHFPrivateMessagesModel () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *channelArray;
@property (nonatomic, strong) NSMutableArray *messagesArray;
@property (nonatomic, strong) NSArray *channelTextViewArray;

@property (nonatomic,strong) ANKMessage *fetchedMessage;

@end

@implementation CHFPrivateMessagesModel

#pragma mark
#pragma mark - Lifecycle

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    
    if (self)
    {
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[CHFPrivateMessageCell class] forCellWithReuseIdentifier:kCell];
        
        self.collectionViewLayout = self.collectionView.collectionViewLayout;
        
        self.channelArray = @[];
        self.channelTextViewArray = @[];
        self.messagesArray = [[NSMutableArray alloc]init];
    }
    
    return self;
}


#pragma mark
#pragma mark - CollectionView
#pragma mark DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.channelArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHFPrivateMessageCell *cell = (CHFPrivateMessageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    ANKChannel *channel = [self.channelArray objectAtIndex:indexPath.row];
    UITextView *textView = [self.channelTextViewArray objectAtIndex:indexPath.row];

    
    //TO:DO
    [cell setChannel:channel withPostTextView:textView];
    
    return cell;
}

#pragma mark
#pragma mark -
- (void)loadInitialData
{
    [self fetchPrivateChannelsCompletion:^(BOOL success, NSError *error)
     {
         if (success)
         {
             [self updateUI];
         }
         else
         {
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
}

- (void)updateUI
{
    [self.collectionView reloadData];
}

- (void)fetchPrivateChannelsCompletion:(FetchPrivateMessagesCompletionHandler)completion
{
    
    [[ClientManager currentClient] fetchCurrentUserPrivateMessageChannelsWithCompletion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
    {
        if (responseObject)
        {
            self.channelArray = responseObject;
            NSLog(@"self.channel array = %@",self.channelArray);

            [self populateTextViews];
            completion(YES, nil);
        }
        else
        {
            completion(YES, error);
        }
    }];
}

//-(void)fetchLastMessageInChannel
//{
//    __weak id weakSelf = self;
//    
//    for (ANKChannel *channel in self.channelArray)
//    {
//        NSLog(@"channels %@",channel);
//        
//        NSLog(@"channel last message %@",channel.latestMessageID);
//        
//        NSLog(@"weak self %@",weakSelf);
//        
//        [[ClientManager currentClient] fetchMessageWithID:channel.latestMessageID inChannel:channel
//                                               completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
//         {
//             NSLog(@"message object %@",responseObject);
//             ANKMessage *message = responseObject;
//             NSLog(@"weak self is %@",weakSelf);
//             
//             dispatch_async(dispatch_get_main_queue(), ^{
////                 [weakSelf populateTextViews:message.text];
//             });
//             
//             NSLog(@"message text %@",message.text);
//             
//         }];
//        
//    }
//}
//
//-(void)populateTextViews:(NSString *)message
//{
//    
//    NSMutableArray *textViews = [@[] mutableCopy];
//    
//    NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:message];
//    [postText addAttributes:@{
//                              NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
//                              NSForegroundColorAttributeName : [UIColor darkTextColor]
//                              }
//                      range:NSMakeRange(0, postText.length)];
//    
//    UITextView *postTextView = [[UITextView alloc] initWithFrame:CGRectMake(80, 30, kPostLabelMaxWidth, 44)];
//    postTextView.attributedText = postText;
//    postTextView.dataDetectorTypes = UIDataDetectorTypeAll;
//    postTextView.backgroundColor = [UIColor whiteColor];
//    postTextView.editable = NO;
//    postTextView.scrollEnabled = NO;
//    postTextView.clipsToBounds = NO; // So it doesn't clip the text selector
//    
//    CGRect textViewBounds = postTextView.bounds;
//    textViewBounds.origin = CGPointMake(80, 30);
//    textViewBounds.size.width = MAX(textViewBounds.size.width, kPostLabelMaxWidth);
//    textViewBounds.size.height = postTextView.contentSize.height;
//    
//    
//    postTextView.bounds = textViewBounds;
//    
//    [postTextView sizeToFit]; // Reload the content size
//    
//    [textViews addObject:postTextView];
//    
//    
//    
//    self.channelTextViewArray = [textViews copy];
//}


- (void)populateTextViews
{
    NSMutableArray *textViews = [@[] mutableCopy];
    
        for (ANKChannel *channel in self.channelArray)
        {
            __block NSString *messageText = [NSString new];
            
            [[ClientManager currentClient] fetchMessageWithID:channel.latestMessageID inChannel:channel
                                                   completion:^(id responseObject, ANKAPIResponseMeta *meta, NSError *error)
             {
                 NSLog(@"message object %@",responseObject);
                 ANKMessage *message = responseObject;
                 messageText = message.text;
                 
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                    [self.collectionView reloadData];
                 });
                 
                 NSLog(@"message text %@",messageText);
                 
             }];
    
            NSLog(@"Message outside of block %@",messageText);

       
        // Make an attributed string from the post text content
        NSMutableAttributedString *postText = [[NSMutableAttributedString alloc] initWithString:messageText];
        [postText addAttributes:@{
                                  NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                  NSForegroundColorAttributeName : [UIColor darkTextColor]
                                  }
                          range:NSMakeRange(0, postText.length)];
        
        UITextView *postTextView = [[UITextView alloc] initWithFrame:CGRectMake(80, 30, kPostLabelMaxWidth, 44)];
        postTextView.attributedText = postText;
        postTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        postTextView.backgroundColor = [UIColor whiteColor];
        postTextView.editable = NO;
        postTextView.scrollEnabled = NO;
        postTextView.clipsToBounds = NO; // So it doesn't clip the text selector
        
        CGRect textViewBounds = postTextView.bounds;
        textViewBounds.origin = CGPointMake(80, 30);
        textViewBounds.size.width = MAX(textViewBounds.size.width, kPostLabelMaxWidth);
        textViewBounds.size.height = postTextView.contentSize.height;
            
    
        postTextView.bounds = textViewBounds;
        
        [postTextView sizeToFit]; // Reload the content size
        
        [textViews addObject:postTextView];
            
            
        }
    
    self.channelTextViewArray = [textViews copy];
    
    NSLog(@"channel text array %lu",(unsigned long)self.channelTextViewArray.count);

}


#pragma mark - Helper Methods

- (CGFloat)calculatedHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITextView *postTextView = self.channelTextViewArray[indexPath.row];
    
    CGFloat calculatedHeight = postTextView.bounds.size.height + postTextView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

- (CGFloat)calculatedHeightForTextView:(UITextView *)textView
{
    CGFloat calculatedHeight = textView.bounds.size.height + textView.frame.origin.y + kPadding;
    
    return MAX(kCellMinHeight, calculatedHeight);
}

#pragma mark - CollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.frame.size.width - (kPadding * 2);
    CGFloat height = [self calculatedHeightForItemAtIndexPath:indexPath];
    
    return CGSizeMake(width, height);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kPadding;
}

@end
