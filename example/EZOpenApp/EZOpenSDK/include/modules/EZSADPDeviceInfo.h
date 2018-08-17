//
//  EZSADPDeviceInfo.h
//  EzvizOpenSDK
//
//  Created by linyong on 2017/8/15.
//  Copyright © 2017年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZSADPDeviceInfo : NSObject

///长设备序列号
@property (nonatomic,copy) NSString *deviceSerial;
///设备mac地址
@property (nonatomic,copy) NSString *deviceMac;
///设备是否激活
@property (nonatomic,assign) BOOL actived;
///设备本地地址 IPV4
@property (nonatomic,copy) NSString *localIp;
///设备端口号
@property (nonatomic,assign) NSInteger localPort;
///设备本地地址 IPV6
@property (nonatomic,copy) NSString *localIpV6;
///http端口号
@property (nonatomic,assign) NSInteger httpPort;
///设备类型
@property (nonatomic,assign) NSInteger deviceType;
///设备类型描述
@property (nonatomic,copy) NSString *deviceTypeDes;
///设备固件版本号
@property (nonatomic,copy) NSString *firmwareVersion;
///按位表示,对应为为1表示支持,0x01:是否支持Ipv6,0x02:是否支持修改Ipv6参数,0x04:是否支持Dhcp,0x08:是否支持udp多播,0x10:是否含加密节点,0x20:是否支持恢复密码,0x40:是否支持重置密码,0x80:是否支持同步IPC密码
@property (nonatomic,assign) NSInteger abilitySupport;
///是否启用DHCP
@property (nonatomic,assign) BOOL DHCPOn;
///是否是萤石设备
@property (nonatomic,assign) BOOL isEzvizDevice;



@end
