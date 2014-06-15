//
//  JRKSearchPeopleController.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/14/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKSearchPeopleController.h"
#import "JRKAppContext.h"

@interface JRKSearchPeopleController ()

@end

@implementation JRKSearchPeopleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;
    [self.notImplementedLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 4)];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.title = @"Search Network";
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)startSearchingProfiles{
    __weak typeof(self) weakSelf = self;
    [[JRKAppContext instance] getRecommendedUsers:self.searchTextField.text andPerformBlock:^(id result) {
        [weakSelf updateWithData:result];
           }];
}

-(void)updateWithData:(NSDictionary*)result{
    
}

@end
