//
//  EOASetVoiceStateRequest.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "V2CommonRequest.h"

@interface EOASetVoiceStateRequest : V2CommonRequest

@property (nonatomic,copy) NSString *deviceSerial;//设备序列号
@property (nonatomic,assign) NSInteger enable;//开关状态1：开启 0：关闭
@property (nonatomic,assign) NSInteger channelNo;//通道号,非必须，暂时填0

- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block;


@end
