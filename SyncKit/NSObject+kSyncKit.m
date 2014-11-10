//
//  NSObject+kSyncKit.m
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "NSObject+kSyncKit.h"

@implementation NSObject (kSyncKit)


- (NSDate *)mostRecentlyUpdatedDateForModel
{
    @throw [NSException exceptionWithName:@"mostRecentlyUpdatedDateForModel Not Overridden" reason:@"Must override mostRecentlyUpdatedDate on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSDate *)latestSyncDate
{
    @throw [NSException exceptionWithName:@"latestSyncDate Not Overridden" reason:@"Must override mostRecentlyUpdatedDate on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)URLForFetchMethod
{
    @throw [NSException exceptionWithName:@"URLForFetchMethod Not Overridden" reason:@"Must override URLForFetchMethod on NSManagedObject class" userInfo:nil];
    return nil;
}


- (NSString *)URLForFetchRecordDetails
{
    @throw [NSException exceptionWithName:@"URLForFetchRecordDetails Not Overridden" reason:@"Must override URLForFetchMethod on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSString *)URLForUpdateServerObject
{
    @throw [NSException exceptionWithName:@"URLForUpdateServerObject Not Overridden" reason:@"Must override URLForUpdateServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSString *)URLForDeleteServerObject
{
    @throw [NSException exceptionWithName:@"URLForDeleteServerObject Not Overridden" reason:@"Must override URLForDeleteServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}
@end
