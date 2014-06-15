//
//  JRKFirstViewController.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRKProfileViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet UILabel* headLineLabel;
@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UIView* profileDetailsHolderView;

@property (nonatomic, strong) IBOutlet UILabel* skillsHeadingLabel;
@property (nonatomic, strong) IBOutlet UILabel* skillsTextLabel;
@property (nonatomic, strong) IBOutlet UIScrollView* profileDetailsScrollView;
@end
