//
//  JRKAppContext.m
//  AskMe
//
//  Created by Jagarlamudi, Ravikiran on 6/12/14.
//  Copyright (c) 2014 Individual. All rights reserved.
//

#import "JRKAppContext.h"
#import "JRKUserInfo.h"
#import "JRKAppDelegate.h"
#import <Parse/Parse.h>

#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

#import "JRKAppConstants.h"
#import "NSString+LIAEncode.h"
#import "JRKUtils.h"

#define LINKEDIN_CLIENT_ID @""
#define LINKEDIN_CLIENT_SECRET @""

#define PARSE_CLIENT_SECRET @""
#define PARSE_APPLICATION_ID @""

@interface JRKAppContext (){
	 LIALinkedInHttpClient *_client;
    NSMutableDictionary* _connectionProfileDetails;
     NSMutableDictionary* _NLPProcessedDetails;
}

@end

@implementation JRKAppContext

+(JRKAppContext *) instance {
    
    //Singleton
    static JRKAppContext* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JRKAppContext alloc] init];
    });
    
    return sharedInstance;
}

-(JRKAppContext*)init{
	if (self = [super init]) {
		_client = [self client];
        _connectionProfileDetails = [NSMutableDictionary dictionary];
        _NLPProcessedDetails= [NSMutableDictionary dictionary];
		[Parse setApplicationId:PARSE_APPLICATION_ID
					  clientKey:PARSE_CLIENT_SECRET];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionSetUpSuceeded:) name:SessionSetupSucceedNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetMyConnectionsSucceeded:) name:GetMyConnectionsSucceedNotification object:nil];
		
	}
	return self;
}


- (void)connectWithLinkedIn{
	
	//if the access tolen is not present then proceed
	if (self.userInfo.sessionToken) {
        
		return;
	}
	
	[self.client getAuthorizationCode:^(NSString *code) {
		[self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
			NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
			self.userInfo.sessionToken = accessToken;
			[self requestMeWithToken:accessToken];
		}                   failure:^(NSError *error) {
			NSLog(@"Quering accessToken failed %@", error);
		}];
	}                      cancel:^{
		NSLog(@"Authorization was cancelled by user");
	}                     failure:^(NSError *error) {
		NSLog(@"Authorization failed %@", error);
	}];
}

#pragma mark - BATCH API REQUESTS

-(void)makeBatchRequestForConnectionDetail{
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < self.userInfo.connectionsSet.count; i++) {
        // Enter the group for each request we create
        dispatch_group_enter(group);
//        if ([[(JRKBasicProfile*)[self.userInfo.connectionsSet objectAtIndex:i] userId] isEqualToString:@"private"]) {
//            NSLog(@"skip getting profile details for %@ as userid is private",[(JRKBasicProfile*)[self.userInfo.connectionsSet objectAtIndex:i] firstName]);
//            continue;
//        }
        
        //https://api.linkedin.com/v1/people/id=t95IsFtHMB:(id,headline,honors,summary,specialties,num-recommenders)?oauth2_access_token=%@&format=json
        // Fire the request
        [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/id=%@:(id,headline,honors,summary,specialties,num-recommenders)?oauth2_access_token=%@&format=json", [(JRKBasicProfile*)[self.userInfo.connectionsSet objectAtIndex:i] userId],self.userInfo.sessionToken]
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              //save it in Dictionay of connection details
              NSString* summmary = [responseObject objectForKey:@"summary"];
              NSString* specialties = [responseObject objectForKey:@"specialties"];
              NSString* headline = [responseObject objectForKey:@"headline"];
              NSString* consolidatedSummary = @"";
              if (summmary.length > 0) {
                  consolidatedSummary = [[[consolidatedSummary stringByAppendingString:headline?:@""] stringByAppendingString:summmary] stringByAppendingString:specialties?:@""];
                  [_connectionProfileDetails setObject:consolidatedSummary forKey:[responseObject objectForKey:@"id"]];
              }
              // Leave the group as soon as the request succeeded
              dispatch_group_leave(group);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Falied to get connection detail of:%@",operation.request.URL);
              // Leave the group as soon as the request completed
              dispatch_group_leave(group);
          }];
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [self makeBatchRequestForALCHEMYAPIDetail];
    });
    
}

