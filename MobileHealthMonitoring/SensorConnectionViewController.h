//
//  ViewController.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 15/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MQTTMessengerDelegate.h"
#import "MQTTMessenger.h"
@import HealthKit;

#define DEVICE_INFO_SERVICE_UUID @"180A"                // service
#define HEART_RATE_SERVICE_UUID @"180D"                 // service
#define HEART_RATE_CONTROL_POINT_SERVICE_UUID @"2A39"   // characteristic from 180D
#define HEART_RATE_MEASUREMENT_SERVICE_UUID @"2A37"     // characteristic from 180D
#define HEART_RATE_DEVICE_BODY_LOCATION_UUID @"2A38"    // characteristic from 180D
#define DEVICE_MANUFACTURER_NAME_UUID @"2A29"           // characteristic from 180A
#define DEVICE_SERIAL_NUMBER_UUID @"2A25"               // characteristic from 180A

@interface SensorConnectionViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, MQTTMessengerDelegate>
{
    MQTTMessenger* mqttMessenger;
}

// Backend
@property (nonatomic, strong) MQTTMessenger* mqttMessenger;

// HealthKit
@property (nonatomic) HKHealthStore *healthStore;

// CoreData
@property (nonatomic, strong) NSMutableArray* allSensorData;

// Bluetooth
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;

// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString *connected;
@property (nonatomic, strong) NSString *bodyData;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *deviceData;
@property (nonatomic, strong) NSString *serialNumber;
@property (assign) uint16_t heartRate;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;

@end

