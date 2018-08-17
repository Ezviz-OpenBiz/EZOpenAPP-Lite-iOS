//
//  EZDevice.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EZProbeDeviceInfo,EZDeviceInfo,EZDeviceVersion,EZDeviceUpgradeStatus,EZLeaveMessage,EZHiddnsDeviceInfo;

/* 设备布防状态枚举类型 */
typedef NS_ENUM(NSInteger, EZDefenceStatus) {
    EZDefenceStatusOffOrSleep     = 0,  //A1设备睡眠模式或者非A1设备的撤防状态
    EZDefenceStatusOn             = 1,  //非A1设备的布防状态
    EZDefenceStatusAtHome         = 8,  //A1在家模式
    EZDefenceStatusOuter          = 16, //A1外出模式
};

/* 消息状态 */
typedef NS_ENUM(NSInteger, EZMessageStatus) {
    EZMessageStatusRead = 1,    //已读
};

/* 通道清晰度，请注意不是所有设备都有这些清晰度的，请根据实际场景使用 */
typedef NS_ENUM(NSInteger, EZVideoLevelType)
{
    EZVideoLevelLow       = 0,  //流畅
    EZVideoLevelMiddle    = 1,  //均衡
    EZVideoLevelHigh      = 2,  //高清
    EZVideoLevelSuperHigh = 3   //超清
};

/* 设备ptz命令 */
typedef NS_OPTIONS(NSUInteger, EZPTZCommand) {
    EZPTZCommandUp              = 0, //向上旋转
    EZPTZCommandDown            = 1, //向下旋转
    EZPTZCommandLeft            = 2, //向左旋转
    EZPTZCommandRight           = 3, //向右旋转
    EZPTZCommandZoomIn          = 8, //镜头拉进
    EZPTZCommandZoomOut         = 9, //镜头拉远
};

/* 设备ptz动作命令 */
typedef NS_ENUM(NSInteger, EZPTZAction) {
    EZPTZActionStart = 1, //ptz开始
    EZPTZActionStop = 2   //ptz停止
};

/* 消息类型 */
typedef NS_ENUM(NSInteger, EZMessageType)
{
    EZMessageTypeAlarm = 1,   //告警类型
    EZMessageTypeLeave,       //留言类型
};

@interface EZDevice : NSObject

/**
 *  尝试查询设备信息，设备Wifi配置前查询一次设备的信息
 *
 *  @param deviceSerial 设备序列号
 *  @param deviceType 设备型号，无法获取到设备型号则可传nil
 *  @param completion   回调block，正常时返回EZProbeDeviceInfo对象，错误码返回错误码
 *  @see 全新的设备是没有注册到平台的，所以会出现设备不存在的情况，设备wifi配置成功以后会上报数据到萤石云平台，以后每次查询就不会出现设备不存在的情况了。
 *
 *  @return operation
 */
+ (NSOperation *)probeDeviceInfo:(NSString *)deviceSerial
                      deviceType:(NSString *) deviceType
                      completion:(void (^)(EZProbeDeviceInfo *deviceInfo, NSError *error))completion;

/**
 *  根据设备序列号和设备验证码添加设备接口
 *
 *  @param deviceSerial 设备序列号
 *  @param verifyCode   设备验证码
 *  @param completion   回调block，error为空时表示添加成功
 *
 *  @return operation
 */
+ (NSOperation *)addDevice:(NSString *)deviceSerial
                verifyCode:(NSString *)verifyCode
                completion:(void (^)(NSError *error))completion;

/**
 *  获取用户所有的设备列表
 *
 *  @param pageIndex  分页当前页码（从0开始）
 *  @param pageSize   分页每页数量（建议20以内）
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象数组和设备总数，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceList:(NSInteger)pageIndex
                      pageSize:(NSInteger)pageSize
                    completion:(void (^)(NSArray *deviceList, NSInteger totalCount, NSError *error))completion;

/**
 *  根据序列号获取设备信息
 *
 *  @param deviceSerial 设备序列号
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceInfo:(NSString *)deviceSerial
                    completion:(void (^)(EZDeviceInfo *deviceInfo, NSError *error))completion;

/**
 *  获取分享给用户的设备列表接口
 *
 *  @param pageIndex  分页当前页码（从0开始）
 *  @param pageSize   分页每页数量（建议20以内）
 *  @param completion 回调block，正常时返回EZDeviceInfo的对象数组和设备总数，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getSharedDeviceList:(NSInteger)pageIndex
                            pageSize:(NSInteger)pageSize
                          completion:(void (^)(NSArray *deviceList, NSInteger totalCount, NSError *error))completion;

/**
 *  设备设置布防状态，兼容A1和IPC设备的布防
 *
 *  @param defence      布防状态, IPC布防状态只有0和1，A1有0:睡眠 8:在家 16:外出
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空表示设置成功
 *
 *  @return operation
 */
