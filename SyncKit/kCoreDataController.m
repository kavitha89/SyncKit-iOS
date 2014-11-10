//
//  kCoreDataController.m
//  SignificantDates
//
//  Created by Chris Wagner on 5/14/12.
//

#import "kCoreDataController.h"
#import <RestKit/RestKit.h>
#import <objc/runtime.h>
#import <RestKit/RKManagedObjectStore.h>

@interface kCoreDataController ()

@property (strong, nonatomic) NSManagedObjectContext *masterManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (copy,   nonatomic) NSString *modelNameString;

@end

@implementation kCoreDataController

@synthesize masterManagedObjectContext = _masterManagedObjectContext;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



static kCoreDataController  *sharedController = nil;

+ (void)setSharedController:(id)controller
{
    sharedController = controller;
}

+ (instancetype)sharedController
{
    return sharedController;
}

+ (instancetype)sharedControllerWithModelName:(NSString *)modelName {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedController = [[self alloc] initWithModelName:modelName];
    });
    
    return sharedController;
}


- (instancetype)initWithModelName:(NSString *)mName
{
    self = [super init];
    if (self) {
        _modelNameString = mName;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Core Data stack

- (void)createPersistentStoreCoordinator
{
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
}

- (void)createManagedObjectContexts
{
    NSAssert(!self.masterManagedObjectContext, @"Unable to create managed object contexts: A primary managed object context already exists.");
    NSAssert(!self.backgroundManagedObjectContext, @"Unable to create managed object contexts: A main queue managed object context already exists.");
    NSAssert([[self.persistentStoreCoordinator persistentStores] count], @"Cannot create managed object contexts: The persistent store coordinator does not have any persistent stores. This likely means that you forgot to add a persistent store or your attempt to do so failed with an error.");
    
    // Our primary MOC is a private queue concurrency type
    
    /*self.masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.masterManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    self.masterManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    // Create an MOC for use on the main queue
    self.backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.backgroundManagedObjectContext.parentContext = self.masterManagedObjectContext;
    self.backgroundManagedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;*/
    
}

// Used to propegate saves to the persistent store (disk) without blocking the UI
- (NSManagedObjectContext *)masterManagedObjectContext {
    /*if (_masterManagedObjectContext != nil) {
        return _masterManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _masterManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_masterManagedObjectContext performBlockAndWait:^{
            [_masterManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
        
    }
    return _masterManagedObjectContext;*/
    
    return [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    /*if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:masterContext]; 
        }];
    }
    
    return _backgroundManagedObjectContext;*/
    return [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)newManagedObjectContext {
    NSManagedObjectContext *newContext = nil;
    NSManagedObjectContext *masterContext = [self masterManagedObjectContext];
    if (masterContext != nil) {
        newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [newContext performBlockAndWait:^{
            [newContext setParentContext:masterContext]; 
        }];
    }
    
    return newContext;
}

- (void)saveContextToPersistentStore
{
    //[self saveMasterContext];
    [self saveBackgroundContext];
}

- (void)saveMasterContext {
       NSError *error = nil;
    [[[[RKObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext] save:&error];
//    [self.masterManagedObjectContext performBlockAndWait:^{
//        NSError *error = nil;
//        BOOL saved = [self.masterManagedObjectContext save:&error];
//        if (!saved) {
//            // do some real error handling 
//            NSLog(@"Could not save master context due to %@", error);
//        }
//    }];
}

- (void)saveBackgroundContext {
    

    [[[[RKObjectManager sharedManager] managedObjectStore] persistentStoreManagedObjectContext]  performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.backgroundManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling 
            NSLog(@"Could not save background context due to %@", error);
        }
    }];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelNameString withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.modelNameString]];
    
    NSError *error = nil;

    
    //for iOS7 and backward iOS compatibility.Removing new iOS7 'WAL' Journal mode.Using the old 'ROLLBACK' Journal mode
    
    NSDictionary *options = @{ NSSQLitePragmasOption : @{ @"journal_mode" : @"DELETE" } };
   
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (BOOL)shouldPerformFetchAllForEntity:(NSString *)entityName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:[self backgroundManagedObjectContext]]];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *err;
    NSUInteger count = [[self backgroundManagedObjectContext] countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Fetch Methods


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
