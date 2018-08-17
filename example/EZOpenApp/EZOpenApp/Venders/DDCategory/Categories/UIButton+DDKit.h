//
//  UIButton+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (DDKit)

@end

@interface UIButton (DDBadgeView)

/**
 *  Remove the badge value on the button.
 */
- (void)dd_removeBadgeValue;

/**
 *  Add a badge value view on the button.
 *
 *  @param strBadgeValue The badge value.
 *
 *  @return A view contrain the badge value.
 */
- (UIView *)dd_showBadgeValue:(NSString *)strBadgeValue;

/**
 *  Add a badage value view use the padding position.
 *
 *  @param strBadgeValue The badge value.
 *  @param point         The padding offset position.
 *
 *  @return A view contrain the badge value.
 */
- (UIView *)dd_showBadgeValue:(NSString *)strBadgeValue andPadding:(CGPoint)point;

@end


@interface UIButton (DDButtonCenterStyle)

/**
 *  Set the title & image center in the button bounds
 *
 *  @param space The title & image space
 */
- (void)dd_centerImageAndTitle:(float)space;

/**
 *  Default center method.
 */
- (void)dd_centerImageAndTitle;

@end