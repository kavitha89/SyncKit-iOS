//
//  kSyncKit.h
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kCoreDataController.h"
#import "kSyncEngine.h"

/**
 *  The main interface of the SyncKit framework. This class takes care of all the intialization that is required for the SyncKit to perform all of its intended operations.
 */
@interface kSyncKit : NSObject

/**
 *  Common HTTP headers that should be included in all kind of requests.
 */
@property (nonatomic, strong) NSDictionary *HTTPHeaders;

/**
 *  The base URL of the RESTFUL services that the sync kit would interact with.
 */
@property (nonatomic, copy)   NSString *baseURLString;

/**
 *  The sync engine object for the class, all sync opertaions happen through this object of the class.
 */
@property (nonatomic, strong) kSyncEngine *syncEngine;

/**
 *  The name of the file that contains all the configuration parameters and the model mapping parameters.
 */
@property (nonatomic, copy) NSString *parametersFileName;

/**
 *  The Dictionary that contains the confifguration parameters,
 */
@property (nonatomic, readonly, strong) NSDictionary *syncParameters;
/**
 *  Used to set the shared instances of the class
 *
 *  @param kit pass the instance of the class to be set as the shared instance of the class.
 */
+ (void)setSharedKit:(id)kit;

/**
 *  The shared instance of the object, it is recommended to use the sharedKit at all places to avoid concurrency issues
 *
 *  @return The shared instance of the class
 */
+ (instancetype)sharedKit;

/**
 *  Creates a shared instance of the class with the base url intialized.
 *
 *  @param url The base URL of the RESTFUL services that the sync kit would interact with.
 *
 *  @return The shared instance of the class.
 */
+ (instancetype)sharedKitWithRemoteBaseURl:(NSString *)url;

/**
 *  Creates a shared instance of the class with a given configuration file
 *
 *  @param configFileName The config file name
 *
 *  @return The shared instance of the class
 */
+ (instancetype)sharedKitWithConfigurationFile:(NSString *)configFileName;

/**
 *  Creates an instance of the class with a given configuration file
 *
 *  @param configFileName The config file name
 *
 *  @return The shared instance of the class
 */
- (id)initWithConfigurationFile:(NSString *)configFileName;

/**
 *  Creates an instance of the class with the base url initialized.
 *
 *  @param baseURL The base URL of the RESTFUL services that the sync kit would interact with.
 *
 *  @return An instance of the class.
 */
- (id)initWithRemoteBaseURL:(NSString *)baseURL;

/**
 *  Call this method to start performing sync
 */
- (void)startSync;

/**
 *  Method used to setup the local database to cache remote values
 *
 *  @param modelName The model file's name that should be used to setup the local database (core data .xcdatamodel file).
 */
- (void)setupSyncComponentWithLocalDBModelName:(NSString *)modelName;

@end
