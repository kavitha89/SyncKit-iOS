
//
//  kSyncEngine.m
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "kSyncEngine.h"
#import "kCoreDataController.h"
#import "NSObject+kSyncKit.h"
#import "NSManagedObject+kSyncKit.h"
#import "kSyncOperation.h"
#import <objc/runtime.h>
#import "kSyncConstants.h"
#import "kSyncKit.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface kSyncEngine()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) dispatch_queue_t backgroundSyncQueue;
@property (nonatomic, assign) int numberOfObjectsSynced;
@property (nonatomic, strong) NSDate *syncStartDate;
@property (nonatomic, strong) NSDate *syncEndDate;
@property (nonatomic, strong) id<GAITracker> tracker;


@end

@implementation kSyncEngine


+ (kSyncEngine *)sharedEngine {
    static kSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[kSyncEngine alloc] init];
        sharedEngine.conflictManager = [[kSyncConflictManager alloc]init];
    });
    
    return sharedEngine;
}

- (void)startSync
{
    if (!self.syncInProgress)
    {
        [self willChangeValueForKey:ckSyncInProgress];
        _syncInProgress = YES;
        [self didChangeValueForKey:ckSyncInProgress];
        
        self.backgroundSyncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        self.tracker = [[GAI sharedInstance] defaultTracker];
        
        dispatch_async(self.backgroundSyncQueue, ^{
            
            [self downloadDataForRegisteredObjects];
            
        });
    }
}

- (void)downloadDataForRegisteredObjects
{
    dispatch_group_t group = dispatch_group_create();
    
    for(NSString *className in self.registeredClassesToSync)
    {
        /**
         *  This is fetch all opertaion, done during the first time sync for all managed objects
         */
        if ([self isFirstTimeSyncForManagedObjectClass:className])
        {
            //do fetch all
            //[self doFetchAllCallForManagedObjectClass:className];
            
            dispatch_group_enter(group);
            
            dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                [[kSyncOperation sharedSyncOperationAPI] performFetchAllRequestForClass:className parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
                    
                    dispatch_group_leave(group);
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    dispatch_group_leave(group);
                    
                }];
            });
            
        }
        /**
         *  This is delta fetch operation, done during every sync.
         */
        else
        {
            /*if([NSClassFromString(className) respondsToSelector:K_MODEL_URL_FOR_GET_SERVER_DELETED_OBJECTS])
             {
             if (![NSClassFromString(className) URLToGetDeletedRecordsFromServer]) {
             // do fetch all if there is no special service that returns all deleted objects, OK??
             [self doFetchAllCallForManagedObjectClass:className];
             return;
             }
             }*/
            
            //do delta fetch
            //[self doDeltaFetchForManagedObjectClass:className];
            
            //dispatch_group_t group = dispatch_group_create();
            
            dispatch_group_enter(group);
            
            NSDate *mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
            
            [[kSyncOperation sharedSyncOperationAPI] performFetchAllRecordsOperationOfClass:className updatedAfterDate:mostRecentUpdatedDate success:^(RKObjectRequestOperation *operation, id responseObject) {
                
                dispatch_group_leave(group);
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                dispatch_group_leave(group);
                
            }];
            
            
        }
        
    }
    
    dispatch_group_notify(group, self.backgroundSyncQueue, ^{
        NSLog(@"SynKit doFetchAllCallForManagedObjectClass operations completed");
        [self postAllDirtyRecordsToServer];
    });
    
    
    //    for(NSString *className in self.registeredClassesToSync)
    //    {
    //    /**
    //         *  This is fetch all opertaion, done during the first time sync for all managed objects
    //         */
    //        if ([self isFirstTimeSyncForManagedObjectClass:className])
    //            {
    //            //do fetch all
    //            //[self doFetchAllCallForManagedObjectClass:className];
    //
    //                dispatch_group_t group = dispatch_group_create();
    //
    //                dispatch_group_enter(group);
    //
    //                [[kSyncOperation sharedSyncOperationAPI] performFetchAllRequestForClass:className parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
    //
    //                    dispatch_group_leave(group);
    //
    //                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    //                    dispatch_group_leave(group);
    //
    //                }];
    //                dispatch_group_notify(group, self.backgroundSyncQueue, ^{
    //                    NSLog(@"SynKit doFetchAllCallForManagedObjectClass operations completed");
    //                    [self postAllDirtyRecordsToServer];
    //                });
    //
    //        }
    //        /**
    //         *  This is delta fetch operation, done during every sync.
    //         */
    //        else
    //        {
    //            /*if([NSClassFromString(className) respondsToSelector:K_MODEL_URL_FOR_GET_SERVER_DELETED_OBJECTS])
    //            {
    //                if (![NSClassFromString(className) URLToGetDeletedRecordsFromServer]) {
    //                    // do fetch all if there is no special service that returns all deleted objects, OK??
    //                    [self doFetchAllCallForManagedObjectClass:className];
    //                    return;
    //                }
    //            }*/
    //
    //            //do delta fetch
    //            //[self doDeltaFetchForManagedObjectClass:className];
    //
    //            dispatch_group_t group = dispatch_group_create();
    //
    //            dispatch_group_enter(group);
    //
    //            NSDate *mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
    //
    //            [[kSyncOperation sharedSyncOperationAPI] performFetchAllRecordsOperationOfClass:className updatedAfterDate:mostRecentUpdatedDate success:^(RKObjectRequestOperation *operation, id responseObject) {
    //
    //                    dispatch_group_leave(group);
    //
    //            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    //                    dispatch_group_leave(group);
    //
    //            }];
    //
    //            dispatch_group_notify(group, self.backgroundSyncQueue, ^{
    //                NSLog(@"SynKit doDeltaFetchForManagedObjectClass operations completed");
    //                [self postAllDirtyRecordsToServer];
    //            });
    //        }
    //
    //    }
}

