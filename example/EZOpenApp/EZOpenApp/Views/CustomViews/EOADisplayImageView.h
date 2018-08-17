//
//  EOADisplayImageView.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/13.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOADisplayImageView : UIView

- (instancetype)initWithFrame:(CGRect)frame imageUrl:(NSString *) imageUrl;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *) image;

- (void) showInView:(UIView*) view;

@end
