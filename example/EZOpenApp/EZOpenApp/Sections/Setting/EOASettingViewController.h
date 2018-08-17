//
//  EOASettingViewController.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

@class EOADeviceInfo;

@interface EOASettingViewController : EOABaseViewController

+ (void) showSettingViewFrom:(UIViewController *) fromVC
                  deviceInfo:(EOADeviceInfo *) deviceInfo
                 bgImageName:(NSString *) imageName
                 needPresent:(BOOL) needPresent;

@end
