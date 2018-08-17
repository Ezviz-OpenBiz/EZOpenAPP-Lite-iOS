//
//  EOAVerifyCodeManager.h
//  EZOpenApp
//
//  Created by linyong on 17/1/5.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RLMResults;

extern const NSNotificationName EOAVerifyCodeChanged;//验证码变更通知


@interface EOAVerifyCodeManager : NSObject

/**
 获取设备验证管理単例

 @return 验证码管理単例
 */
+ (EOAVerifyCodeManager*) sharedInstance;

/**
 向缓存中添加或更新验证码信息

 @param deviceSerial 设备序列号
 @param verifyCode 设备验证码
 */
- (void) updateVerifyCodeWithSerial:(NSString *) deviceSerial code:(NSString*) verifyCode;

/**
 根据设备序列号获取设备验证码

 @param deviceSerial 设备序列号
 @return 设备验证码
 */
- (NSString *) getVerifyCodeWithSerial:(NSString *) deviceSerial;

@end
