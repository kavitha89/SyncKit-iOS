//
//  NSManagedObject+SyncKit.h
//  kSyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

/**
 *  The category for NSManagedObject that contains all SyncKit customizations
 */
@interface NSManagedObject (kSyncKit)

/**
 *  The temporary sync status of the record, used for internal manipulations (never try to set or get it from the outside)
 */
@property (nonatomic,strong) NSNumber *temp_sync_status;

/**
 *  Returns whether the update to a record is an update from the server or the client.
 *
 *  @return YES if server update, NO for client.
 */
- (BOOL)isRemoteUpdate;

/**
 *  Returns the column in the model that would contain records primary identifier.
 *
 *  @return theIdentificationAttribute.
 */
+ (NSString *)identificationAttribute;

/**
 *  Returns the column in the model that would contain the records last server updated date.
 *
 *  @return recordsLastUpdatedDate.
 */
+ (NSString *)lastUpdatedDateContainerAttribute;

/**
 *  Returns the column in the model that would contain the records sync status flag.
 *
 *  @return records sync status column name.
 */
+ (NSString *)syncStatusFlagAttribute;

/**
 *  Returns the column in the model that would contain the last server synchronizatin date for the record.
 *
 *  @return last server synch data container of the record.
 */
+ (NSString *)lastServerSyncedDataContainerAttribute;

/**
 *  Returns the keypath to be searched in the response to get the desired data for the model.
 *
 *  @return The key path to be seached.
 */
+ (NSString *)keyPathToSearch;

/**
 *  Returns the post object(JSON dictionary) that is to be sent to the server to create a new object.
 *
 *  @return The post object for object creation.
 */
- (NSDictionary *)postObjectForNewServerObject;

#pragma mark Create methods

/**
 *  Returns the request mapping for server side object insertion.
 *
 *  @return Dictionay containing the data mapping that is to be used during server object insertion.
 */
+ (NSDictionary *)requestObjectMappingForRemoteObjectCreation;

/**
 *  Returns the response mapping for handling the server side response for object creation.
 *
 *  @return Dictionary containing the data mapping for the response from the server for object insertion.
 */
+ (NSDictionary *)responseObjectMappingForRemoteObjectCreation;

/**
 *  Returns the URL that is to be used to create a new object.
 *
 *  @return The NSString URL object to be used for new object creation.
 */
+ (NSString *)URLForNewServerObject;

#pragma mark Update Methods

/**
 *  Returns the request mapping for server side object update.
 *
 *  @return Dictionay containing the data mapping that is to be used during server object update.
 */
+ (NSDictionary *)requestObjectMappingForRemoteObjectUpdate;

/**
 *  Returns the response mapping for handling the server side response for object update.
 *
 *  @return Dictionary containing the data mapping for the response from the server for object update.
 */
+ (NSDictionary *)responseObjectMappingForRemoteObjectUpdate;

/**
 *  Returns the post object(JSON dictionary) that is to be sent to the server to update any already existing object.
 *
 *  @return The post object for object update.
 */
- (NSDictionary *)postObjectForUpdateServerObject;

/**
 *  Returns the URL that is to be used to update an existing object.
 *
 *  @return The NSString url object to be used for object updation.
 */
- (NSString *)URLForUpdateServerObject;

/**
 *  Returns the URL Path patter for server update of record.
 *
 *  @return The NSString url object that specifies the path patter for remote update.
 */
+ (NSString *)URLPathPatternForUpdateRemoteObject;

/**
 *  Returns the type of operation to be performed for a update request
 *
 *  @return One of kHTTPMethodType's enum specifying the HTTP Method type to be performed for an update operation.
 */
+ (kHTTPMethodType)methodTypeForUpdateOperation;

#pragma mark Delete Methods

/**
 *  Returns the post object(JSON dictionary) that is to be sent to the server for deleting an object.
 *
 *  @return The post object for object delete.
 */
