//
//  EOACameraInfo.h
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@class EZCameraInfo,EZDeviceInfo;

RLM_ARRAY_TYPE(EOAVideoQualityInfo)

//通道信息，基于realm，方便缓存
@interface EOACameraInfo : EOABaseModel

///关联的设备序列号与通道号组合，作为数据库中的主键 格式如：999999999_1
@property (nonatomic, copy) NSString *serialAndNo;
/// 摄像头名称
@property (nonatomic, copy) NSString *cameraName;
/// 摄像头分类
@property (nonatomic, copy) NSString *category;
/// 通道号
@property (nonatomic) NSInteger cameraNo;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 分享状态：0、未分享，1、分享所有者，2、分享接受者（表示此摄像头是别人分享给我的）
@property (nonatomic) NSInteger isShared;
/// 通道封面
@property (nonatomic, copy) NSString *cameraCover;
/// 视频质量，0-流畅，1-均衡，2-高清，3-超清
@property (nonatomic) NSInteger videoLevel;
/// 设备类型
@property (nonatomic, copy) NSString *deviceType;
/// 设备状态，1-在线，2-不在线
@property (nonatomic) NSInteger status;
/// 设备布防状态，A1设备布撤防状态，0:睡眠 8:在家 16:外出；非A1设备，0-撤防 1-布防
@property (nonatomic) NSInteger defence;
///已刷新过封面标识
@property (nonatomic) BOOL hasRefreshCover;

/// 通道清晰度信息
@property (nonatomic,strong) RLMArray<EOAVideoQualityInfo> *qualityList;
/**
 根据SDK中提供的通道信息创建UI层的通道信息
 
 @param camInfo 通道信息
 @param devInfo 设备信息
 @return 通道信息实例
 */
+ (instancetype) cameraInfoWithInfo:(EZCameraInfo *) camInfo deviceInfo:(EZDeviceInfo *) devInfo;

/**
 根据SDK中提供的通道信息更新已有的UI层的通道信息
 
 @param camInfo 通道信息
 @param devInfo 设备信息
 */
- (void) updateWithInfo:(EZCameraInfo *) camInfo deviceInfo:(EZDeviceInfo *) devInfo;

@end
