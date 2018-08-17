//
//  EOADeviceManager.h
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMResults,EOACameraInfo,EOADeviceInfo;

typedef  void(^deviceListCallback)(RLMResults *deviceList,BOOL result);

typedef  void(^captureCallback)(NSString *coverUrl);

typedef  void(^resultCallback)(BOOL result);


extern const NSNotificationName EOADeviceManagerListChanged;//设备列表更新通知

@interface EOADeviceManager : NSObject

@property (nonatomic,strong) RLMResults *mDeviceList;//设备信息列表

/**
 获取设备管理器単例

 @return 设备管理器単例
 */
+ (EOADeviceManager*) sharedInstance;

/**
 获取设备列表

 @param completion 回调block
 */
- (void) getDeviceListWithCompletion:(deviceListCallback) completion;

/**
 通道抓图

 @param deviceSerial 设备序列号
 @param cameraNo 通道号
 @param completion 抓图完成回调
 */
- (void) captureCameraCoverWithSerial:(NSString *) deviceSerial
                             cameraNo:(NSInteger) cameraNo
                           completion:(captureCallback) completion;

/**
 获取通道列表

 @return 通道列表
 */
- (NSArray *) getCameraList;

/**
 获取通道封面url

 @param deviceSerial 设备序列号
 @param camaeraNo 通道号
 @return 通道封面url
 */
- (NSString *) getCoverUrlWithSerial:(NSString *) deviceSerial cameraNo:(NSInteger) camaeraNo;

/**
 更新封面url
 
 @param deviceSerial 设备序列号
 @param camaeraNo 通道号
 @param coverUrl 封面url
 */
- (void) updateCoverUrlWithSerial:(NSString *) deviceSerial
                         cameraNo:(NSInteger) camaeraNo
                         CoverUrl:(NSString *) coverUrl;

/**
 更新设备列表
 */
- (void) updateDeviceList;

/**
 清除所有缓存的设备信息
 */
- (void) clearSavedDeviceInfo;

/**
 设置摄像头活动检测开关接口

 @param serial 设备序列号
 @param isOn 开启或关闭
 @param result 结果回调
 */
- (void) switchCameraMotionDetectWithSerial:(NSString *) serial isOn:(BOOL) isOn result:(resultCallback) result;

/**
 设置设备名称

 @param deviceSerial 设备序列号
 @param newName 新的设备名称
 @param result 结果回调
 */
- (void) changeDeviceNameWithSerial:(NSString *) deviceSerial newName:(NSString *) newName result:(resultCallback) result;


/**
 设置通道名称
 
 @param cameraSerial 通道序列号
 @param cameraNo 通道号
 @param newName 新的通道名称
 @param result 结果回调
 */
- (void) changeCameraNameWithSerial:(NSString *) cameraSerial
                           cameraNo:(NSInteger) cameraNo
                            newName:(NSString *) newName
                             result:(resultCallback) result;

/**
 获取服务器上设备大类图片

 @param typeStr 设备大类
 @return 图片url
 */
- (NSString *) getDeviceImageUrlWithType:(NSString *) typeStr;

/**
 根据通道信息获取对应的设备信息

 @param cameraInfo 通道信息
 @return 设备信息
 */
- (EOADeviceInfo *) getDeviceInfoWithCameraInfo:(EOACameraInfo *) cameraInfo;

/**
 获取设备信息对应索引号的的设备设置界面背景图片名称

 @param index 设备信息在设备信息列表中的索引号
 @return 设备设置界面背景图片
 */
- (NSString *) getDeviceBgImageNameWithIndex:(NSInteger) index;

/**
 切换视频清晰度

 @param deviceSerial 设备序列号
 @param cameraNo 通道号
 @param videoLevel 清晰度,0-流畅，1-均衡，2-高清，3-超清
 @param resultCallback 结果回调
 */
- (void) setVideoLevelWithSerial:(NSString *) deviceSerial
                        cameraNo:(NSInteger) cameraNo
                      videoLevel:(NSInteger) videoLevel
                          result:(resultCallback) resultCallback;

/**
 删除设备

 @param deviceSerial 设备序列号
 @param resultCallback 结果回调
 */
- (void) deleteDeviceWithSerial:(NSString *) deviceSerial result:(resultCallback) resultCallback;

/**
 设置设备图片、视频加密开关

 @param serial 设备序列号
 @param verifyCode 验证码（设备标签上的验证码）
 @param value 开关值
 @param resultCallback 结果回调
 */
- (void) setDeviceEncryptWithSerial:(NSString *) serial
                         verifyCode:(NSString *) verifyCode
                              value:(BOOL) value
                             result:(resultCallback) resultCallback;

/**
 获取设备语音提示开关状态

 @param serial 设备序列号
 @param resultCallback 结果回调，result：YES:成功，NO：失败；status：YES:开启，NO:关闭
 */
- (void) getDeviceVoiceStateWithSerial:(NSString *) serial result:(void(^)(BOOL result,BOOL status)) resultCallback;

/**
 获取设备云存储状态

 @param serial 设备序列号
 @param resultCallback 结果回调 result：YES:成功，NO：失败；status：云存储状态，-2:设备不支持，-1:未开通云存储，0:未激活，1:激活，2:过期
 */
- (void) getDeviceCloudStateWithSerial:(NSString *) serial result:(void(^)(BOOL result,NSInteger status)) resultCallback;

/**
 设置语音提示开关

 @param serial 设备序列号
 @param state 开关 1：开 0：关
 @param callback 结果回调
 */
- (void) setDeviceVoiceStateWithSerial:(NSString *) serial state:(NSInteger) state result:(resultCallback) callback;

@end