- (NSDictionary *)postObjectForDeleteServerObject;

/**
 *  Returns the URL that is to be used to perform a delete opertaion.
 *
 *  @return The NSString url object to be used for object deletion.
 */
- (NSString *)URLForDeleteServerObject;

/**
 *  Returns the URL that is to be used to fetch all records that were deleted on the server.
 *
 *  @return The NSString url object to be used for getting delted objects from the server.
 */
+ (NSString *)URLToGetDeletedRecordsFromServer;

/**
 *  Returns the post object(JSON dictionary) that is to be sent to the server for performing a batch deletion.
 *
 *  @return The post object for batch deletion.
 */
- (NSDictionary *)postObjectForBatchDeleteServerObjects;

/**
 *  Returns the URL that is to be used to perform a batch delete operation.
 *
 *  @return The NSURL object to be used for batch delete operation.
 */
- (NSURL *)URLForBatchDeleteServerObjects;

#pragma mark Fetch Methods

/**
 *  Returns the URL that is to be used to perform a fetch all or query a particular server parameter in a server object.
 *
 *  @return The NSString object to be used for fetch/query opertaion.
 */
+ (NSString *)URLForFetchMethod;

/**
 *  Returns the URL that is to be used to perform a fetch all for a model.
 *
 *  @return The NSString object containing the url.
 */
+ (NSString *)URLForFetchAllMethod;

/**
 *  Returns the list of query parameters that need to be appended in the URL to make a succesfull request
 *
 *  @return An NSDictionary containing the list of URL query parameters.
 */
+ (NSDictionary *)queryParametersForFetchAllMethod;
/**
 *  Returns the URL that is to be used to perform a fetch record details.
 *
 *  @return The NSString object containing the url.
 */
- (NSString *)URLForFetchRecordDetails;

/**
 *  Returns the URL that is to be used to perform a fetch delta of a model.
 *
 *  @return The NSString object containing the url.
 */
+ (NSString *)URLForDeltaFetchMethod;

/**
 *  Returns the query parameters if any to do a delta fetch for a model.
 *
 *  @return A NSDictionary object containing delta fetch query parameters.
 */
+ (NSDictionary *)parametersForDeltaFetchMethodWithLastUpdatedDate:(NSDate *)updatedDate;

/**
 *  Returns the query parameters if any to do a delta fetch for a model.
 *
 *  @param updatedDate the date from which you want most recent information
 *
 *  @return A NSDictionary object containing delta fetch query parameters.
 */
+ (NSDictionary *)queryParametersForDeltaFetchMethodWithLastUpdatedDate:(NSDate *)updatedDate;

#pragma mark Object Mapping Methods

/**
 *  Returns the object mapping between the local store model and the server model/JSON parameters.
 *
 *  @return The model mapping between the local and server parameters.
 */
+ (NSDictionary *)objectMappingForManagedObject;

/**
 *  Returns the relationship mapping between two models.
 *
 *  @return The relationship mapping between two models.
 */
- (NSDictionary *)relationshipMappingForManagedObject;

/**
 *  Method to call to roll back a record to its immediate previous state.
 */
- (void)rollBackRecord;


#pragma mark Record Status Change Methods

- (void)markAsDirty;

- (void)markAsNew;

- (void)markAsDeleted;

- (void)markAsSynced;

#pragma mark Record Status Manager & Helpers

/**
 * Custom method to perform operations after record insert.
 */
- (void)syncKitValidateForInsert;

/**
 * Custom method to perform operations after record Delete.
 */
- (void)syncKitValidateForDelete;

/**
 * Custom method to perform operations before a record update
 *
 *  @return YES or NO based on the update.
 */
- (BOOL)syncKitValidateForUpdate;

/**
 *  Custom method to perform operations before saving.
 */
- (void)syncKitWillSave;

/**
 *  Custom method to perform operations after saving.
 */
- (void)syncKitDidSave;

@end