- (void)doFetchAllCallForManagedObjectClass:(NSString *)className
{
    
}

- (void)doDeltaFetchForManagedObjectClass:(NSString *)className
{
    
}

- (void)postLocalObjectsToServer {
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *operations = [NSMutableArray array];
    
    for (NSString *className in self.registeredClassesToSync) {
        
        NSDate *startDate = [NSDate date];
        
        int numberOfObjectsSynced = 0;
        
        NSArray *objectsToCreate = [self managedObjectsForClass:className withSyncStatus:kObjectCreated];
        
        NSLog(@"SynKit found %lu objects of class %@ to be created at server",(unsigned long)objectsToCreate.count,className);
        
        
        for(NSManagedObject *objectToCreate in objectsToCreate)
        {
            dispatch_group_enter(group);
            
            numberOfObjectsSynced++;
            
            [[kSyncOperation sharedSyncOperationAPI]  performPOSTRequestForObject:objectToCreate parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
                
                [operations addObject:operation];
                
                if(numberOfObjectsSynced == objectsToCreate.count)
                {
                    ////
                    [self postGoogleAnalytics:className withStatus:@"Success" withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsSynced];
                    
                }
                
                dispatch_group_leave(group);
                
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                
                [operations addObject:operation];
                
                if(numberOfObjectsSynced == objectsToCreate.count)
                {
                    ////
                    [self postGoogleAnalytics:className withStatus:@"Failure." withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsSynced];
                }

                
                dispatch_group_leave(group);
                
                
            }];
            
        }
        
    }
    
    dispatch_group_notify(group, self.backgroundSyncQueue, ^{
        NSLog(@"SynKit postLocalObjectsToServer operations completed");
        
        if ([operations count] > 0) {
            [[kCoreDataController sharedController] saveContextToPersistentStore];
        }
        
        
        [self deleteObjectsOnServer];
    });
}

- (void)deleteObjectsOnServer {
    
    dispatch_group_t group = dispatch_group_create();
    
    NSDate *startDate = [NSDate date];
    
    int numberOfObjectsDeleted = 0;
    
    
    NSMutableArray *operations = [NSMutableArray array];
    
    for (NSString *className in self.registeredClassesToSync) {
        
        NSArray *objectsToDelete = [self managedObjectsForClass:className withSyncStatus:kObjectDeleted];
        
        NSLog(@"SynKit found %lu objects of class %@ to be deleted at server",(unsigned long)objectsToDelete.count,className);
        
        
        for(NSManagedObject *objectToDelete in objectsToDelete)
        {
            dispatch_group_enter(group);
            
            numberOfObjectsDeleted++;
            
            [[kSyncOperation sharedSyncOperationAPI] performDeleteOpertaionForObject:objectToDelete parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
                
                [operations addObject:operation];
                
                ////
                if(numberOfObjectsDeleted == objectsToDelete.count)
                {
                    [self postGoogleAnalytics:className withStatus:@"Success" withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsDeleted];
                }
                
                dispatch_group_leave(group);
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                
                [operations addObject:operation];
                
                ////
                if(numberOfObjectsDeleted == objectsToDelete.count)
                {
                    [self postGoogleAnalytics:className withStatus:@"Failure." withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsDeleted];
                }
                
                dispatch_group_leave(group);
                
            }];
            
        }
    }
    
    dispatch_group_notify(group, self.backgroundSyncQueue, ^{
        
        NSLog(@"SynKit deleteObjectsOnServer operations completed");
        
        if ([operations count] > 0) {
            
            [[kCoreDataController sharedController] saveContextToPersistentStore];
        }
        
        [self executeSyncCompletedOperations];
        
    });
}

