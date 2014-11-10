//
//  NSManagedObject+SyncKit.m
//  kSyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "NSManagedObject+kSyncKit.h"
#import "kCoreDataController.h"
#import "kSyncEngine.h"
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import "kSyncKit.h"

@implementation NSManagedObject (kSyncKit)

@dynamic temp_sync_status;

static char const * const ObjectTagKey = "temp_sync_status";


-(void)setTemp_sync_status:(NSNumber *)temp_sync_status
{
    objc_setAssociatedObject(self, ObjectTagKey, temp_sync_status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//not completely sure about implementation
}

- (NSNumber *)temp_sync_status
{
    return objc_getAssociatedObject(self, ObjectTagKey);///not completely sure about implementation
}

- (BOOL)isRemoteUpdate
{
    return [[kSyncEngine sharedEngine] syncInProgress];
}

#pragma mark Record Status Manager & Helpers

- (void)syncKitValidateForInsert
{
    
    if ([self isRemoteUpdate])
    {
        //TODO other validations
        self.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
    }
    
    else
    {
        //TODO other validations
        self.temp_sync_status = [NSNumber numberWithInt:kObjectCreated];
    }
    
}

- (void)syncKitValidateForDelete
{
    if ([self isRemoteUpdate])
    {
        //TODO other validations
        //status = kObjectDirty;
    }
    
    else
    {
        //TODO other validations
        self.temp_sync_status = [NSNumber numberWithInt:kObjectDeleted];
    }

}

- (BOOL)syncKitValidateForUpdate
{
    
    kObjectSyncStatus recordCurrentStatus = [[self valueForKey:[self.class syncStatusFlagAttribute]] intValue];

    if ([self isRemoteUpdate])
    {
        NSLog(@"temp_sync_status= %i  syncStatus=%i",self.temp_sync_status.integerValue,  [[self valueForKey:[self.class syncStatusFlagAttribute]] intValue]);
        if(recordCurrentStatus == kObjectClientConflictResolved)
        {
            //self.temp_sync_status =  [NSNumber numberWithInt:kObjectSynced];
            return YES;
        }
       return [[kSyncKit sharedKit].syncEngine.conflictManager checkConflictsForManagedObject:self];
    }
    else
    {
       //TODO other validations
       if(self.temp_sync_status != [NSNumber numberWithInt:kObjectClientConflictResolved])
       {
        
           switch (recordCurrentStatus) {
                   
               case kObjectCreated:
               {
                   self.temp_sync_status = [NSNumber numberWithInt:kObjectCreated]; //added to make sure that tempstatus should not be nil
                   return YES;
               }
               case kObjectDeleted:
               {
                    self.temp_sync_status = [NSNumber numberWithInt:kObjectDeleted];
                    return YES;
               }
                   break;
                   default:
                        self.temp_sync_status = [NSNumber numberWithInt:kObjectDirty];
                   break;
           }
       }
    }
    return YES;

}
- (void)syncKitDidSave
{
    switch(self.temp_sync_status.integerValue)
    {
            case kObjectClientAccept:
        {
            self.temp_sync_status =  [NSNumber numberWithInt:kObjectClientConflictResolved];
        }
            break;
            default:
            break;
    }
}

- (void)syncKitWillSave
{

    switch (self.temp_sync_status.integerValue) {
            
        case kObjectSynced:
        {
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectSynced] forKey:[self.class syncStatusFlagAttribute]];
        }
            break;
            
        case kObjectCreated:
        {
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectCreated] forKey:[self.class syncStatusFlagAttribute]];
        }
            break;
            
        case kObjectDeleted:
        {
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectDeleted] forKey:[self.class syncStatusFlagAttribute]];
        }
            break;
            
        case kObjectDirty:
        {
            NSNumber *num = [NSNumber numberWithInt:kObjectDeleted];
            if( [num isEqualToNumber:[self primitiveValueForKey:[self.class syncStatusFlagAttribute]]])
            {
                [self setPrimitiveValue:[NSNumber numberWithInt:kObjectDeleted] forKey:[self.class syncStatusFlagAttribute]];
            }
            else
            {
                [self setPrimitiveValue:[NSNumber numberWithInt:kObjectDirty] forKey:[self.class syncStatusFlagAttribute]];
                
                if (![self isRemoteUpdate]) {
                    [self setPrimitiveValue:[NSDate date] forKey:[self.class lastUpdatedDateContainerAttribute]];
                }
            }
            
        }
            break;
        case kObjectConflicted:
        {
            [self completeRollBackRecord];
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectConflicted] forKey:[self.class syncStatusFlagAttribute]];
        }
            break;
        case kObjectClientAccept:
        {
            [self rollBackRecord];
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectClientAccept] forKey:[self.class syncStatusFlagAttribute]];
        }
            break;
      
        case kObjectClientConflictResolved:
        {
            if (![self isRemoteUpdate])
            {
            [self setPrimitiveValue:[NSNumber numberWithInt:kObjectClientConflictResolved] forKey:[self.class syncStatusFlagAttribute]];
            }
            else
            {
            [self completeRollBackRecord];
             [self setPrimitiveValue:[NSNumber numberWithInt:kObjectClientConflictResolved] forKey:[self.class syncStatusFlagAttribute]];
            }

        }
            break;
        default:
            
            break;
    }
    
    if([self isRemoteUpdate])
    [self setPrimitiveValue:[self valueForKey:[self.class lastServerSyncedDataContainerAttribute]] forKey:[self.class lastUpdatedDateContainerAttribute]];

}

