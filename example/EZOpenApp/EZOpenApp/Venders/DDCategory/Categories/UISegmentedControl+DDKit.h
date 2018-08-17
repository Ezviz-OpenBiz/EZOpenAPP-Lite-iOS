//
//  UISegmentedControl+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (DDKit)

@end

@interface UISegmentedControl (DDFlatten)

#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED <= 60000)

/**
 *  iOS6中使用UISegmentedControl 扁平化
 */
- (void)dd_flattenIniOS6;

/**
 *  iOS6中使用UISegmentedControl 扁平化 设置选中颜色
 *
 *  @param selectedColor 选中颜色
 */
- (void)dd_flattenIniOS6:(UIColor *)selectedColor;

#endif

@end