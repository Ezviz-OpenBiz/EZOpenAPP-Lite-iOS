//
//  EZBaseCore.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZBaseCore : NSObject

/**
 *  初始化接口，默认使用国内服务器
 *
 *  @param appKey 传入申请的appKey
 *
 *  @return YES/NO
 */
+ (BOOL)initLibWithAppKey:(NSString *)appKey;

/**
 *  初始化接口，可设置服务器，海外用户使用该初始化方法
 *
 *  @param appKey 传入申请的appKey
 *  @param apiUrl apiUrl地址
 *  @param authUrl 登录页地址，不需要时则填nil
 *
 *  @return YES/NO
 */
+ (BOOL)initLibWithAppKey:(NSString *)appKey apiUrl:(NSString *)apiUrl authUrl:(NSString *)authUrl;

/**
 *  销毁EZOpenSDK接口
 *
 */
+ (void)destoryLib;

/**
 *  获取SDK版本号接口
 *
 *  @return 版本号
 */
+ (NSString *)getVersion;

/**
 *  设置p2p功能是否开启，默认不开启p2p，用户自己选择是否开启
 *
 *  @param enable p2p是否开启
 */
+ (void)enableP2P:(BOOL)enable;

/**
 *  设置是否打印debug日志,需在初始化sdk之前调用
 *
 *  @param enable 是否打印日志，默认关闭
 */
+ (void)setDebugLogEnable:(BOOL)enable;

/**
 *  获取终端（手机等）唯一识别码
 *
 *  @return 终端唯一识别码
 */
+ (NSString *) getTerminalId;

/**
 清除取流时的缓存数据
 */
+ (void) clearStreamInfoCache;

/**
 http请求通用接口，如果已登录成功或设置过accessToken，外部调用时不需要再设置accessToken信息。

 @param apiPath api地址
 @param param 参数字典
 @param completion 结果回调
 @return operation
 */
+ (NSOperation *) requestWithApiPath:(NSString *) apiPath
                               param:(NSDictionary *) param
                          completion:(void(^)(NSString *jsonStr,NSError *error)) completion;

@end