- (void)postAllDirtyRecordsToServer
{
    dispatch_group_t group = dispatch_group_create();
    
    NSDate *startDate = [NSDate date];
    
    int numberOfObjectsUpdated = 0;
    
    NSMutableArray *operations = [NSMutableArray array];
    
    for (int i=0;i<self.registeredClassesToSync.count;i++) {
        
        NSString *className = [self.registeredClassesToSync objectAtIndex:i];
        
        NSArray *objectsToUpdate=[self fetchAllRecordsToBePostedForManagedObjectClass:className];
        
        NSLog(@"SynKit found %lu  dirty objects of class %@ to be updated at server",(unsigned long)objectsToUpdate.count,className);
        
        for (NSManagedObject *objectToDelete in objectsToUpdate) {
            
            dispatch_group_enter(group);
            
            numberOfObjectsUpdated++;
            
            Class objectClass = NSClassFromString(className);
            
            if([objectClass methodTypeForUpdateOperation] == kHTTPMethodTypeUNDEFINED)
            {
                [[kSyncOperation sharedSyncOperationAPI] performPUTOperationForObject:objectToDelete parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
                    
                    [operations addObject:operation];
                    
                    ////
                    if(numberOfObjectsUpdated == objectsToUpdate.count)
                    {
                     [self postGoogleAnalytics:className withStatus:@"Success" withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsUpdated];
                    }
                    
                    dispatch_group_leave(group);
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    
                    [operations addObject:operation];
                    
                    ////
                    if(numberOfObjectsUpdated == objectsToUpdate.count)
                    {
                    [self postGoogleAnalytics:className withStatus:@"Failure." withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsUpdated];
                    }
                    
                    dispatch_group_leave(group);
                    
                }];
            }
            else if([objectClass methodTypeForUpdateOperation] == kHTTPMethodTypePATCH)
            {
                [[kSyncOperation sharedSyncOperationAPI] performPATCHOperationForObject:objectToDelete parameters:nil success:^(RKObjectRequestOperation *operation, id responseObject) {
                    
                    [objectToDelete markAsSynced];
                    
                    [operations addObject:operation];
                    
                    ////
                    if(numberOfObjectsUpdated == objectsToUpdate.count)
                    {
                     [self postGoogleAnalytics:className withStatus:@"Success" withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsUpdated];
                    }
                    
                    dispatch_group_leave(group);
                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    
                    [operations addObject:operation];
                    
                    ////
                    if(numberOfObjectsUpdated == objectsToUpdate.count)
                    {
                     [self postGoogleAnalytics:className withStatus:@"Failure." withStartDate:startDate withNoOfObjectsSynced:numberOfObjectsUpdated];
                    }
                    
                    dispatch_group_leave(group);
                    
                }];
                
            }
            
            
        }
    }
    
    dispatch_group_notify(group, self.backgroundSyncQueue, ^{
        
        NSLog(@"SynKit postAllDirtyRecordsToServer operations completed");
        
        if ([operations count] > 0) {
            
            [[kCoreDataController sharedController] saveContextToPersistentStore];
        }
        
        [self postLocalObjectsToServer];
        
    });
    
}
- (void)newManagedObjectWithClassName:(NSString *)className
                            forRecord:(NSDictionary *)record {
    
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[kCoreDataController sharedController] backgroundManagedObjectContext]];
    
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:newManagedObject];
    }];
    
    [record setValue:[NSNumber numberWithInt:kObjectSynced] forKey:@"syncStatus"];
}

