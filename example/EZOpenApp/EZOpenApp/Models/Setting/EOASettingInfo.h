//
//  EOASettingInfo.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/14.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SETTING_CELL_TYPE_MODIFY = 0, //可修改类型
    SETTING_CELL_TYPE_SWITCH, //开关类型
    SETTING_CELL_TYPE_DISPLAY, //展示类型
    SETTING_CELL_TYPE_ACTION, //可操作类型
    SETTING_CELL_TYPE_DELETE, //删除操作类型
    SETTING_CELL_TYPE_MAX
}
SettingCellType;

typedef void(^cellAction)(void);

@interface EOASettingInfo : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) UIColor *titleColor;
@property (nonatomic,assign) SettingCellType type;
@property (nonatomic,assign) BOOL switchValue;
@property (nonatomic,copy) NSString *desMessage;//内容描述信息
@property (nonatomic,strong) UIColor *desColor;
@property (nonatomic,copy) cellAction cellSelectedCallback;
@property (nonatomic,assign) SEL switchCallback;

@end
