//
//  EZAccessToken.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/10/19.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为萤石开放平台授权登录以后的凭证信息
@interface EZAccessToken : EZEntityBase

/// accessToken 登录凭证
@property (nonatomic, copy) NSString *accessToken;
/// accessToken过期的时间点,相对于1970年的毫秒数
@property (nonatomic, assign) NSInteger expire;

@end