+ (NSOperation *)setDefence:(EZDefenceStatus)defence
               deviceSerial:(NSString *)deviceSerial
                 completion:(void (^)(NSError *error))completion;

/**
 *  通过设备验证码开关视频图片加密接口
 *
 *  @param isEncrypt    是否加密，只有NO(关闭)的时候需要设备验证码的相关参数(vaildateCode)
 *  @param deviceSerial 设备序列号
 *  @param verifyCode 设备验证码
 *  @param completion   回调block，error为空时表示操作成功
 *
 *  @return operation
 */
+ (NSOperation *)setDeviceEncryptStatus:(NSString *)deviceSerial
                             verifyCode:(NSString *)verifyCode
                                encrypt:(BOOL)isEncrypt
                             completion:(void (^)(NSError *error))completion;

/**
 *  根据设备序列号删除当前账号的设备接口
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空时表示删除成功
 *  @see 该接口与终端绑定功能相关，会遇到删除时报106002的错误，请关闭终端绑定以后再试
 *
 *  @return operation
 */
+ (NSOperation *)deleteDevice:(NSString *)deviceSerial
                   completion:(void (^)(NSError *error))completion;

/**
 *  获取设备的版本信息接口
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZDeviceVersion的对象信息，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceVersion:(NSString *)deviceSerial
                       completion:(void (^)(EZDeviceVersion *version, NSError *error))completion;

/**
 *  根据设备序列号修改设备名称接口
 *
 *  @param deviceSerial 设备序列号
 *  @param deviceName   设备名称
 *  @param completion   回调block，error为空时表示修改成功
 *
 *  @return operation
 */
+ (NSOperation *)setDeviceName:(NSString *)deviceName
                  deviceSerial:(NSString *)deviceSerial
                    completion:(void (^)(NSError *error))completion;

/**
 *  查询云存储录像信息列表接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param beginTime    查询时间范围开始时间
 *  @param endTime      查询时间范围结束时间
 *  @param completion   回调block，正常时返回EZCloudRecordFile的对象数组，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)searchRecordFileFromCloud:(NSString *)deviceSerial
                                  cameraNo:(NSInteger)cameraNo
                                 beginTime:(NSDate *)beginTime
                                   endTime:(NSDate *)endTime
                                completion:(void (^)(NSArray *couldRecords, NSError *error))completion;

/**
 *  查询远程SD卡存储录像信息列表接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param beginTime    查询时间范围开始时间
 *  @param endTime      查询时间范围结束时间
 *  @param completion   回调block，正常时返回EZDeviceRecordFile的对象数组，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)searchRecordFileFromDevice:(NSString *)deviceSerial
                                   cameraNo:(NSInteger)cameraNo
                                  beginTime:(NSDate *)beginTime
                                    endTime:(NSDate *)endTime
                                 completion:(void (^)(NSArray *deviceRecords, NSError *error))completion;

/**
 *  根据设备序列号获取存储介质状态(如是否初始化，格式化进度等)
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZStorageInfo的对象数组，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getStorageStatus:(NSString *)deviceSerial
                       completion:(void (^)(NSArray *storageStatus, NSError *error))completion;

/**
 *  根据设备序列号和分区编号格式化分区（SD卡）
 *
 *  @param deviceSerial 设备序列号
 *  @param storageIndex 查询返回的分区号，0表示全部格式化，可能会有几块硬盘的情况
 *  @param completion   回调block，error为空表示设置成功
 *
 *  @return operation
 */
+ (NSOperation *)formatStorage:(NSString *)deviceSerial
                  storageIndex:(NSInteger)storageIndex
                    completion:(void (^)(NSError *error))completion;

/**
 *  根据设备序列号获取告警信息列表，设备序列号为nil时查询整个账户下的告警信息列表
 *
 *  @param deviceSerial 设备序列号
 *  @param pageIndex    分页当前页码（从0开始）
 *  @param pageSize     分页每页数量（建议20以内）
 *  @param beginTime    搜索时间范围开始时间
 *  @param endTime      搜索时间范围结束时间
 *  @param completion   回调block，正常时返回EZAlarmInfo的对象数据和查询时间范围内的告警个数的总数，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getAlarmList:(NSString *)deviceSerial
                    pageIndex:(NSInteger)pageIndex
                     pageSize:(NSInteger)pageSize
                    beginTime:(NSDate *)beginTime
                      endTime:(NSDate *)endTime
                   completion:(void (^)(NSArray *alarmList, NSInteger totalCount, NSError *error))completion;

/**
 *  设置告警信息为已读接口
 *
 *  @param alarmIds   告警信息Id数组(可以只有一个Id)，最多为10个id,否则会报错
 *  @param status     告警消息状态
 *  @param completion 回调block，error为空时表示设置成功
 *
 *  @return operation
 */
