//
//  EOAVideoQualityInfo.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAVideoQualityInfo.h"
#import "EZVideoQualityInfo.h"

@implementation EOAVideoQualityInfo

+ (instancetype) qualityInfoWithInfo:(EZVideoQualityInfo *) qualityInfo
{
    if (!qualityInfo)
    {
        return nil;
    }
    
    EOAVideoQualityInfo *destQualityInfo = [[EOAVideoQualityInfo alloc] init];
    
    [destQualityInfo updateWithInfo:qualityInfo];
    
    return destQualityInfo;
}

- (void) updateWithInfo:(EZVideoQualityInfo *)qualityInfo
{
    if (!qualityInfo)
    {
        return;
    }
    
    self.videoQualityName = qualityInfo.videoQualityName;
    self.videoLevel = qualityInfo.videoLevel;
    self.streamType = qualityInfo.streamType;
}

@end
