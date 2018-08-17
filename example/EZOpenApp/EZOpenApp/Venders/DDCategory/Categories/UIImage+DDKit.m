//
//  UIImage+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 14-12-21.
//  Copyright (c) 2014年 DDKit. All rights reserved.
//

#import "UIImage+DDKit.h"

@implementation UIImage (DDKit)

+ (UIImage *)dd_createImageWithCGSize:(CGSize)size color:(UIColor *)color{
    CGSize imageSize = size;
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)dd_navigationBarBackButton
{
    CGSize size = CGSizeMake(18.0, 30.0);
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [[UIColor clearColor] set];
    UIRectFill(CGRectMake(0, 0, 18.0, 30.0));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2.5);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);

    //左上角
    CGPoint pointsTopLeftA[] = {
        CGPointMake(1, 15.5),
        CGPointMake(10, 6)
    };
    
    CGPoint pointsTopLeftB[] = {
        CGPointMake(1, 14.5),
        CGPointMake(10, 24)
    };
    [self addLine:pointsTopLeftA pointB:pointsTopLeftB ctx:ctx];
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

@end
