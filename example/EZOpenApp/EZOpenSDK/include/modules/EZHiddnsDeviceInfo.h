//
//  EZHiddnsDeviceInfo.h
//  EzvizOpenSDK
//
//  Created by linyong on 2017/9/9.
//  Copyright © 2017年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

@interface EZHiddnsDeviceInfo : EZEntityBase

///设备域名
@property (nonatomic,copy) NSString *domain;

///设备外网地址
@property (nonatomic,copy) NSString *deviceIp;

///设备短序列号
@property (nonatomic,copy) NSString *subSerial;

///设备长序列号
@property (nonatomic,copy) NSString *serial;

///设备名称
@property (nonatomic,copy) NSString *deviceName;

///映射模式，1-手动，0-自动
@property (nonatomic,assign) NSInteger upnpMappingMode;

///手动映射http端口，upnpMappingMode=1时使用
@property (nonatomic,assign) NSInteger mappingHiddnsHttpPort;

///映射http端口
@property (nonatomic,assign) NSInteger hiddnsHttpPort;

///映射https端口
@property (nonatomic,assign) NSInteger hiddnsHttpsPort;

///手动映射服务端口，upnpMappingMode=1时使用
@property (nonatomic,assign) NSInteger mappingHiddnsCmdPort;

///映射服务端口
@property (nonatomic,assign) NSInteger hiddnsCmdPort;

///映射取流端口
@property (nonatomic,assign) NSInteger hiddnsRtspPort;

/////设备局域网IP地址
//@property (nonatomic,copy) NSString *localIp;
//
/////本地http端口
//@property (nonatomic,assign) NSInteger localHiddnsHttpPort;
//
/////本地https端口
//@property (nonatomic,assign) NSInteger localHiddnsHttpsPort;
//
/////本地服务端口
//@property (nonatomic,assign) NSInteger localHiddnsCmdPort;
//
/////本地取流端口
//@property (nonatomic,assign) NSInteger localHiddnsRtspPort;
//
/////外网Telenet端口
//@property (nonatomic,assign) NSInteger cmdPort;
//
/////外网Http监听的端口UPNP检测使用
//@property (nonatomic,assign) NSInteger httpPort;
//
/////外网推流使用的监听端口
//@property (nonatomic,assign) NSInteger streamPort;
//
/////内网Telent端口
//@property (nonatomic,assign) NSInteger localCmdPort;
//
/////内网Http监听的端口UPNP检测使用
//@property (nonatomic,assign) NSInteger localHttpPort;
//
/////内网推流使用的监听端口
//@property (nonatomic,assign) NSInteger localStreamPort;


@end

