//
//  UIButton+DDKit.m
//  DDCategory
//
//  Created by DeJohn Dong on 15-3-20.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "UIButton+DDKit.h"

@implementation UIButton (DDKit)

@end

@implementation UIButton (DDBadgeView)

- (UIView *)dd_showBadgeValue:(NSString *)strBadgeValue
{
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    NSArray *array = [[NSArray alloc] initWithObjects:item, nil];
    tabBar.items = array;
    //寻找
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //从原视图上移除
                [subview removeFromSuperview];
                //
                [self addSubview:subview];
                subview.frame = CGRectMake(self.frame.size.width-subview.frame.size.width, 0, subview.frame.size.width, subview.frame.size.height);
                return subview;
            }
        }
    }
    return nil;
}

- (void)dd_removeBadgeValue
{
    //
    for (UIView *subview in self.subviews) {
        NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
        if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
            [strClassName isEqualToString:@"_UIBadgeView"]) {
            [subview removeFromSuperview];
            break;
        }
    }
}

- (UIView *)dd_showBadgeValue:(NSString *)strBadgeValue andPadding:(CGPoint)point
{
    [self dd_removeBadgeValue];
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:nil tag:0];
    item.badgeValue = strBadgeValue;
    NSArray *array = [[NSArray alloc] initWithObjects:item, nil];
    tabBar.items = array;
    //search the view
    for (UIView *viewTab in tabBar.subviews) {
        for (UIView *subview in viewTab.subviews) {
            NSString *strClassName = [NSString stringWithUTF8String:object_getClassName(subview)];
            if ([strClassName isEqualToString:@"UITabBarButtonBadge"] ||
                [strClassName isEqualToString:@"_UIBadgeView"]) {
                //remove from the origin view.
                [subview removeFromSuperview];
                
                [self addSubview:subview];
                subview.frame = CGRectMake(self.frame.size.width-subview.frame.size.width - point.x, 0 + point.y, subview.frame.size.width, subview.frame.size.height);
                return subview;
            }
        }
    }
    return nil;
}

@end

@implementation UIButton (DDButtonCenterStyle)

- (void)dd_centerImageAndTitle:(float)spacing
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = CGSizeZero;
    if([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        titleSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    }
    else
    {
        titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    }
    
    // check if the size.width is more than the frame.size.width
    titleSize = titleSize.width > self.frame.size.width ? CGSizeMake(self.frame.size.width, titleSize.height):titleSize;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(
                                            - (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width - (titleSize.width/imageSize.width >=2 ));
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(
                                            0.0, - imageSize.width, - (totalHeight - titleSize.height), 0.0);
}

- (void)dd_centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self dd_centerImageAndTitle:DEFAULT_SPACING];
}

@end