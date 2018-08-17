//
//  EOAVerifyCodeInfo.h
//  EZOpenApp
//
//  Created by linyong on 17/1/5.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@interface EOAVerifyCodeInfo : EOABaseModel

@property (nonatomic,strong) NSString *deviceSerial;//设备序列号

@property (nonatomic,strong) NSString *verifyCode;//设备验证码

/**
 创建验证码信息实例

 @param deviceSerial 设备序列号
 @param verifyCode 设备验证码
 @return 验证码信息实例
 */
+ (instancetype) verifyCodeInfoWithSerial:(NSString *) deviceSerial code:(NSString *) verifyCode;

/**
 更新验证码信息

 @param deviceSerial 设备序列号
 @param verifyCode 设备验证码
 */
- (void) updateWithSerial:(NSString *) deviceSerial code:(NSString *) verifyCode;

@end