#pragma mark Attribute Mapping methods


+ (NSString *)identificationAttribute
{
    
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"identificationAttribute"];
    
    @throw [NSException exceptionWithName:@"identificationAttribute Not Overridden" reason:@"Must override identificationAttribute on NSManagedObject class" userInfo:nil];
    return nil;
}


+ (NSString *)lastUpdatedDateContainerAttribute
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"lastUpdatedDateContainerAttribute"];

    @throw [NSException exceptionWithName:@"lastUpdatedDateContainerAttribute Not Overridden" reason:@"Must override lastUpdatedDateContainerAttribute on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)lastServerSyncedDataContainerAttribute
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"lastServerSyncedDataContainerAttribute"];
    
    @throw [NSException exceptionWithName:@"lastServerSyncedDataContainerAttribute Not Overridden" reason:@"Must override lastServerSyncedDataContainerAttribute on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)keyPathToSearch
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"keyPathToSearch"];

    @throw [NSException exceptionWithName:@"keyPathToSearch Not Overridden" reason:@"Must override keyPathToSearch on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)syncStatusFlagAttribute
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"syncStatusFlagAttribute"];

    @throw [NSException exceptionWithName:@"syncStatusFlagAttribute Not Overridden" reason:@"Must override syncStatusFlagAttribute on NSManagedObject class" userInfo:nil];
    return nil;
}
#pragma mark Create methods

