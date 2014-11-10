//
//  kSyncKit.m
//  SyncKit
//
//  Created by Kavitha on 6/6/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "kSyncKit.h"
#import <RestKit/RestKit.h>
#import "kSyncEngine.h"
#import "kSyncConstants.h"

@interface kSyncKit()

@property (nonatomic, readwrite, strong) NSDictionary *syncParameters;

@end

@implementation kSyncKit

static kSyncKit  *sharedKit = nil;

+ (void)setSharedKit:(id)kit

{
    sharedKit = kit;
}


+ (instancetype)sharedKit
{
    return sharedKit;
}

+ (instancetype)sharedKitWithRemoteBaseURl:(NSString *)url
{
    static dispatch_once_t onceSyncKit;
    dispatch_once(&onceSyncKit, ^{
        sharedKit = [[self alloc] initWithRemoteBaseURL:url];
    });

    return sharedKit;
}

+ (instancetype)sharedKitWithConfigurationFile:(NSString *)configFileName
{
    static dispatch_once_t onceSyncKit;
    dispatch_once(&onceSyncKit, ^{
        sharedKit = [[self alloc] initWithConfigurationFile:configFileName];
    });
    
    return sharedKit;
}

- (id)initWithConfigurationFile:(NSString *)configFileName
{
    self = [super init];
    if (self) {
        
        //Initialize the paramtersDictionary
        
        _parametersFileName = configFileName;
        
        _syncParameters = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[configFileName stringByDeletingPathExtension] ofType:configFileName.pathExtension]];
        
        _baseURLString = [self.syncParameters objectForKey:@"remoteBaseURL"];
        
        _HTTPHeaders = [self.syncParameters objectForKey:@"defaultHeaders"];
        
    }
    return self;

}

- (id)initWithRemoteBaseURL:(NSString *)baseURL
{
    self = [super init];
    if (self) {
        _baseURLString = baseURL;
    }
    return self;
}

- (kSyncEngine *)syncEngine
{
    return [kSyncEngine sharedEngine];
}

- (void)setupSyncComponentWithLocalDBModelName:(NSString *)modelName
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[self.baseURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    for(id key in self.HTTPHeaders.allKeys)
    {
        [objectManager.HTTPClient setDefaultHeader:key value:[self.HTTPHeaders objectForKey:key]];
    }
    
    //[RKObjectManager setSharedManager:objectManager];
    
    [kCoreDataController setSharedController:[kCoreDataController sharedControllerWithModelName:modelName]];
    
    
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithPersistentStoreCoordinator:[[kCoreDataController sharedController]persistentStoreCoordinator]];
    
    objectManager.managedObjectStore = managedObjectStore;
    
    [objectManager.managedObjectStore createManagedObjectContexts];
    
    
    // Create the managed object contexts

    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
}

- (void)startSync
{
    [[kSyncEngine sharedEngine] startSync];
}




@end
