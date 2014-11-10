//
//  Boiler.h
//  SyncKit
//
//  Created by kavitha on 08/11/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Boiler : NSManagedObject

@property (nonatomic, retain) NSDate * lastServerSyncDate;
@property (nonatomic, retain) NSDate * lastUpdatedDate;
@property (nonatomic, retain) NSDecimalNumber * syncStatus;
@property (nonatomic, retain) NSString * bName;
@property (nonatomic, retain) NSString * bCapacity;
@property (nonatomic, retain) NSString * bLocation;
@property (nonatomic, retain) NSString * bMake;
@property (nonatomic, retain) NSString * bTemp;
@property (nonatomic, retain) NSString * bPressure;
@property (nonatomic, retain) NSString * bHealthStatus;
@property (nonatomic, retain) NSString * bCurrentContainment;
@property (nonatomic, retain) NSString * boilerID;

@end
