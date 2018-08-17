//
//  EOABaseViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/18.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

@implementation EOABaseTabbarController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end


@implementation EOABaseNavigationController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end


@implementation EOABaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - override

//只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
