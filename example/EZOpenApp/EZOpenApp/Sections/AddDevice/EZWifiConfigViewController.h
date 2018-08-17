//
//  EZWifiConfigViewController.h
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

#import "EZWiFiConfigManager.h"

@interface EZWifiConfigViewController : EOABaseViewController

@property (nonatomic,assign) EZWiFiConfigMode configMode;
@property (nonatomic,copy) NSString *wifiSsid;
@property (nonatomic,copy) NSString *wifiPwd;


@end
