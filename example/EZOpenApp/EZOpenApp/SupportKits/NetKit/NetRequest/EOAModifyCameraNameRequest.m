//
//  EOAModifyCameraNameRequest.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/17.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAModifyCameraNameRequest.h"

@implementation EOAModifyCameraNameRequest

- (NSString *) apiUrl
{
    return @"api/lapp/camera/name/update";
}

- (id) customRequestParams
{
    return nil;//采用默认参数
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
