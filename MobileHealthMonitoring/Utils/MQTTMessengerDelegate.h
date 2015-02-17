//
//  MQTTMessengerDelegate.h
//  MobileHealthMonitoring
//
//  Created by Adriana Micu on 17/02/15.
//  Copyright (c) 2015 Adriana Micu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MQTTMessengerDelegate <NSObject>

- (void) startSendingData;

@end
