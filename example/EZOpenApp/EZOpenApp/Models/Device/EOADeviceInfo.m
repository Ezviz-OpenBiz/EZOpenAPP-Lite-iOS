//
//  EOADeviceInfo.m
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOADeviceInfo.h"
#import "EOACameraInfo.h"
#import "EOADetectorInfo.h"
#import "EZDeviceInfo.h"
#import "EZCameraInfo.h"
#import "EZDetectorInfo.h"

@implementation EOADeviceInfo

//realm方法，设置主键
+ (NSString *)primaryKey
{
    return @"deviceSerial";
}

+ (instancetype) deviceInfoWithInfo:(EZDeviceInfo *) devInfo
{
    if (!devInfo)
    {
        return nil;
    }
    
    EOADeviceInfo *destInfo = [[EOADeviceInfo alloc] init];
    [destInfo updateWithInfo:devInfo];
    
    return destInfo;
}

- (void) updateWithInfo:(EZDeviceInfo *) devInfo
{
    if (!devInfo)
    {
        return;
    }
    
    self.cameraNum = devInfo.cameraNum;
    self.defence = devInfo.defence;
    self.detectorNum = devInfo.detectorNum;
    self.deviceCover = devInfo.deviceCover;
    self.deviceName = devInfo.deviceName;
    if (!self.deviceSerial)//主键需特殊处理，无则说明是新建的，有则说明是更新数据
    {
        self.deviceSerial = devInfo.deviceSerial;
    }
    self.deviceType = devInfo.deviceType;
    self.deviceVersion = devInfo.deviceVersion;
    self.category = devInfo.category;
    self.isEncrypt = devInfo.isEncrypt;
    self.status = devInfo.status;
    self.supportTalkMode = devInfo.supportTalkMode;
    self.isSupportPTZ = devInfo.isSupportPTZ;
    self.isSupportZoom = devInfo.isSupportZoom;
    self.isSupportAudioOnOff = devInfo.isSupportAudioOnOff;
    self.isSupportMirrorCenter = devInfo.isSupportMirrorCenter;
    self.addTime = devInfo.addTime;
    if (self.realm)
    {
        //与设备关联的通道和探测器更新，采用删除再添加的方式更新
        RLMResults *tempCameraList = [EOACameraInfo objectsInRealm:self.realm where:@"deviceSerial=%@",self.deviceSerial];
        if (tempCameraList.count > 0)
        {
            [self.realm deleteObjects:tempCameraList];
        }
        
        RLMResults *tempDetectorList = [EOADetectorInfo objectsInRealm:self.realm where:@"deviceSerial=%@",self.deviceSerial];
        if (tempDetectorList.count > 0)
        {
            [self.realm deleteObjects:tempDetectorList];
        }
    }
    
    if (devInfo.cameraInfo && devInfo.cameraInfo.count > 0)
    {
        for (EZCameraInfo *camInfo in devInfo.cameraInfo)
        {
            EOACameraInfo *cameraInfo = [EOACameraInfo cameraInfoWithInfo:camInfo deviceInfo:devInfo];
            
            [self.cameraList addObject:cameraInfo];
        }
    }
    
    if (devInfo.detectorInfo && devInfo.detectorInfo.count > 0)
    {
        for (EZDetectorInfo *detInfo in devInfo.detectorInfo)
        {
            EOADetectorInfo *detectorInfo = [EOADetectorInfo detectorInfoWithInfo:detInfo deviceSerial:devInfo.deviceSerial];
            [self.detectorList addObject:detectorInfo];
        }
    }
}

@end
