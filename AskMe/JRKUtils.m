//
//  JRKUtils.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/13/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKUtils.h"
#import "JRKUserInfo.h"

@implementation JRKUtils
+(NSString *) getTempDirectoryPath {
    return NSTemporaryDirectory();
}

+(NSString *) getDocumentsPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * path = [paths objectAtIndex:0];
	return path;
}

+(NSString *) getLibraryPath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString * path = [paths objectAtIndex:0];
	return path;
}

+(NSString *) getCachePath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString * path = [paths objectAtIndex:0];
	return path;
}

+(NSString *) getDataCachePath {
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString * path = [paths objectAtIndex:0];
	return [path stringByAppendingString:@"/Data"];
}

+(void) mkdir:(NSString *)path {
	NSFileManager * manager = [NSFileManager defaultManager];
	if(![manager fileExistsAtPath:path]) {
		NSError * error = nil;
		if(![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error] || error) {
			NSLog(@"================================================================");
			NSLog(@"  could not create folder: %@", path);
			NSLog(@"  with error: %@", error);
			NSLog(@"================================================================");
		}
	} else {
		NSLog(@"folder %@ already exists", path);
	}
}
+(NSString *)userAccountPath {
	return [[JRKUtils getDocumentsPath] stringByAppendingPathComponent:@"user.info"];
}
+(UIColor *)colorWithCode:(int)code {
    int red = (code >> 16) & 0x000000FF;
    int green = (code >> 8) & 0x000000FF;
    int blue = (code) & 0x000000FF;
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
}


+(void) saveUserInfo:(JRKUserInfo*)info {
	
	NSString * path = [JRKUtils userAccountPath];
	//Save to file.
	if (!info) {
		//Set to nil. We should remove user.info
		NSFileManager* fm = [[NSFileManager alloc] init];
		if (![fm removeItemAtPath:path error:nil]) {
			NSLog(@"could not remove: %@", path);
		}
	} else {
		if(![NSKeyedArchiver archiveRootObject:info toFile:path]) {
			NSLog(@"could not save: %@ into %@", info, path);
		} else {
			NSLog(@"saved: %@", info);
		}
	}
		
}

+ (void)deleteCurrentUserAccount{
	// remove user info
    [JRKUtils saveUserInfo:nil];
}


@end
