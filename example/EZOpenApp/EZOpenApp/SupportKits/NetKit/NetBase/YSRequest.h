//
//  YSRequest.h
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSBaseRequest.h"

/*
 YSRequest 定义特定功能（目前实现Cache功能）
 目前的Cache是以文件形式缓存，暂时没有加上定期删除功能。
 */

@interface YSRequest : YSBaseRequest

@property (nonatomic) BOOL ignoreCache; //让某次请求忽略缓存（请求前）
@property (nonatomic,readonly) BOOL isDataFromCache; //判断数据是否来自缓存（获得Response后）

// 用于返回cache的数据
- (id)cacheJson;

#pragma mark ************** 可重载 **************
- (NSInteger)cacheTimeInSeconds; //接口的缓存时间，如果<=0，则不会缓存。
- (long long)cacheVersion; //缓存的版本。 如果app版本更替，接口有改变。则可以返回不同的cacheVersion，以便让之前的缓存失效。
- (id)cacheNameForRequestParams:(id)params;// cache结果并计算cache文件名时，可过滤一些参数

@end
