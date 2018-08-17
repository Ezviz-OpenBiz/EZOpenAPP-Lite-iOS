//
//  EOASetVoiceStateRequest.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOASetVoiceStateRequest.h"

@implementation EOASetVoiceStateRequest

- (NSString *) apiUrl
{
    return @"api/lapp/device/sound/switch/set";
}

- (id)customRequestParams
{
    NSDictionary *superDic = [super customRequestParams];
    NSMutableDictionary *dic = [superDic mutableCopy];
    [dic setObject:EOA_SAFE_STRING(self.deviceSerial) forKey:@"deviceSerial"];
    [dic setObject:[NSNumber numberWithInteger:self.enable] forKey:@"enable"];

    if (self.channelNo <= 0)
    {
        return dic;
    }
    [dic setObject:[NSNumber numberWithInteger:self.channelNo] forKey:@"channelNo"];
    return dic;
}

- (void)startWithCustomBLock:(void(^)(NSMutableDictionary *dictionary))block
{
    [self startWithSuccess:^(__kindof YSBaseRequest *request, id responseObject) {
        NSMutableDictionary *resultDictionary = [self successDictionaryWithResponse:responseObject];
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
