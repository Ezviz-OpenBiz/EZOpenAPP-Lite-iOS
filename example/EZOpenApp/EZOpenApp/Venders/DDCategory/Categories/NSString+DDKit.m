//
//  NSString+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "NSString+DDKit.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (DDKit)

@end

@implementation NSString (DDDate)

+ (NSString *)dd_formatInfoFromDate:(NSDate *)date {
    NSString *returnString = @"";
    NSTimeInterval time = fabs([[NSDate date] timeIntervalSinceDate:date]);
    if(time < 60)
        returnString = @"刚刚";
    else if(time >=60 && time < 3600)
        returnString = [NSString stringWithFormat:@"%.0f分钟前",time/60];
    else if(time >= 3600 && time < 3600 * 24)
        returnString = [NSString stringWithFormat:@"%.0f小时前",time/(60 * 60)];
    else if(time >= 3600 * 24 && time < 3600 * 24 * 30)
        returnString = [NSString stringWithFormat:@"%.0f天前",time/(60 * 60 * 24)];
    else if(time >= 3600 * 24 * 30 && time < 3600 * 24 * 30 * 12)
        returnString = [NSString stringWithFormat:@"%.0f月前",time/(60 * 60 * 24 * 30)];
    else if(time >= 3600 * 24 * 30 * 12)
        returnString = [NSString stringWithFormat:@"%.0f年前",time/(60 * 60 * 24 * 30 * 12)];
    return returnString;
}

+ (NSString *)dd_formatDateFromDate:(NSDate *)date {
    NSString *returnString = @"";
    NSTimeInterval time = fabs([[NSDate date] timeIntervalSinceDate:date]);
    if(time < 60)
        returnString = @"刚刚";
    else if(time >=60 && time < 3600)
        returnString = [NSString stringWithFormat:@"%.0f分钟前",time/60];
    else if(time >= 3600 && time < 3600 * 24)
        returnString = [NSString stringWithFormat:@"%.0f小时前",time/(60 * 60)];
    else if(time >= 3600 * 24 && time < 3600 * 24 * 3)
        returnString = [NSString stringWithFormat:@"%.0f天前",time/(60 * 60 * 24)];
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
        returnString = [formatter stringFromDate:date];
    }
    return returnString;
}


@end

@implementation NSString (DDPredicate)

+ (BOOL)dd_checkEmail:(NSString *)input {
    return [[self class] input:input andRegex:@"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"];
}

+ (BOOL)dd_checkChineseName:(NSString *)input {
    return [[self class] input:input andRegex:@"^[\u4E00-\uFA29]{2,8}$"];
}

+ (BOOL)dd_checkPhoneNumber:(NSString *)input {
    return [[self class] input:input andRegex:@"^(([0\\+]\\d{2,3}-?)?(0\\d{2,3})-?)?(\\d{7,8})"];
}

+ (BOOL)dd_checkMobileNumber:(NSString *)input {
    return [[self class] input:input andRegex:@"^1\\d{10}$"];
}

+ (BOOL)dd_checkValidateCode:(NSString *)input {
    return [[self class] input:input andRegex:@"(\\d{6})"];
}

+ (BOOL)dd_checkPassword:(NSString *)input {
    return [[self class] input:input andRegex:@"^\\w{6,20}"];
}

+ (BOOL)dd_checkWithDrawMoney:(NSString *)input {
    return [[self class] input:input andRegex:@"^[0-9]{3,}|[2-9][0-9]$"];
}

+ (BOOL)input:(NSString *)input andRegex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:input];
}

@end

@implementation NSString(md5)

- (NSString *)dd_md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

@end

@implementation NSString (subString)

- (NSString *)dd_getSubStringBeginKey:(NSString *)bKey endKey:(NSString *)eKey {
    if(bKey && eKey){
        NSRange rangeBegin = [self rangeOfString:bKey];
        NSRange rangeEnd = [self rangeOfString:eKey];
        if(rangeBegin.length > 0 && rangeEnd.length > 0){
            NSRange resultRange = NSMakeRange(rangeBegin.location+rangeBegin.length, rangeEnd.location - rangeBegin.location - rangeBegin.length);
            NSString *subString = [self substringWithRange:resultRange];
            return subString;
        }
        return nil;
    }else if(bKey && !eKey && [self rangeOfString:bKey].length > 0){
        NSRange rangeBegin = [self rangeOfString:bKey];
        return [self substringFromIndex:rangeBegin.location + rangeBegin.length];
    }else if(!bKey && eKey && [self rangeOfString:eKey].length > 0){
        NSRange rangeEnd = [self rangeOfString:eKey];
        return [self substringToIndex:rangeEnd.location + rangeEnd.length];
    }else{
        return nil;
    }
}

@end

@implementation NSString (DDPrice)

+ (NSString *)dd_formatPrice:(NSNumber *)price {
    price = @(price.floatValue);
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [NSString stringWithFormat:@"￥%@",[formatter stringFromNumber:price]];
}

@end


