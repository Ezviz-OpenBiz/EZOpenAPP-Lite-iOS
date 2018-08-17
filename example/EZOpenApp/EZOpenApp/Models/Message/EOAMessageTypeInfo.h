//
//  EOAMessageTypeInfo.h
//  EZOpenApp
//
//  Created by linyong on 2017/3/30.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EOAMessageTypeInfo : NSObject

@property (nonatomic,assign) NSInteger typeNum;//报警类型编号
@property (nonatomic,copy) NSString *imageName;//报警类型图片
@property (nonatomic,copy) NSString *typeName;//报警类型名
@property (nonatomic,strong) UIColor *color;//文字颜色

@end
