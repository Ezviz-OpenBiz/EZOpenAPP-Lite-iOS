//
//  NSString+videoPlayUrl.m
//  VideoGo
//
//  Created by zhilshi on 2016/11/24.
//  Copyright © 2016年 hikvision. All rights reserved.
//

#import "NSString+videoPlayUrl.h"

@implementation NSString (videoPlayUrl)

- (NSString *)videoPlayProtocolUrlFromRTSP
{
    if (!self)
    {
        return self;
    }
    
    if ([self rangeOfString:@"ysproto://"].length)
    {
        return self;
    }
    
    if (![self rangeOfString:@"rtsp://"].length)
    {
        return nil;
    }
    
    
    NSMutableString *livePlayUrl = [NSMutableString stringWithFormat:@"%@",@"ysproto:"];
    NSArray *realInfoAry = [self componentsSeparatedByString:@":"];
    if(realInfoAry.count != 12)
    {
        return nil;
    }
    
     //vtm服务器IP
    NSString *vtmIP = [realInfoAry objectAtIndex:1];
    [livePlayUrl appendFormat:@"%@:",vtmIP];
    
    //vtm服务端口
    NSString *vtmPort = [realInfoAry objectAtIndex:2];
    NSArray *vtmportAry = [vtmPort componentsSeparatedByString:@"/"];
    if ([vtmportAry count] == 2)
    {
        vtmPort = [vtmportAry objectAtIndex:0];
    }
    [livePlayUrl appendFormat:@"%@",vtmPort];
    
    //取流设备序列号
    NSString *deviceSerial = [realInfoAry objectAtIndex:3];
    deviceSerial = [deviceSerial substringFromIndex:2];
    [livePlayUrl appendFormat:@"/live?dev=%@",deviceSerial];
    
    //取流通道号
    NSString *realChannel = [realInfoAry objectAtIndex:4];
    [livePlayUrl appendFormat:@"&chn=%@",realChannel];
    
    //取流类型
    NSString *realStreamType = [realInfoAry objectAtIndex:5];
    [livePlayUrl appendFormat:@"&stream=%@",realStreamType];
    
    //终端类型
    [livePlayUrl appendString:@"&cln=1"];
    
    //运营商类型,0:电信、1:网通、2:移动、3:铁通
    NSString *clientIspType = [realInfoAry objectAtIndex:9];
    clientIspType = [clientIspType substringFromIndex:([clientIspType length]-1)];
    [livePlayUrl appendFormat:@"&isp=%@&biz=3",clientIspType];
    
    return [livePlayUrl copy];
}

- (NSString *)deviceSerialNo
{
    if (!self)
    {
        return self;
    }
    NSRange devRange = [self rangeOfString:@"dev="];
    
    if (devRange.length == 0)
    {
        return nil;
    }
    
    NSString *subString = [self substringFromIndex:devRange.location+devRange.length];
    if (!subString.length)
    {
        return nil;
    }
    
    NSRange endRange = [subString rangeOfString:@"&"];
    if(endRange.length == 0)
    {
        return nil;
    }
    
    NSString *deviceSerialNo = [subString substringToIndex:endRange.location];
    
    return deviceSerialNo;
}

- (NSInteger)channelNo
{
    if (!self)
    {
        return 0;
    }
    NSRange chnRange = [self rangeOfString:@"chn="];
    
    if (chnRange.length == 0)
    {
        return 0;
    }
    
    NSString *subString = [self substringFromIndex:chnRange.location+chnRange.length];
    if (!subString.length)
    {
        return 0;
    }
    
    NSRange endRange = [subString rangeOfString:@"&"];
    if(endRange.length == 0)
    {
        return 0;
    }
    
    NSString *chnStr = [subString substringToIndex:endRange.location];
    if (!chnStr.length)
    {
        return 0;
    }
    
    return [chnStr intValue];
}
@end
