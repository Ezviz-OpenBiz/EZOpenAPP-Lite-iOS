//
//  EZVideoQualityInfo.h
//  EzvizOpenSDK
//
//  Created by linyong on 2017/2/28.
//  Copyright © 2017年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为通道支持的清晰度信息
@interface EZVideoQualityInfo : EZEntityBase

/// 清晰度名称，如超清、高清、均衡、流畅等
@property (nonatomic,copy) NSString *videoQualityName;

/// 视频质量，0-流畅，1-均衡，2-高清，3-超清
@property (nonatomic,assign) NSInteger videoLevel;

/// 该清晰度所使用的码流类型，1为主码流，2为子码流
@property (nonatomic,assign) NSInteger streamType;

@end
