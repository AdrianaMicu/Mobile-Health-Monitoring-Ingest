//
//  SensorDataDAO.m
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 17/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import "SensorDataDAO.h"
#import "AppDelegate.h"

@implementation SensorDataDAO

@synthesize context;

- (id)init
{
    self = [ super init ];
    
    if (self != nil)
    {
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext * delegateContext = [appDelegate managedObjectContext];
        
        // Get persistent obejct context
        context = delegateContext;
        if (!context)
        {
            // NSLog(@" BarcodesComponent - init: context is nil");
        }
    }
    
    return self;
}

- (SensorData *)insertNewSensorData
{
    SensorData * sensorData = (SensorData *)[NSEntityDescription insertNewObjectForEntityForName:@"SensorData" inManagedObjectContext:context];
    
    return sensorData;
}

- (void) saveNSManagedObjectContext
{
    NSError * error = nil;
    
    if (![context save:&error])
    {
        // NSLog(@" BarcodesComponent - save: error on save");
    }
    else
    {
        // Save OK message
    }
}

- (NSMutableArray *) getAllSensorData
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity  = [NSEntityDescription entityForName:@"SensorData" inManagedObjectContext:context];
    
    [request setEntity:entity];
    
    NSSortDescriptor * sortDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"receivedTime" ascending:NO];
    NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    
    NSError * error = nil;
    NSMutableArray * mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
    
    if (mutableFetchResults == nil)
    {

    }
    else
    {
        
    }
    
    return mutableFetchResults;
}

@end