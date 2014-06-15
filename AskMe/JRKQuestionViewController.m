//
//  JRKSecondViewController.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKQuestionViewController.h"
#import "JRKLinkedInUserTableViewCell.h"
#import "JRKFullProfile.h"
#import "JRKAppContext.h"
#import "JRKUserInfo.h"
#import "JRKSearchPeopleController.h"
#import <TMCache.h>
#import <QuartzCore/QuartzCore.h>

@interface JRKQuestionViewController ()<UITableViewDataSource, UITableViewDataSource,UITextViewDelegate>

@property(nonatomic, strong) NSMutableDictionary * completeProfilesDic;
@property(nonatomic, strong) NSArray * completListOfProfiles;
@property(nonatomic, strong) NSMutableArray * recommendedListOfProfiles;
@property(nonatomic, strong) NSMutableArray * remainingListOfProfiles;
@property(nonatomic, strong) NSMutableOrderedSet * selectedListOfProfiles;
@end

@implementation JRKQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	self.completListOfProfiles = [[[[JRKAppContext instance] userInfo] connectionsSet] array];
    self.completeProfilesDic =[NSMutableDictionary dictionary];
    for (JRKFullProfile * profile in self.completListOfProfiles) {
        [self.completeProfilesDic setObject:profile forKey:profile.userId ];
    }
    //At start of screen , recommended list should be empty
    self.completListOfProfiles = [self.completeProfilesDic allKeys];
    self.recommendedListOfProfiles = [NSMutableArray arrayWithArray:[self.completListOfProfiles objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)]]];
    self.remainingListOfProfiles = [NSMutableArray arrayWithArray:self.completListOfProfiles];
    [self.remainingListOfProfiles removeObjectsInArray:self.recommendedListOfProfiles];
    self.selectedListOfProfiles = [NSMutableOrderedSet orderedSet];
    
    self.questionFieldTextView.layer.borderWidth = 1.0f;
    self.questionFieldTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.questionFieldTextView.layer.cornerRadius = 4.0f;
    self.questionFieldTextView.clipsToBounds = YES;
    
    self.contactsView.layer.borderWidth = 1.0f;
    self.contactsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.contactsView.layer.cornerRadius = 4.0f;
    self.contactsView.clipsToBounds = YES;
    
    self.questionFieldTextView.scrollsToTop = NO;
    self.contactsView.scrollsToTop = NO;
    self.tableView.scrollsToTop = YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self view] endEditing:TRUE];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationController.navigationBarHidden = YES;
}
-(void)clearRecommendations{
    
    NSMutableArray * newRecomList = [NSMutableArray array];
    
    [newRecomList addObject:[self.completListOfProfiles firstObject]];
    
    [self updateTableViewWithCurrentRecommendedList:newRecomList];
}

#pragma mark - UITextFieldDelegate

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString * currenttext = [textView.text stringByReplacingCharactersInRange:range withString:text];
	//Look for Space or any specific string such as a space
    if ([text isEqualToString:@" "]) {
        //pick 2 new userid from remainign list
        __weak typeof(self) weakSelf = self;
        [[JRKAppContext instance] getRecommendedUsers:self.questionFieldTextView.text andPerformBlock:^(NSArray * arr) {
            
            NSMutableArray * newRecomList = [NSMutableArray arrayWithArray:[arr copy]];
            
            //backup logic if table doesn't have good data
            if (newRecomList.count == 0) {
                NSLog(@"NO RECOMMENDATIONS IN TABLE");
                //get your best recommendations
                
                int rand = random()%10;
                [ newRecomList addObject: [self.remainingListOfProfiles objectAtIndex:rand]];
            }else{
                NSLog(@"RECOMMENDED USERS :%@",arr);
               
            }
            [newRecomList addObjectsFromArray:self.recommendedListOfProfiles];
            [weakSelf updateTableViewWithCurrentRecommendedList:newRecomList];
        }];
    }
    if (self.questionFieldTextView.text.length < 2) {
        [self clearRecommendations];
    }
    self.askButton.enabled = self.questionFieldTextView.text.length > 0 && self.selectedListOfProfiles.count >0;
	return YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.recommendedListOfProfiles.count;
    }
	return self.remainingListOfProfiles.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	JRKLinkedInUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JRKLinkedInUserTableViewCellID"];
    
    if (!cell) {       
		// Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"JRKLinkedInUserTableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
		
		cell.profileImageView.layer.borderWidth = 1.0f;
		cell.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
		cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2;
		cell.profileImageView.clipsToBounds = YES;
		cell.isSelected = NO;
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
    }
	JRKBasicProfile * profile = nil;
    if(indexPath.section == 0){
        profile = [self.completeProfilesDic objectForKey:[self.recommendedListOfProfiles objectAtIndex:indexPath.row] ];
    }else{
        profile = [self.completeProfilesDic objectForKey:[self.remainingListOfProfiles objectAtIndex:indexPath.row] ];
    }
    if ([self.selectedListOfProfiles containsObject:profile.userId]) {
        cell.isSelected= YES;
    }
    cell.nameLabel.text = [profile fullName];
	cell.headLineLabel.text = [profile headLine];
