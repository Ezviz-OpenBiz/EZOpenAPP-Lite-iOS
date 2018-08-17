//
//  EOAMessageManager.h
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EOAMessageManager : NSObject

///消息列表
@property (nonatomic,readonly) NSMutableArray *messageList;

///没有更多的报警消息标志
@property (nonatomic,readonly) BOOL noMore;

/**
 获取消息管理器単例
 
 @return 消息管理器単例
 */
+ (EOAMessageManager*) sharedInstance;


/**
 获取一页（20条）报警消息

 @param fromTop YES:从第一条开始获取;NO:继续获取更早的消息
 @param completion 获取结果回调
 */
- (void) getAlarmMessageFromTop:(BOOL) fromTop Completion:(void(^)(BOOL result)) completion;

@end
