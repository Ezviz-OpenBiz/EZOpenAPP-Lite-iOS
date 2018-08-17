//
//  EZUIError.h
//  EZUIKit
//
//  Created by linyong on 2017/2/20.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * accesstoken异常或失效，需要重新获取accesstoken，并传入到sdk
 */
#define UE_ERROR_ACCESSTOKEN_ERROR_OR_EXPIRE @"UE001"
/**
 * appkey和AccessToken不匹配,建议更换appkey或者AccessToken
 */
#define UE_ERROR_APPKEY_ERROR @"UE002"
/**
 * 通道不存在，设备参数错误，建议重新获取播放地址
 */
#define UE_ERROR_CAMERA_NOT_EXIST @"UE004"
/**
 * 设备不存在，设备参数错误，建议重新获取播放地址
 */
#define UE_ERROR_DEVICE_NOT_EXIST @"UE005"
/**
 * 参数错误，建议重新获取播放地址
 */
#define UE_ERROR_PARAM_ERROR @"UE006"
/**
 * 播放地址格式错误，建议重新获取播放地址
 */
#define UE_ERROR_URL_FORMAT_ERROR @"UE007"
/**
 * 设备连接数过大，升级设备固件版本,海康设备可咨询客服获取升级流程
 */
#define UE_ERROR_CAS_MSG_PU_NO_RESOURCE @"UE101"
/**
 * 设备不在线，确认设备上线之后重试
 */
#define UE_ERROR_TRANSF_DEVICE_OFFLINE @"UE102"
/**
 * 播放失败，请求连接设备超时，检测设备网路连接是否正常
 */
#define UE_ERROR_INNER_STREAM_TIMEOUT @"UE103"
/**
 * 视频验证码错误，建议重新获取url地址增加验证码
 */
#define UE_ERROR_INNER_VERIFYCODE_ERROR @"UE104"
/**
 * 视频播放失败
 */
#define UE_ERROR_PLAY_FAIL @"UE105"
/**
 * 当前账号开启了终端绑定，只允许指定设备登录操作
 */
#define UE_ERROR_TRANSF_TERMINAL_BINDING @"UE106"
/**
 * 设备信息异常为空，建议重新获取播放地址
 */
#define UE_ERROR_INNER_DEVICE_NULLINFO @"UE107"
/**
 *  未查找到录像文件
 */
#define UE_ERROR_NOT_FOUND_RECORD_FILES @"UE108"
/**
 *  取流并发路数限制
 */
#define UE_ERROR_STREAM_CLIENT_LIMIT @"UE109"

/// 错误信息类
@interface EZUIError : NSObject

@property (nonatomic,copy) NSString *errorString;           /// 错误字符串，见本文件中定义，开发者需要处理
@property (nonatomic,assign) NSInteger internalErrorCode;   /// 内部错误码，开发者可以联系萤石官方人员处理

/**
 创建错误信息实例

 @param errorCode 内部错误码
 @return 错误信息实例
 */
+ (EZUIError *) errorWithInternalErrorCode:(NSInteger) errorCode;

@end
