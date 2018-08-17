//
//  EZQRView.m
//  EZOpenSDKDemo
//
//  Created by DeJohn Dong on 15/10/29.
//  Copyright © 2015年 hikvision. All rights reserved.
//

#import "EZQRView.h"

@implementation EZQRView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupUI];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    //整个二维码扫描界面的颜色
    CGSize screenSize = self.bounds.size;
    CGRect screenDrawRect = CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - self.clearSize.width / 2,
                                      screenDrawRect.size.height / 3 - self.clearSize.height / 2,
                                      self.clearSize.width,self.clearSize.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
}


#pragma mark - Custom Methods

- (void)setupUI
{
    
}

#pragma mark - Draw Methods

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    
    CGContextSetRGBFillColor(ctx, 40/255.0, 40/255.0, 40/255.0, 0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, 3);
    CGContextSetRGBStrokeColor(ctx, 255/255.0, 84/255.0, 0/255.0, 1);//绿色
    
    //左上角
    CGPoint pointsTopLeftA[] = {
        CGPointMake(rect.origin.x + 0.7, rect.origin.y),
        CGPointMake(rect.origin.x + 0.7 , rect.origin.y + 15)
    };
    
    CGPoint pointsTopLeftB[] = {
        CGPointMake(rect.origin.x, rect.origin.y + 0.7),
        CGPointMake(rect.origin.x + 15, rect.origin.y + 0.7)
    };
    [self addLine:pointsTopLeftA pointB:pointsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint pointsBottomLeftA[] = {
        CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height - 15),
        CGPointMake(rect.origin.x + 0.7, rect.origin.y + rect.size.height)
    };
    CGPoint pointsBottomLeftB[] = {
        CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7),
        CGPointMake(rect.origin.x + 15.7, rect.origin.y + rect.size.height - 0.7)
    };
    [self addLine:pointsBottomLeftA pointB:pointsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint pointsTopRightA[] = {
        CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + 0.7),
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + 0.7 )
    };
    CGPoint pointsTopRightB[] = {
        CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y),
        CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y + 15.7 )
    };
    [self addLine:pointsTopRightA pointB:pointsTopRightB ctx:ctx];
    
    //右下角
    CGPoint pointsBottomRightA[] = {
        CGPointMake(rect.origin.x + rect.size.width - 0.7, rect.origin.y +rect.size.height - 15),
        CGPointMake(rect.origin.x - 0.7 + rect.size.width, rect.origin.y +rect.size.height)
    };
    CGPoint pointsBottomRightB[] = {
        CGPointMake(rect.origin.x + rect.size.width - 15, rect.origin.y + rect.size.height - 0.7),
        CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.7)
    };
    [self addLine:pointsBottomRightA pointB:pointsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}


@end
