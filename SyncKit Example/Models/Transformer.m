//
//  Transformer.m
//  SyncKit
//
//  Created by kavitha on 08/11/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "Transformer.h"
#import "NSManagedObject+kSyncKit.h"
#import "kSyncKit.h"

@implementation Transformer

@dynamic lastServerSyncDate;
@dynamic lastUpdatedDate;
@dynamic syncStatus;
@dynamic trsLocation;
@dynamic trsName;
@dynamic trsOperatingPower;
@dynamic trsOilLevel;
@dynamic trsWindingCount;
@dynamic trsMake;
@dynamic trsWindingMake;
@dynamic trsCurrentTemp;
@dynamic trsType;
@dynamic transformerID;


#pragma mark Overriden Methods

- (void)willSave
{
    [super willSave];
    [self syncKitWillSave];
}
- (void)didSave
{
    [super didSave];
    [self syncKitDidSave];
}

- (BOOL)validateForInsert:(NSError *__autoreleasing *)error
{
    [super validateForInsert:error];
    [self syncKitValidateForInsert];
    return YES;
}

- (BOOL)validateForDelete:(NSError *__autoreleasing *)error
{
    [super validateForDelete:error];
    [self syncKitValidateForDelete];
    return YES;
}

- (BOOL)validateForUpdate:(NSError *__autoreleasing *)error
{
    [super validateForUpdate:error];
    return [self syncKitValidateForUpdate];
}

#pragma mark Configuration Methods


+ (NSDictionary *)queryParametersForDeltaFetchMethodWithLastUpdatedDate:(NSDate *)updatedDate
{
    NSDictionary *parameters = nil;
    
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString
                                stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",
                                [dateFormatter stringFromDate:updatedDate]];
        
        parameters = [NSDictionary dictionaryWithObject:jsonString forKey:@"where"];
    }
    
    return parameters;
    
}
@end