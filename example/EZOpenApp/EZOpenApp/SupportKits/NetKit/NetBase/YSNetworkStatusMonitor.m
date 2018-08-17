//
//  YSNetworkStatusMonitor.h
//  YSNetwork
//
//  Created by qiandong on 8/11/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSNetworkStatusMonitor.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AFNetworking.h"


@interface YSNetworkStatusMonitor ()
@property(strong)void(^callBackBlock)(YSNetStatus netStatus, NSString *netName, YSNetStatusDetail netStatusDetail);
@end

@implementation YSNetworkStatusMonitor

+(void)startMonitorWithBlock:(void (^)(YSNetStatus , NSString *, YSNetStatusDetail))block
{
    static  YSNetworkStatusMonitor *monitor;
    if (!monitor){
        monitor = [[YSNetworkStatusMonitor alloc]init];
    }
    monitor.callBackBlock = block;
    
    [[NSNotificationCenter defaultCenter]addObserver:monitor
                                            selector:@selector(applicationNetworkStatusChanged:)
                                                name:AFNetworkingReachabilityDidChangeNotification
                                              object:nil];
    AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
    [reachability startMonitoring];
}

-(void)applicationNetworkStatusChanged:(NSNotification*)userinfo
{
    NSInteger status = [[[userinfo userInfo]objectForKey:@"AFNetworkingReachabilityNotificationStatusItem"] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            [self noNetwork];
            return;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            [self wwanNetwork];
            return;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [self wifiNetwork];
            return;
        case AFNetworkReachabilityStatusUnknown:
        default:
            [self unknowNetwork];
            return;
    }
}

-(void)noNetwork
{
    self.callBackBlock (YS_NoNetwork, @"NoNetwork", YS_DETAIL_NoNetwork);
}

-(void)wwanNetwork
{
    CTTelephonyNetworkInfo *networkStatus = [[CTTelephonyNetworkInfo alloc]init];
    
    //WWAN状态
    NSString *currentStatus  = networkStatus.currentRadioAccessTechnology;
    
    //运营商名字
    NSString *carrierName  = networkStatus.subscriberCellularProvider.carrierName;
    
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_GPRS);
        //GPRS网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_Edge);
        //2.75G的EDGE网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_WCDMA);
        //3G WCDMA网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_HSDPA);
        //3.5G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_HSUPA);
        //3.5G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_CDMA1xNetwork);
        //CDMA2G网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_CDMAEVDORev0);
        //CDMA的EVDORev0(应该算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_CDMAEVDORevA);
        //CDMA的EVDORevA(应该也算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_CDMAEVDORevB);
        //CDMA的EVDORev0(应该还是算3G吧?)
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_HRPD);
        //HRPD网络
        return;
    }
    if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
        self.callBackBlock (YS_WWANNetwork, carrierName, YS_DETAIL_LTE);
        //LTE4G网络
        return;
    }
}

-(void)wifiNetwork
{
    self.callBackBlock (YS_WifiNetwork, [[self wifiInfo] objectForKey:@"BSSID"], YS_DETAIL_WifiNetwork);
}

-(void)unknowNetwork
{
    self.callBackBlock (YS_UnknowNetwork, @"UnknowNetwork", YS_DETAIL_UnknowNetwork);
}

/**
 *  获取WIFI信息
 */
- (id)wifiInfo
{
    NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs)
    {
        info = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        if (info && [(NSDictionary *)info count])
        {
            break;
        }
    }
    return info;
}

@end
