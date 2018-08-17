//
//  EZDeviceVersion.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/10.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为设备版本信息对象
@interface EZDeviceVersion : EZEntityBase

/// 当前版本
@property (nonatomic, copy) NSString *currentVersion;
/// 最新版本
@property (nonatomic, copy) NSString *latestVersion;
/// 是否可以更新,注：0-不需要升级 1-需要升级 3-需要升级1.7版本以上
@property (nonatomic) NSInteger isNeedUpgrade;
/// 是否正在升级,注：0-不在升级 1-正在升级
@property (nonatomic) NSInteger isUpgrading;
/// 固件下载地址，只有可以更新时才会有值
@property (nonatomic, copy) NSString *downloadUrl;
/// 更新内容描述
@property (nonatomic, copy) NSString *upgradeDesc;

@end
