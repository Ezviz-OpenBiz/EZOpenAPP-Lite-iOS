//
//  UIColor+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DDKit)

@end

@interface UIColor (DDHexString)

/**
 *  Convert hex color string into UIColor
 *
 *  @param stringToConvert The hex color string.
 *
 *  @return UIColor
 */
+ (UIColor *)dd_hexStringToColor:(NSString *)stringToConvert;

@end