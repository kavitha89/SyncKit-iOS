//
//  kSyncOperation.h
//  SyncKit
//
//  Created by Kavitha on 6/9/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <RestKit/RestKit.h>

/**
 *  This class takes care of all the REST opertaions that takes place in the SyncKit framework.
 */
@interface kSyncOperation : NSObject

/**
 *  The Succes completion handler that is inovked on a succesfull operaiton completion
 *
 *  @param operation      The operation that yielded the success result
 *  @param responseObject The response object of the result
 */
typedef void (^SuccessBlockType)(RKObjectRequestOperation *operation, id responseObject);

/**
 *  The failure completion handler that is invoked when the undelying operation fails.
 *
 *  @param operation The opertaion that yielded the failure result
 *  @param error     The error object of the failure completion handler
 */
typedef void (^FailureBlockType)(RKObjectRequestOperation *operation, NSError *error);

/**
 *  The shared instance of the sync opertaion API.
 *
 *  @return The shared instance of the class
 */
+ (instancetype)sharedSyncOperationAPI;

/**
 *  Performs a GET to fetch all records of a given model class
 *
 *  @param className  The class name
 *  @param parameters Paramters if any
 *  @param success    The success completion handler
 *  @param failure    The failure completion handler
 */
- (void)performFetchAllRequestForClass:(NSString *)className
                            parameters:(NSDictionary *)parameters
                               success:(SuccessBlockType)success
                               failure:(FailureBlockType)failure;

/**
 *  Performs a custom GET to fetch details of a record
 *
 *  @param className The class name
 *  @param ID        The ID of the record
 *  @param params    Parameters if any
 *  @param success   The success completion handler
 *  @param failure   The failure completion handler
 */
- (void)performFetchRequestForRecordOfClassName:(NSString *)className
                                 andIdentifeier:(NSString *)ID parameters:(NSDictionary *)params
                                        success:(SuccessBlockType)success failure:(FailureBlockType)failure;

/**
 *  Performs a GET to fetch all of the records that were updated after a given date/time interval
 *
 *  @param className   The class name
 *  @param updatedDate Parameters if any
 *  @param success     The success completion handler
 *  @param failure     The failure completion handler
 */
- (void)performFetchAllRecordsOperationOfClass:(NSString *)className
                              updatedAfterDate:(NSDate *)updatedDate
                                       success:(SuccessBlockType)success
                                       failure:(FailureBlockType)failure;

/**
 *  Performs a POST opertion to update records from a client to the server
 *
 *  @param object      The object that is to be posted to the server, included in the body
 *  @param parameters  Parameters if any
 *  @param success     The success completion handler
 *  @param failure     The failure completion handler
 */
- (void)performPOSTRequestForObject:(id)object parameters:(NSDictionary *)parameters
                            success:(SuccessBlockType)success
                            failure:(FailureBlockType)failure;

/**
 *  Performs a PATCH opertion to update records from a client to the server
 *
 *  @param object      The object that is to be posted to the server, included in the body
 *  @param parameters  Parameters if any
 *  @param success     The success completion handler
 *  @param failure     The failure completion handler
 */
- (void)performPATCHOperationForObject:(id)object parameters:(NSDictionary *)parameters
                               success:(SuccessBlockType)success
                               failure:(FailureBlockType)failure;
/**
 *  Performs a PUT operation to create records that were created in client and have to be created at the server
 *
 *  @param object      The object that is to be created
 *  @param parameters  Parameters if any
 *  @param success     The success completion handler
 *  @param failure     The failure completion handler
 */
- (void)performPUTOperationForObject:(id)object parameters:(NSDictionary *)parameters
                             success:(SuccessBlockType)success
                             failure:(FailureBlockType)failure;

/**
 *  Performs a Delete operation to delete records that were delted at the client and have to be deleted at the server
 *
 *  @param object     The object that is to be deleted
 *  @param params     Parameters if any
 *  @param success    The success completion handler
 *  @param failure    The failure completion handler
 */
- (void)performDeleteOpertaionForObject:(id)object parameters:(NSDictionary *)params
                                success:(SuccessBlockType)success
                                failure:(FailureBlockType)failure;

@end
