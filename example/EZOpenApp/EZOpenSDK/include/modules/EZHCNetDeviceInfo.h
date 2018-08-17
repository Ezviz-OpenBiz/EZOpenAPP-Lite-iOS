//
//  EZHCNetDeviceInfo.h
//  EzvizOpenSDK
//
//  Created by linyong on 2017/9/15.
//  Copyright © 2017年 Hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZHCNetDeviceInfo : NSObject

///登录后user id
@property (nonatomic,assign) NSInteger userId;
///模拟通道数
@property (nonatomic,assign) NSInteger channelCount;
///模拟通道起始通道号,0为无效果
@property (nonatomic,assign) NSInteger startChannelNo;
///数字通道数
@property (nonatomic,assign) NSInteger dChannelCount;
///起始数字通道号，0为无效果
@property (nonatomic,assign) NSInteger dStartChannelNo;
///告警输入个数
@property (nonatomic,assign) NSInteger byAlarmInPortNum;
///告警输出个数
@property (nonatomic,assign) NSInteger byAlarmOutPortNum;
///硬盘个数
@property (nonatomic,assign) NSInteger byDiskNum;
///设备类型
@property (nonatomic,assign) NSInteger byDVRType;
///零通道个数
@property (nonatomic,assign) NSInteger byZeroChanNum;
///设备语音通道数
@property (nonatomic,assign) NSInteger byAudioChanNum;

@end
