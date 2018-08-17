//
//  EOACameraCoverInfo.h
//  EZOpenApp
//
//  Created by linyong on 17/1/6.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOABaseModel.h"

@interface EOACameraCoverInfo : EOABaseModel

///关联的设备序列号与通道号组合，作为数据库中的主键 格式如：999999999_1
@property (nonatomic,copy) NSString *serialAndNo;

//通道封面
@property (nonatomic,copy) NSString *coverUrl;


/**
 根据设备序列号，通道号，封面url创建cameraCoverInfo实例

 @param deviceSerial 设备序列号
 @param cameraNo 通道号
 @param coverUrl 封面url
 @return cameraCoverInfo实例
 */
+ (instancetype) cameraCoverInfoWithSerial:(NSString *) deviceSerial
                                  cameraNo:(NSInteger) cameraNo
                                  coverUrl:(NSString *) coverUrl;

/**
 更新封面url

 @param coverUrl 封面url
 */
- (void) updateWithCoverUrl:(NSString *) coverUrl;


@end
