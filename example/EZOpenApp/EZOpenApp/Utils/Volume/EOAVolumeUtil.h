//
//  EOAVolumeUtil.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSNotificationName EOASysVolumeChanged;//系统音量变更通知

@interface EOAVolumeUtil : NSObject

/**
 获取音量控制単例和初始化

 @return 音量控制単例
 */
+ (EOAVolumeUtil *) shareInstance;

/**
 获取系统音量

 @return 音量值(0~1.0)
 */
- (float) getSysVolume;

/**
 设置系统音量

 @param volumeValue 音量值 (0~1.0)
 */
- (void) setSysVolume:(float) volumeValue;

@end