+ (NSOperation *)setAlarmStatus:(NSArray *)alarmIds
                    alarmStatus:(EZMessageStatus)status
                     completion:(void (^)(NSError *error))completion;

/**
 *  根据alarmId删除告警信息接口
 *
 *  @param alarmIds   告警信息Id数组(可以只有一个Id)，最多为10个Id，否则会报错
 *  @param completion 回调block，error为空时表示删除成功
 *
 *  @return operation
 */
+ (NSOperation *)deleteAlarm:(NSArray *)alarmIds
                  completion:(void (^)(NSError *error))completion;

/**
 *  获取抓取摄像头图片的url接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param completion   回调block，正常时返回url地址信息，错误时返回错误码
 *  @see 该接口比较耗时，不建议进行批量设备抓图，SDK内部只支持6个http请求并发，该接口会持续占用http请求资源，如果遇到http请求延时巨大问题，优先考虑抓图接口并发造成的问题,
 *  抓图将在服务器端保留2个小时
 *
 *  @return operation
 */
+ (NSOperation *)captureCamera:(NSString *)deviceSerial
                      cameraNo:(NSInteger)cameraNo
                    completion:(void (^)(NSString *url, NSError *error))completion;

/**
 *  设置设备通道的清晰度
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param videoLevel   通道清晰度，0-流畅，1-均衡，2-高清，3-超清
 *  @param completion   回调block，无error表示设置成功
 *  @see 如果是正在播放时调用该接口，设置清晰度成功以后必须让EZPlayer调用stopRealPlay再调用startRealPlay重新取流才成完成画面清晰度的切换。
 *
 *  @return operation
 */
+ (NSOperation *)setVideoLevel:(NSString *)deviceSerial
                      cameraNo:(NSInteger)cameraNo
                    videoLevel:(EZVideoLevelType)videoLevel
                    completion:(void (^)(NSError *error))completion;

/**
 *  通过设备序列号对设备进行升级操作，前提是该设备有更新软件的提示
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，error为空表示操作成功
 *
 *  @return operation
 */
+ (NSOperation *)upgradeDevice:(NSString *)deviceSerial
                    completion:(void (^)(NSError *error))completion;

/**
 *  根据设备序列号获取设备升级时的进度状态
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block，正常时返回EZDeviceUpgradeStatus对象，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getDeviceUpgradeStatus:(NSString *)deviceSerial
                             completion:(void (^)(EZDeviceUpgradeStatus *status, NSError *error))completion;

/**
 *  PTZ 控制接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *  @param command      ptz控制命令
 *  @param action       控制启动/停止
 *  @param speed        云台速度：0-慢，1-适中，2-快
 *  @param resultBlock  回调block，当error为空时表示操作成功
 *
 *  @return operation
 */
+ (NSOperation *)controlPTZ:(NSString *)deviceSerial
                   cameraNo:(NSInteger)cameraNo
                    command:(EZPTZCommand)command
                     action:(EZPTZAction)action
                      speed:(NSInteger)speed
                     result:(void (^)(NSError *error))resultBlock;

/**
 *  数据解密
 *
 *  @param data       需要解密的数据
 *  @param verifyCode 设备验证码
 *
 *  @return 解密的NSData对象，如果返回的数据是空的，请检查密码是否正确或者传入的数据是否正确。
 */
+ (NSData *)decryptData:(NSData *)data verifyCode:(NSString *)verifyCode;

/**
 *  根据设备序列号获取未读消息数，设备序列号为空时获取所有设备的未读消息数
 *
 *  @param deviceSerial 需要获取的设备序列号，为空时返回账户下所有设备的未读消息数
 *  @param type         消息类型：EZMessageTypeAlarm 告警消息（1），EZMessageTypeLeave 留言消息（2）
 *  @param completion   回调block，正常时返回未读数量，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getUnreadMessageCount:(NSString *)deviceSerial
                           messageType:(EZMessageType)type
                            completion:(void (^)(NSInteger count, NSError *error))completion;

/**
 *  根据设备序列号获取设备的留言消息列表
 *
 *  @param deviceSerial 需要获取的设备序列号
 *  @param beginTime    开始时间
 *  @param endTime      结束时间
 *  @param pageIndex    分页页码
 *  @param pageSize     分页单页数量
 *  @param completion   回调block，正常时返回EZLeaveMessage的对象数组，错误时返回错误码
 *
 *  @return operation
 */
