//
//  ViewController.m
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 15/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import "SensorConnectionViewController.h"

@interface SensorConnectionViewController ()

@end

@implementation SensorConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Bluetooth and Sensor methods

// callback from viewDidLoad -> centralManager
- (void)centralManagerDidUpdateState:(CBCentralManager *)centralManager
{
    switch (centralManager.state)
    {
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"State: Unsupported");
        } break;
            
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"State: Unauthorized");
        } break;
            
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"State: Powered Off");
        } break;
            
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"State: Powered On");
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            
        } break;
            
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"State: Unknown");
        } break;
            
        default:
        {
        }
            
    }
}

// method called whenever we have successfully connected to the BLE peripheral
// callback from didDiscoverPeripheral -> connectPeripheral
- (void)centralManager:(CBCentralManager *)centralManager didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
// callback from didConnectPeripheral -> discoverServices
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
// callback from centralManagerDidUpdateState -> scanForPeripheralsWithServices
- (void)centralManager:(CBCentralManager *)centralManager didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (![localName isEqual:@""]) {
        // We found the Monitoring Device
        [self.centralManager stopScan];
        self.peripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// Invoked when you discover the characteristics of a specified service.
// callback from didDiscoverServices -> discoverCharacteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics)
    {
        // Request heart rate notifications
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_SERVICE_UUID]]) {
            [self.peripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        
        // Request body sensor location
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_DEVICE_BODY_LOCATION_UUID]]) {
            [self.peripheral readValueForCharacteristic:aChar];
        }
    }
    
    // Retrieve Device Information Services for the Manufacturer Name
    if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_INFO_SERVICE_UUID]])  {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DEVICE_MANUFACTURER_NAME_UUID]]) {
                [self.peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_MEASUREMENT_SERVICE_UUID]]) { // 1
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
    
    // Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DEVICE_MANUFACTURER_NAME_UUID]]) {  // 2
        [self getManufacturerName:characteristic];
    }
    
    // Retrieve the characteristic value for the body sensor location received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HEART_RATE_DEVICE_BODY_LOCATION_UUID]]) {  // 3
        [self getBodyLocation:characteristic];
    }
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }

    if( (characteristic.value) || !error ) {
        self.heartRate = bpm;
        
        //send in HealthApp
        
        //send to Backend
        [self sendSensorDataToDB];
    }
    return;
}

// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
    NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.manufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
    return;
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
    NSData *sensorData = [characteristic value];
    uint8_t *bodyData = (uint8_t *)[sensorData bytes];
    if (bodyData ) {
        uint8_t bodyLocation = bodyData[0];
        self.bodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
    }
    else {
        self.bodyData = [NSString stringWithFormat:@"Body Location: N/A"];
    }
    return;
}

# pragma mark Backend methods

+ (NSArray*) parseCommaList:(NSString*)field {
    return [field componentsSeparatedByString:@","];
}

+ (NSString*) uniqueId {
    return [NSString stringWithFormat: @"MQTTTest.%d", arc4random_uniform(10000)];
}

- (void) sendSensorDataToDB
{
    NSArray *servers = [SensorConnectionViewController parseCommaList:@"xyzkfq.messaging.internetofthings.ibmcloud.com"];
    NSArray *ports = [SensorConnectionViewController parseCommaList:@"1883"];
    
    NSString *clientID = @"d:xyzkfq:iOSDeviceMT:a88e24348a82";
    if (clientID == NULL) {
        clientID = [SensorConnectionViewController uniqueId];
        //[[Messenger sharedMessenger] setClientID:clientID];
    }
    //[[Messenger sharedMessenger] connectWithHosts:servers ports:ports clientId:clientID cleanSession:self.cleanSession.isOn];
}

@end