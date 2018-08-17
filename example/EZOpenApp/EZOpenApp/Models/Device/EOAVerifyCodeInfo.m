//
//  EOAVerifyCodeInfo.m
//  EZOpenApp
//
//  Created by linyong on 17/1/5.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAVerifyCodeInfo.h"

@implementation EOAVerifyCodeInfo

//realm方法，设置主键
+ (NSString *)primaryKey
{
    return @"deviceSerial";
}

+ (instancetype) verifyCodeInfoWithSerial:(NSString *) deviceSerial code:(NSString *) verifyCode
{
    EOAVerifyCodeInfo *verifyCodeInfo = [[EOAVerifyCodeInfo alloc] init];
    [verifyCodeInfo updateWithSerial:deviceSerial code:verifyCode];
    
    return verifyCodeInfo;
}

- (void) updateWithSerial:(NSString *) deviceSerial code:(NSString *) verifyCode
{
    if (!self.deviceSerial)
    {
        self.deviceSerial = deviceSerial;
    }
    
    self.verifyCode = verifyCode;
}


@end
