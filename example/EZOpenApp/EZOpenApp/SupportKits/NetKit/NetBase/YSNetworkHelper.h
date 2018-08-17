//
//  YSNetworkHelper.h
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void YSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface YSNetworkHelper : NSObject

//校验返回JSON是否满足预定义要求
+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

//组织GET请求的完整URL
+ (NSString *)urlWithOriginUrl:(NSString *)originUrl appendParams:(NSDictionary *)params;

//文件路径不加入Icloud备份
+ (void)notBackupWithPath:(NSString *)path;

//字符串 -》 MD5
+ (NSString *)md5StringFromString:(NSString *)string;

//APP版本
+ (NSString *)appVersionString;

//字典转JSON
+ (NSString*)dictToJson:(id)object;

@end
