//
//  EZAuth.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAccessToken.h"
#import "EZUserInfo.h"

//萤石开放平台委托方法
@protocol EZAuthDelegate <NSObject>

@optional

/**
 萤石登录是否成功
 
 @param result 是否成功
 */
- (void) ezvizLoginResult:(BOOL) result;

@end

/* 萤石研发的APP */
typedef NS_ENUM(NSInteger, EZAppType)
{
    EZEzviz                 = 0,  //萤石云视频国内版
    EZEzvizInternational    = 1,  //萤石云视频海外版
    EZHIKConnect            = 2,  //HIK-Connect
};

/* 萤石负责研发的APP */
typedef NS_ENUM(NSInteger, EZAppPageType)
{
    EZPageDeviceList        = 0,  //设备列表页面
    EZPageAlarmList         = 1,  //告警消息列表页面
};

@interface EZAuth : NSObject

/**
 *  设置accessToken接口，适用于服务端控制登录授权
 *
 *  @param accessToken 授权登录获取的accessToken
 */
+ (void)setAccessToken:(NSString *)accessToken;

/**
 *  打开授权登录中间页面接口，国内版
 *
 *  @param completion 回调completion
 */
+ (void)openLoginPage:(void (^)(EZAccessToken *accessToken)) completion;


/**
 *  获取区域列表接口
 *
 *  @param completion 回调block，areaList中的元素为EZAreaInfo对象
 *
 *  @return operation
 */
+ (NSOperation *)getAreaList:(void (^)(NSArray *areaList, NSError *error))completion;

/**
 *  打开授权登录中间页面，国际版
 *
 *  @param areaId 区域码
 *  @param completion 回调completion
 */
+ (void)openLoginPageWithAreaId:(NSInteger)areaId
                     completion:(void (^)(EZAccessToken *accessToken))completion;

/**
 *  账户注销接口
 *
 *  @param completion 回调block，error为空表示登出成功
 */
+ (void)logout:(void (^)(NSError *error))completion;

/**
 *  获取用户基本信息的接口
 *
 *  @param completion 回调block， 正常时返回EZUserInfo的对象，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getUserInfo:(void (^)(EZUserInfo *userInfo, NSError *error))completion;

/**
 *  打开修改密码中间页
 *
 *  @param completion 回调block resultCode为0时表示修改密码成功
 */
+ (void)openChangePasswordPage:(void (^)(NSInteger resultCode))completion;

/**
 *  打开云存储中间页
 *
 *  @param deviceSerial 设备序列号
 */
+ (void)openCloudPage:(NSString *)deviceSerial;

/**
 是否已经登录
 
 @return YES：已经登录；NO：未登录
 */
+ (BOOL) isLogin;

/**
 获取当前accessToken
 
 @return accessToken
 */
+ (NSString *) getAccesstoken;

/**
 根据应用类型判断是否安装了对应的应用
 
 @param appType 应用类型
 @return YES:已安装，NO:没有安装或安装的萤石APP版本过低
 */
+ (BOOL) isEzvizAppInstalledWithType:(EZAppType) appType;

/**
 跳转到指定萤石APP进行授权登录
 
 @param appType 萤石APP类型
 @return 跳转结果
 */
+ (BOOL) ezvizLoginWithAppType:(EZAppType) appType;

/**
 跳转到指定APP的指定界面
 
 @param pageType 界面类型
 @param appType APP类型
 @return 跳转结果
 */
+ (BOOL) gotoEzvizAppPage:(EZAppPageType) pageType appType:(EZAppType) appType;

/**
 外部跳转处理方法，适用于iOS9以上，包括iOS9
 
 @param url 跳转过来的url
 @param opetions 参数，默认为空，目前未进行处理，预留
 @param delegate 委托
 @return 结果
 */
+ (BOOL) handleOpenUrl:(NSURL *) url options:(NSDictionary *) opetions delegate:(id<EZAuthDelegate>) delegate;

/**
 外部跳转处理方法，适用于iOS8以下,包括iOS8
 
 @param url 跳转过来的url
 @param delegate 委托
 @return 结果
 */
+ (BOOL) handleOpenUrl:(NSURL *) url delegate:(id<EZAuthDelegate>) delegate;

/**
 外部跳转处理方法，适用于iOS8以下,包括iOS8
 
 @param url 跳转过来的url
 @param sourceApplication 源APP
 @param annotation 注释
 @param delegate 委托
 @return 结果
 */
+ (BOOL) handleOpenUrl:(NSURL *) url
     sourceApplication:(NSString *) sourceApplication
            annotation:(id) annotation
              delegate:(id<EZAuthDelegate>) delegate;

@end
