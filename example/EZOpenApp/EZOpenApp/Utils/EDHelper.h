//
//  EDHelper.h
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/13.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDHelper : NSObject

@property (nonatomic,copy) NSString *deviceSerial;
@property (nonatomic,copy) NSString *verifyCode;
@property (nonatomic,copy) NSString *deviceType;
@property (nonatomic,assign) BOOL needRefreshDeviceList;

+ (instancetype) sharedInstance;

- (NSString *) getVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo;

- (void) saveVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo code:(NSString *) code;

- (void) removeVerifyCodeWithDeviceSerial:(NSString *) deviceSerial cameraNo:(NSInteger) cameraNo;

@end
