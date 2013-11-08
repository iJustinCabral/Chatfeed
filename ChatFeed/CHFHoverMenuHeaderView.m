//
//  CHFHoverMenuHeaderView.m
//  ChatFeed
//
//  Created by Larry Ryan on 8/26/13.
//  Copyright (c) 2013 Thinkr LLC. All rights reserved.
//

#import "CHFHoverMenuHeaderView.h"

@interface CHFHoverMenuHeaderView ()

@property (nonatomic, strong) UILabel *headerLabel;

@end

@implementation CHFHoverMenuHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor orangeColor];
        self.headerLabel = [[UILabel alloc] initWithFrame:self.frame];
    }
    return self;
}

- (void)setSection:(NSUInteger)section
{
    _section = section;
    
    if (section == 0)
    {
        self.headerLabel.text = @"User";
    }
    else if (section == 1)
    {
        self.headerLabel.text = @"Message";
    }
    else if (section == 2)
    {
        self.headerLabel.text = @"Chat";
    }
    else if (section == 3)
    {
        self.headerLabel.text = @"Stack";
    }
}

@end
