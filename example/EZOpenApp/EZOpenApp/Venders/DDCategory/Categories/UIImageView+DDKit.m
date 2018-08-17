//
//  UIImageView+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "UIImageView+DDKit.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (DDKit)

@end


@implementation UIImageView (DDPlaceholder)

- (void)sd_setImageWithURL:(NSURL *)url placeholderImageScale:(UIImage *)placeholder{
    placeholder = [self scaleImage:placeholder];
    [self sd_setImageWithURL:url placeholderImage:placeholder];
}

- (UIImage *)scaleImage:(UIImage *)originImage{
    CGSize imageSize = self.frame.size;
    //判断图片尺寸是否小于UIImageView的尺寸
    if(imageSize.width <= originImage.size.width ||
       imageSize.height <= originImage.size.height)
        return originImage;
    //绘制新的图片
    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
    [[UIColor colorWithRed:238.0/255.0f green:238.0/255.0f blue:238.0/255.0f alpha:1.0f] set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    [originImage drawAtPoint:CGPointMake((imageSize.width - originImage.size.width)/2.0f, (imageSize.height - originImage.size.height)/2.0f)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end