- (void)updateManagedObject:(NSManagedObject *)managedObject
                 withRecord:(NSDictionary *)record {
    
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
}

- (void)setValue:(id)value
          forKey:(NSString *)key
forManagedObject:(NSManagedObject *)managedObject {
    
    [managedObject setValue:value forKey:key];
}

#pragma mark - Convinent Fetch methods

- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    
    __block NSDate *date = nil;
    
    NSManagedObjectContext *managedObjectContext =  [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    Class entityClass = NSClassFromString(entityName);
    /*NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ = %d",[entityClass syncStatusFlagAttribute], kObjectSynced];
     [fetchRequest setPredicate:predicate];*/
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:[entityClass lastServerSyncedDataContainerAttribute] ascending:NO]]];
    
    [fetchRequest setFetchLimit:1];
    
    [managedObjectContext performBlockAndWait:^{
        
        NSError *error = nil;
        
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([results lastObject])   {
            
            date = [[results lastObject] valueForKey:[entityClass lastServerSyncedDataContainerAttribute]];
        }
    }];
    
    return date;
}

- (BOOL)isFirstTimeSyncForManagedObjectClass:(NSString *)className
{
    if([self managedObjectsForClass:className withSyncStatus:kObjectSynced].count >0)
        return NO;
    else
        return YES;
    
    return NO;
}
- (NSArray *)dirtyObjectsFormanagedObjectClass:(NSString *)className
{
    return [self managedObjectsForClass:className withSyncStatus:kObjectDirty];
}

- (NSArray *)newlyCreatedObjectsForManagedObjectClass:(NSString *)className
{
    return [self managedObjectsForClass:className withSyncStatus:kObjectCreated];
}

- (NSArray *)deletedObjectsForManagedObjectClass:(NSString *)className
{
    return [self managedObjectsForClass:className withSyncStatus:kObjectDeleted];
}

