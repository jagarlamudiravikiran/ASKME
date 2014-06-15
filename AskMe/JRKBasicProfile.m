//
//  JRKBasicProfile.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKBasicProfile.h"
#import "JRKAppConstants.h"

@implementation JRKBasicProfile

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:self.firstName forKey:LinkedInFirstNameKey];
	[aCoder encodeObject:self.lastName forKey:LinkedInLastNameKey];
	[aCoder encodeObject:self.headLine forKey:LinkedInHeadLineKey];
	[aCoder encodeObject:self.userId forKey:LinkedInUserIdKey];
	[aCoder encodeObject:self.specialities forKey:LinkedInProfileSpecialitiesKey];
	[aCoder encodeObject:self.industry forKey:LinkedInIndustryKey];
	[aCoder encodeObject:self.summary forKey:LinkedInSummaryKey];
	[aCoder encodeObject:self.pictureUrl forKey:LinkedInProfilePictureUrlKey];
	[aCoder encodeObject:self.title forKey:LinkedInTitleKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [self init])  {
		self.firstName = [aDecoder decodeObjectForKey:LinkedInFirstNameKey];
		self.lastName = [aDecoder decodeObjectForKey:LinkedInLastNameKey];
		self.headLine = [aDecoder decodeObjectForKey:LinkedInHeadLineKey];
		self.userId = [aDecoder decodeObjectForKey:LinkedInUserIdKey];
		self.industry = [aDecoder decodeObjectForKey:LinkedInIndustryKey];
		self.specialities = [aDecoder decodeObjectForKey:LinkedInProfileSpecialitiesKey];
		self.summary = [aDecoder decodeObjectForKey:LinkedInSummaryKey];
		self.pictureUrl = [aDecoder decodeObjectForKey:LinkedInProfilePictureUrlKey];
		self.title = [aDecoder decodeObjectForKey:LinkedInTitleKey];
	}
	return (self);
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init])  {
		if ([dictionary objectForKey:LinkedInFirstNameKey]) {
			self.firstName = [dictionary objectForKey:LinkedInFirstNameKey];
		}
		if ([dictionary objectForKey:LinkedInLastNameKey]) {
			self.lastName = [dictionary objectForKey:LinkedInLastNameKey];
		}
		if ([dictionary objectForKey:LinkedInHeadLineKey]) {
			self.headLine = [dictionary objectForKey:LinkedInHeadLineKey];
		}
		if ([dictionary objectForKey:LinkedInUserIdKey]) {
			self.userId = [dictionary objectForKey:LinkedInUserIdKey];
		}
		if ([dictionary objectForKey:LinkedInIndustryKey]) {
			self.industry = [dictionary objectForKey:LinkedInUserIdKey];
		}
		if ([dictionary objectForKey:LinkedInSummaryKey]) {
			self.summary = [dictionary objectForKey:LinkedInSummaryKey];
		}
		if ([dictionary objectForKey:LinkedInTitleKey]) {
			self.title = [dictionary objectForKey:LinkedInTitleKey];
		}
		if ([dictionary objectForKey:LinkedInProfilePictureUrlKey]) {
			self.pictureUrl = [dictionary objectForKey:LinkedInProfilePictureUrlKey];
		}
		if ([dictionary objectForKey:LinkedInProfileSpecialitiesKey]) {
			self.specialities = [dictionary objectForKey:LinkedInProfileSpecialitiesKey];
		}
	}
	return (self);
}

-(BOOL)isEqual:(id)object{
	if (![object isKindOfClass:[JRKBasicProfile class]]) {
		return NO;
	}
	return [[(JRKBasicProfile*)object userId] isEqualToString:self.userId];
}

-(NSString*)fullName{
	return [NSString stringWithFormat:@"%@ %@",self.firstName.length>0?self.firstName:@"",self.lastName.length>0?self.lastName:@""];
}


@end
