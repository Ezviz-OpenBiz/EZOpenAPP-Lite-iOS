//
//  EOAModifyNameViewController.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/6.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

@class EOACameraInfo,EOADeviceInfo;

@interface EOAModifyNameViewController : EOABaseViewController

+ (void) showModifyNameViewControllerFrom:(UIViewController *) fromVC cameraInfo:(EOACameraInfo *) cameraInfo isPresent:(BOOL) isPresent;

+ (void) showModifyNameViewControllerFrom:(UIViewController *) fromVC deviceInfo:(EOADeviceInfo *) deviceInfo isPresent:(BOOL) isPresent;


@end
