//
//  YSNetworkAgent.h
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSBaseRequest.h"
#import "AFNetworking.h"

@interface YSNetworkAgent : NSObject

@property(nonatomic,strong) AFHTTPSessionManager *manager;

//模拟抽象类的方法:子类必须重载该方法，且不能调用[super method]; 
+ (YSNetworkAgent *)sharedInstance;

- (void)addRequest:(YSBaseRequest *)request; //加入request并执行
- (void)cancelRequest:(YSBaseRequest *)request; //取消request执行
- (void)cancelAllRequests; //取消所有request执行





@end
