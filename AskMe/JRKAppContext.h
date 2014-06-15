//
//  JRKAppContext.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JRKUserInfo;

@interface JRKAppContext : NSObject

@property (nonatomic, strong) JRKUserInfo * userInfo;
+(JRKAppContext *) instance ;
- (void)connectWithLinkedIn;
-(void)getRecommendedUsers:(NSString*)question andPerformBlock:(void (^)(NSArray*))block;
- (void)searchLinkedInWithKeywords:(NSString*)keywords completionBlock:(void (^)(id))block;


@end