- (NSArray *)fetchAllRecordsForManagedObjectClass:(NSString *)className
{
    __block NSArray *results=nil;
    NSManagedObjectContext *managedObjectContext = [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    
    Class modelClass = NSClassFromString(className);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %d",[modelClass syncStatusFlagAttribute], kObjectDeleted];
    [fetchRequest setPredicate:predicate];
    
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
    
}

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(kObjectSyncStatus)syncStatus
{
    __block NSArray *results=nil;
    
    NSManagedObjectContext *managedObjectContext = [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    Class modelClass = NSClassFromString(className);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %d",[modelClass syncStatusFlagAttribute] ,syncStatus];
    [fetchRequest setPredicate:predicate];
    
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (NSArray *)fetchAllRecordsToBePostedForManagedObjectClass:(NSString *)className
{
    __block NSArray *results=nil;
    
    NSManagedObjectContext *managedObjectContext = [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    
    Class modelClass = NSClassFromString(className);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K IN %@",[modelClass syncStatusFlagAttribute], @[[NSNumber numberWithInt:kObjectClientAccept],[NSNumber numberWithInt:kObjectDirty],[NSNumber numberWithInt:kObjectClientConflictResolved]]];
    
    
    [fetchRequest setPredicate:predicate];
    
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[kCoreDataController sharedController] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"%@ IN %@", [(NSManagedObject *)(NSClassFromString(className)) performSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR] , idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }
    
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:[(NSManagedObject *)(NSClassFromString(className)) performSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR] ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

#pragma mark Registering Model methods

- (void)registerNSManagedObjectClassToSync:(Class)theClass {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([theClass isSubclassOfClass:[NSManagedObject class]]) {
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(theClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(theClass)];
            [self setupRestKitMappingForNSManagedObjectClass:theClass];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(theClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(theClass));
    }
    
}


- (void)setupRestKitMappingForNSManagedObjectClass:(Class)theClass
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    /**
     *  Fetch All response mapping
     */
    if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_URL_FOR_FETCH_ALL_METHOD_SELECTOR]
       && [(NSManagedObject *)theClass respondsToSelector:k_MODEL_KEY_PATH_SELECTOR])
    {
        
        RKEntityMapping *modelClassObjectMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(theClass) inManagedObjectStore:objectManager.managedObjectStore];
        modelClassObjectMapping.performsKeyValueValidation = YES;
        modelClassObjectMapping.discardsInvalidObjectsOnInsert = YES;
        if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR])
            modelClassObjectMapping.identificationAttributes = @[[theClass performSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR]];
        
        
        if([(NSManagedObject *)theClass respondsToSelector:k_MODEL_OBJECT_MAPPING_FOR_MANAGED_OBJECT_SELECTOR])
            [modelClassObjectMapping addAttributeMappingsFromDictionary:[theClass performSelector:k_MODEL_OBJECT_MAPPING_FOR_MANAGED_OBJECT_SELECTOR
                                                                         ]];
        NSString *fetchURLString = [theClass performSelector:K_MODEL_URL_FOR_FETCH_ALL_METHOD_SELECTOR
                                    ];
        RKResponseDescriptor *responseDescriptorForFetchAll = [RKResponseDescriptor responseDescriptorWithMapping:modelClassObjectMapping
                                                                                                           method:RKRequestMethodGET
                                                                                                      pathPattern:[fetchURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                                                                          keyPath:[theClass performSelector:k_MODEL_KEY_PATH_SELECTOR
                                                                                                                   ]
                                                                                                      statusCodes:RKStatusCodeIndexSetForClass (RKStatusCodeClassSuccessful)];
        
        /* if([theClass respondsToSelector:K_MODEL_URL_FOR_GET_SERVER_DELETED_OBJECTS])
         {
         if (![theClass URLToGetDeletedRecordsFromServer]) {
         
         [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
         
         RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:[theClass performSelector:K_MODEL_URL_FOR_FETCH_METHOD_SELECTOR]];
         
         NSDictionary *argsDict = nil;
         
         BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
         
         if (match) {
         // Return  a fetch request telling the object manager which objects to compare the remote payload to so it can cleanup any orphaned objects.
         NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
         NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(theClass) inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
         [fetchRequest setEntity:entity];
         NSPredicate *predicateForInnocentRecords = [NSPredicate predicateWithFormat:@"syncStatus IN %@", @[[NSNumber numberWithInt:kObjectSynced]]];
         [fetchRequest setPredicate:predicateForInnocentRecords];
         
         if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR])
         {
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[theClass performSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR] ascending:YES];
         NSArray *sortDescriptors = @[sortDescriptor];
         [fetchRequest setSortDescriptors:sortDescriptors];
         }
         return fetchRequest;
         } else {
         return nil;
         }
         }];
         }
         }*/
        
        [objectManager addResponseDescriptor:responseDescriptorForFetchAll];
    }
    
    /**
     *  Fetch Delta response mapping
     */
    
    //TO-DO REMOVE COMMENTS AND INCORPORATE DELTA FETCH
    
    if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_URL_FOR_FETCH_DELTA_OBJECTS]
       && [(NSManagedObject *)theClass respondsToSelector:k_MODEL_KEY_PATH_SELECTOR])
    {
        
        RKEntityMapping *modelClassObjectMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(theClass) inManagedObjectStore:objectManager.managedObjectStore];
        modelClassObjectMapping.performsKeyValueValidation = YES;
        modelClassObjectMapping.discardsInvalidObjectsOnInsert = YES;
        
        if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR])
            modelClassObjectMapping.identificationAttributes = @[[theClass performSelector:K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR]];
        
        
        if([(NSManagedObject *)theClass respondsToSelector:k_MODEL_OBJECT_MAPPING_FOR_MANAGED_OBJECT_SELECTOR])
            [modelClassObjectMapping addAttributeMappingsFromDictionary:[theClass performSelector:k_MODEL_OBJECT_MAPPING_FOR_MANAGED_OBJECT_SELECTOR
                                                                         ]];
        RKResponseDescriptor *responseDescriptorForFetchDelta = [RKResponseDescriptor responseDescriptorWithMapping:modelClassObjectMapping
                                                                                                             method:RKRequestMethodGET
                                                                                                        pathPattern:[theClass performSelector:K_MODEL_URL_FOR_FETCH_DELTA_OBJECTS
                                                                                                                     ]
                                                                                                            keyPath:[theClass performSelector:k_MODEL_KEY_PATH_SELECTOR
                                                                                                                     ]
                                                                                                        statusCodes:RKStatusCodeIndexSetForClass (RKStatusCodeClassSuccessful)];
        
        
        [objectManager addResponseDescriptor:responseDescriptorForFetchDelta];
        
        
    }
    
    /**
     *  Remote Object Creation request and response mapping
     */
    if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_CREATION])
    {
        
        
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:theClass];
        [responseMapping addAttributeMappingsFromDictionary:[theClass performSelector:K_MODEL_RESPONSE_OBJECT_MAPPING_REMOTE_OBJET_CREATION]];
        
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                                method:RKRequestMethodPOST
                                                                                           pathPattern:[theClass performSelector:K_MODEL_URL_FOR_NEW_REMOTE_OBJECT
                                                                                                        ]
                                                                                               keyPath:nil
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
        [requestMapping addAttributeMappingsFromDictionary:[theClass performSelector:K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_CREATION]];
        requestMapping = [requestMapping inverseMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping  objectClass:theClass rootKeyPath:nil method:RKRequestMethodPOST];
        
        [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
        [objectManager addResponseDescriptor:responseDescriptor];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        
    }
    /**
     *  Remote Object Updation request and response mapping
     */
    if([(NSManagedObject *)theClass respondsToSelector:K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_UPDATE])
    {
        
        RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:theClass];
        [responseMapping addAttributeMappingsFromDictionary:[theClass performSelector:K_MODEL_RESPONSE_OBJECT_MAPPING_REMOTE_OBJET_UPDATE]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                                method:([theClass methodTypeForUpdateOperation] == kHTTPMethodTypeUNDEFINED?RKRequestMethodPUT:RKRequestMethodPATCH)
                                                                                           pathPattern:[theClass performSelector:K_MODEL_URL_PATH_PATTERN_FOR_UPDATE_REMOTE_OBJET
                                                                                                        ]
                                                                                               keyPath:nil
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
        [requestMapping addAttributeMappingsFromDictionary:[theClass performSelector:K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_UPDATE]];
        requestMapping = [requestMapping inverseMapping];
        
        RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:requestMapping  objectClass:theClass rootKeyPath:nil method:([theClass methodTypeForUpdateOperation] == kHTTPMethodTypeUNDEFINED?RKRequestMethodPUT:RKRequestMethodPATCH)];
        
        [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
        [objectManager addResponseDescriptor:responseDescriptor];
        [objectManager addRequestDescriptor:requestDescriptor];
        
        
    }
    
    
}

