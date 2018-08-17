//
//  EOAGetVoiceStateRequest.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "V2CommonRequest.h"

@interface EOAGetVoiceStateRequest : V2CommonRequest

@property (nonatomic,copy) NSString *deviceSerial;//设备序列号

/**
 开始获取语音状态

 @param block 返回的dictionary中键为enable的值为语音状态0:关闭,1:打开
 */
- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block;


@end
