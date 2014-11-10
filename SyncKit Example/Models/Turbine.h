//
//  Turbine.h
//  SyncKit
//
//  Created by kavitha on 08/11/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Turbine : NSManagedObject

@property (nonatomic, retain) NSDate * lastServerSyncDate;
@property (nonatomic, retain) NSDate * lastUpdatedDate;
@property (nonatomic, retain) NSDecimalNumber * syncStatus;
@property (nonatomic, retain) NSString * trbLocation;
@property (nonatomic, retain) NSString * trbName;
@property (nonatomic, retain) NSString * trbCapacity;
@property (nonatomic, retain) NSString * trbTemp;
@property (nonatomic, retain) NSString * trbPressure;
@property (nonatomic, retain) NSString * trbCurrentRPM;
@property (nonatomic, retain) NSString * trbOilLevel;
@property (nonatomic, retain) NSString * trbCompressorHealth;
@property (nonatomic, retain) NSString * trbRotationSpeed;
@property (nonatomic, retain) NSString * trbRotorCount;
@property (nonatomic, retain) NSString * turbineID;

@end
