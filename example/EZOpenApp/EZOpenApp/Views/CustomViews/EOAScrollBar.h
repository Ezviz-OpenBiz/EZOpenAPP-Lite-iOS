//
//  EOAScrollBarBar.h
//  EZOpenApp
//
//  Created by linyong on 15/4/17.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EOAScrollBarDelegate <NSObject>

@optional
/**
 点击操作代理方法

 @param index 选中的索引号
 */
- (void) tabButtonClickByIndex:(NSInteger) index;

@end

@interface EOAScrollBar : UIView

@property (nonatomic,readonly) NSInteger selectedIndex;
@property (nonatomic,readonly) NSArray *titleList;

/**
 创建滚动条

 @param target 代理对象
 @param frame 区域
 @param titles 标题数组
 @param selectedIndex 默认选中索引，索引为标题数组中的索引号
 @return 实例
 */
- (id) initWithTarget:(id<EOAScrollBarDelegate>) target
                frame:(CGRect) frame
               titles:(NSArray *) titles
        selectedIndex:(NSInteger) selectedIndex;

//选中项，index为titles数组中的索引号
- (void) selectAtIndex:(NSInteger) index;

//offset 为偏移量除以总共可以移动的长度
- (void) flagScrollToOffset:(CGFloat) offset;

//设置字体
- (void) setTabTitleFont:(UIFont *) font;

//设置title颜色
- (void) setTabTitleColor:(UIColor *) color forState:(UIControlState) state;

//设置指示条颜色
- (void) setTabTitleIndicatorColor:(UIColor *) color;

@end
