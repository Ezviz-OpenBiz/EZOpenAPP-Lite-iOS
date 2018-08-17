//
//  EOAWaitView.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/11.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOAWaitView : UIView

+ (void) showWaitViewInView:(UIView *) view frame:(CGRect) frame;

+ (void) hideWaitView;

@end
