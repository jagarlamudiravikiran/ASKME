//
//  JRKUtils.h
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JRKUserInfo;

@interface JRKUtils : NSObject
+(NSString *) getDocumentsPath;
+(NSString *) getLibraryPath;
+(NSString *) getDataCachePath;
+(NSString *) getCachePath;
+(void) mkdir:(NSString *)path;
+(NSString *)userAccountPath;
+(UIColor *)colorWithCode:(int)code;
+(void) saveUserInfo:(JRKUserInfo*)info ;
+ (void)deleteCurrentUserAccount;

@end