+ (NSOperation *)getLeaveMessageList:(NSString *)deviceSerial
                           pageIndex:(NSInteger)pageIndex
                            pageSize:(NSInteger)pageSize
                           beginTime:(NSDate *)beginTime
                             endTime:(NSDate *)endTime
                          completion:(void (^)(NSArray *leaveMessageList, NSInteger totalCount, NSError *error))completion;

/**
 *  根据leaveId设置留言消息状态
 *
 *  @param leaveIds   留言消息Id数组(最大数量为10，允许只有1个)
 *  @param status     需要设置的留言状态，目前只支持 EZMessageStatusRead(已读)
 *  @param completion 回调block，error为空表示设置成功
 *
 *  @return operation
 */
+ (NSOperation *)setLeaveMessageStatus:(NSArray *)leaveIds
                         messageStatus:(EZMessageStatus)status
                            completion:(void (^)(NSError *error))completion;

/**
 *  根据leaveId删除留言消息
 *
 *  @param leaveIds   留言消息Id数组(最大数量为10，允许只有1个)
 *  @param completion 回调block，error为空表示删除成功
 *
 *  @return operation
 */
+ (NSOperation *)deleteLeaveMessage:(NSArray *)leaveIds
                         completion:(void (^)(NSError *error))completion;

/**
 *  通过设备序列号和设备域名获取设备ddns信息
 *
 *  @param deviceSerial 设备序列号
 *  @param domain 设备域名
 *  @param completion   回调block
 *
 *  @return operation
 */
+ (NSOperation *)getHiddnsDeviceInfo:(NSString *)deviceSerial
                              domain:(NSString *) domain
                          completion:(void (^)(EZHiddnsDeviceInfo *ddnsDeviceInfo, NSError *error))completion;

/**
 *  该接口用于设置设备ddns域名，包括设置分享获得的设备的ddns域名
 *
 *  @param deviceSerial 设备序列号
 *  @param domain 设备域名,设备域名规则修改，不能为空，6-32位，可以为本身序列号，包含小写字母、数字、-，首位必须字母，末位不能为-
 *  @param completion   回调block
 *
 *  @return operation
 */
+ (NSOperation *)setHiddnsDomain:(NSString *)deviceSerial
                          domain:(NSString *) domain
                      completion:(void (^)(NSError *error))completion;

/**
 *  设置设备的DDNS映射方式为自动映射
 *
 *  @param deviceSerial 设备序列号
 *  @param completion   回调block
 *
 *  @return operation
 */
+ (NSOperation *)setHiddnsModeAuto:(NSString *)deviceSerial
                        completion:(void (^)(NSError *error))completion;

/**
 *  设置设备的DDNS映射方式为手动映射
 *
 *  @param deviceSerial 设备序列号
 *  @param httpPort http端口号
 *  @param cmdPort 服务端口号
 *  @param completion   回调block
 *
 *  @return operation
 */
+ (NSOperation *)setHiddnsModeManual:(NSString *)deviceSerial
                            httpPort:(NSInteger) httpPort
                             cmdPort:(NSInteger) cmdPort
                          completion:(void (^)(NSError *error))completion;

/**
 *  获取当前账号下的所有设备的DDNS信息
 *
 *  @param pageIndex 分页起始页，从0开始，默认为0
 *  @param pageSize 分页大小，默认为10，最大为50
 *  @param completion   回调block ddnsDeviceList中对象为EZHiddnsDeviceInfo
 *
 *  @return operation
 */
+ (NSOperation *)getHiddnsDeviceList:(NSInteger) pageIndex
                            pageSize:(NSInteger) pageSize
                          completion:(void (^)(NSArray *ddnsDeviceList, NSInteger totalCount, NSError *error))completion;

/**
 *  把单个设备的DDNS信息分享给其他账户
 *
 *  @param deviceSerial 设备序列号
 *  @param account 被分享账户，可以是邮箱地址或手机号码（包含国家代码）或不是全数字的用户名
 *  @param completion   回调block
 *
 *  @return operation
 */
+ (NSOperation *)shareHiddnsDevice:(NSString *) deviceSerial
                           account:(NSString *) account
                        completion:(void (^)(NSError *error))completion;

/**
 *  获取当前账号下的所有的其它账户分享给自己的设备DDNS信息
 *
 *  @param pageIndex 分页起始页，从0开始，默认为0
 *  @param pageSize 分页大小，默认为10，最大为50
 *  @param completion   回调block ddnsDeviceList中对象为EZHiddnsDeviceInfo
 *
 *  @return operation
 */
+ (NSOperation *)getShareHiddnsDeviceList:(NSInteger) pageIndex
                                 pageSize:(NSInteger) pageSize
                               completion:(void (^)(NSArray *ddnsDeviceList, NSInteger totalCount, NSError *error))completion;



@end
