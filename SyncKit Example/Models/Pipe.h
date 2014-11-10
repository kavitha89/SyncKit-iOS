//
//  Pipe.h
//  SyncKit
//
//  Created by kavitha on 08/11/14.
//  Copyright (c) 2014 Cognizant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pipe : NSManagedObject

@property (nonatomic, retain) NSDate * lastServerSyncDate;
@property (nonatomic, retain) NSDate * lastUpdatedDate;
@property (nonatomic, retain) NSDecimalNumber * syncStatus;
@property (nonatomic, retain) NSString * pDiameter;
@property (nonatomic, retain) NSString * pLocation;
@property (nonatomic, retain) NSString * pLength;
@property (nonatomic, retain) NSString * pMake;
@property (nonatomic, retain) NSString * pHealthStatus;
@property (nonatomic, retain) NSString * pCurrentContainment;
@property (nonatomic, retain) NSString * pPressure;
@property (nonatomic, retain) NSString * pTemperature;
@property (nonatomic, retain) NSString * pMaxPressure;
@property (nonatomic, retain) NSString * pMaxTemperature;
@property (nonatomic, retain) NSString * pipeID;

@end
