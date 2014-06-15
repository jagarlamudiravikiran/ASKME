//
//  JRKFullProfile.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKBasicProfile.h"


@interface JRKCompany : NSObject <NSCoding>

@property (nonatomic, copy) NSString* companyId;
@property (nonatomic, copy) NSString* companyName;
@property (nonatomic, copy) NSString* companyType;
@property (nonatomic, copy) NSString* companyIndustry;
-(id) initWithDictionary:(NSDictionary *)dictionary;

@end

@interface JRKPostionHold : NSObject<NSCoding>

@property (nonatomic, strong) JRKCompany* company;
@property (nonatomic, copy) NSString* positionSummary;
@property (nonatomic, copy) NSString* positionTitle;
-(id) initWithDictionary:(NSDictionary *)dictionary;

@end

@interface JRKFullProfile : JRKBasicProfile<NSCoding>

@property (nonatomic, assign) NSInteger recommendationsReceivedCount;
@property (nonatomic, copy) NSString* locationName;
@property (nonatomic, copy) NSString* specialities;
@property (nonatomic, strong) NSMutableArray* companiesWorkedAt;
@property (nonatomic, strong) NSMutableArray* skills;
@property (nonatomic, strong) NSArray* postionHoldTillNow;

@end
