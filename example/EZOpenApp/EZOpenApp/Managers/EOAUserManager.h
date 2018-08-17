//
//  EOAUserManager.h
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSNotificationName EOAUserManagerLogout;//注销通知


@class EOAUserInfo,EZAccessToken;

typedef  void(^userInfoCallback) (EOAUserInfo* userInfo,BOOL result);

typedef  void(^resultCallback)(BOOL result);

@interface EOAUserManager : NSObject

@property (nonatomic,readonly) BOOL isLogin;//是否已登录

@property (nonatomic,strong) EOAUserInfo *mUserInfo;//用户信息

/**
 获取用户信息管理器単例

 @return 用户信息管理器単例
 */
+ (EOAUserManager*) sharedInstance;

/**
 从缓存中获取已保存的用户信息和登录信息
 */
- (void) getInfoFromCache;

/**
 清楚缓存中的用户信息和登录信息
 */
- (void) clearInfoInCache;

/**
 获取用户信息

 @param completion 获取用户信息回调
 */
- (void) getUserInfoCompletion:(userInfoCallback) completion;

/**
 登录

 @param callback 登录结果回调
 */
- (void) loginWithResult:(resultCallback) callback;

/**
 注销
*/
- (void) logout;

/**
 打开修改密码页
 */
- (void) changePassword;

@end
