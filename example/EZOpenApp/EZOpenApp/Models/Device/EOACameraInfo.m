//
//  EOACameraInfo.m
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOACameraInfo.h"
#import "EZCameraInfo.h"
#import "EZDeviceInfo.h"
#import "EZVideoQualityInfo.h"
#import "EOAVideoQualityInfo.h"

@implementation EOACameraInfo

//realm方法，设置主键
+ (NSString *)primaryKey
{
    return @"serialAndNo";
}

//不受Realm管理的属性
+ (nullable NSArray<NSString *> *)ignoredProperties
{
    return @[@"hasRefreshCover"];
}

+ (instancetype) cameraInfoWithInfo:(EZCameraInfo *) camInfo deviceInfo:(EZDeviceInfo *) devInfo
{
    if (!camInfo)
    {
        return nil;
    }
    
    EOACameraInfo *cameraInfo = [[EOACameraInfo alloc] init];
    
    [cameraInfo updateWithInfo:camInfo deviceInfo:devInfo];
    
    return cameraInfo;
}

- (void) updateWithInfo:(EZCameraInfo *) camInfo deviceInfo:(EZDeviceInfo *) devInfo
{
    if (!camInfo)
    {
        return;
    }
    
    if (!self.serialAndNo)
    {
        self.serialAndNo = [NSString stringWithFormat:@"%@_%ld",camInfo.deviceSerial,camInfo.cameraNo];
    }
    
    self.cameraName = camInfo.cameraName;
    self.category = devInfo.category;
    self.cameraNo = camInfo.cameraNo;
    self.deviceSerial = camInfo.deviceSerial;
    self.isShared = camInfo.isShared;
    self.cameraCover = camInfo.cameraCover;
    self.videoLevel = camInfo.videoLevel;
    self.deviceType = devInfo.deviceType;
    self.status = devInfo.status;
    self.defence = devInfo.defence;
    
    if (camInfo.videoQualityInfos && camInfo.videoQualityInfos.count > 0)
    {
        for (EZVideoQualityInfo *qualityInfo in camInfo.videoQualityInfos)
        {
            EOAVideoQualityInfo *destQualityInfo = [EOAVideoQualityInfo qualityInfoWithInfo:qualityInfo];
            
            [self.qualityList addObject:destQualityInfo];
        }
    }
}

@end
