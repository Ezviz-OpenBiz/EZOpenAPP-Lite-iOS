//
//  EOAGetCloudStateRequest.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAGetCloudStateRequest.h"

@implementation EOAGetCloudStateRequest

- (NSString *) apiUrl
{
    return @"api/lapp/cloud/storage/device/info";
}

- (id)customRequestParams
{
    NSDictionary *superDic = [super customRequestParams];
    NSMutableDictionary *dic = [superDic mutableCopy];
    [dic setObject:self.deviceSerial forKey:@"deviceSerial"];
    if (self.channelNo > 0)
    {
        [dic setObject:[NSNumber numberWithInteger:self.channelNo] forKey:@"channelNo"];
    }
    
    if (self.phone && self.phone.length > 0)
    {
        [dic setObject:self.phone forKey:@"phone"];
    }
    
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
