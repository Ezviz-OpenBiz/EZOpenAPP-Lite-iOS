//
//  EOAVideoQualityInfo.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@class EZVideoQualityInfo;

@interface EOAVideoQualityInfo : EOABaseModel

/// 清晰度名称，如超清、高清、均衡、流畅等
@property (nonatomic,copy) NSString *videoQualityName;

/// 视频质量，0-流畅，1-均衡，2-高清，3-超清
@property (nonatomic,assign) NSInteger videoLevel;

/// 该清晰度所使用的码流类型，1为主码流，2为子码流
@property (nonatomic,assign) NSInteger streamType;

/**
 根据SDK中提供的通道清晰度信息创建UI层的通道清晰度信息
 
 @param qualityInfo 通道清晰度信息
 @return 清晰度信息实例
 */
+ (instancetype) qualityInfoWithInfo:(EZVideoQualityInfo *) qualityInfo;

/**
 根据SDK中提供的通道清晰度信息更新已有的UI层的通道清晰度信息
 
 @param qualityInfo 通道清晰度信息
 */
- (void) updateWithInfo:(EZVideoQualityInfo *) qualityInfo;


@end
