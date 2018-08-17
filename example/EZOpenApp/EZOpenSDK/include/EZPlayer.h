//
//  EZPlayer.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EZDeviceRecordFile;
@class EZCloudRecordFile;
@class EZPlayer;
@class UIView;
@class UIImage;

/**
 *  预览清晰度
 */
typedef NS_ENUM(NSInteger, EZVideoQuality) {
    EZVideoQualityLow    = 0,  //流畅
    EZVideoQualityMiddle = 1,  //均衡
    EZVideoQualityHigh   = 2   //高清
};

/* 播放器EZPlayer的状态消息定义 */
typedef NS_ENUM(NSInteger, EZMessageCode) {
    EZ_REALPLAY_START = 0,          //直播开始
    EZ_PLAYBACK_START,              //录像回放开始播放
    EZ_PLAYBACK_STOP,               //录像回放结束播放
    EZ_PLAYBACK_PAUSE,              //录像回放暂停，主动调用pause接口不会触发
    EZ_PLAYBACK_RESUMING,           //录像回放恢复中，主动调用resume接口不会触发
};

/// 萤石播放器delegate方法
@protocol EZPlayerDelegate <NSObject>

@optional
/**
 *  播放器播放失败错误回调
 *
 *  @param player 播放器对象
 *  @param error  播放器错误
 */
- (void)player:(EZPlayer *)player didPlayFailed:(NSError *)error;

/**
 *  播放器消息回调
 *
 *  @param player      播放器对象
 *  @param messageCode 播放器消息码，请对照EZOpenSDK头文件中的EZMessageCode使用
 */
- (void)player:(EZPlayer *)player didReceivedMessage:(EZMessageCode)messageCode;

/**
 *  收到的数据长度（每秒调用一次）
 *
 *  @param player     播放器对象
 *  @param dataLength 播放器流媒体数据的长度（每秒字节数）
 */
- (void)player:(EZPlayer *)player didReceivedDataLength:(NSInteger)dataLength;

/**
 *  收到的画面长宽值
 *
 *  @param player 播放器对象
 *  @param height 高度
 *  @param width  宽度
 */
- (void)player:(EZPlayer *)player didReceivedDisplayHeight:(NSInteger)height displayWidth:(NSInteger)width;

@end

/// 此类为萤石播放器类
@interface EZPlayer : NSObject

/// EZPlayer关联的delegate
@property (nonatomic, weak) id<EZPlayerDelegate> delegate;

/// 是否让播放器处理进入后台,YES:自动处理;NO:不处理,默认为YES
@property (nonatomic) BOOL autoBgMode;

/**
 *  根据设备序列号和通道号创建EZPlayer对象
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *
 *  @return EZPlayer对象
 */
+ (instancetype)createPlayerWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo;

/**
 *  根据url构造EZPlayer对象 （主要用来处理视频广场的播放）
 *
 *  @param url 播放url
 *
 *  @return EZPlayer对象
 */
+ (instancetype)createPlayerWithUrl:(NSString *)url;


/**
 局域网设备创建播放器接口
 
 @param userId 用户id，登录局域网设备后获取
 @param cameraNo 通道号
 @param streamType 码流类型 1:主码流 2:子码流
 @return EZPlayer对象
 */
+ (instancetype)createPlayerWithUserId:(NSInteger) userId cameraNo:(NSInteger) cameraNo streamType:(NSInteger) streamType;

/**
 *  销毁EZPlayer
 *
 *  @return YES/NO;
 */
- (BOOL)destroyPlayer;

/**
 *  设置播放器的view
 *
 *  @param playerView 播放器view
 */
- (void)setPlayerView:(UIView *)playerView;

/**
 *  开始播放，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @return YES/NO
 */
- (BOOL)startRealPlay;

/**
 *  停止播放，异步接口，返回值只是表示操作成功
 *
 *  @return YES/NO
 */
- (BOOL)stopRealPlay;

/**
 *  设置播放器解码密码
 *
 *  @param verifyCode 设备验证码
 */
- (void)setPlayVerifyCode:(NSString *)verifyCode;

/**
 *  开启声音
 *
 *  @return YES/NO
 */
- (BOOL)openSound;

/**
 *  关闭声音
 *
 *  @return YES/NO
 */
- (BOOL)closeSound;

/**
 *  开始云存储远程回放，异步接口，返回值只是表示操作成功，不代表播放成功
 *  @param cloudFile 云存储文件信息
 *
 *  @return YES/NO
 */
- (BOOL)startPlaybackFromCloud:(EZCloudRecordFile *)cloudFile;

/**
 *  开始远程SD卡回放，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @param deviceFile SD卡文件信息
 *
 *  @return YES/NO
 */
- (BOOL)startPlaybackFromDevice:(EZDeviceRecordFile *)deviceFile;

/**
 *  暂停远程回放播放
 */
- (BOOL)pausePlayback;

/**
 *  继续远程回放播放
 */
- (BOOL)resumePlayback;

/**
 *  根据偏移时间播放
 *
 *  @param offsetTime 录像偏移时间
 */
- (void)seekPlayback:(NSDate *)offsetTime;

/**
 *  获取当前播放时间进度
 *
 *  @return 播放进度的NSDate数据
 */
- (NSDate *)getOSDTime;

/**
 *  停止远程回放
 */
- (BOOL)stopPlayback;

/**
 *  开始本地直播流录像功能（用户自行处理存储过程）
 *
 *  @param recordDataBlock 录像回调数据（可以对数据进行分析，比较人脸识别等）
 *
 *  @return YES/NO
 */
- (BOOL)startLocalRecord:(void (^)(NSData *data))recordDataBlock;

/**
 *  开始本地录像功能（SDK处理存储过程）
 *
 *  @param path 文件存储路径
 *
 *  @return YES/NO
 */
- (BOOL)startLocalRecordWithPath:(NSString *)path;

/**
 *  结束本地直播流录像
 *
 *  @return YES/NO
 */
- (BOOL)stopLocalRecord;

/**
 *  直播画面抓图
 *
 *  @param quality 抓图质量（0～100）,数值越大图片质量越好，图片大小越大
 *
 *  @return image
 */
- (UIImage *)capturePicture:(NSInteger)quality;


@end
