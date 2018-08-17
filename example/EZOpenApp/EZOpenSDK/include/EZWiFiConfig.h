//
//  EZWiFiConfig.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    EZ_DEVICE_WIFI_CONNECTED = 0,       //wifi connected
    EZ_DEVICE_PLATFORM_REGISTERED,      //platform registered
} EZBonjourDeviceState;


@interface EZBonjourInfo : NSObject

///device type
@property (nonatomic,strong) NSString *deviceType;

///device serial
@property (nonatomic,strong) NSString *deviceSerial;

///device state
@property (nonatomic,assign) EZBonjourDeviceState deviceState;

@end



@interface EZWiFiConfig : NSObject

///wifi name  required
@property (nonatomic,strong) NSString *ssid;

///wifi password
@property (nonatomic,strong) NSString *pwd;

/**
 get manager singleton
 
 @return manager instance
 */
+ (EZWiFiConfig*) shareInstance;

/**
 start smart wifi config
 
 @return result
 */
- (BOOL) startSmartConfig;

/**
 stop smart wifi config
 */
- (void) stopSmartConfig;

/**
 start sound wave wifi config
 
 @return result
 */
- (BOOL) startSoundWaveConfig;

/**
 stop sound wave wifi config
 */
- (void) stopSoundWaveConfig;

/**
 start SADP device search
 
 @param resultCallback search result callback，devices:array of NSString
 @return result
 */
- (BOOL) startSADPSearchResult:(void(^)(NSArray *devices, NSError *error)) resultCallback;

/**
 stop SADP device search
 */
- (void) stopSADPSearch;

/**
 start Bonjour device search
 
 @param resultCallback search result callback,devices:array of EZBonjourInfo
 @return result
 */
- (BOOL) startBonjourResult:(void(^)(NSArray *devices, NSError *error)) resultCallback;

/**
 stop  Bonjour device search
 */
- (void) stopBonjour;

/**
 start ap WiFi config
 
 @param deviceSerial serial number of device
 @param verifyCode verify cod of device
 @param callback result callback

 @return result
 */
- (BOOL)startAPConfigWithSerial:(NSString *) deviceSerial
                     verifyCode:(NSString *) verifyCode
                         result:(void (^)(BOOL ret)) callback;

/**
 stop AP WiFi config
 */
- (void)stopAPConfigWifi;

@end
