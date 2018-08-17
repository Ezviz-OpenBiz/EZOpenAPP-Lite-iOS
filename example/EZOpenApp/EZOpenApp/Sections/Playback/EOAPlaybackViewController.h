//
//  EOAPlaybackViewController.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/8.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

@class EZAlarmInfo;

@interface EOAPlaybackViewController : EOABaseViewController

+ (void) showPlaybackViewFrom:(UIViewController *) fromVC alarmInfo:(EZAlarmInfo *) alarmInfo;

@end
