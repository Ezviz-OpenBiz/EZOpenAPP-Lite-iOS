//
//  EOACameraCoverInfo.m
//  EZOpenApp
//
//  Created by linyong on 17/1/6.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOACameraCoverInfo.h"

@implementation EOACameraCoverInfo


//realm方法，设置主键
+ (NSString *)primaryKey
{
    return @"serialAndNo";
}

+ (instancetype) cameraCoverInfoWithSerial:(NSString *) deviceSerial
                                  cameraNo:(NSInteger) cameraNo
                                  coverUrl:(NSString *) coverUrl
{
    if (!deviceSerial)
    {
        return nil;
    }
    
    EOACameraCoverInfo *cameraCoverInfo = [[EOACameraCoverInfo alloc] init];
    cameraCoverInfo.serialAndNo = [NSString stringWithFormat:@"%@_%ld",deviceSerial,cameraNo];
    cameraCoverInfo.coverUrl = coverUrl;
    
    return cameraCoverInfo;
}

- (void) updateWithCoverUrl:(NSString *) coverUrl
{
    self.coverUrl = coverUrl;
}


@end
