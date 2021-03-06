//
//  MQTTMessenger.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 16/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttOCClient.h"
#import "MQTTMessengerDelegate.h"

@interface MQTTMessenger : NSObject {
    MqttClient *client;
    
    id<MQTTMessengerDelegate> __weak delegate;
}

@property (nonatomic, retain) MqttClient *client;
@property (nonatomic, retain) NSString *clientID;
@property (nonatomic, weak) id<MQTTMessengerDelegate> delegate;

+ (id)sharedMessenger;
- (void)connectWithHosts:(NSArray *)hosts ports:(NSArray *)ports clientId:(NSString *)clientId cleanSession:(BOOL)cleanSession;
- (void)publish:(NSString *)topic payload:(NSString *)payload qos:(int)qos retained:(BOOL)retained;
- (void)notifyConnectSuccess;
- (void)notifyPublishSuccess;

@end
