//
//  NSString+videoPlayUrl.h
//  VideoGo
//
//  Created by zhilshi on 2016/11/24.
//  Copyright © 2016年 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (videoPlayUrl)
/**
 如果是老的rtsp协议，则转为心的ysprotocl协议
 如果转换失败，则返回nil;如果本身就是ysprotocol协议，则返回self
 @return
 */
- (NSString *)videoPlayProtocolUrlFromRTSP;

/**
 获取设备序列号

 @return 设备序列号
 */
- (NSString *)deviceSerialNo;


/**
 获取通道号

 @return 通道号
 */
- (NSInteger)channelNo;

@end
