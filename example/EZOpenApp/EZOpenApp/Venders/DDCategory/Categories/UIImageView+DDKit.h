//
//  UIImageView+DDKit.h
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (DDKit)

@end


@interface UIImageView (DDPlaceholder)

/**
 *  Set a web-cache imageView can use an scale placeholder image;
 *
 *  @param url         The web image url
 *  @param placeholder The place holder image can scale
 */
- (void)sd_setImageWithURL:(NSURL *)url
     placeholderImageScale:(UIImage *)placeholder;

@end