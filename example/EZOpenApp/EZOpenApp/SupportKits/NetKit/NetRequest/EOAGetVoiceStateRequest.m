//
//  EOAGetVoiceStateRequest.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAGetVoiceStateRequest.h"

@implementation EOAGetVoiceStateRequest

- (NSString *) apiUrl
{
    return @"api/lapp/device/sound/switch/status";
}

- (id) customRequestParams
{
    return nil;//采用默认参数
}

- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block
{
    [self startWithSuccess:^(__kindof YSBaseRequest *request, id responseObject) {
        NSMutableDictionary *resultDictionary = [self successDictionaryWithResponse:responseObject];
        if ([[resultDictionary objectForKey:RESULT_CODE_KEY] integerValue] == DEFAULT_SUCCESS_CODE)
        {
            NSDictionary *dic = (NSDictionary*)responseObject;
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            
            [resultDictionary setObject:[dataDic objectForKey:@"enable"] forKey:@"enable"];
        }
        if (block)
        {
            block(resultDictionary);
        }
    } failure:^(__kindof YSBaseRequest *request, NSError *error) {
        if (block)
        {
            block([self failDictionaryWithError:error]);
        }
    }];
}

@end
