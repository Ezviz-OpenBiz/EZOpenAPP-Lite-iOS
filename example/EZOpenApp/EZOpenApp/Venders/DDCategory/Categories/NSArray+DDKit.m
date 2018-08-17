//
//  NSArray+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15/4/25.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "NSArray+DDKit.h"

@implementation NSArray (DDKit)

- (id)dd_objectAtIndex:(NSUInteger)index {
    if (index >= [self count]) {
        return nil;
    }
    
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

@end
