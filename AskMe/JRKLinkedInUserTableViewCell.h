//
//  JRKLinkedInUserTableViewCell.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRKLinkedInUserTableViewCell : UITableViewCell

@property (nonatomic, strong ) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong ) IBOutlet UILabel * headLineLabel;
@property (nonatomic, strong ) IBOutlet UIImageView * profileImageView;
@property (nonatomic, strong ) IBOutlet UIImageView * checkMarkIconImageView;
@property (nonatomic, assign) BOOL isSelected;

@end
