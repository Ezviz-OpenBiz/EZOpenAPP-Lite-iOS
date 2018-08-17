//
//  EZDeviceRecordFile.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/9/17.
//  Copyright (c) 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为设备录像文件信息（包含SD卡、后端关联设备的录像）
@interface EZDeviceRecordFile : EZEntityBase

/// 设备录像文件的开始时间
@property (nonatomic, strong) NSDate *startTime;
/// 设备录像文件的结束时间
@property (nonatomic, strong) NSDate *stopTime;

@end
