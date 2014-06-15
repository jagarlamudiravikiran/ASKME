//
//  JRKUserInfo.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKUserInfo.h"

static NSString *const JRKUserInfoUserIdKey  = @"userId";
static NSString *const JRKUserInfoSessionTokenKey  = @"sessionToken";
static NSString *const JRKUserInfoUserProfileKey  = @"UserProfileKey";
static NSString *const JRKUserInfoConnectionSetKey  = @"ConnectionSetKey";
static NSString *const JRKUserInfoCompleteParsedTextKey = @"CompleteParsedTextKey";

@implementation JRKUserInfo

-(void) encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.uid forKey:JRKUserInfoUserIdKey];
	[coder encodeObject:self.sessionToken forKey:JRKUserInfoSessionTokenKey];
	[coder encodeObject:self.loggedInUserProfile forKey:JRKUserInfoUserProfileKey];
	[coder encodeObject:self.connectionsSet forKey:JRKUserInfoConnectionSetKey];
	[coder encodeObject:self.completeParsedTextSummary forKey:JRKUserInfoCompleteParsedTextKey];
}



-(id) initWithCoder:(NSCoder *)coder {
	if (self = [self init])  {
		self.sessionToken = [coder decodeObjectForKey:JRKUserInfoSessionTokenKey];
		self.completeParsedTextSummary = [coder decodeObjectForKey:JRKUserInfoCompleteParsedTextKey];
		self.connectionsSet = [coder decodeObjectForKey:JRKUserInfoConnectionSetKey];
		self.loggedInUserProfile = [coder decodeObjectForKey:JRKUserInfoUserProfileKey];
        self.uid = [coder decodeObjectForKey:JRKUserInfoUserIdKey];
	}
	return (self);
}

-(void) updateWithDictionary:(NSDictionary *)dictionary {
	self.uid= [dictionary objectForKey:@"id"];
	self.loggedInUserProfile = [[JRKFullProfile alloc] initWithDictionary:dictionary];
	
	//construct the complete summary
	[self processCompleteParsedTextSummary];
}

-(void) updateConnectionsFromDictionary:(NSDictionary *)dictionary {
	self.numOfTotalConnections = [[dictionary objectForKey:@"_total"] integerValue];
	[self updateConnections:[dictionary objectForKey:@"values"]];
}

-(void)updateConnections:(NSArray*)arrayOfConnections{
	NSMutableOrderedSet * tempConectionsSet =[[NSMutableOrderedSet alloc] initWithOrderedSet:self.connectionsSet];
	for (NSDictionary* connectionDic in arrayOfConnections) {
		[tempConectionsSet addObject:[[JRKBasicProfile alloc] initWithDictionary:connectionDic]];
	}	
	self.connectionsSet = tempConectionsSet;
}

-(void)processCompleteParsedTextSummary{
	
	NSString* textFromCompany = @"";
	for (JRKPostionHold* position in self.loggedInUserProfile.postionHoldTillNow) {
		textFromCompany = [textFromCompany stringByAppendingString:[NSString stringWithFormat:@" %@ . %@ . ",position.positionSummary,position.positionTitle]];
	}
	
	NSString* textFromSkills = @"";
	for (NSString* skill in self.loggedInUserProfile.skills) {
		[textFromSkills stringByAppendingString:[NSString stringWithFormat:@"%@ ,",skill]];
	}
	
	self.completeParsedTextSummary = [NSString stringWithFormat:@"%@ %@ %@ ",textFromSkills,textFromCompany,self.loggedInUserProfile.specialities];
}

@end
