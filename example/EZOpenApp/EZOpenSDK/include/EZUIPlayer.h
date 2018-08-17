//
//  EZUIPlayer.h
//  EZUIKit
//
//  Created by linyong on 2017/2/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZUIPlayer;
@class EZUIError;

typedef enum
{
    EZUIKIT_PLAYMODE_LIVE = 0,//预览
    EZUIKIT_PLAYMODE_REC,//回放
    EZUIKIT_PLAYMODE_MAX //越界标识，默认值
}EZUIKitPlayMode;//播放器模式

@protocol EZUIPlayerDelegate <NSObject>

@optional

/**
 播放失败

 @param player 播放器对象
 @param error 错误码对象
 */
- (void) EZUIPlayer:(EZUIPlayer *) player didPlayFailed:(EZUIError *) error;

/**
 播放成功

 @param player 播放器对象
 */
- (void) EZUIPlayerPlaySucceed:(EZUIPlayer *) player;

/**
 播放器回调返回视频宽高

 @param player 播放器对象
 @param pWidth 视频宽度
 @param pHeight 视频高度
 */
- (void) EZUIPlayer:(EZUIPlayer *) player previewWidth:(CGFloat) pWidth previewHeight:(CGFloat) pHeight;

/**
 播放器准备完成回调
 @param player 播放器对象
 */
- (void) EZUIPlayerPrepared:(EZUIPlayer *) player;

/**
 播放结束，回放模式可用
 @param player 播放器对象
 */
- (void) EZUIPlayerFinished:(EZUIPlayer *) player;

/**
 回放模式有效，播放的当前时间点回调，每1秒回调一次

 @param osdTime osd时间点
 */
- (void) EZUIPlayerPlayTime:(NSDate *) osdTime;

@end

/// 播放器类
@interface EZUIPlayer : NSObject

@property (nonatomic,readonly) UIView *previewView; /// 展示画面的视图
@property (nonatomic,weak) id<EZUIPlayerDelegate> mDelegate; /// 代理
@property (nonatomic,strong) UIView *customIndicatorView; /// 默认为系统自带加载动画，如用户自定义需自行控制动画，设置为nil则无加载动画
@property (nonatomic,readonly) NSMutableArray *recordList;//录像列表

/**
 创建播放器实例

 @param url 视频源url地址
 @return 播放器实例
 */
+ (EZUIPlayer *) createPlayerWithUrl:(NSString *) url;

/**
 根据url获取播放模式

 @param urlStr 播放url
 @return EZUIKitPlayMode播放模式
 */
+ (EZUIKitPlayMode) getPlayModeWithUrl:(NSString *) urlStr;

/**
 设置url

 @param urlStr ezopen协议url
 */
- (void) setEZOpenUrl:(NSString *) urlStr;

/**
 开始播放
 */
- (void) startPlay;

/**
 停止播放
 */
- (void) stopPlay;

/**
 暂停播放，回放模式可用
 */
- (void) pausePlay;

/**
 恢复播放，回放模式可用
 */
- (void) resumePlay;

/**
 指定时间点开始播放，回放模式可用

 @param time 时间点
 */
- (void) seekToTime:(NSDate *) time;

/**
 释放播放器资源
 */
- (void) releasePlayer;

/**
 设置预览界面的frame，会自动调节画面等比居中

 @param frame 预览界面frame
 */
- (void) setPreviewFrame:(CGRect) frame;

@end
