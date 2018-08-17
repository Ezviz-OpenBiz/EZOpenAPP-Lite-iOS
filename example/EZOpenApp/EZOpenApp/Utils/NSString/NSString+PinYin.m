//
//  NSString+PinYin.m
//  SZLAddressBookDemo
//
//  Created by mr.shi on 15/8/30.
//  Copyright (c) 2015年 zhil.shi. All rights reserved.
//

#import "NSString+PinYin.h"
#import "pinyin.h"
@implementation NSString(PinYin)

- (NSString *)transToPinyinStr
{
    if ([self isEqualToString:@""])
    {
        return self;
    }
    NSString *sourceString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    sourceString = [sourceString uppercaseString];
    
    // 特殊字处理 系统转换
    if (([sourceString rangeOfString:@"呵"].length > 0))
    {
        sourceString = [sourceString stringByReplacingOccurrencesOfString:@"呵" withString:@"HE"];
    }
    
    
    NSMutableString *source = [NSMutableString stringWithString:sourceString];

    // 汉子转化成拼音
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    // 特殊子处理
    if ([[(NSString *)sourceString substringToIndex:1] compare:@"长"] == NSOrderedSame)
    {
        [source replaceCharactersInRange:NSMakeRange(0, 5)withString:@"chang"];
    }
    
    if ([[(NSString *)sourceString substringToIndex:1] compare:@"沈"] == NSOrderedSame)
    {
        [source replaceCharactersInRange:NSMakeRange(0, 4)withString:@"shen"];
    }
    
    if ([[(NSString *)sourceString substringToIndex:1] compare:@"厦"] == NSOrderedSame)
    {
        [source replaceCharactersInRange:NSMakeRange(0, 3)withString:@"xia"];
    }
    
    if ([[(NSString *)sourceString substringToIndex:1] compare:@"地"] == NSOrderedSame)
    {
        [source replaceCharactersInRange:NSMakeRange(0, 2)withString:@"di"];
    }
    
    if ([[(NSString *)sourceString substringToIndex:1] compare:@"重"] == NSOrderedSame)
    {
        [source replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chong"];
    }
    
    NSString *pinyinStr = source;
    
    if (source &&source.length)
    {
        pinyinStr = [source stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return pinyinStr;
}

- (NSString *)letterChar
{
    if (!self || self.length == 0)
    {
        return @"#";
    }
    
    if ([self isFirstChar])
    {
        return [[self substringToIndex:1] uppercaseString];
    }
    else
    {
        return  [[NSString stringWithFormat:@"%c",pinyinFirstLetter([self  characterAtIndex:0])]uppercaseString];
    }
    
}
- (BOOL)isFirstChar
{
    if (!self || self.length == 0)
    {
        return NO;
    }
    
    NSString *firstChar = [[self substringToIndex:1] uppercaseString];
    NSString *regex = @"^[A-Za-z]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:firstChar];
}
@end
