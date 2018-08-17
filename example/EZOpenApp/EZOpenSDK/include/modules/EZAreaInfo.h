//
//  EZAreaInfo.h
//  EzvizOpenSDK
//
//  Created by DeJohn Dong on 16/7/19.
//  Copyright © 2016年 Hikvision. All rights reserved.
//

#import "EZEntityBase.h"

/// 此对象为区域对象，海外开放平台专用对象
@interface EZAreaInfo : EZEntityBase

@property (nonatomic) NSInteger id; ///区域ID
@property (nonatomic, copy) NSString *name; ///区域名称
@property (nonatomic, copy) NSString *region; ///区域标识
@property (nonatomic) NSInteger telephoneCode; ///区域手机国际号

@end