-(void)makeBatchRequestForALCHEMYAPIDetail{
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString* userid in  _connectionProfileDetails.allKeys) {
        // Enter the group for each request we create
        dispatch_group_enter(group);
//        if ([[_connectionProfileDetails objectForKey:userid] length] == 0) {
//            continue;
//        }
        
        NSString* alchemyUrl = [NSString stringWithFormat: @"http://access.alchemyapi.com/calls/text/TextGetRankedKeywords?apikey=@""&text=%@&outputMode=json",[[_connectionProfileDetails objectForKey:userid] LIAEncode]];
        
        // Fire the request
        [self.client GET:alchemyUrl
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //save it in Dictionay of connection details
                     NSArray* keyWordsArrayJSON = [responseObject objectForKey:@"keywords" ];
                     [_NLPProcessedDetails setObject:keyWordsArrayJSON forKey:userid];
                     // Leave the group as soon as the request succeeded
                     dispatch_group_leave(group);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Failed to get NLP for detail :%@",operation.request.URL);
                     // Leave the group as soon as the request completed
                     dispatch_group_leave(group);
                 }];
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        NSLog(@"Finshed processing alchemy API:%d count ",[_NLPProcessedDetails count]);
    });
    
}



#pragma mark - API REQUESTS

- (void)searchLinkedInWithKeywords:(NSString*)keywords completionBlock:(void (^)(id))block{

	
	[self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,site-standard-profile-request,headline,honors,location:(name,country:(code)),industry,current-share,num-connections,summary,specialties,proposal-comments,associations,interests,positions,publications,patents,languages:(id),skills,certifications,educations,num-recommenders,recommendations-received)?oauth2_access_token=%@&format=json", self.userInfo.sessionToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
		if (block!=NULL) {
            block(result);
        }
		
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failed to fetch current user %@", error);
	}];
}


- (void)requestMeWithToken:(NSString *)accessToken {
	
	//https://api.linkedin.com/v1/people/~:(id,headline,first-name,last-name)?oauth2_access_token=%@&format=json
	
	[self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,site-standard-profile-request,headline,honors,location:(name,country:(code)),industry,current-share,num-connections,summary,specialties,proposal-comments,associations,interests,positions,publications,patents,languages:(id),skills,certifications,educations,num-recommenders,recommendations-received)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
		//NSLog(@"current user %@", result);
		//create PFObject/PFUser Object
		//Pass on Notification to update the First Welcome Screen and proceed to
		[[NSNotificationCenter defaultCenter] postNotificationName:SessionSetupSucceedNotification object:nil userInfo:result];
		//Fetch the connections
		//http://api.linkedin.com/v1/people/~/connections
		
	}        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failed to fetch current user %@", error);
	}];
}

- (void)requestGetMyConnectionsWithToken:(NSString *)accessToken {
	[self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,public-profile-url,picture-url,industry,headline,honors,summary,specialties,proposal-comments,associations,interests,positions)?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
		//NSLog(@"current user connections %@", result);
		[self.userInfo updateConnectionsFromDictionary:result];
		[JRKUtils saveUserInfo:self.userInfo];
		
		//Pass on Notification to update the First Welcome Screen and proceed to
		[[NSNotificationCenter defaultCenter] postNotificationName:GetMyConnectionsSucceedNotification object:nil userInfo:result];
		
	}        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failed to fetch connections of current user %@", error);
	}];
}
-(void)getKeyWordsFromAlchemyAPIForSummary:(NSString*)summary{
    [self getKeyWordsFromAlchemyAPIForSummary:summary getRelavanceOnComplete:NO andPerformBlock:nil userId:(self.userInfo.loggedInUserProfile.userId.length>0 ?self.userInfo.loggedInUserProfile.userId:self.userInfo.uid)];
}

