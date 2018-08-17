//
//  EOAWaitView.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/11.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAWaitView.h"

#define INDICATOR_WH (50)
#define ANIMATION_DURATION (0.2)
#define DEFAULT_COLOR ([UIColor colorWithWhite:0.0 alpha:0.0])
#define SHOW_COLOR ([UIColor colorWithWhite:0.0 alpha:0.4])

static EOAWaitView *gEOAWaitView = nil;

@interface EOAWaitView ()

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@end

@implementation EOAWaitView

+ (void) showWaitViewInView:(UIView *) view frame:(CGRect) frame
{
    if (gEOAWaitView)
    {
        [gEOAWaitView hideWaitView];
        gEOAWaitView = nil;
    }
    
    gEOAWaitView = [[EOAWaitView alloc] initWithFrame:frame];
    
    [gEOAWaitView showWaitViewInView:view];
}

+ (void) hideWaitView
{
    if (!gEOAWaitView)
    {
        return;
    }
    
    [gEOAWaitView hideWaitView];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = DEFAULT_COLOR;
        [self initSubviews];
    }
    return self;
}

- (void) showWaitViewInView:(UIView *) view
{
    [view addSubview:self];
    
    __weak EOAWaitView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.backgroundColor = SHOW_COLOR;
    }];
}

- (void) hideWaitView
{
    __weak EOAWaitView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.backgroundColor = DEFAULT_COLOR;
    } completion:^(BOOL finished)
    {
        [weakSelf.indicatorView stopAnimating];
        [weakSelf removeFromSuperview];
    }];
}

- (void) initSubviews
{
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-INDICATOR_WH)/2,
                                                                                   (CGRectGetHeight(self.frame)-INDICATOR_WH)/2,
                                                                                   INDICATOR_WH, INDICATOR_WH)];
    [self addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

@end
