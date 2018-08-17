//
//  EZCloudFile.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/9/17.
//  Copyright (c) 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为云存储录像文件对象
@interface EZCloudRecordFile : EZEntityBase

/// 云存储录像文件Id
@property (nonatomic, copy) NSString *fileId;
/// 云存储录像文件开始时间
@property (nonatomic, strong) NSDate *startTime;
/// 云存储录像文件结束时间
@property (nonatomic, strong) NSDate *stopTime;
/// 云存储录像截图地址
@property (nonatomic, copy) NSString *coverPic;
/// 云存储录像下载地址
@property (nonatomic, copy) NSString *downloadPath;
/// 云存储图片加密密码，如果是[NSNull null]或者nil指针则图片不加密
@property (nonatomic, copy) NSString *encryption;

@end
