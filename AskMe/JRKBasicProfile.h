//
//  JRKBasicProfile.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRKBasicProfile : NSObject<NSCoding>

@property(nonatomic, copy) NSString* firstName;
@property(nonatomic, copy) NSString*  lastName;
@property(nonatomic, copy) NSString*  headLine;
@property(nonatomic, copy) NSString*  userId;

@property(nonatomic, copy) NSString*  summary;
@property(nonatomic, copy) NSString*  industry;
@property(nonatomic, copy) NSString*  title;
@property(nonatomic, copy) NSString*  pictureUrl;
@property(nonatomic, copy) NSString*  specialities;

-(id) initWithDictionary:(NSDictionary *)dictionary;

-(NSString*)fullName;

@end
