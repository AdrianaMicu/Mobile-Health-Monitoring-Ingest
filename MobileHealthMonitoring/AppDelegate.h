//
//  AppDelegate.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 15/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SensorDataDAO.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    SensorDataDAO *sensorDataDAO;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) SensorDataDAO *sensorDataDAO;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

