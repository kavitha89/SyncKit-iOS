//
//  kSyncOperation.m
//  SyncKit
//
//  Created by Kavitha on 6/9/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import "kSyncOperation.h"
#import <RestKit/RestKit.h>
#import "NSManagedObject+kSyncKit.h"
#import "NSObject+kSyncKit.h"

@implementation kSyncOperation


+ (instancetype)sharedSyncOperationAPI
{
    static kSyncOperation *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[kSyncOperation alloc] init];
    });
    
    return sharedClient;

}

- (void)performFetchAllRequestForClass:(NSString *)className
                                      parameters:(NSDictionary *)parameters
                                         success:(SuccessBlockType)success
                                         failure:(FailureBlockType)failure
{
    Class objectClass = NSClassFromString(className);
    
    NSString *urlPath = @"";
    NSDictionary *paramsDict;
    
    if([objectClass isSubclassOfClass:[NSManagedObject class]])
    {
        urlPath = [((NSManagedObject *)objectClass) performSelector:@selector(URLForFetchAllMethod)
                   ] ;
        urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        paramsDict = [((NSManagedObject *)objectClass) performSelector:@selector(queryParametersForFetchAllMethod)
                   ] ;

        
    }else if([objectClass isSubclassOfClass:[NSObject class]])
    {
        urlPath = [((NSObject *)objectClass) performSelector:@selector(URLForFetchAllMethod)
                   ] ;
        
        paramsDict = [((NSObject *)objectClass) performSelector:@selector(queryParametersForFetchAllMethod)
                      ] ;
    }
        
    [[RKObjectManager sharedManager] getObjectsAtPath:urlPath parameters:paramsDict success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        success(operation,mappingResult);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation,error);
        
    }];
    
}

- (void)performFetchRequestForRecordOfClassName:(NSString *)className andIdentifeier:(NSString *)ID parameters:(NSDictionary *)params success:(SuccessBlockType)success failure:(FailureBlockType)failure
{
    Class objectClass = NSClassFromString(className);
    
    NSString *urlPath = @"";
    
    if([objectClass isSubclassOfClass:[NSObject class]])
    {
        urlPath = [((NSObject *)objectClass) performSelector:@selector(URLForFetchMethod)
                   ] ;
        
    }else if([objectClass isSubclassOfClass:[NSManagedObject class]])
        urlPath = [((NSManagedObject *)objectClass) performSelector:@selector(URLForFetchMethod)
                   ] ;
    
    [[RKObjectManager sharedManager] getObject:ID  path:urlPath  parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        success(operation,mappingResult);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation,error);

    }];

}


- (void)performFetchAllRecordsOperationOfClass:(NSString *)className
                                            updatedAfterDate:(NSDate *)updatedDate
                                                     success:(SuccessBlockType)success
                                                     failure:(FailureBlockType)failure
{
    Class objectClass = NSClassFromString(className);
    
    NSString *urlPath = @"";
    
    NSMutableDictionary *paramsDict;
    
    if([objectClass isSubclassOfClass:[NSManagedObject class]])
    {
        urlPath = [((NSManagedObject *)objectClass) performSelector:@selector(URLForDeltaFetchMethod)
                   ];
        if([objectClass queryParametersForDeltaFetchMethodWithLastUpdatedDate:updatedDate])
        paramsDict = [NSMutableDictionary dictionaryWithDictionary:[objectClass queryParametersForDeltaFetchMethodWithLastUpdatedDate:updatedDate]] ;
        
        
    }else if([objectClass isSubclassOfClass:[NSObject class]])
    {
        urlPath = [((NSObject *)objectClass) performSelector:@selector(URLForDeltaFetchMethod)
                   ];
        if([objectClass queryParametersForDeltaFetchMethodWithLastUpdatedDate:updatedDate])
        paramsDict = [NSMutableDictionary dictionaryWithDictionary:[objectClass queryParametersForDeltaFetchMethodWithLastUpdatedDate:updatedDate]] ;
    }
    
    
    [[RKObjectManager sharedManager] getObjectsAtPath:urlPath parameters:paramsDict success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
 
        success(operation,mappingResult);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation,error);
        
    }];
    

    
}


- (BOOL)mappingOperation:(RKMappingOperation *)operation shouldSetValue:(id)value forKeyPath:(NSString *)keyPath usingMapping:(RKPropertyMapping *)propertyMapping
{
    return NO;
}



- (void)performPOSTRequestForObject:(id)object parameters:(NSDictionary *)parameters
                                          success:(SuccessBlockType)success
                                          failure:(FailureBlockType)failure
{
    
    NSString *urlPath = @"";
    
    if([object isKindOfClass:[NSManagedObject class]])
    {
        urlPath = [[object class] URLForNewServerObject] ;
        
    }else if([object isKindOfClass:[NSObject class]])
        urlPath = [((NSObject *)object) URLForUpdateServerObject
                   ] ;
    
    [[RKObjectManager sharedManager] postObject:object path:urlPath parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation,mappingResult);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSString *postBOcy = [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody] encoding:NSUTF8StringEncoding] ;
        NSLog(@"body: %@",postBOcy);
        failure(operation,error);
    }];
}

- (void)performPUTOperationForObject:(id)object parameters:(NSDictionary *)parameters
                            success:(SuccessBlockType)success
                            failure:(FailureBlockType)failure
{
    
    NSString *urlPath = @"";
    
    if([object isKindOfClass:[NSManagedObject class]])
    {
        urlPath = [((NSManagedObject *)object) URLForUpdateServerObject] ;
        
    }else if([object isKindOfClass:[NSObject class]])
        urlPath = [((NSObject *)object) URLForUpdateServerObject
                   ] ;
    
    [[RKObjectManager sharedManager] putObject:object path:urlPath parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation,mappingResult);
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSString *postBOcy = [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody] encoding:NSUTF8StringEncoding] ;
        NSLog(@"body: %@",postBOcy);
        failure(operation,error);
    }];
    
}

- (void)performPATCHOperationForObject:(id)object parameters:(NSDictionary *)parameters
                             success:(SuccessBlockType)success
                             failure:(FailureBlockType)failure
{
    
    NSString *urlPath = @"";
    
    if([object isKindOfClass:[NSManagedObject class]])
    {
        urlPath = [((NSManagedObject *)object) URLForUpdateServerObject] ;
        
    }else if([object isKindOfClass:[NSObject class]])
        urlPath = [((NSObject *)object) URLForUpdateServerObject
                   ] ;
    
    [[RKObjectManager sharedManager] patchObject:object path:urlPath parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation,mappingResult);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSString *postBOcy = [[NSString alloc] initWithData:[operation.HTTPRequestOperation.request HTTPBody] encoding:NSUTF8StringEncoding] ;
        NSLog(@"body: %@",postBOcy);
        failure(operation,error);

    }];
    
}

- (void)performDeleteOpertaionForObject:(id)object parameters:(NSDictionary *)params
                                            success:(SuccessBlockType)success
                                            failure:(FailureBlockType)failure
{
    
    NSString *urlPath = @"";
    
    if([object isKindOfClass:[NSManagedObject class]])
    {
        urlPath = [((NSManagedObject *)object) performSelector:@selector(URLForDeleteServerObject)
                   ] ;
        
    }else if([object isKindOfClass:[NSObject class]])
        urlPath = [((NSObject *)object) URLForDeleteServerObject
                   ] ;

    
    [[RKObjectManager sharedManager] deleteObject:object  path:urlPath parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(operation,mappingResult);

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        failure(operation,error);

    }];
}

@end