+ (NSDictionary *)requestObjectMappingForRemoteObjectCreation
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"requestObjectMappingForRemoteObjectCreation"];

    @throw [NSException exceptionWithName:@"requestObjectMappingForRemoteObjectCreation Not Overridden" reason:@"Must override requestObjectMappingForRemoteObjectCreation on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSDictionary *)responseObjectMappingForRemoteObjectCreation
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"responseObjectMappingForRemoteObjectCreation"];

    @throw [NSException exceptionWithName:@"responseObjectMappingForRemoteObjectCreation Not Overridden" reason:@"Must override responseObjectMappingForRemoteObjectCreation on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSDictionary *)postObjectForNewServerObject {
    @throw [NSException exceptionWithName:@"postObjectForServer Not Overridden" reason:@"Must override postObjectForServer on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)URLForNewServerObject
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForNewServerObject"];
    
    @throw [NSException exceptionWithName:@"postURLForNewServerObject Not Overridden" reason:@"Must override postURLForNewServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}


#pragma mark Update Methods

+ (NSDictionary *)requestObjectMappingForRemoteObjectUpdate
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"requestObjectMappingForRemoteObjectUpdation"];

    @throw [NSException exceptionWithName:@"requestObjectMappingForRemoteObjectUpdate Not Overridden" reason:@"Must override requestObjectMappingForRemoteObjectUpdate on NSManagedObject class" userInfo:nil];
    return nil;}

+ (NSDictionary *)responseObjectMappingForRemoteObjectUpdate
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"responseObjectMappingForRemoteObjectUpdate"];

    @throw [NSException exceptionWithName:@"responseObjectMappingForRemoteObjectUpdate Not Overridden" reason:@"Must override responseObjectMappingForRemoteObjectUpdate on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSDictionary *)postObjectForUpdateServerObject
{
    @throw [NSException exceptionWithName:@"postObjectForUpdateServerObject Not Overridden" reason:@"Must override postObjectForUpdateServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}


- (NSString *)URLForUpdateServerObject
{
    id updateURLObject = [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForUpdateServerObject"];
    
    if([updateURLObject isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableString *updateURLString = [[NSMutableString alloc]init];
        
        [updateURLString appendString:[updateURLObject objectForKey:@"serviceURL"]];
        
        for (NSDictionary *appendItem in [updateURLObject objectForKey:@"appendItems"]) {
            
            if([[appendItem objectForKey:@"type"] isEqualToString:@"mapping"])
            {
                [updateURLString appendString:[self valueForKeyPath:[appendItem objectForKey:@"value"]]];
            }
            
            else if ([[appendItem objectForKey:@"type"] isEqualToString:@"plain"])
            {
                [updateURLString appendString:[appendItem objectForKey:@"value"]];
                
            }
        }
        
        return updateURLString;
    }
    
    else if([updateURLObject isKindOfClass:[NSString class]])
    {
        return updateURLObject;
    }
    
    @throw [NSException exceptionWithName:@"postObjectForUpdateServerObject Not Overridden" reason:@"Must override postObjectForUpdateServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)URLPathPatternForUpdateRemoteObject
{
    
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLPathPatternForUpdateRemoteObject"];

    @throw [NSException exceptionWithName:@"postObjectForUpdateServerObject Not Overridden" reason:@"Must override postObjectForUpdateServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (kHTTPMethodType)methodTypeForUpdateOperation
{
    NSString *methodType = [[[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForUpdateServerObject"] objectForKey:@"HTTPMethod"] ;
    
    if(methodType != nil && methodType.length>0)
        return [methodType integerValue];
    else
        return kHTTPMethodTypeUNDEFINED;
}

#pragma mark Delete Methods

- (NSDictionary *)postObjectForDeleteServerObject
{
    @throw [NSException exceptionWithName:@"postObjectForServer Not Overridden" reason:@"Must override postObjectForServer on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSString *)URLForDeleteServerObject
{
    id deleteURLObject = [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForDeleteServerObject"];
    
    if([deleteURLObject isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableString *deleteURLString = [[NSMutableString alloc]init];
        
        [deleteURLString appendString:[deleteURLObject objectForKey:@"serviceURL"]];
        
        for (NSDictionary *appendItem in [deleteURLObject objectForKey:@"appendItems"]) {
            
            if([[appendItem objectForKey:@"type"] isEqualToString:@"mapping"])
            {
                [deleteURLString appendString:[self valueForKeyPath:[appendItem objectForKey:@"value"]]];
            }
            
            else if ([[appendItem objectForKey:@"type"] isEqualToString:@"plain"])
            {
                [deleteURLString appendString:[appendItem objectForKey:@"value"]];

            }
        }
        
        return deleteURLString;
    }
    
    else if([deleteURLObject isKindOfClass:[NSString class]])
    {
        return deleteURLObject;
    }
    
    @throw [NSException exceptionWithName:@"URLForDeleteServerObject Not Overridden" reason:@"Must override URLForDeleteServerObject on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSDictionary *)postObjectForBatchDeleteServerObjects
{
    @throw [NSException exceptionWithName:@"postObjectForBatchDeleteServerObjects Not Overridden" reason:@"Must override postObjectForBatchDeleteServerObjects on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSURL *)URLForBatchDeleteServerObjects
{
    @throw [NSException exceptionWithName:@"postURLForBatchDeleteServerObjects Not Overridden" reason:@"Must override postURLForBatchDeleteServerObjects on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)URLToGetDeletedRecordsFromServer
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLToGetDeletedRecordsFromServer"];

    @throw [NSException exceptionWithName:@"URLToGetDeletedRecordsFromServer Not Overridden" reason:@"Must override URLToGetDeletedRecordsFromServer on NSManagedObject class" userInfo:nil];
    return nil;
}

#pragma mark Fetch Methods

+ (NSString *)URLForDeltaFetchMethod
{
    return [[[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForDeltaFetchMethod"] objectForKey:@"serviceURL"];
    
    @throw [NSException exceptionWithName:@"URLForDeltaFetchMethod Not Overridden" reason:@"Must override URLForDeltaFetchMethod on NSManagedObject class" userInfo:nil];
    return nil;

}

+ (NSDictionary *)queryParametersForDeltaFetchMethodWithLastUpdatedDate:(NSDate *)updatedDate
{
    NSArray * queryParams = [[[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForDeltaFetchMethod"] objectForKey:@"queryParameters"];
    
    NSMutableDictionary *qParameters = [NSMutableDictionary dictionary];
    
    for(NSDictionary *queryParam in queryParams)
    {
        if([[queryParam objectForKey:@"type"] isEqualToString:@"plainString"])
        {
            if([[queryParam objectForKey:@"value"] isKindOfClass:[NSString class]])
            [qParameters setObject:[queryParam objectForKey:@"value"] forKey:[queryParam objectForKey:@"parameter"]];
            
            else if([[queryParam objectForKey:@"value"] isKindOfClass:[NSArray class]])
            {
                NSMutableString *parameterString = [[NSMutableString alloc]init];
                
                for(NSDictionary *appendItems in [queryParam objectForKey:@"value"])
                {
                    if([[appendItems objectForKey:@"type"] isEqualToString:@"plainString"])
                    {
                        [parameterString appendString:[appendItems objectForKey:@"value"]];
                    }
                    
                    else if ([[appendItems objectForKey:@"type"] isEqualToString:@"mapping"])
                    {
                        if([[appendItems objectForKey:@"value"] isEqualToString:[self.class lastServerSyncedDataContainerAttribute]])
                        {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            //Event where LastModifiedDate > 2013-06-21T00:00:00.000Z
                            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                            [parameterString appendString:[dateFormatter stringFromDate:updatedDate]];
                        }
                        else
                            [parameterString appendString:[self valueForKey:[appendItems objectForKey:@"value"]]];
                    }
                }
                
                [qParameters setObject:parameterString forKey:[queryParam objectForKey:@"parameter"]];
            }
        }
    }
    
    if(qParameters.count>0)
        return qParameters;
    else
        return nil;
    
    @throw [NSException exceptionWithName:@"queryParametersForFetchAllMethod Not Overridden" reason:@"Must override queryParametersForFetchAllMethod on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSDictionary *)parametersForDeltaFetchMethodWithLastUpdatedDate:(NSDate *)updatedDate;
{
    /*@throw [NSException exceptionWithName:@"parametersForDeltaFetchMethodWithLastUpdatedDate Not Overridden" reason:@"Must override parametersForDeltaFetchMethodWithLastUpdatedDate on NSManagedObject class" userInfo:nil];*/
    return nil;

}

+ (NSString *)URLForFetchMethod
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForFetchMethod"];

    @throw [NSException exceptionWithName:@"URLForFetchMethod Not Overridden" reason:@"Must override URLForFetchMethod on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSString *)URLForFetchAllMethod
{
    return [[[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForFetchAllMethod"] objectForKey:@"serviceURL"];
    
    @throw [NSException exceptionWithName:@"URLForFetchAllMethod Not Overridden" reason:@"Must override URLForFetchAllMethod on NSManagedObject class" userInfo:nil];
    return nil;
}

+ (NSDictionary *)queryParametersForFetchAllMethod
{
    NSArray * queryParams = [[[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"URLForFetchAllMethod"] objectForKey:@"queryParameters"];
    NSMutableDictionary *qParameters = [NSMutableDictionary dictionary];
    
    for(NSDictionary *queryParam in queryParams)
    {
        if([[queryParam objectForKey:@"type"] isEqualToString:@"plainString"])
        {
            [qParameters setObject:[queryParam objectForKey:@"value"] forKey:[queryParam objectForKey:@"parameter"]];
        }
    }
    
    if(qParameters.count>0)
        return qParameters;
    else
        return nil;
    
    @throw [NSException exceptionWithName:@"queryParametersForFetchAllMethod Not Overridden" reason:@"Must override queryParametersForFetchAllMethod on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSString *)URLForFetchRecordDetails
{
    @throw [NSException exceptionWithName:@"URLForFetchRecordDetails Not Overridden" reason:@"Must override URLForFetchMethod on NSManagedObject class" userInfo:nil];
    return nil;
}
#pragma mark Object Mapping Methods

+ (NSDictionary *)objectMappingForManagedObject
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"objectMappingForManagedObject"];

    @throw [NSException exceptionWithName:@"objectMappingForManagedObject Not Overridden" reason:@"Must override objectMappingForManagedObject on NSManagedObject class" userInfo:nil];
    return nil;
}

- (NSDictionary *)relationshipMappingForManagedObject
{
    return [[[[[kSyncKit sharedKit] syncParameters] objectForKey:@"kSyncModels"] objectForKey:NSStringFromClass(self.class)] objectForKey:@"relationshipMappingForManagedObject"];

    @throw [NSException exceptionWithName:@"relationshipMappingForManagedObject Not Overridden" reason:@"Must override relationshipMappingForManagedObject on NSManagedObject class" userInfo:nil];
    return nil;
}


#pragma mark record operations

- (void)rollBackRecord
{
    NSDictionary *changedValues = [self changedValues];
    NSDictionary *committedValues = [self committedValuesForKeys:[changedValues allKeys]];
    NSEnumerator *enumerator;
    id key;
    enumerator = [changedValues keyEnumerator];
    
    while ((key = [enumerator nextObject])) {
        if(![key isEqualToString:[self.class syncStatusFlagAttribute]] && ![key isEqualToString:[self.class lastServerSyncedDataContainerAttribute]])
        {
        NSLog(@"Reverting field ""%@"" from ""%@"" to ""%@""", key, [changedValues objectForKey:key], [committedValues objectForKey:key]);
        [self setPrimitiveValue:[committedValues objectForKey:key] forKey:key];
        }
    }
}

- (void)completeRollBackRecord
{
    NSDictionary *changedValues = [self changedValues];
    NSDictionary *committedValues = [self committedValuesForKeys:[changedValues allKeys]];
    NSEnumerator *enumerator;
    id key;
    enumerator = [changedValues keyEnumerator];
    
    while ((key = [enumerator nextObject])) {
             NSLog(@"Reverting field ""%@"" from ""%@"" to ""%@""", key, [changedValues objectForKey:key], [committedValues objectForKey:key]);
            [self setPrimitiveValue:[committedValues objectForKey:key] forKey:key];
    }
}

#pragma mark Record Status change methods

- (void)markAsDirty
{
    [self setValue:[NSNumber numberWithInt:kObjectDirty] forKey:[self.class syncStatusFlagAttribute]];
}

- (void)markAsNew
{
    [self setValue:[NSNumber numberWithInt:kObjectCreated] forKey:[self.class syncStatusFlagAttribute]];
}

- (void)markAsDeleted
{
    [self setValue:[NSNumber numberWithInt:kObjectDeleted] forKey:[self.class syncStatusFlagAttribute]];
}

- (void)markAsSynced
{
    [self setValue:[NSNumber numberWithInt:kObjectSynced] forKey:[self.class syncStatusFlagAttribute]];
}

#pragma mark Record Current Operation Methods

- (kObjectRemoteOperationType)getCurrentOpertaionForRecord
{
    if([[self.changedValues allKeys] isEqualToArray:[self.class responseObjectMappingForRemoteObjectCreation].allValues])
        return kObjectRemoteOperationInsert;
    else if([[self.changedValues allKeys] isEqualToArray:[self.class responseObjectMappingForRemoteObjectUpdate].allValues])
        return  kObjectRemoteOperationUpdate;
    else if([[self.changedValues allKeys] isEqualToArray:[self.class objectMappingForManagedObject].allValues])
        return kObjectRemoteOperationFetch;
    
    return kObjectRemoteOperationUndefined;
}

@end
