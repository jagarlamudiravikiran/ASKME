//
//  JRKLinkedInUserTableViewCell.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKLinkedInUserTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation JRKLinkedInUserTableViewCell

- (void)awakeFromNib
{
    // Initialization code	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setIsSelected:(BOOL)isSelected{
	_isSelected = isSelected;
	self.checkMarkIconImageView.hidden = !isSelected;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.isSelected =NO;
    self.profileImageView.image =nil;
}

@end
