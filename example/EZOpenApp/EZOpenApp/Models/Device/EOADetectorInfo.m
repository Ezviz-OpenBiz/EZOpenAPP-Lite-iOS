//
//  EOADetectorInfo.m
//  EZOpenApp
//
//  Created by linyong on 16/12/28.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOADetectorInfo.h"
#import "EZDetectorInfo.h"

@implementation EOADetectorInfo

//realm方法，设置主键
+ (NSString*) primaryKey
{
    return @"mainKey";
}

+ (instancetype) detectorInfoWithInfo:(EZDetectorInfo *) detInfo deviceSerial:(NSString *) deviceSerial
{
    if (!detInfo)
    {
        return nil;
    }
    
    EOADetectorInfo *detectorInfo = [[EOADetectorInfo alloc] init];
    
    [detectorInfo updateWithInfo:detInfo deviceSerial:deviceSerial];
    
    return detectorInfo;
    
}

- (void) updateWithInfo:(EZDetectorInfo *) detInfo deviceSerial:(NSString *)deviceSerial
{
    if (!detInfo)
    {
        return;
    }
    
    if (!self.mainKey)
    {
        self.mainKey = [NSString stringWithFormat:@"%@_%@",deviceSerial,detInfo.detectorSerial];
    }
    
    self.detectorSerial = detInfo.detectorSerial;
    self.deviceSerial = deviceSerial;
    self.state = detInfo.state;
    self.type = detInfo.type;
    self.typeName = detInfo.typeName;
    self.faultZoneStatus = detInfo.faultZoneStatus;
    self.underVoltageStatus = detInfo.underVoltageStatus;
    self.wirelessInterferenceStatus = detInfo.wirelessInterferenceStatus;
    self.offlineStatus = detInfo.offlineStatus;
    self.atHomeEnable = detInfo.atHomeEnable;
    self.outerEnable = detInfo.outerEnable;
    self.sleepEnable = detInfo.sleepEnable;
}

@end
