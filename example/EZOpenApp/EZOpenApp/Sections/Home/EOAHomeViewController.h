//
//  EOAHomeViewController.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/1.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseViewController.h"

@interface EOAHomeViewController : EOABaseViewController

+ (void) loginFrom:(UIViewController *) controller rsult:(void(^)(BOOL result)) resultCallback;

@end
