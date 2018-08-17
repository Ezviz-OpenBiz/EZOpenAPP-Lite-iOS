//
//  EZDeviceUpgradeStatus.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/21.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为设备升级状态对象
@interface EZDeviceUpgradeStatus : EZEntityBase

/// 升级进度，仅status_type为升级状态时有效，取值范围为1-100
@property (nonatomic) NSInteger upgradeProgress;
/// 升级状态： 0：正在升级 1：设备重启 2：升级成功 3：升级失败
@property (nonatomic) NSInteger upgradeStatus;

@end
