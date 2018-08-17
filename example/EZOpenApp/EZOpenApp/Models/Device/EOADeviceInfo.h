//
//  EOADeviceInfo.h
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@class EZDeviceInfo,EOACameraInfo,EOADetectorInfo;


RLM_ARRAY_TYPE(EOACameraInfo)
RLM_ARRAY_TYPE(EOADetectorInfo)


//设备信息，基于realm，方便缓存
@interface EOADeviceInfo : EOABaseModel

/// 设备关联的通道信息
@property (nonatomic,strong) RLMArray<EOACameraInfo> *cameraList;
/// 设备关联的探测器信息
@property (nonatomic, strong) RLMArray<EOADetectorInfo> *detectorList;
/// 设备关联的通道数量
@property (nonatomic) NSInteger cameraNum;
/// 设备布防状态，A1设备布撤防状态，0:睡眠 8:在家 16:外出；非A1设备，0-撤防 1-布防
@property (nonatomic) NSInteger defence;
/// 设备关联的探测器数量
@property (nonatomic) NSInteger detectorNum;
/// 设备图片
@property (nonatomic, copy) NSString *deviceCover;
/// 设备名称
@property (nonatomic, copy) NSString *deviceName;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 设备类型
@property (nonatomic, copy) NSString *deviceType;
/// 设备版本号
@property (nonatomic, copy) NSString *deviceVersion;
/// 摄像头分类
@property (nonatomic, copy) NSString *category;
/// 设备是否开启加密
@property (nonatomic) BOOL isEncrypt;
/// 设备状态，1-在线，2-不在线
@property (nonatomic) NSInteger status;
/// 是否支持对讲 0-不支持对讲，1-支持全双工对讲，3-支持半双工对讲
@property (nonatomic) NSInteger supportTalkMode;
/// 是否支持云台控制
@property (nonatomic) BOOL isSupportPTZ;
/// 是否支持放大
@property (nonatomic) BOOL isSupportZoom;
/// 是否支持语音提示开关
@property (nonatomic) BOOL isSupportAudioOnOff;
/// 是否支持镜像翻转
@property (nonatomic) BOOL isSupportMirrorCenter;
/// 设备注册到服务器的时间
@property (nonatomic, strong) NSDate *addTime;

/**
 根据SDK中提供的设备信息创建UI层的设备信息

 @param devInfo 设备信息
 @return 设备信息实例
 */
+ (instancetype) deviceInfoWithInfo:(EZDeviceInfo *) devInfo;

/**
  根据SDK中提供的设备信息更新已有的UI层的设备信息

 @param devInfo 设备信息
 */
- (void) updateWithInfo:(EZDeviceInfo *) devInfo;

@end
