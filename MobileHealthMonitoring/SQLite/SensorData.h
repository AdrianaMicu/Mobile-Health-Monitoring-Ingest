//
//  SensorData.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 17/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SensorData : NSManagedObject

@property (nonatomic, strong) NSString *sensor;
@property (nonatomic, strong) NSNumber *data;
@property (nonatomic, strong) NSDate *receivedTime;

@end