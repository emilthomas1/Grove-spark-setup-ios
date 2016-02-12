//
//  SparkSetupSuccessFailureViewController.h
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupUIViewController.h"
#ifdef FRAMEWORK
#import <ParticleSDK/ParticleSDK.h>
#else
#import "Spark-SDK.h"
#endif

typedef NS_ENUM(NSInteger, SparkSetupResult) {
    SparkSetupResultSuccess=0,
    SparkSetupResultSuccessUnknown,
    SparkSetupResultSuccessDeviceOffline,
    SparkSetupResultFailureClaiming,
    SparkSetupResultFailureConfigure,
    SparkSetupResultFailureCannotDisconnectFromDevice,
    SparkSetupResultFailureLostConnectionToDevice
};

@interface SparkSetupResultViewController : SparkSetupUIViewController
@property (nonatomic, strong) SparkDevice *device;
@property (nonatomic) SparkSetupResult setupResult;

/**
 *  Static method that ends the SparkSetup flow by triggering the listener on SparkSetupMainViewController
 *
 *  @param setupResult typically self.setupResult
 *  @param device      typically self.device
 */
+(void)exitSetup:(SparkSetupResult)setupResult :(SparkDevice *)device;

@end
