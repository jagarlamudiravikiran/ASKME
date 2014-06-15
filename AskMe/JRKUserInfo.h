//
//  JRKUserInfo.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRKBasicProfile.h"
#import "JRKFullProfile.h"

@interface JRKUserInfo : NSObject<NSCoding>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, strong) JRKFullProfile * loggedInUserProfile;
@property (nonatomic, strong) NSOrderedSet * connectionsSet;
@property (nonatomic, assign) NSInteger numOfTotalConnections;

@property (nonatomic, copy) NSString * completeParsedTextSummary;

-(void) updateConnectionsFromDictionary:(NSDictionary *)dictionary;
-(void) updateWithDictionary:(NSDictionary *)dictionary;
@end
