//
//  Transformer.h
//  SyncKit
//
//  Created by kavitha on 08/11/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Transformer : NSManagedObject

@property (nonatomic, retain) NSDate * lastServerSyncDate;
@property (nonatomic, retain) NSDate * lastUpdatedDate;
@property (nonatomic, retain) NSDecimalNumber * syncStatus;
@property (nonatomic, retain) NSString * trsLocation;
@property (nonatomic, retain) NSString * trsName;
@property (nonatomic, retain) NSString * trsOperatingPower;
@property (nonatomic, retain) NSString * trsOilLevel;
@property (nonatomic, retain) NSString * trsWindingCount;
@property (nonatomic, retain) NSString * trsMake;
@property (nonatomic, retain) NSString * trsWindingMake;
@property (nonatomic, retain) NSString * trsCurrentTemp;
@property (nonatomic, retain) NSString * trsType;
@property (nonatomic, retain) NSString * transformerID;

@end
