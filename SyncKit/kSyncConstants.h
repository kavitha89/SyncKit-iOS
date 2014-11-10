//
//  kSyncConstants.h
//  SyncKit
//
//  Created by Kavitha on 6/12/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#ifndef SyncKit_kSyncConstants_h
#define SyncKit_kSyncConstants_h

/**
 *  @abstract The enum that specifies the different states of a record in the data store
 *
 *  @constant kObjectSynced   Specifies that the record is synced properly and no further operation is to be done for that particular record
 *  @constant kObjectCreated  Specifies that the record has been newly created and a corresponding operation is to be done inroder to preserve the sync
 *  @constant kObjectDeleted  Specifies that the record has been deleted from the data store and a corresponding operation is to be done inroder to preserve the sync
 */
typedef enum {
    kObjectSynced = 0,
    kObjectCreated=1,
    kObjectDeleted=2,
    kObjectDirty=3,
    kObjectConflicted=4,
    kObjectClientAccept=5
    ,kObjectClientConflictResolved=6
} kObjectSyncStatus;

/**
 *  @abstract The enum that specifies the different conflict resolution scenarios in the SyncKit
 *
 *  @constant kConflictResolutionServerWins   Specifies that the Server data wins and changes are persisted at both ends.
 *  @constant kConflictResolutionClientWins  Specifies that the Client data wins and the record is marked dirty for the dirty records manager to maked the changes to persist at both ends.
 *  @constant kConflictResolutionMostRecentWins  Specifies that the most recent record wins the confict and he record is marked dirty for the dirty records manager to maked the changes to persist at both ends.
 *  @constant kConflictResolutionCustomMerge  Specifies that there is a custom way of handling the conflict and clients may observe for kConflitManager's conflictedObjects:(NSMutableDictionary *)conflcitData delegate.
 *  @constant kConflictResolutionNone  Specifies that there is no conflict resolution technique assigned.
 */
typedef enum{
    kConflictResolutionServerWins,
    kConflictResolutionClientWins,
    kConflictResolutionMostRecentWins,
    kConflictResolutionCustomMerge,
    kConflictResolutionNone //for one way sync.
} kConflictResolutionType;


typedef enum{
    kObjectRemoteOperationInsert=1,
    kObjectRemoteOperationUpdate,
    kObjectRemoteOperationDelete,
    kObjectRemoteOperationFetch,
    kObjectRemoteOperationUndefined
} kObjectRemoteOperationType;

typedef enum{
    kHTTPMethodTypeGET=1,
    kHTTPMethodTypePUT,
    kHTTPMethodTypePOST,
    kHTTPMethodTypeDELETE,
    kHTTPMethodTypePATCH,
    kHTTPMethodTypeUPDATE,
    kHTTPMethodTypeMERGE,
    kHTTPMethodTypeHEAD,
    kHTTPMethodTypeTRACE,
    kHTTPMethodTypeCONNECT,
    kHTTPMethodTypeCHECKOUT,
    kHTTPMethodTypeOPTIONS,
    kHTTPMethodTypeUNDEFINED

} kHTTPMethodType;

#define ckSyncEngineInitializationCompleteKey @"kSyncEngineInitializationCompleteKey"
#define ckSyncEngineSyncCompletedNotificationName @"kSyncEngineSyncCompletedNotificationName"
#define ckSyncEngineConflictedObjectsNotification @"kSyncEngineConflictedObjectNotificationName"
#define ckSyncInProgress  @"syncInProgress"
#define ckLastCompleteSyncDate  @"kLastCompleteSyncDate"


#define K_MODEL_IDENTIFICATION_ATTRIBUTE_SELECTOR @selector(identificationAttribute)
#define k_MODEL_OBJECT_MAPPING_FOR_MANAGED_OBJECT_SELECTOR @selector(objectMappingForManagedObject)
#define K_MODEL_URL_FOR_FETCH_ALL_METHOD_SELECTOR @selector(URLForFetchAllMethod)

#define K_MODEL_URL_FOR_FETCH_METHOD_SELECTOR @selector(URLForFetchMethod)
#define k_MODEL_KEY_PATH_SELECTOR @selector(keyPathToSearch)
#define K_MODEL_URL_FOR_NEW_REMOTE_OBJECT @selector(URLForNewServerObject)
#define K_MODEL_RESPONSE_OBJECT_MAPPING_REMOTE_OBJET_CREATION @selector(responseObjectMappingForRemoteObjectCreation)
#define K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_CREATION @selector(requestObjectMappingForRemoteObjectCreation)
#define K_MODEL_URL_FOR_UPDATE_REMOTE_OBJECT @selector(URLForUpdateServerObject)
#define K_MODEL_URL_PATH_PATTERN_FOR_UPDATE_REMOTE_OBJET @selector(URLPathPatternForUpdateRemoteObject)
#define K_MODEL_RESPONSE_OBJECT_MAPPING_REMOTE_OBJET_UPDATE @selector(responseObjectMappingForRemoteObjectUpdate)
#define K_MODEL_REQUEST_OBJECT_MAPPING_REMOTE_OBJECT_UPDATE @selector(requestObjectMappingForRemoteObjectUpdate)
#define K_MODEL_URL_FOR_FETCH_DELTA_OBJECTS @selector(URLForDeltaFetchMethod)
#define K_MODEL_URL_FOR_GET_SERVER_DELETED_OBJECTS @selector(URLToGetDeletedRecordsFromServer)


#define K_CONFLICT_OBJECT_CLIENT_DATA @"clientData"
#define K_CONFLICT_OBJECT_SERVER_DATA @"serverData"

#endif
 