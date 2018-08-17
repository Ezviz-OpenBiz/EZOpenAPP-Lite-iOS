//
//  EZLeaveMessage.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 15/12/11.
//  Copyright © 2015年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此类为留言消息对象
@interface EZLeaveMessage : EZEntityBase

/// 消息Id
@property (nonatomic, copy) NSString *id;
/// 设备序列号
@property (nonatomic, copy) NSString *deviceSerial;
/// 设备名称
@property (nonatomic, copy) NSString *deviceName;
/// 留言时长（单位：秒）
@property (nonatomic) NSInteger duration;
/// 留言消息类型：1-语音留言 2-视频留言
@property (nonatomic) NSInteger contentType;
/// 接收or回复：1-用户接收（设备发送）2-用户回复（客户端发送）
@property (nonatomic) NSInteger messageDirection;
/// 发送端类型：1–F1设备 2–Web客户端 3–iPhone客户端 4–iPad客户端 5–android客户端 6–androidPad客户端
@property (nonatomic) NSInteger senderType;
/// 发送端别名
@property (nonatomic, copy) NSString *senderName;
/// 留言封面截图地址
@property (nonatomic, copy) NSString *messagePicUrl;
/// 消息状态：0-未读 1-已读 2-删除
@property (nonatomic) NSInteger status;
/// 云存储服务器地址，目前默认为武汉云存储，格式为:{域名:端口}
@property (nonatomic, copy) NSString *cloudServerUrl;
/// 创建时间
@property (nonatomic, strong) NSDate *createTime;
/// 修改时间
@property (nonatomic, strong) NSDate *updateTIme;

@end