//	NSURL *imageURL = [NSURL URLWithString:profile.pictureUrl];
//    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//    if (imageData) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.profileImageView.image = [UIImage imageWithData:imageData];
//        });
//    }

    
	[[TMCache sharedCache] objectForKey:profile.pictureUrl
								  block:^(TMCache *cache, NSString *key, id object) {
									  UIImage *image = (UIImage *)object;
									  if (!image) {
										  NSURL *imageURL = [NSURL URLWithString:profile.pictureUrl];
										  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
										  if (imageData) {
											  dispatch_async(dispatch_get_main_queue(), ^{
												  cell.profileImageView.image = [UIImage imageWithData:imageData];
											  });
										  }
										  UIImage *img = [[UIImage alloc] initWithData:imageData scale:[[UIScreen mainScreen] scale]];
										  [[TMCache sharedCache] setObject:img forKey:profile.pictureUrl block:nil]; // returns immediately
									  }else{
										  dispatch_async(dispatch_get_main_queue(), ^{
											  cell.profileImageView.image = image;
										  });
									  }
									  
								  }];
	
	
	return cell;

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0 && tableView.numberOfSections>1) {
		return @"RECOMMENDATIONS";
	}
	return @"ALL CONNECTIONS";
}

-(void)updateContactView{
     self.contactsView.text = @"";
    for (NSString* selectedItem in self.selectedListOfProfiles) {
        NSString * firstname =  [(JRKFullProfile*)[self.completeProfilesDic objectForKey:selectedItem] firstName];
        NSString * lastname =  [(JRKFullProfile*)[self.completeProfilesDic objectForKey:selectedItem] lastName];
        self.contactsView.text = [self.contactsView.text stringByAppendingString:[NSString stringWithFormat:@" %@ %@ ; ",firstname,lastname]];
    }
    
}

#pragma mark UITableViewDelegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Don't take action when keyboard is on screen
     self.askButton.enabled = self.questionFieldTextView.text.length > 0 && self.selectedListOfProfiles.count >0;
    if ([self.questionFieldTextView isFirstResponder]) {
        [[self view] endEditing:TRUE];
        return;
    }
    
	JRKLinkedInUserTableViewCell* currentCell = (JRKLinkedInUserTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	[currentCell setIsSelected:!currentCell.isSelected];
    
    JRKBasicProfile * profile = nil;
    if(indexPath.section == 0){
        profile = [self.completeProfilesDic objectForKey:[self.recommendedListOfProfiles objectAtIndex:indexPath.row] ];
    }else{
        profile = [self.completeProfilesDic objectForKey:[self.remainingListOfProfiles objectAtIndex:indexPath.row] ];
    }
    if (currentCell.isSelected) {
        [self.selectedListOfProfiles addObject:profile.userId];
    }else{
        [self.selectedListOfProfiles removeObject:profile.userId];
    }
    [self updateContactView];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 25;
}

-(void)updateTableViewWithCurrentRecommendedList:(NSArray*)newList{
    
    //for every object in new list find its index and if it is in remaining list , move
    NSMutableArray* listTobeRemovedFromRecommended = [NSMutableArray array];
    NSMutableArray* listTobeRemovedFromRemaining = [NSMutableArray array];
    
    for(NSString * userId in self.recommendedListOfProfiles){
        if (![newList containsObject:userId]) {
            [listTobeRemovedFromRecommended addObject:userId];
        }
    }
    [self.recommendedListOfProfiles removeObjectsInArray:listTobeRemovedFromRecommended];
    for (NSString* recommUserId in newList) {
        if ([self.remainingListOfProfiles containsObject:recommUserId ]) {
            [listTobeRemovedFromRemaining addObject:recommUserId];
        }
    }
    [self.remainingListOfProfiles removeObjectsInArray:listTobeRemovedFromRemaining ];
    
    //The items in to be moved around are deleted so add them in appropriate array
    [self.remainingListOfProfiles addObjectsFromArray:listTobeRemovedFromRecommended];
    [self.recommendedListOfProfiles addObjectsFromArray:listTobeRemovedFromRemaining];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    
}

-(IBAction)askBtnTapped:(id)sender{
    //save the question , userid asked and ids to be notified in table
}

-(IBAction)searchBtnTapped:(id)sender{
    JRKSearchPeopleController* vc  =[[JRKSearchPeopleController alloc] initWithNibName:@"JRKSearchPeopleController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController.navigationBar setHidden:NO] ;
    
}

@end
