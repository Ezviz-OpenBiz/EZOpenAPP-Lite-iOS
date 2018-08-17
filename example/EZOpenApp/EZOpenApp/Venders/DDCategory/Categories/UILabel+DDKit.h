//
//  UILabel+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DDKit)

/**
 *  Calculate the text height with the systemFontSize & constrain width
 *
 *  @param text     The Calculate text
 *  @param fontSize The System font size
 *  @param width    The constraint
 *
 *  @return The calculated height
 */
+ (CGFloat)dd_heightOfText:(NSString *)text
                  fontSize:(CGFloat)fontSize
           constraintWidth:(CGFloat)width;

/**
 *  Calculate the text height with the systemFontSize & constrain width then return a minimum height
 *
 *  @param text     The calculate text
 *  @param fontSize The system font size
 *  @param width    The constraint
 *  @param height   The minimum height
 *
 *  @return The calculated height with the minimum height
 */
+ (CGFloat)dd_heightOfText:(NSString *)text
                  fontSize:(CGFloat)fontSize
           constraintWidth:(CGFloat)width
             minimumHeight:(CGFloat)height;

/**
 *  Calculate the text height with the font & constrain width then return a minimum height
 *
 *  @param text     The calculate text
 *  @param font     The font
 *  @param width    The constraint
 *  @param height   The minimum height
 *
 *  @return The calculated height with the minimum height
 */
+ (CGFloat)dd_heightOfText:(NSString *)text
                      font:(UIFont *)font
           constraintWidth:(CGFloat)width
             minimumHeight:(CGFloat)height;

@end

@interface UILabel (DDAutoSize)

/**
 * 垂直方向固定获取动态宽度的UILabel的方法
 *
 * @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)dd_resizeLabelHorizontal;

/**
 *  水平方向固定获取动态宽度的UILabel的方法
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)dd_resizeLabelVertical;

/**
 *  垂直方向固定获取动态宽度的UILabel的方法
 *
 *  @param minimumWidth minimum width
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)dd_resizeLabelHorizontal:(CGFloat)minimumWidth;

/**
 *  水平方向固定获取动态宽度的UILabel的方法
 *
 *  @param minimumHeigh minimum height
 *
 *  @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)dd_resizeLabelVertical:(CGFloat)minimumHeigh;

@end