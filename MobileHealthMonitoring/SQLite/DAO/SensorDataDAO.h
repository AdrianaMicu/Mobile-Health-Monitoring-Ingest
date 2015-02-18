//
//  SensorDataDAO.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 17/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SensorData.h"


@interface SensorDataDAO : NSObject
{
    NSManagedObjectContext * context;
}

@property (nonatomic, strong) NSManagedObjectContext *context;

-(void) saveNSManagedObjectContext;

-(SensorData *) insertNewSensorData;
-(NSMutableArray *) getAllSensorData;
- (void)deleteSensorData:(NSManagedObject *)target;

@end

