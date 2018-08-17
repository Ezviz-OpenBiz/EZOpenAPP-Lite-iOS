//
//  UISegmentedControl+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "UISegmentedControl+DDKit.h"
#import "UIImage+DDKit.h"

@implementation UISegmentedControl (DDKit)

@end

@implementation UISegmentedControl (DDFlatten)

#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)
//处理UISegmentedControl 在iOS6及以下的扁平化效果
- (void)dd_flattenIniOS6 {
    [self dd_flattenIniOS6:nil];
}

- (void)dd_flattenIniOS6:(UIColor *)selectedColor {
    if([[UIDevice currentDevice].systemVersion floatValue] < 6.9){
        UIImage *image = [UIImage dd_createImageWithCGSize:CGSizeMake(1, 28) color:self.tintColor];
        [[UISegmentedControl appearance] setBackgroundImage:image
                                                   forState:UIControlStateSelected
                                                 barMetrics:UIBarMetricsDefault];
        [[UISegmentedControl appearance] setDividerImage:image
                                     forLeftSegmentState:UIControlStateNormal
                                       rightSegmentState:UIControlStateSelected
                                              barMetrics:UIBarMetricsDefault];
        
        image = [UIImage dd_createImageWithCGSize:CGSizeMake(1, 28) color:[UIColor clearColor]];
        [[UISegmentedControl appearance] setBackgroundImage:image
                                                   forState:UIControlStateNormal
                                                 barMetrics:UIBarMetricsDefault];
        
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 4.0f;
        self.layer.masksToBounds = YES;
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{UITextAttributeTextColor:selectedColor?:[UIColor whiteColor],UITextAttributeFont:[UIFont systemFontOfSize:14],UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetZero]}
                                                       forState:UIControlStateSelected];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{UITextAttributeTextColor:self.tintColor?:[UIColor whiteColor],UITextAttributeFont:[UIFont systemFontOfSize:14],UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)]}
                                                       forState:UIControlStateNormal];
        
    }
}
#endif
@end