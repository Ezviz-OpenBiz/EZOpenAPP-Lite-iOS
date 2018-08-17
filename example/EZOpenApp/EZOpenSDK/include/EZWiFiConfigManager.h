//
//  EZWiFiConfigManager.h
//  EZOpenSDK
//
//  Created by linyong on 2018/6/27.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 配网方式 */
typedef NS_ENUM(NSInteger, EZWiFiConfigMode)
{
    EZWiFiConfigSmart        = 1 << 0,  //smart config
    EZWiFiConfigWave         = 1 << 1,  //声波配网
};

/* WiFi配置设备状态 */
typedef NS_ENUM(NSInteger, EZWifiConfigStatus)
{
    DEVICE_WIFI_CONNECTING = 1,   //设备正在连接WiFi
    DEVICE_WIFI_CONNECTED = 2,    //设备连接WiFi成功
    DEVICE_PLATFORM_REGISTED = 3, //设备注册平台成功
};

@interface EZWiFiConfigManager : NSObject

/**
 获取単例

 @return 単例
 */
+ (instancetype)sharedInstance;

/**
 配网接口

 @param wifiSsid WiFi的名称
 @param wifiPwd WiFi的密码
 @param deviceSerial 设备序列号，序列号为空则为批量配网
 @param mode 配网模式，可同时进行两种配网方式
 @param resultBlock 配网结果回调
 @return 方法执行结果
 */
- (BOOL) startWifiConfigWithWifiSsid:(NSString *) wifiSsid
                             wifiPwd:(NSString *) wifiPwd
                        deviceSerial:(NSString *) deviceSerial
                                mode:(EZWiFiConfigMode) mode
                              reuslt:(void(^)(EZWifiConfigStatus status,NSString *deviceSerial,NSError *error)) resultBlock;

/**
 停止配网
 */
- (void) stopWifiConfig;

/**
 AP配网接口

 @param wifiName WiFi的名称
 @param wifiPwd WiFi的密码
 @param deviceSerial 设备序列号
 @param verifyCode 设备验证码
 @param resultBlock 配网结果回调
 @return 方法执行结果
 */
- (BOOL) startAPWifiConfigWithWifiName:(NSString *) wifiName
                               wifiPwd:(NSString *) wifiPwd
                          deviceSerial:(NSString *) deviceSerial
                            verifyCode:(NSString *) verifyCode
                                reuslt:(void(^)(BOOL ret)) resultBlock;

/**
 停止AP配网
 */
- (void) stopAPWifiConfig;


@end
