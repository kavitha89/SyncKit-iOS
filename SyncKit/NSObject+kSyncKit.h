//
//  NSObject+kSyncKit.h
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (kSyncKit)

- (NSDate *)mostRecentlyUpdatedDateForModel;

- (NSDate *)latestSyncDate;

+ (NSString *)URLForFetchMethod;

- (NSString *)URLForFetchRecordDetails;

- (NSString *)URLForUpdateServerObject;

- (NSString *)URLForDeleteServerObject;
@end
