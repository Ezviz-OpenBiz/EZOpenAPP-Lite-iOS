//
//  EZUserInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/11.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为用户信息对象
@interface EZUserInfo : EZEntityBase

/// 用户名
@property (nonatomic, copy) NSString *username;
/// 昵称，海外版本该字段为空
@property (nonatomic, copy) NSString *nickname;
/// 用户头像地址，海外版本该字段为空
@property (nonatomic, copy) NSString *avatarUrl;
/// 用户区域domain
@property (nonatomic, copy) NSString *areaDomain;

@end
