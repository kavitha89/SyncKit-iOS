//
//  kSyncConflictManager.m
//  SyncKit
//
//  Created by Kavitha on 7/4/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "kSyncConflictManager.h"
#import "kCoreDataController.h"
#import "NSManagedObject+kSyncKit.h"
#import "kSyncConstants.h"
#import <objc/runtime.h>

@interface kSyncConflictManager()
{
    NSMutableArray *managedObjectConflicts;
}
@end
@implementation kSyncConflictManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _conflictedObjects = [NSMutableDictionary dictionary];
        managedObjectConflicts = [NSMutableArray array];
        
    }
    return self;
}

- (BOOL)checkConflictsForManagedObject:(NSManagedObject *)obj
{
    NSDictionary * oldValues = [obj committedValuesForKeys:nil];
    NSDictionary * newValues=[obj changedValues];
    
    NSDate *clientLastUpdatedDate = [oldValues objectForKey:[obj.class lastUpdatedDateContainerAttribute]];
    NSDate *serverLastUpdatedDate = [newValues objectForKey:[[obj.class objectMappingForManagedObject] objectForKey:[obj.class lastServerSyncedDataContainerAttribute]]];
    
    
    kObjectSyncStatus recordCurrentStatus = [[obj valueForKey:[obj.class syncStatusFlagAttribute]] intValue];
    
    switch (self.conflictResolutionType) {
            
        case kConflictResolutionClientWins:
        {
            if(recordCurrentStatus == kObjectDirty || recordCurrentStatus == kObjectDeleted){
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectClientAccept];
                return YES;
            }
            else if(recordCurrentStatus == kObjectClientAccept )
            {
                if(obj.temp_sync_status.integerValue == [NSNumber numberWithInt:kObjectClientConflictResolved].integerValue)
                    obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
                else
                    obj.temp_sync_status = [NSNumber numberWithInt:kObjectClientAccept];
                return YES;
            }
            else if (recordCurrentStatus == kObjectCreated || recordCurrentStatus == kObjectSynced)
            {
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
                return YES;
            }
            
        }
            break;
        case kConflictResolutionServerWins:
        {
            
            obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
            return YES;
        }
            break;
        case kConflictResolutionCustomMerge:
        {
            if(recordCurrentStatus == kObjectDirty || recordCurrentStatus == kObjectDeleted)
            {
                if([self.conflictedObjects objectForKey:NSStringFromClass(obj.class)])
                {
                    NSMutableArray *preExisitngConflictObjects = [self
                                                                  .conflictedObjects objectForKey:NSStringFromClass(obj.class)];
                    [preExisitngConflictObjects addObject:[NSMutableDictionary dictionaryWithObjects:@[oldValues,newValues] forKeys:@[K_CONFLICT_OBJECT_CLIENT_DATA,K_CONFLICT_OBJECT_SERVER_DATA]]];
                    
                    [self.conflictedObjects setObject:preExisitngConflictObjects forKey:NSStringFromClass(obj.class)];
                }
                
                else
                {
                    NSMutableArray *preExisitngConflictObjects = [self
                                                                  .conflictedObjects objectForKey:NSStringFromClass(obj.class)];
                    if(preExisitngConflictObjects== nil)
                        preExisitngConflictObjects = [NSMutableArray array];
                    NSMutableDictionary *conflictedObject = [NSMutableDictionary dictionaryWithObjects:@[oldValues,newValues] forKeys:@[K_CONFLICT_OBJECT_CLIENT_DATA,K_CONFLICT_OBJECT_SERVER_DATA]];
                    
                    if(![preExisitngConflictObjects containsObject:conflictedObject])
                        [preExisitngConflictObjects addObject:conflictedObject];
                    
                    [self.conflictedObjects setObject:preExisitngConflictObjects forKey:NSStringFromClass(obj.class)];
                    
                }
                
                if(![managedObjectConflicts containsObject:obj])
                    [managedObjectConflicts addObject:obj];
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectConflicted];
            }
            else if(recordCurrentStatus == kObjectConflicted )
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectConflicted];
            else if(recordCurrentStatus == kObjectClientConflictResolved  )
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectClientConflictResolved];
            else if(recordCurrentStatus == kObjectSynced)
                obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
            
            return YES;
        }
            break;
        case kConflictResolutionMostRecentWins:
        {
            if([serverLastUpdatedDate timeIntervalSinceDate:clientLastUpdatedDate] > 0)
            {
                //server data is new - so update server data at both ends.
                if(recordCurrentStatus == kObjectDirty || recordCurrentStatus == kObjectDeleted){
                    //reject client data, mark dirty record as synced to prevent dirty records manager to post dirty objects.
                    obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
                    return YES;
                }
            }
            else
            {
                if(recordCurrentStatus == kObjectDirty || recordCurrentStatus == kObjectDeleted){
                    
                    obj.temp_sync_status = [NSNumber numberWithInt:kObjectSynced];
                    return NO;
                }
            }
        }
            break;
        case kConflictResolutionNone:
            return YES;
            break;
        default:
            break;
    }
    return YES;
}