-(void)getKeyWordsFromAlchemyAPIForSummary:(NSString*)summary getRelavanceOnComplete:(BOOL)getRelavance andPerformBlock:(void (^)(NSArray*))updateTableBlock userId:(NSString*)userId{
    
	NSString* alchemyUrl = [NSString stringWithFormat: @"http://access.alchemyapi.com/calls/text/TextGetRankedKeywords?apikey=@""&text=%@&outputMode=json",[summary LIAEncode]];
	
	NSLog(@"Sending to alchemy :%@",alchemyUrl);
	
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager GET:alchemyUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"JSON: %@", responseObject);
		//Write to parse "for each keyword in keywords , add this user to userlist
		NSArray* keyWordsArrayJSON = [responseObject objectForKey:@"keywords" ];
        NSMutableArray* keyWords_arr = [NSMutableArray array];
       
		NSString* testSearchKeyWord =nil;
		NSMutableArray* pfObjectsOfkeywordAndUserIds = [NSMutableArray array];
		for (NSDictionary* keywordRelavanceDicJSON in keyWordsArrayJSON) {
			NSString* relavance =  [keywordRelavanceDicJSON objectForKey:@"relevance"];
			NSString* keyword = [keywordRelavanceDicJSON objectForKey:@"text"];
			NSMutableDictionary* keywordRelavanceDic = [NSMutableDictionary dictionary ];
            // //words in keywordRelavanceDic used for writing to table
			[keywordRelavanceDic setObject:relavance forKey:@"relevance"];
			[keywordRelavanceDic setObject:[keyword lowercaseString] forKey:@"keyword"];
			[keywordRelavanceDic setObject:userId forKey:@"userId"];
            //words in keyWords_arr used for seraching and also to filter
            [keyWords_arr addObject:[keyword lowercaseString]];
			if (!testSearchKeyWord) {
				testSearchKeyWord = keyword;
			}
			
			PFObject * obj =[PFObject objectWithClassName:UserIdKeywordRelavanceClassName dictionary:keywordRelavanceDic];
			[pfObjectsOfkeywordAndUserIds addObject:obj];
		}
        
        if (getRelavance) {
             [self findObjectsInRelavanceTableForKeyWord:keyWords_arr andPerformBlock:updateTableBlock];
        }else{
            
            //save only the objects whose keyword + userid combo is not present
            PFQuery *query = [PFQuery queryWithClassName:UserIdKeywordRelavanceClassName];
            [query whereKey:@"keyword" containedIn:keyWords_arr];
            
            PFQuery *query2 = [PFQuery queryWithClassName:UserIdKeywordRelavanceClassName];
            [query2 whereKey:@"userId" equalTo:self.userInfo.uid];
            
            PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[query,query2]];
            [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"Succesfully fetched objects for userid and keyword combinations");
                if (!error) {
                    //removed already pfobjects from tobe saved list
                    for (NSDictionary* objFromTable in objects) {
                        PFObject* objectTobeRemoved =nil;
                        for (PFObject* obj in pfObjectsOfkeywordAndUserIds) {
                            if ([obj[@"userId"] isEqualToString:objFromTable[@"userId"]] && [obj[@"keyword"] isEqualToString:objFromTable[@"keyword"]]) {
                                objectTobeRemoved = obj;
                                break;
                            }
                        }
                        
                        [pfObjectsOfkeywordAndUserIds removeObject:objectTobeRemoved];
                    }

                }
                if (pfObjectsOfkeywordAndUserIds.count > 0) {
                    [PFObject saveAllInBackground:pfObjectsOfkeywordAndUserIds block:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            NSLog(@"Succesfully saved relavance userid keyword pairs");
                            //now query on "objective-c"
                            //[self findObjectsInRelavanceTableForKeyWord:[NSArray arrayWithObject:testSearchKeyWord]];
                            
                        }else{
                            NSLog(@"Failed to save relavance userid keyword pairs");
                        }
                    }];
                }
                
                
            }];
            
        }
        
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
	
}



-(void)getRecommendedUsers:(NSString*)question andPerformBlock:(void (^)(NSArray*))block{
    [self getKeyWordsFromAlchemyAPIForSummary:question getRelavanceOnComplete:YES andPerformBlock:block userId:self.userInfo.uid];
    
}

#pragma mark - Private Methods

-(void)sessionSetUpSuceeded:(NSNotification*)notification{
	NSDictionary* userInfo = notification.userInfo;
	[self.userInfo updateWithDictionary:userInfo];
	[self getKeyWordsFromAlchemyAPIForSummary:self.userInfo.completeParsedTextSummary];
	
	//create or update pfobject from user info
	[self createOrUpdatePFObject:userInfo];
	
	//get connections
	[self requestGetMyConnectionsWithToken:self.userInfo.sessionToken];
}

