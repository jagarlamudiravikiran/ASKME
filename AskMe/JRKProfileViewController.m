//
//  JRKFirstViewController.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKProfileViewController.h"
#import "JRKAppContext.h"
#import "JRKAppConstants.h"
#import "JRKFullProfile.h"
#import "JRKUserInfo.h"
#import <TMCache.h>

#import <QuartzCore/QuartzCore.h>

@interface JRKProfileViewController ()

@end

@implementation JRKProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self initilaizeUI];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionSetUpSuceeded:) name:SessionSetupSucceedNotification object:nil];
	// Do any additional setup after loading the view, typically from a nib.
	[[JRKAppContext instance] connectWithLinkedIn];
    
    //update UI from accahe
    if ([[[JRKAppContext instance] userInfo] loggedInUserProfile]) {
        [self updateUIWithFirstName:[[[[JRKAppContext instance] userInfo] loggedInUserProfile] firstName] lastName:[[[[JRKAppContext instance] userInfo] loggedInUserProfile] lastName] profilePic:[[[[JRKAppContext instance] userInfo] loggedInUserProfile] pictureUrl] headLine:[[[[JRKAppContext instance] userInfo] loggedInUserProfile] headLine]];
        [self fillprofileDetails];
    }
    
}

-(void)initilaizeUI{
    
    self.profileDetailsHolderView.layer.borderWidth = 1.0f;
    self.profileDetailsHolderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.profileDetailsHolderView.layer.cornerRadius = 5.0f;
    self.profileDetailsHolderView.clipsToBounds = YES;
    
	NSString* firstName = [[[[JRKAppContext instance] userInfo] loggedInUserProfile] firstName];
	NSString* lastName = [[[[JRKAppContext instance] userInfo] loggedInUserProfile] lastName];
	self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",firstName.length > 0 ?firstName:@"",lastName.length>0?lastName:@""];
	self.headLineLabel.text = [[[[JRKAppContext instance] userInfo] loggedInUserProfile] headLine];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[JRKAppContext instance] connectWithLinkedIn];
    });
}

-(void)sessionSetUpSuceeded:(NSNotification*)notification{
	NSDictionary * userInfo = notification.userInfo;
	NSString* firstName = @"";
	if ([userInfo objectForKey:LinkedInFirstNameKey]) {
		firstName = [userInfo objectForKey:LinkedInFirstNameKey];
	}
	NSString* lastName = @"";
    NSString* headLine = @"";
	if ([userInfo objectForKey:LinkedInLastNameKey]) {
		lastName = [userInfo objectForKey:LinkedInLastNameKey];
	}
	self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
	if ([userInfo objectForKey:LinkedInHeadLineKey]) {
		headLine = [userInfo objectForKey:LinkedInHeadLineKey];
	}
    [self updateUIWithFirstName:firstName lastName:lastName profilePic:[notification.userInfo objectForKey:LinkedInProfilePictureUrlKey] headLine:headLine];
    [[JRKAppContext instance].userInfo updateWithDictionary:userInfo];
    [self fillprofileDetails];
    
    
}
-(void)updateUIWithFirstName:(NSString*)firstName lastName:(NSString*)lastName profilePic:(NSString*)profilePicURL headLine:(NSString*)headLine{
    
	self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
	self.headLineLabel.text = headLine;
    //	NSURL *imageURL = [NSURL URLWithString:[userInfo objectForKey:LinkedInProfilePictureUrlKey]];
    //	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    //	[self.profileImageView setImage:[UIImage imageWithData:imageData]];
    [[TMCache sharedCache] objectForKey:profilePicURL
								  block:^(TMCache *cache, NSString *key, id object) {
									  UIImage *image = (UIImage *)object;
									  if (!image) {
										  NSURL *imageURL = [NSURL URLWithString:profilePicURL];
										  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
										  if (imageData) {
											  dispatch_async(dispatch_get_main_queue(), ^{
												  [self.profileImageView setImage:[UIImage imageWithData:imageData]];
											  });
										  }
										  UIImage *img = [[UIImage alloc] initWithData:imageData scale:[[UIScreen mainScreen] scale]];
										  [[TMCache sharedCache] setObject:img forKey:profilePicURL block:nil]; // returns immediately
									  }else{
										  dispatch_async(dispatch_get_main_queue(), ^{
											  self.profileImageView.image = image;
										  });
									  }
									  
								  }];
    
    
}



-(void)fillprofileDetails{
    NSString * skillsText =@"";
    for (NSString* str in [[[[JRKAppContext instance] userInfo] loggedInUserProfile] skills]) {
        skillsText = [skillsText stringByAppendingString:str];
        skillsText = [skillsText stringByAppendingString:@", "];
    }
    self.skillsTextLabel.text = skillsText ;
    
    CGSize constrainedSize = CGSizeMake(self.skillsTextLabel.frame.size.width  , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          self.skillsTextLabel.font, NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.skillsTextLabel.text attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (requiredHeight.size.width > self.skillsTextLabel.frame.size.width) {
        requiredHeight = CGRectMake(0,0, self.skillsTextLabel.frame.size.width, requiredHeight.size.height);
    }
    CGRect newFrame = self.skillsTextLabel.frame;
    newFrame.size.height = requiredHeight.size.height;
    self.skillsTextLabel.frame = newFrame;
    
    if (self.skillsTextLabel.frame.origin.y + self.skillsTextLabel.frame.size.height > self.profileDetailsScrollView.frame.size.height) {
        NSLog(@"Increasing scrollview size");
        self.profileDetailsScrollView.contentSize = CGSizeMake(self.profileDetailsScrollView.contentSize.width, (self.skillsTextLabel.frame.origin.y + self.skillsTextLabel.frame.size.height + 10.0));
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[[self view] endEditing:TRUE];
}
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
