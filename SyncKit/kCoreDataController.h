//
//  kCoreDataController.h
//  SignificantDates
//
//  Created by Chris Wagner on 5/14/12.
//

#import <Foundation/Foundation.h>

/**
 *  This class is used by the SyncKit to perform all core data related operations, other than opertaions done by RESTKIT.
 */
@interface kCoreDataController : NSObject

/**
 *  Method that is used to set the share instance of the class.
 *
 *  @param controller An instance of the kCoreDataController class.
 */
+ (void)setSharedController:(id)controller;

/**
 *  Returns the shared instance of the class.
 *
 *  @return The shared instance of the class.
 */
+ (instancetype)sharedController;

/**
 *  Returns the shared instance of the class intialized with a xcdatamodel file name.
 *
 *  @param modelName The xcdatamodel file name.
 *
 *  @return The shared instnce of the class.
 */
+ (instancetype)sharedControllerWithModelName:(NSString *)modelName;

/**
 *  Returns the master managed object context.
 *
 *  @return A NSManagedObject context which is the master context.
 */
- (NSManagedObjectContext *)masterManagedObjectContext;

/**
 *  Returns the master managed object context.
 *
 *  @return A NSManagedObject context which is the master context.
 */
- (NSManagedObjectContext *)backgroundManagedObjectContext;

/**
 *  Returns the master managed object context.
 *
 *  @return A NSManagedObject context which is the master context.
 */
- (NSManagedObjectContext *)newManagedObjectContext;

/**
 *  Saves all changes to the persistent store.
 */
- (void)saveContextToPersistentStore;

/**
 *  Saves the changes in the master context.
 */
- (void)saveMasterContext;

/**
 *  Saves the changes in the private or background context.
 */
- (void)saveBackgroundContext;

/**
 *  Returns the managed object model.
 *
 *  @return A NSManagedObjectModel instance.
 */
- (NSManagedObjectModel *)managedObjectModel;

/**
 *  Returns the persistentStoreCoordinator object.
 *
 *  @return A NSPersistentStoreCoordinator object.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 *  Method to create a persistent store coordinator.
 */
- (void)createPersistentStoreCoordinator;

/**
 *  Method to create a all managed object contexts.
 */
- (void)createManagedObjectContexts;

/**
 *  Says whether a fetch all opertaion should be made for a particular entity.
 *
 *  @param entityName The entity or class name
 *
 *  @return Bool value saying whether to make a fetch all or a delta call
 */
- (BOOL)shouldPerformFetchAllForEntity:(NSString *)entityName;

@end
