//
//  EOAGetCloudStateRequest.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "V2CommonRequest.h"

@interface EOAGetCloudStateRequest : V2CommonRequest

@property (nonatomic,copy) NSString *deviceSerial;//设备序列号
@property (nonatomic,copy) NSString *phone;//开通云存储用户的手机号，非必选参数
@property (nonatomic,assign) NSInteger channelNo;//非必选参数，不为空表示查询指定通道云存储信息，为空表示查询设备本身云存储信息，默认是1

- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block;

@end
