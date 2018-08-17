//
//  EOAVideoQualitySelectView.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOAVideoQualitySelectView : UIView

/**
 初始化

 @param frame 区域
 @param qualityList 视频支持的清晰度列表
 @param selectedIndex 当前设置的清晰度在清晰度列表中的索引号
 @param selectCallback 点击回调
 @return 清晰度选择界面实例
 */
- (instancetype) initWithFrame:(CGRect)frame
                   qualityList:(NSArray *) qualityList
                 selectedIndex:(NSInteger) selectedIndex
                selectCallback:(void(^)(NSInteger selectIndex)) selectCallback;

/**
 选择清晰度

 @param index 被选中的清晰度在清晰度列表中的索引号
 */
- (void) selectAtIndex:(NSInteger) index;

/**
 设置按钮是否可用
 
 @param enable YES:按钮可用 NO:按钮不可用
 */
- (void) setBtnsEnable:(BOOL) enable;

@end
