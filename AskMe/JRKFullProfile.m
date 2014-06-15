//
//  JRKFullProfile.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKFullProfile.h"
#import "JRKAppConstants.h"

static NSString *const LinkedInLocationKey  = @"location";
static NSString *const LinkedInPositionHoldKey  = @"positions";
static NSString *const LinkedInSkillsKey  = @"skills";
static NSString *const LinkedInRecommendationsCount  = @"recommendationsReceived";

@implementation JRKFullProfile

-(id) initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super initWithDictionary:dictionary])  {
		if ([dictionary objectForKey:LinkedInLocationKey]) {
			NSDictionary* locationDic = [dictionary objectForKey:LinkedInLocationKey];
			self.locationName = [locationDic objectForKey:@"name"];
		}
        self.skills =[NSMutableArray array];
		if ([dictionary objectForKey:LinkedInSkillsKey]) {
			NSDictionary* SkillsDic = [dictionary objectForKey:LinkedInSkillsKey];
			if([SkillsDic objectForKey:@"values"]){
				NSArray* skillsArrayDic= [SkillsDic objectForKey:@"values"];
				for (NSDictionary * skillDic in skillsArrayDic) {
					if([skillDic objectForKey:@"skill"]){
						NSString* skillName = [[skillDic objectForKey:@"skill"] objectForKey:@"name"];
						if (skillName) {
							[self.skills addObject:skillName];
						}
					}
				}
				
			}
		}
        
		if ([dictionary objectForKey:LinkedInRecommendationsCount]) {
			NSDictionary* recommDic = [dictionary objectForKey:LinkedInLocationKey];
			self.recommendationsReceivedCount = [[recommDic objectForKey:@"_total"] integerValue];
		}
		if ([dictionary objectForKey:LinkedInProfileSpecialitiesKey]) {
			self.specialities = [dictionary objectForKey:LinkedInProfileSpecialitiesKey];
		}
		
		if ([dictionary objectForKey:LinkedInPositionHoldKey]) {
			NSDictionary* positionsDic = [dictionary objectForKey:LinkedInPositionHoldKey];
			if ([positionsDic objectForKey:@"values"]) {
				NSMutableArray* positionHeld =[NSMutableArray array];
				NSArray* postionsArray = [positionsDic objectForKey:@"values"];
				for (NSDictionary * positionDic in postionsArray) {
					[positionHeld addObject:[[JRKPostionHold alloc] initWithDictionary:positionDic]];
				}
				self.postionHoldTillNow = positionHeld;
			}
		}
		self.companiesWorkedAt = [NSMutableArray array];
		for (JRKPostionHold * pos in self.postionHoldTillNow) {
			[self.companiesWorkedAt addObject:pos.company];
		}
	
	}
	return (self);
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
	[super encodeWithCoder:aCoder];
	[aCoder encodeInteger:self.recommendationsReceivedCount forKey:LinkedInRecommendationsCount];
	[aCoder encodeObject:self.locationName forKey:LinkedInLocationKey];
	[aCoder encodeObject:self.specialities forKey:LinkedInProfileSpecialitiesKey];
	[aCoder encodeObject:self.companiesWorkedAt forKey:@"companies"];
	[aCoder encodeObject:self.skills forKey:LinkedInSkillsKey];
	[aCoder encodeObject:self.postionHoldTillNow forKey:LinkedInPositionHoldKey];

}

-(id)initWithCoder:(NSCoder *)aDecoder{
	
	if (self = [super initWithCoder:aDecoder])  {
		self.recommendationsReceivedCount = [aDecoder decodeIntegerForKey:LinkedInRecommendationsCount];
		self.locationName = [aDecoder decodeObjectForKey:LinkedInLocationKey];
		self.specialities = [aDecoder decodeObjectForKey:LinkedInProfileSpecialitiesKey];
		self.companiesWorkedAt = [aDecoder decodeObjectForKey:@"companies"];
		self.skills = [aDecoder decodeObjectForKey:LinkedInSkillsKey];
		self.postionHoldTillNow = [aDecoder decodeObjectForKey:LinkedInPositionHoldKey];
		
	}
	
	
	return self;
}


@end


@implementation JRKCompany

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:self.companyId forKey:@"id"];
	[aCoder encodeObject:self.companyIndustry forKey:@"industry"];
	[aCoder encodeObject:self.companyName forKey:@"name"];
	[aCoder encodeObject:self.companyType forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [self init])  {
		self.companyId = [aDecoder decodeObjectForKey:@"id"];
		self.companyIndustry = [aDecoder decodeObjectForKey:@"industry"];
		self.companyName = [aDecoder decodeObjectForKey:@"name"];
		self.companyType = [aDecoder decodeObjectForKey:@"type"];
		
	}
	return (self);
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init])  {
		if ([dictionary objectForKey:@"id"]) {
			self.companyId = [dictionary objectForKey:@"id"];
		}
		if ([dictionary objectForKey:@"industry"]) {
			self.companyIndustry = [dictionary objectForKey:@"industry"];
		}
		if ([dictionary objectForKey:@"name"]) {
			self.companyName = [dictionary objectForKey:@"name"];
		}
		if ([dictionary objectForKey:@"type"]) {
			self.companyType = [dictionary objectForKey:@"type"];
		}
	}
	return (self);
}


@end

@implementation JRKPostionHold

- (void)encodeWithCoder:(NSCoder *)aCoder{
	[aCoder encodeObject:self.positionSummary forKey:@"summary"];
	[aCoder encodeObject:self.positionTitle forKey:@"title"];
	[aCoder encodeObject:self.company forKey:@"company"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
	if (self = [self init])  {
		self.positionSummary = [aDecoder decodeObjectForKey:@"summary"];
		self.positionTitle = [aDecoder decodeObjectForKey:@"title"];
		self.company = [aDecoder decodeObjectForKey:@"company"];
			
	}
	return (self);
}

-(id) initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init])  {
		if ([dictionary objectForKey:@"summary"]) {
			self.positionSummary = [dictionary objectForKey:@"summary"];
		}
		if ([dictionary objectForKey:@"title"]) {
			self.positionTitle = [dictionary objectForKey:@"title"];
		}
		if ([dictionary objectForKey:@"company"]) {
			self.company = [[JRKCompany alloc] initWithDictionary:[dictionary objectForKey:@"company"]];
		}
	}
	return (self);
}


@end