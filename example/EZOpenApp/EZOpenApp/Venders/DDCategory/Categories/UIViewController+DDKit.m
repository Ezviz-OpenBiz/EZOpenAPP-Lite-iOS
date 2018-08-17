//
//  UIViewController+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-18.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "UIViewController+DDKit.h"

@implementation UIViewController (DDKit)

+ (instancetype)dd_loadWithNib{
    return [[[self class] alloc] initWithNibName:[self description] bundle:nil];
}

@end
