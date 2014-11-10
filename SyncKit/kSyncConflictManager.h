//
//  kSyncConflictManager.h
//  SyncKit
//
//  Created by Kavitha on 7/4/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol kSyncConflictManagerDelegate <NSObject>

/**
 *  This delegate is fired after sync has been completed and there are conflicts to be resolved. Note: This method is called when conflictResolutionType is set to kConflictResolutionCustomMerge only.
 *
 *  @param conflcitData Dictionary of conflicted data containing both server and client data.
 */
-(void)conflictedObjects:(NSMutableDictionary *)conflcitData;

@end

/**
 *  This Class is responsible for handling all the conflicts that happen in all of the models in the app, this class needs intialization for the whole of synckit to work.
 */
@interface kSyncConflictManager : NSObject

/**
 *  The conflict resolutuon technique that would be used to resolve conflicted records.
 */
@property (nonatomic,assign) kConflictResolutionType conflictResolutionType;

/**
 * The array containing all the conflicted objects after last sync, this array would contain values only when conflictResolutionType is set to kConflictResolutionCustomMerge.
 */
@property (nonatomic,strong) NSMutableDictionary *conflictedObjects;

/**
 *  The delegate that is to be subscribed to recieve and handle conflicts
 */
@property (nonatomic,weak)  id<kSyncConflictManagerDelegate> conflictResolutionDelegate;

/**
 *  The method that is used by the managedObject category to check whether a managedObject has conflicts
 *
 *  @param obj The managedObject which needs to be checked for conflicts
 *
 *  @return YES when there is a conflict and NO when not.
 */
- (BOOL)checkConflictsForManagedObject:(NSManagedObject *)obj;

/**
 *  Called by the engine when it has done its part of the sync and tells the conflict manager to report all conflicts to the recievers thorough the delegate
 */
- (void)reportConfclitsToRecievers;

/**
 *  This is the asynchronous way of relpying to the conflictedObjects: delegate method with conflict resolved records.
 *
 *  @param resolvedData The array that would contain conflict resolved reocrds.
 */
- (void)resolveConflictsInDictionary:(NSMutableDictionary *)resolvedData;

@end
