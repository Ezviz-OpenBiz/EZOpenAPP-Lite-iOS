//
//  EOADisplayImageView.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/13.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOADisplayImageView.h"
#import "UIImageView+WebCache.h"

#define DEFAULT_BG_COLOR ([UIColor colorWithWhite:0.0 alpha:0.0])
#define SHOW_BG_COLOR ([UIColor colorWithWhite:0.0 alpha:0.6])
#define ANIMATION_DURATION (0.2)
#define DEFAULT_IMAGE_WH (5)

@interface EOADisplayImageView ()

@property (nonatomic,copy) NSString *mImageUrl;
@property (nonatomic,strong) UIImage *mImage;
@property (nonatomic,strong) UIImageView *mImageView;

@end

@implementation EOADisplayImageView

- (instancetype)initWithFrame:(CGRect)frame imageUrl:(NSString *) imageUrl
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.mImageUrl = imageUrl;
        self.backgroundColor = DEFAULT_BG_COLOR;
        [self initSubviews];
        [self addTouch];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *) image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.mImage = image;
        self.backgroundColor = DEFAULT_BG_COLOR;
        [self initSubviews];
        [self addTouch];
    }
    return self;
}

- (void) showInView:(UIView *)view
{
    [view addSubview:self];
    __weak EOADisplayImageView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.backgroundColor = SHOW_BG_COLOR;
        weakSelf.mImageView.frame = weakSelf.bounds;
    }];
}

- (void) initSubviews
{
    self.mImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame)-DEFAULT_IMAGE_WH)/2,
                                                                    (CGRectGetHeight(self.frame)-DEFAULT_IMAGE_WH)/2,
                                                                    DEFAULT_IMAGE_WH, DEFAULT_IMAGE_WH)];
    if (self.mImage)
    {
        self.mImageView.image = self.mImage;
    }
    else
    {
        self.mImageView.image = [UIImage imageNamed:@"device_other"];
        [self.mImageView sd_setImageWithURL:[NSURL URLWithString:self.mImageUrl]];
    }
    self.mImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mImageView];
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCallback:)];
    
    [self addGestureRecognizer:tap];
}

- (void) tapCallback:(UITapGestureRecognizer *) tap
{
    __weak EOADisplayImageView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.backgroundColor = DEFAULT_BG_COLOR;
        weakSelf.mImageView.frame = CGRectMake((CGRectGetWidth(self.frame)-DEFAULT_IMAGE_WH)/2,
                                               (CGRectGetHeight(self.frame)-DEFAULT_IMAGE_WH)/2,
                                               DEFAULT_IMAGE_WH, DEFAULT_IMAGE_WH);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
