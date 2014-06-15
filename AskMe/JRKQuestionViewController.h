//
//  JRKSecondViewController.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRKQuestionViewController : UIViewController

@property(nonatomic, strong) IBOutlet UITableView * tableView;
@property(nonatomic, strong) IBOutlet UITextView * questionFieldTextView;
@property(nonatomic, strong) IBOutlet UITextView * contactsView;
@property(nonatomic, strong) IBOutlet UIButton * askButton;
@property(nonatomic, strong) IBOutlet UIButton * searchOthersButton;

-(IBAction)askBtnTapped:(id)sender;
-(IBAction)searchBtnTapped:(id)sender;

@end
