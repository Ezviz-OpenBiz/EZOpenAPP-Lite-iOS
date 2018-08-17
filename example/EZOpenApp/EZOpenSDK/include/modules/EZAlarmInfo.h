//
//  EZAlarmInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/9/16.
//  Copyright (c) 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为告警信息对象
@interface EZAlarmInfo : EZEntityBase

/// 告警ID
@property (nonatomic, copy) NSString *alarmId;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 通道号
@property (nonatomic) NSInteger cameraNo;
/// 告警名称
@property (nonatomic, copy) NSString *alarmName;
/// 告警图片
@property (nonatomic, copy) NSString *alarmPicUrl;
/// 告警开始时间
@property (nonatomic, strong) NSDate *alarmStartTime;
/// 告警类型
@property (nonatomic) NSInteger alarmType;
/// 是否加密
@property (nonatomic) BOOL isEncrypt;
/// 是否已读
@property (nonatomic) BOOL isRead;
/// 存储类型，0-无存储，1-萤石，2-百度，4-sd卡存储，5-萤石和sd卡，6-百度和sd卡
@property (nonatomic) NSInteger recState;
/// 告警录像结束时间时间延后偏移量，通过alarmStartTime加上延后偏移量获得告警录像的具体结束时间
@property (nonatomic) NSInteger delayTime;
/// 告警录像开始时间提前偏移量，通过alarmStartTime减去提前偏移量获得告警录像的具体开始时间
@property (nonatomic) NSInteger preTime;
/// 设备名称
@property (nonatomic, copy) NSString *deviceName;
/// 设备大类
@property (nonatomic, copy) NSString *category;

/// 4530 扩展字段
@property (nonatomic, copy) NSString *customerType;
/// 4530 扩展字段
@property (nonatomic, copy) NSString *customerInfo;

@end
