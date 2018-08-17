//
//  V2CommonRequest.m
//  YSNetwork
//
//  Created by qiandong on 7/13/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "V2CommonRequest.h"
#import "V2CommonAgent.h"
#import "NSString+Utilities.h"
#import "EOAUserManager.h"
#import "EOAUserInfo.h"
#import "EZOpenSDK.h"

#define HOST_URL @"https://open.ys7.com/"

@implementation V2CommonRequest

//重载：基路径
- (NSString *)baseUrl
{
    return HOST_URL;
}

- (id) customRequestParams
{
    NSString *accessToken = [EZOpenSDK getAccesstoken];
    return @{@"accessToken":EOA_SAFE_STRING(accessToken)};
}

//重载：公共参数
- (id)commonParams
{
    NSString *accessToken = [EZOpenSDK getAccesstoken];
    return @{@"accessToken":EOA_SAFE_STRING(accessToken)};
}

//重载，明确使用哪个agent
- (YSNetworkAgent *)networkAgent
{
    return [V2CommonAgent sharedInstance];   //默认使用JSON ResponseSerial 的agent
}

- (NSMutableDictionary *)failDictionaryWithError:(NSError *)error
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[NSNumber numberWithInteger:error.code]
                  forKey:RESULT_CODE_KEY];
    [dictionary setValue:error.description forKey:RESULT_DESC_KEY];
    return dictionary;
}

- (NSMutableDictionary *)successDictionaryWithResponse:(id)response
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (response == nil || ![response isKindOfClass:[NSDictionary class]])
    {
        [dictionary setValue:[NSNumber numberWithInt:DEFAULT_ERROR_CODE] forKey:RESULT_CODE_KEY];
        return dictionary;
    }
    
    NSDictionary *dataDictionary = (NSDictionary *)response;
    
    int result = DEFAULT_ERROR_CODE;
    NSNumber *resultCode = [dataDictionary objectForKey:RESULT_CODE_KEY];
    if (![resultCode isKindOfClass:[NSNull class]])
    {
        result = [resultCode intValue]; //获取结果操作码
    }
    [dictionary setValue:[NSNumber numberWithInt:result] forKey:RESULT_CODE_KEY];

    NSString *desc = [dataDictionary objectForKey:RESULT_DESC_KEY];
    if ([desc isKindOfClass:[NSString class]])
    {
        [dictionary setValue:desc forKey:RESULT_DESC_KEY];
    }
    
    return dictionary;
}

@end
