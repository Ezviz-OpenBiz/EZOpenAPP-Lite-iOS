//
//  YSNetworkStatusMonitor.h
//  YSNetwork
//
//  Created by qiandong on 8/11/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YSNetStatusDetail) {
    YS_DETAIL_UnknowNetwork = -1,//不知名网络
    YS_DETAIL_NoNetwork = 0,     //没有网络
    YS_DETAIL_WifiNetwork = 1,   //WIFI网络
    YS_DETAIL_CDMA1xNetwork = 2, //电信2G网络
    YS_DETAIL_CDMAEVDORev0 = 3,  //电信3G Rev0
    YS_DETAIL_CDMAEVDORevA = 4,  //电信3G RevA
    YS_DETAIL_CDMAEVDORevB = 5,  //电信3G RevB
    YS_DETAIL_Edge = 6,          //移动/联通E网 (2G网络)
    YS_DETAIL_GPRS = 7,          //移动/联通GPRS(2G网络)
    YS_DETAIL_HSDPA = 8,         //移动/联通3G网络  (虽然移动用的是td而不是wcdma但也算是3G)
    YS_DETAIL_HSUPA = 9,         //移动/联通3G网络
    YS_DETAIL_LTE = 10,          //4G网络
    YS_DETAIL_WCDMA= 11,         //3G网络
    YS_DETAIL_HRPD = 12,         //CDMA网络
    //大类 : 0没有网络 1为WIFI网络 2/6/7为2G网络  3/4/5/8/9/11/12为3G网络
    //10为4G网络
    //-1为不知名网络
    /**
     *  更大的划分为：大于1的都是WWAN网络
     */
};

typedef NS_ENUM(NSInteger, YSNetStatus) {
    YS_UnknowNetwork = -1,  //不知名网络
    YS_NoNetwork = 0,       //没有网络
    YS_WifiNetwork = 1,     //WIFI网络
    YS_WWANNetwork          //WWAN网络
};

@interface YSNetworkStatusMonitor : NSObject

/**
 *  获取网络状态及网络名称
 *
 *  @param block netName 网络名称：WWAN下是运营商名称，WIFI下是WIFI的MAC
 */
+(void)startMonitorWithBlock:(void(^)(YSNetStatus netStatus, NSString *netName, YSNetStatusDetail netStatusDetail))block;

@end