-(void)GetMyConnectionsSucceeded:(NSNotification*)notification{
	NSDictionary *result = notification.userInfo;
	[self createOrUpdateConnections:[result objectForKey:@"values"]];
}
-(void)createOrUpdateConnections:(NSArray*)connectionsArrayJSON{
	if (connectionsArrayJSON.count == 0 || !connectionsArrayJSON) {
		return;
	}
	
	NSMutableArray* userIdsInconnectionsArrayJSON = [NSMutableArray array];
	
	for (NSDictionary* userInfoDic in connectionsArrayJSON) {
		if ([userInfoDic objectForKey:LinkedInUserIdKey]) {
			[userIdsInconnectionsArrayJSON addObject:[userInfoDic objectForKey:LinkedInUserIdKey]];
		}
	}
	
	PFQuery *query = [PFQuery queryWithClassName:UserProfileClassName];
	[query whereKey:LinkedInUserIdKey containedIn:userIdsInconnectionsArrayJSON];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			
			NSMutableArray* pfObjectsToBeSaved = [NSMutableArray array];
			/*
			NSMutableArray* userIdsInDB = [NSMutableArray array];
			// Do something with the found objects
			for (PFObject *object in objects) {
				//update the object info with latest JSON
				
				[pfObjectsToBeSaved addObject:object];
				[userIdsInDB addObject:object[LinkedInUserIdKey]];
			}
			//update the not found ids array
			NSMutableArray* userIdsNotInParseDB = [NSMutableArray arrayWithArray:userIdsInconnectionsArrayJSON];
			[userIdsNotInParseDB removeObjectsInArray:userIdsInDB];
			 
			 */
			
			//for users not in DB create them in DB;
			for (NSDictionary* userInfo in connectionsArrayJSON) {
				BOOL objectFound = NO;
				for (PFObject *object in objects) {
					if ([object[@"id"] isEqualToString:[userInfo objectForKey:@"id"]]) {
						objectFound = YES;
						//update the object
						[userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
							object[key]=obj;
						} ];
						[pfObjectsToBeSaved addObject:object];
						break;
					}
				}
				if (!objectFound) {
					PFObject* myProfile =  [PFObject objectWithClassName:UserProfileClassName dictionary:userInfo];
					[pfObjectsToBeSaved addObject:myProfile];
				}
			}
			
			[PFObject saveAllInBackground:pfObjectsToBeSaved block:^(BOOL succeeded, NSError *error) {
				if (!error) {
					NSLog(@"current user connections written to DB");
                    //[self makeBatchRequestForConnectionDetail ];
				}else{
					NSLog(@"Failed to Update current user Connections,%@",error);
				}
			}];
			
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];
}


-(void)createOrUpdatePFObject:(NSDictionary*)userInfo{
	PFQuery *query = [PFQuery queryWithClassName:UserProfileClassName];
	[query whereKey:@"id" equalTo:[userInfo objectForKey:@"id"]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			BOOL objectNotFound = YES;
			// Do something with the found objects
			for (PFObject *object in objects) {
				if ([object[@"id"] isEqualToString:[userInfo objectForKey:@"id"]]) {
					[userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
						object[key] = obj;
					} ];
					objectNotFound = NO;
					[object saveInBackground];
					break;
				}
			}
			
			if (objectNotFound) {
				PFObject* myProfile =  [PFObject objectWithClassName:UserProfileClassName dictionary:userInfo];
				[myProfile saveInBackground];
			}
			
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];
}

-(void)findObjectsInRelavanceTableForKeyWord:(NSArray*)keywords{
    [self findObjectsInRelavanceTableForKeyWord:keywords andPerformBlock:nil];
}

-(void)findObjectsInRelavanceTableForKeyWord:(NSArray*)keywords andPerformBlock:(void (^)(NSArray*))block{
	PFQuery *query = [PFQuery queryWithClassName:UserIdKeywordRelavanceClassName];
	[query whereKey:@"keyword" containedIn:keywords];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray* userIds =[NSMutableArray array];
		if (!error) {
			// Do something with the found objects
            
            //sort objects using relavance
            [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if([obj1[@"relevance"] floatValue] > [obj2[@"relevance"] floatValue]){
                    return NSOrderedDescending;
                }else{
                     return NSOrderedAscending;
                }
            }];
			for (PFObject *object in objects) {
				NSLog(@"Found relavance:%@",object);
                [userIds addObject:object[@"userId"]];
			}
			NSLog(@"Found relavant objects count :%d",[objects count]);
            
            
			
		} else {
			// Log details of the failure
			NSLog(@"Error in finding relavance: %@ %@", error, [error userInfo]);
		}
        if (block!=NULL) {
            block(userIds);
        }
	}];

}

#pragma mark - Getter Methods

- (LIALinkedInHttpClient *)client {
	LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"https://www.google.com/"
																					clientId:LINKEDIN_CLIENT_ID
																				clientSecret:LINKEDIN_CLIENT_SECRET
																					   state:@"DCEEFWF45453sdffef424"
																			   grantedAccess:@[@"r_fullprofile", @"r_network"]];
	return [LIALinkedInHttpClient clientForApplication:application presentingViewController:[[(JRKAppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController]];
   // return [LIALinkedInHttpClient clientForApplication:application presentingViewController:[(JRKAppDelegate*)[[UIApplication sharedApplication] delegate] window]];
}


-(JRKUserInfo*)userInfo{
	if (_userInfo) {
		return _userInfo;
	}
		
	if (!_userInfo) {
		NSString * path = [JRKUtils userAccountPath];
        @try {
			if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
				_userInfo  = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
			}else{
				_userInfo = [[JRKUserInfo alloc] init];
			}
            
        }
        @catch (NSException *exception) {
            // clear user cache
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
			
            if (error) {
                NSLog(@"Could not clear user info at path: %@, received error: %@", path, error.localizedDescription);
            }
        }
	}
	
	return _userInfo;
	
}

@end
