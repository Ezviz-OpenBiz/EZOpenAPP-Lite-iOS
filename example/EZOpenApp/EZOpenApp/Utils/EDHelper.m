//
//  EDHelper.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/13.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EDHelper.h"

@interface EDHelper ()

@property (nonatomic,strong) NSMutableDictionary *verifyCodeDic;

@end

@implementation EDHelper

+ (instancetype) sharedInstance
{
    static EDHelper *gHelper = nil;
    static dispatch_once_t helperOnceToken;
    dispatch_once(&helperOnceToken, ^{
        gHelper = [EDHelper new];
    });
    
    return gHelper;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        self.verifyCodeDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *) getVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo
{
    if (!self.verifyCodeDic || !deviceSerial || deviceSerial.length == 0)
    {
        return nil;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%ld",deviceSerial,cameraNo];
    
    NSString *code = [self.verifyCodeDic objectForKey:key];
    
    if (!code || [code isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    return code;
}

- (void) saveVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo code:(NSString *) code
{
    if (!self.verifyCodeDic || !deviceSerial || deviceSerial.length == 0 || !code || code.length == 0)
    {
        return ;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%ld",deviceSerial,cameraNo];

    [self.verifyCodeDic setObject:code forKey:key];
}

- (void) removeVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo
{
    if (!self.verifyCodeDic || !deviceSerial || deviceSerial.length == 0)
    {
        return ;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%ld",deviceSerial,cameraNo];
    
    [self.verifyCodeDic removeObjectForKey:key];
}

@end