- (void)registerNSObjectSQLiteModelClassToSync:(Class)aClass
{
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([aClass isSubclassOfClass:[NSObject class]]) {
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
    
}

#pragma mark Sync Completion and Start Handlers

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:ckSyncEngineInitializationCompleteKey] boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:ckSyncEngineInitializationCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:ckSyncEngineSyncCompletedNotificationName
         object:nil];
        [self willChangeValueForKey:ckSyncInProgress];
        _syncInProgress = NO;
        [self didChangeValueForKey:ckSyncInProgress];
        [self updateLastSuccessfullCompleteSyncDate];
        
        if(self.conflictManager.conflictedObjects.count > 0 && self.conflictManager.conflictResolutionType == kConflictResolutionCustomMerge)
            [self.conflictManager reportConfclitsToRecievers];
        
        // [[NSNotificationCenter defaultCenter]postNotificationName:ckSyncEngineConflictedObjectsNotification object:self.conflictManager.conflictedObjects userInfo:nil];
    });
}

- (void)updateLastSuccessfullCompleteSyncDate
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    [standardDefaults setObject:[NSDate date] forKey:ckLastCompleteSyncDate];
    
    [standardDefaults synchronize];
}

- (NSDate *)lastSuccesfullCompleteSyncDate
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    return [standardDefaults objectForKey:ckLastCompleteSyncDate];
}

#pragma mark ResolveConflictedObjects

#pragma mark GooGleAnalyticsMethods

-(void)postGoogleAnalytics:(NSString*)className withStatus:(NSString*)status withStartDate:(NSDate*)startDate withNoOfObjectsSynced:(int)numberOfObjectsSynced
{
    /********** Applying Values to Multiple Hits********/
    
    /* Set the screen name on the tracker */
    [self.tracker set:kGAIScreenName value:@"Sync Process"];
    [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    /********** Measuring Events**********/
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"Post %@ Objects To Server - %@", className,status]
                                                               action:[NSString stringWithFormat:@"Time Taken-%f",[[NSDate date] timeIntervalSinceDate:startDate]]
                                                                label:[NSString stringWithFormat:@"No. Of objects Synced-%@",[NSNumber numberWithInt:numberOfObjectsSynced                                                                   ]]
                                                                value:nil] build]];
}

@end