- (void)reportConfclitsToRecievers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ckSyncEngineConflictedObjectsNotification object:self.conflictedObjects];
    
    //[self.conflictResolutionDelegate conflictedObjects:self.conflictedObjects];
}

- (void)resolveConflictForManagedObject:(NSManagedObject *)object withData:(NSMutableDictionary *)resolvedData
{
    
    
    if(resolvedData.count>0)
    {
        
        for (id key in resolvedData.allKeys) {
            NSString *attributeName = (NSString *)key;
            if(class_getProperty([object class], [attributeName UTF8String]) && ![attributeName isEqualToString:[object.class identificationAttribute]] && ![attributeName isEqualToString:[object.class syncStatusFlagAttribute]])
            {
                if([resolvedData objectForKey:attributeName] != [NSNull null] && [resolvedData.allKeys containsObject:attributeName])
                [object setValue:[resolvedData objectForKey:attributeName] forKey:attributeName];
            }
        }
        
        [object setTemp_sync_status:[NSNumber numberWithInt:kObjectClientConflictResolved]];
        [object setValue:[NSNumber numberWithInt:kObjectClientConflictResolved] forKey:[object.class syncStatusFlagAttribute]];
     
        NSMutableDictionary *serverData = [self findConflictedObjectsServerDataForManagedObject:object ofClassType:NSStringFromClass(object.class)];

        [object setValue:[serverData objectForKey:[object.class lastServerSyncedDataContainerAttribute]] forKey:[object.class lastServerSyncedDataContainerAttribute]];
        [object setValue:[serverData objectForKey:[object.class lastServerSyncedDataContainerAttribute]] forKey:[object.class lastUpdatedDateContainerAttribute]];

       // [object setValue:[NSDate date] forKey:[object.class lastUpdatedDateContainerAttribute]];
        
        
        //post the dirty records immediately after this happens.
        [[kCoreDataController sharedController] saveContextToPersistentStore];
        [self removeConflictedDataForManagedObject:object];
        [managedObjectConflicts removeObject:object];
        
        
    }
}

- (void)removeConflictedDataForManagedObject:(NSManagedObject *)object
{
    [self.conflictedObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSArray class]]) {
            
            [obj enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx, BOOL *stop1) {
                
                if([obj1 isKindOfClass:[NSDictionary class]])
                {
                    if([[[obj1 objectForKey:@"clientData"]objectForKey:[object.class identificationAttribute]] isEqualToString:[object valueForKey:[object.class identificationAttribute]]])
                    {
                        [obj removeObject:obj1];
                        *stop1 = YES;
                        *stop = YES;
                    }
                }
            }];
        }
    }];
}

- (void)resolveConflictsInDictionary:(NSMutableDictionary *)resolvedData
{
    
    [resolvedData enumerateKeysAndObjectsUsingBlock:^(id key, id objects, BOOL *stop) {
        
        if([objects isKindOfClass:[NSArray class]])
        {
            [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSManagedObject *managedObject = [self findConflictedManagedObjectForData:obj ofClassType:key];
                
                
                if(managedObject)
                {
                    [self resolveConflictForManagedObject:managedObject withData:obj];
                }
                else
                {
                    NSLog(@"could not find a matching conflicted managed object for data: %@ Please try to resolve conflict again",obj);
                }
                
            }];
        }
    }];
    
    
    //if(self.conflictedObjects.allKeys.count>0)
    //[self.conflictedObjects removeAllObjects];
    
}

- (NSMutableDictionary *) findConflictedObjectsServerDataForManagedObject:(NSManagedObject *)managedObject ofClassType:(NSString *)className
{
    
    for(id key in self.conflictedObjects.allKeys)
    {
        Class objectClass = NSClassFromString(className);
        
        if([className isEqualToString:key])
        {
            NSLog(@"found conflicted object class");
            
            for(id obj in [self.conflictedObjects objectForKey:key])
            {
                NSLog(@"obj : %@",obj);
                
                if([[[obj objectForKey:K_CONFLICT_OBJECT_CLIENT_DATA] objectForKey:[objectClass identificationAttribute]] isEqualToString:[managedObject valueForKey:[objectClass identificationAttribute]]])
                {
                    return [obj objectForKey:K_CONFLICT_OBJECT_SERVER_DATA];
                }
            }
        }
        
    }
    
    return nil;
    
}

- (NSManagedObject *)findConflictedManagedObjectForData:(NSMutableDictionary *)data ofClassType:(NSString *)className
{
    //making a fetch request for each call is expensive, try to get object from context by using method objectWithID:
    
     __block NSArray *results = nil;
    
    NSManagedObjectContext *managedObjectContext = [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    
    Class managedObjectClass = NSClassFromString(className);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",[managedObjectClass identificationAttribute],[data objectForKey:[managedObjectClass identificationAttribute]]];
    [fetchRequest setPredicate:predicate];
    
    [managedObjectContext performBlockAndWait:^{
      
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

    }];
    
    
    if(results.count>0)
        return results[0];
    
    return nil;
   
}

@end
