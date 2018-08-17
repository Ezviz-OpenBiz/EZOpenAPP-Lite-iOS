//
//  EZTalk.h
//  EZOpenSDK
//
//  Created by linyong on 2018/5/18.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EZTalk;

/* 对讲播放器EZTalk的状态消息定义 */
typedef NS_ENUM(NSInteger, EZTalkMessageCode) {
    EZ_VOICE_TALK_START = 0,        //对讲开始
    EZ_VOICE_TALK_END,              //对讲结束
};

/// 萤石对讲播放器delegate方法
@protocol EZTalkDelegate <NSObject>

@optional
/**
 *  播放器播放失败错误回调
 *
 *  @param talk 播放器对象
 *  @param error  播放器错误
 */
- (void)talkPlayer:(EZTalk *)talk didPlayFailed:(NSError *)error;

/**
 *  播放器消息回调
 *
 *  @param talk      播放器对象
 *  @param messageCode 播放器消息码，请对照EZTalkMessageCode使用
 */
- (void)talkPlayer:(EZTalk *)talk didReceivedMessage:(EZTalkMessageCode)messageCode;

@end

@interface EZTalk : NSObject

@property (nonatomic, weak) id<EZTalkDelegate> delegate;

/// 是否让播放器自动处理进入后台的过程,YES:自动处理;NO:不处理,默认为YES
@property (nonatomic) BOOL autoBgMode;

/**
 *  根据设备序列号和通道号创建EZTalk对象
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *
 *  @return EZTalk对象
 */
+ (instancetype)createTalkWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo;

/**
 *  根据设备序列号和通道号创建EZTalk对象，透明通道设备专用接口
 *
 *  @param deviceSerial 设备序列号
 *  @param cameraNo     通道号
 *
 *  @return EZTalk对象
 */
+ (instancetype)createTransparentTalkWithDeviceSerial:(NSString *)deviceSerial cameraNo:(NSInteger)cameraNo;

/**
 *  开始对讲，异步接口，返回值只是表示操作成功，不代表播放成功
 *
 *  @return YES/NO
 */
- (BOOL)startVoiceTalk;

/**
 *  停止对讲，异步接口，返回值只是表示操作成功
 *
 *  @return YES/NO
 */
- (BOOL)stopVoiceTalk;

/**
 *  半双工对讲专用接口，切换听说模式
 *
 *  @param canSpeak YES-只说状态，NO-只听状态
 *
 *  @return YES/NO
 */
- (BOOL)setVoiceTalkStatus:(BOOL) canSpeak;

/**
 销毁对讲播放器

 @return YES/NO
 */
- (BOOL)destroyTalk;

@end
