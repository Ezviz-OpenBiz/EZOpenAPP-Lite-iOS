//
//  EZStorageInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/15.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为设备存储信息对象
@interface EZStorageInfo : EZEntityBase

/// 存储介质索引
@property (nonatomic) NSInteger index;
/// 存储介质名称
@property (nonatomic, copy) NSString *name;
/// 存储介质状态，0正常、1存储介质错、2未格式化、3正在格式化
@property (nonatomic) NSInteger status;
/// 存储介质格式化进度
@property (nonatomic) NSInteger formatRate;

@end
