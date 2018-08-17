//
//  EOAUserInfo.h
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@interface EOAUserInfo : EOABaseModel

/// 用户名
@property (nonatomic, copy) NSString *username;
/// 昵称，海外版本该字段为空
@property (nonatomic, copy) NSString *nickname;
/// 用户头像地址，海外版本该字段为空
@property (nonatomic, copy) NSString *avatarUrl;
/// 用户区域domain
@property (nonatomic, copy) NSString *areaDomain;
/// access token
@property (nonatomic, copy) NSString *accessToken;
/// 过期时间 格式如:2016-01-02 12:00:00
@property (nonatomic, copy) NSString *expireTime;

@end
