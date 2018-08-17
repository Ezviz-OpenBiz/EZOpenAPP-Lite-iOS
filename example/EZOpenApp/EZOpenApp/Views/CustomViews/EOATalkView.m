//
//  EOATalkView.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/11.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOATalkView.h"

#define ANIMATION_DURATION (0.3)
#define TALK_BUTTON_WH (100)
#define CANCEL_BUTTON_WH (30)

static EOATalkView *gTalkView = nil;

@interface EOATalkView ()

@property (nonatomic,copy) void(^talkCallback)(BOOL pressed);
@property (nonatomic,copy) void(^cancelCallback)();
@property (nonatomic,strong) UIButton *talkBtn;
@property (nonatomic,assign) EOATalkMode talkMode;

@end

@implementation EOATalkView

+ (void) showTalkViewFromView:(UIView *) view
                        frame:(CGRect) frame
                     talkMode:(EOATalkMode) mode
               cancelCallback:(void(^)()) cancelCallback
                 talkCallback:(void(^)(BOOL pressed)) talkCallback
{
    if (gTalkView || mode == 0)
    {
        return;
    }
    
    gTalkView = [[EOATalkView alloc] initWithFrame:frame];
    gTalkView.talkCallback = talkCallback;
    gTalkView.cancelCallback = cancelCallback;
    [gTalkView updatePressBtnWithMode:mode];
    
    [gTalkView showInView:view];
}

+ (void) hideTalkView
{
    if (!gTalkView)
    {
        return;
    }
    
    [gTalkView hideTalkView];
    gTalkView = nil;
    
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    [self createCancelBtn];
    [self createTalkBtn];
}

- (void) createCancelBtn
{
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-CANCEL_BUTTON_WH-10, 10, CANCEL_BUTTON_WH, CANCEL_BUTTON_WH);
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_delete"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:cancelBtn];
}

- (void) createTalkBtn
{
    self.talkBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.talkBtn.frame = CGRectMake((CGRectGetWidth(self.frame)-TALK_BUTTON_WH)/2,
                                    (CGRectGetHeight(self.frame)-TALK_BUTTON_WH)/2,
                                    TALK_BUTTON_WH, TALK_BUTTON_WH);
    self.talkBtn.layer.masksToBounds = YES;
    self.talkBtn.layer.cornerRadius = TALK_BUTTON_WH/2;
    self.talkBtn.backgroundColor = UIColorFromRGB(0xF37F4C,1.0);
    [self.talkBtn setTintColor:[UIColor whiteColor]];
    [self.talkBtn addTarget:self action:@selector(talkBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [self.talkBtn addTarget:self action:@selector(talkBtnTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.talkBtn];
}

- (void) updatePressBtnWithMode:(EOATalkMode) mode
{
    self.talkMode = mode;
    self.talkBtn.userInteractionEnabled = self.talkMode == EOA_TALK_SINGLE;
    if (self.talkMode == EOA_TALK_DOUBLE)
    {
        [self.talkBtn setTitle:NSLocalizedString(@"realplay_talking", @"对讲中") forState:UIControlStateNormal];
    }
    else if(self.talkMode == EOA_TALK_SINGLE)
    {
        [self.talkBtn setTitle:NSLocalizedString(@"realplay_press_talk", @"按住说话") forState:UIControlStateNormal];
        [self.talkBtn setTitle:NSLocalizedString(@"realplay_talking", @"对讲中") forState:UIControlStateHighlighted];
    }
    else
    {
        
    }
}

- (void) cancelBtnClick:(UIButton *) btn
{
    if (self.cancelCallback)
    {
        self.cancelCallback();
    }
}

- (void) talkBtnPressed:(UIButton *) btn
{
    if (self.talkCallback)
    {
        self.talkCallback(YES);
    }
}

- (void) talkBtnTouchUp:(UIButton *) btn
{
    if (self.talkCallback)
    {
        self.talkCallback(NO);
    }
}

- (void) showInView:(UIView *) view
{
    [view addSubview:self];
    
    CGRect rect = self.frame;
    __weak EOATalkView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.frame = CGRectMake(CGRectGetMinX(rect),
                                    CGRectGetMinY(rect)-CGRectGetHeight(rect),
                                    CGRectGetWidth(rect),
                                    CGRectGetHeight(rect));
    }];
}

- (void) hideTalkView
{
    CGRect rect = self.frame;
    __weak EOATalkView *weakSelf = self;
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        weakSelf.frame = CGRectMake(CGRectGetMinX(rect),
                                    CGRectGetMinY(rect)+CGRectGetHeight(rect),
                                    CGRectGetWidth(rect),
                                    CGRectGetHeight(rect));
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
