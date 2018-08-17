//
//  NSString+Utilities.m
//  VideoGo
//
//  Created by yudan on 14-4-8.
//
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)


/**
 *  判断是否纯数字
 *
 *  @return bool
 */
- (BOOL)isPureInt
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (NSString *)formartTelePhone
{
    NSString * notrailTemp = [self stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (notrailTemp.length < 4)
        return notrailTemp;
    
    
    else if (notrailTemp.length < 8)
    {
        NSString * tempStr = [NSString stringWithFormat:@"%@ %@",[notrailTemp substringToIndex:3],[notrailTemp substringFromIndex:3]];
        return tempStr;
    }
    else
    {
        NSString * tempStr = [NSString stringWithFormat:@"%@ %@ %@",[notrailTemp substringToIndex:3],[notrailTemp substringWithRange:NSMakeRange(3,4)],[notrailTemp substringFromIndex:7]];
        return tempStr;
    }
    
}

- (NSString *)formartHidePhone
{
    if (self.length < 11)
    {
        return self;
    }
    return  [self stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}

- (NSString *)deleteTrimmingWhitespaceCharacterSet
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)parseRTSPSuccess:(void(^)(NSString *ip,NSNumber *port))success
{
    if ([self length] > 0)
    {
        NSLog(@"vtduRedirectUrl : %@",self);
        NSArray *array = [self componentsSeparatedByString:@"/"];
        if (array.count < 3) return NO;
        
        array = [[array objectAtIndex:2] componentsSeparatedByString:@":"];
        if (array.count != 2) return NO;
        
        NSString *ip = [array firstObject];
        NSNumber *port = @([[array lastObject] intValue]);
        
        if (success) {
            success(ip,port);
        }
        return YES;
    }
    return NO;
}

- (NSString *)formatBSSID
{
    if (self.length == 0) {
        return self;
    }
    
    NSMutableArray *arrDes = [NSMutableArray array];
    NSArray *arr = [self componentsSeparatedByString:@":"];
    for (NSString *sep in arr) {
        if (sep.length == 0) { //应该没有空的情况吧。。预防一下
            [arrDes addObject:@"00"];
        }
        else if (sep.length == 1) {
            [arrDes addObject:[@"0" stringByAppendingString:sep]];
        }
        else {
            [arrDes addObject:sep];
        }
    }
    
    return [arrDes componentsJoinedByString:@":"];
}

- (BOOL)isIPAddress
{
    if (self.length <= 0) {
        return NO;
    }
    NSString *regex = [NSString stringWithFormat:@"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:self];
}


@end
