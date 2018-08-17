//
//  EOADefines.h
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>


#define UIColorFromRGB(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(al)]

#define EOA_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define EOA_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define NAVIGATION_BAR_HEIGHT_WITH_STATUSBAR (64.0)
#define NAVIGATION_BAR_HEIGHT_WITHOUT_STATUSBAR (44.0)
#define TAB_BAR_HEIGHT (44.0)

#define EOA_SAFE_STRING(STRING_) STRING_ == nil ? @"" : STRING_


@interface EOADefines : NSObject

@end
