//
//  kSyncEngine.h
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kSyncConflictManager.h"


/**
 *  The kSyncEngine is the heart of the SyncKit framework, this is where all the sync operations are done, dirty records are managed, models register themselves for sync. Always use the sharedEngine object to perform all operations
 */
@interface kSyncEngine : NSObject

/**
 *  The Bool value that specifies whether sync is going on now or not
 */
@property (atomic, readonly) BOOL syncInProgress;

/**
 *  The conflict manager for the whole SDK.
 */
@property (atomic, retain) kSyncConflictManager *conflictManager;


/**
 *  The array that holds the list of model classes that are to be synced by kSyncKit
 */
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
/**
 *  The shared instance method of the kSyncEngine class
 *
 *  @return the shared instance of the class
 */
+ (instancetype)sharedEngine;

/**
 *  Helps in registering a Core Data model class (NSManagedObject subclass) for performing sync, pass the class name not the object that you want to sync.
 *
 *  @param theClass The name of the NSManagedObject subclass that you want to sync.
 */
- (void)registerNSManagedObjectClassToSync:(Class)theClass;

/**
 *  Helps in registering a simple model class for performing sync, may be suitable for SQLite databases
 *
 *  @param theClass The name of the NSObject subclass that you want to sync
 */
- (void)registerNSObjectSQLiteModelClassToSync:(Class)theClass;

/**
 *  The method to do all magic, call this method to perform a complete sync.
 */
- (void)startSync;

/**
 *  Updates the last succesfull complete sync date to current data
 */
- (void)updateLastSuccessfullCompleteSyncDate;
/**
 *  Returns the last succesfull complete sync date
 *
 *  @return The NSDate value of the last succesfull complete sync date.
 */
- (NSDate *)lastSuccesfullCompleteSyncDate;

/**
 *  Posts all dirty records to the server based on the mapping provided.
 */
- (void)postLocalObjectsToServer ;

/**
 *  Fetches all dirty objects for the mentioned model.
 *
 *  @param className The Model class name or the table name.
 *
 *  @return An array of dirty records for the mentioned model class name.
 */
- (NSArray *)dirtyObjectsFormanagedObjectClass:(NSString *)className;

/**
 *  Fetches all newly created objects for the mentioned model
 *
 *  @param className The Model class name or the table name.
 *
 *  @return An array of newly created records that are to be created at the server end, for the mentioned model class name.
 */
- (NSArray *)newlyCreatedObjectsForManagedObjectClass:(NSString *)className;

/**
 *  Fetches all deleted objects for the mentioned model
 *
 *  @param className The Model class name or the table name.
 *
 *  @return An array of deleted records that are to be deleted at the server end, for the mentioned model class name.
 */
- (NSArray *)deletedObjectsForManagedObjectClass:(NSString *)className;

/**
 *  Fetches all valid objects for the mentioned model
 *
 *  @param className The Model class name or the table name.
 *
 *  @return An array of all valid objects for the mentioned model class name.
 */
- (NSArray *)fetchAllRecordsForManagedObjectClass:(NSString *)className;

@end
