//
//  NSString+Utilities.h
//  VideoGo
//
//  Created by yudan on 14-4-8.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)


/**
 *  判断是否纯数字
 *
 *  @return bool
 */
- (BOOL)isPureInt;

/**
 *  手机号格式化
 *  3-4-4
 *  @return eg: 150 6882 2991
 */
- (NSString *)formartTelePhone;

/**
 *  手机号格式化
 *
 *  @return eg 150****3723
 */
- (NSString *)formartHidePhone;
/**
 *  去除空格
 *
 *  @return
 */
- (NSString *)deleteTrimmingWhitespaceCharacterSet;

/**
 *  RTSP url string解析出ip和port
 */
- (BOOL)parseRTSPSuccess:(void(^)(NSString *ip,NSNumber *port))success;

/**
 *  BSSID防止一位
 *
 *  @return
 */
- (NSString *)formatBSSID;

/**
 *  是否IP
 */
- (BOOL)isIPAddress;



@end
