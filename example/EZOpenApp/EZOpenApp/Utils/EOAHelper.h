//
//  EOAHelper.h
//  EZOpenApp
//
//  Created by linyong on 16/12/27.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RLMRealm;

@interface EOAHelper : NSObject


/**
 获取应用内默认数据库

 @return 默认数据库
 */
+ (RLMRealm *) defaultRealm;

/**
 获取APP文档目录

 @return 文档目录
 */
+ (NSString *) documentsPath;

/**
 获取缓存文件目录

 @return 缓存文件目录
 */
+ (NSString *) cachePath;


/**
 获取日期格式对象
 
 @return 日期格式对象
 */
+ (NSDateFormatter *) getDateFormatterWithFormatterString:(NSString *) formatterString;

/**
 毛玻璃效果

 @param radius 越大毛化越严重
 @param image 需进行毛玻璃处理的图片
 @return 毛玻璃处理后的图片
 */
+ (UIImage *)applyBlurRadius:(CGFloat)radius toImage:(UIImage *)image;

@end
