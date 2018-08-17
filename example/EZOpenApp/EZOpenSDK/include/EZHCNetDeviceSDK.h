//
//  EZHCNetDeviceSDK.h
//  EzvizOpenSDK
//
//  Created by linyong on 2017/8/15.
//  Copyright © 2017年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EZHCNetDeviceInfo,EZSADPDeviceInfo;

typedef NS_ENUM(int, EZPTZCommandType) {
    EZPTZCommandType_ZOOM_IN = 11,     /* 焦距变大(倍率变大) */
    EZPTZCommandType_ZOOM_OUT = 12,    /* 焦距变小(倍率变小) */
    EZPTZCommandType_UP = 21,          /* 云台上仰 */
    EZPTZCommandType_DOWN,             /* 云台下俯 */
    EZPTZCommandType_LEFT,             /* 云台左转 */
    EZPTZCommandType_RIGHT,            /* 云台右转 */
    EZPTZCommandType_UP_LEFT,          /* 云台上仰和左转 */
    EZPTZCommandType_UP_RIGHT,         /* 云台上仰和右转 */
    EZPTZCommandType_DOWN_LEFT,        /* 云台下俯和左转 */
    EZPTZCommandType_DOWN_RIGHT,       /* 云台下俯和右转 */
    EZPTZCommandType_PAN_AUTO,         /* 云台左右自动扫描 */
    EZPTZCommandType_MAX               /* 越界标识 */
};

typedef NS_ENUM(int, EZPTZActionType) {
    EZPTZActionType_START = 0,      /* 开始 */
    EZPTZActionType_STOP,           /* 停止 */
    EZPTZActionType_MAX             /* 越界标识 */
};

typedef NS_ENUM(int, EZEncryptType) {
    EZEncryptType_OEMBlue = 0,              //蓝精灵加密
    EZEncryptType_OEMGreen,                 //绿巨人加密
    EZEncryptType_normal                    //没有加密
};

@interface EZHCNetDeviceSDK : NSObject


/**
 初始化SDK
 */
+ (void) initSDK;

/**
 开始搜索局域网设备

 @param searchCallback 搜索结果回调，每搜到一个设备都会回调一次，设备信息EZSADPDeviceInfo
 @return 成功或失败
 */
+ (BOOL) startLocalSearch:(void(^)(EZSADPDeviceInfo *device,NSError *error)) searchCallback;

/**
 停止搜索

 @return 成功或失败
 */
+ (BOOL) stopLocalSearch;

/**
 清楚结果，重新搜索，前提是之前开启过搜索
 */
+ (void) research;

/**
 激活设备，调用stopLocalSearch后将无法激活设备

 @param serial 设备序列号
 @param pwd 激活密码
 @return 成功或失败
 */
+ (BOOL) activeDeviceWithSerial:(NSString *) serial pwd:(NSString *) pwd;

/**
 登录局域网设备

 @param userName 用户名
 @param pwd 用户密码
 @param ipAddr 设备ip地址
 @param port 设备端口号
 @return 登录错误时返回nil
 */
+ (EZHCNetDeviceInfo*) loginDeviceWithUerName:(NSString *) userName
                                          pwd:(NSString *) pwd
                                       ipAddr:(NSString *) ipAddr
                                         port:(NSInteger) port;

/**
 登出局域网设备

 @param userId 用户id
 @return 成功或失败
 */
+ (BOOL)logoutDeviceWithUserId:(NSInteger) userId;

/**
 局域网设备云台控制接口

 @param userId 用户id
 @param channelNo 通道号
 @param command 命令类型 EZPTZCommandType
 @param action 动作类型 EZPTZActionType
 @return 成功或失败
 */
+ (BOOL) ptzControlWithUserId:(NSInteger) userId
                    channelNo:(NSInteger) channelNo
                      command:(EZPTZCommandType) command
                       action:(EZPTZActionType) action;


/**
 设置加密方式

 @param encryptType 加密方式
 @return 成功或失败
 */
+ (BOOL) setEncryptType:(EZEncryptType) encryptType;

@end
