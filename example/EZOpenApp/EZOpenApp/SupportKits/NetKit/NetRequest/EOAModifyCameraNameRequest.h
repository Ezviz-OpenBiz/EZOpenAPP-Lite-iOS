//
//  EOAModifyCameraNameRequest.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "V2CommonRequest.h"

@interface EOAModifyCameraNameRequest : V2CommonRequest

@property (nonatomic,copy) NSString *deviceSerial;//设备序列号
@property (nonatomic,assign) NSInteger channelNo;//通道号
@property (nonatomic,copy) NSString *name;//通道名

- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block;

@end
