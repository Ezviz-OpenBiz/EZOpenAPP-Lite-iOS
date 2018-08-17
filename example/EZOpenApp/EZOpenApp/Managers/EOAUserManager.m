//
//  EOAUserManager.m
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOAUserManager.h"
#import "EZOpenSDK.h"
#import "EZUserInfo.h"
#import "EZAccessToken.h"
#import "EOAUserInfo.h"
#import <Realm/Realm.h>

const NSNotificationName EOAUserManagerLogout = @"EOAUserManagerLogout";

@interface EOAUserManager ()

@property (nonatomic,strong) RLMRealm *mRealm;

@end

@implementation EOAUserManager

+ (EOAUserManager*) sharedInstance
{
    static EOAUserManager *gUserManager = nil;
    static dispatch_once_t userOnceToken;
    dispatch_once(&userOnceToken, ^{
        gUserManager = [[EOAUserManager alloc] init];
    });
    return gUserManager;
}

- (BOOL) isLogin
{
    return [EZOpenSDK isLogin];
}

- (void) getInfoFromCache
{
    [self openDataBaseAndReadData];
}

- (void) clearInfoInCache
{
    if (!self.mRealm || !self.mUserInfo)
    {
        return;
    }
    
    [self.mRealm beginWriteTransaction];
    [self.mRealm deleteObject:self.mUserInfo];
    [self.mRealm commitWriteTransaction];
    self.mUserInfo = nil;
}

- (void) getUserInfoCompletion:(userInfoCallback) completion
{
    __weak EOAUserManager *weakSelf = self;
    [EZOpenSDK getUserInfo:^(EZUserInfo *userInfo, NSError *error) {
        if (completion)
        {
            [weakSelf updateUserinfoWithInfo:userInfo];
            completion(weakSelf.mUserInfo,error?NO:YES);
        }
    }];
}

- (void) loginWithResult:(resultCallback) callback
{
    if (self.isLogin)
    {
        if (callback)
        {
            callback(YES);
        }
        return;
    }
    __weak EOAUserManager *weakSelf = self;
    [EZOpenSDK openLoginPage:^(EZAccessToken *accessToken) {
        BOOL result = NO;
        if (!accessToken)
        {
            NSLog(@"登录失败!!!");
            result = NO;
        }
        else
        {
            result = YES;
            [weakSelf getUserInfoCompletion:^(EOAUserInfo *userInfo, BOOL result) {

            }];
        }
        
        if (callback)
        {
            callback(result);
        }
    }];
}

- (void) logout
{
    [EZOpenSDK logout:^(NSError *error) {
        NSLog(@"logout result error:%@",error);
    }];
    
    [self clearInfoInCache];
    
    [self postLogoutNotification];
}

- (void) changePassword
{
    if (!self.isLogin)
    {
        return;
    }
    
    [EZOpenSDK openChangePasswordPage:^(NSInteger resultCode) {
        
    }];
}

#pragma mark- support

- (NSString *) makeExpireTimeWithTime:(NSInteger) expireTime
{
//    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
//    NSTimeInterval destTime = nowTime + expireTime - 2*60*60;//过期时间减去2小时，保证使用时都在过期时间之前
//    
//    NSDate *destDate = [NSDate dateWithTimeIntervalSince1970:destTime];
//    
    NSDate *destDate = [NSDate dateWithTimeIntervalSince1970:expireTime/1000];

    NSDateFormatter *dateFormatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:destDate];
}

- (void) updateUserinfoWithInfo:(EZUserInfo *) info
{
    if (!info)
    {
        return;
    }
    
    if (!self.mUserInfo)
    {
        [self createAndSaveEmptyUserInfo];
    }
    
    [self.mRealm beginWriteTransaction];
    self.mUserInfo.username = info.username;
    self.mUserInfo.nickname = info.nickname;
    self.mUserInfo.avatarUrl = info.avatarUrl;
    self.mUserInfo.areaDomain = info.areaDomain;
    [self.mRealm commitWriteTransaction];
}

- (void) openDataBaseAndReadData
{
    //realm实例存在说明已读取过缓存，不需要再读
    if (self.mRealm)
    {
        return;
    }
    
    self.mRealm = [EOAHelper defaultRealm];
    
    RLMResults *userInfoList = [EOAUserInfo allObjectsInRealm:self.mRealm];
    if (userInfoList && userInfoList.count > 0)
    {
        self.mUserInfo = [userInfoList firstObject];
    }
    else
    {
        [self createAndSaveEmptyUserInfo];
    }
}

- (void) createAndSaveEmptyUserInfo
{
    if (!self.mRealm)
    {
        return;
    }
    
    self.mUserInfo = [[EOAUserInfo alloc] init];
    [self.mRealm beginWriteTransaction];
    [self.mRealm addObject:self.mUserInfo];
    [self.mRealm commitWriteTransaction];
}

- (void) postLogoutNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EOAUserManagerLogout object:nil];
    });
}

@end
