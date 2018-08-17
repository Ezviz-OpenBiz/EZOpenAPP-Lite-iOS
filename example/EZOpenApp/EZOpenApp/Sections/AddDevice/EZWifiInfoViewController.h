//
//  EZWifiInfoViewController.h
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/29.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

#import "EZWiFiConfigManager.h"

@interface EZWifiInfoViewController : EOABaseViewController

@property (nonatomic,assign) BOOL isApMode;
@property (nonatomic,assign) EZWiFiConfigMode configMode;

@end
