//
//  EOAVerifyCodeManager.m
//  EZOpenApp
//
//  Created by linyong on 17/1/5.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAVerifyCodeManager.h"
#import "EOAVerifyCodeInfo.h"
#import <Realm/Realm.h>


const NSNotificationName EOAVerifyCodeChanged = @"EOAVerifyCodeChanged";


@interface EOAVerifyCodeManager ()

@property (nonatomic,strong) RLMRealm *mRealm;

@end

@implementation EOAVerifyCodeManager

+ (EOAVerifyCodeManager*) sharedInstance
{
    static EOAVerifyCodeManager *gVerifyCodeManager = nil;
    static dispatch_once_t verifyCodeOnceToken;
    dispatch_once(&verifyCodeOnceToken, ^{
        gVerifyCodeManager = [[EOAVerifyCodeManager alloc] init];
        gVerifyCodeManager.mRealm = [EOAHelper defaultRealm];
    });
    return gVerifyCodeManager;
}

- (void) updateVerifyCodeWithSerial:(NSString *) deviceSerial code:(NSString*) verifyCode
{
    EOAVerifyCodeInfo *verifyCodeInfo = nil;
    RLMResults *resultList = [EOAVerifyCodeInfo objectsInRealm:self.mRealm where:@"deviceSerial = %@",deviceSerial];
    
    [self.mRealm beginWriteTransaction];
    if (resultList.count > 0)
    {
        verifyCodeInfo = [resultList firstObject];
        [verifyCodeInfo updateWithSerial:deviceSerial code:verifyCode];
    }
    else
    {
        verifyCodeInfo = [EOAVerifyCodeInfo verifyCodeInfoWithSerial:deviceSerial code:verifyCode];
        [self.mRealm addObject:verifyCodeInfo];
    }
    [self.mRealm commitWriteTransaction];
    
    [self performSelectorOnMainThread:@selector(postVerifyCodeChangedNotification) withObject:nil waitUntilDone:NO];
}

- (NSString *) getVerifyCodeWithSerial:(NSString *) deviceSerial
{
    RLMResults *resultList = [EOAVerifyCodeInfo objectsInRealm:self.mRealm where:@"deviceSerial = %@",deviceSerial];
    if (resultList.count <= 0)
    {
        return nil;
    }
    
    EOAVerifyCodeInfo *verifyCodeInfo = [resultList firstObject];
    
    return verifyCodeInfo.verifyCode;
}

#pragma mark - support


- (void) postVerifyCodeChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EOAVerifyCodeChanged object:nil];
}


@end
