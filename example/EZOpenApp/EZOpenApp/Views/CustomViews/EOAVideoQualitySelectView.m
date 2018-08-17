//
//  EOAVideoQualitySelectView.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//


#import "EOAVideoQualitySelectView.h"
#import "EOAVideoQualityInfo.h"

#define QUALITY_BTN_BASE_FLAG (334)

#define BUTTON_WIDTH (60.0f)
#define BUTTON_HEIGHT (35.0f)

@interface EOAVideoQualitySelectView ()

@property (nonatomic,strong) NSArray *qualityList;
@property (nonatomic,copy) void(^selectCallback)(NSInteger selectIndex);
@property (nonatomic,strong) NSMutableArray *btnList;
@property (nonatomic,assign) NSInteger curSelectedIndex;

@end

@implementation EOAVideoQualitySelectView


- (instancetype) initWithFrame:(CGRect)frame
                   qualityList:(NSArray *) qualityList
                 selectedIndex:(NSInteger) selectedIndex
                selectCallback:(void(^)(NSInteger selectIndex)) selectCallback
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.curSelectedIndex = selectedIndex;
        self.qualityList = qualityList;
        self.selectCallback = selectCallback;
        self.btnList = [NSMutableArray array];
        
        [self createSubviews];
    }
    return self;
}

- (void) selectAtIndex:(NSInteger) index
{
    if (index == self.curSelectedIndex)
    {
        return;
    }
    
    self.curSelectedIndex = index;

    for (int i = 0;i < self.btnList.count;i++)
    {
        UIButton *tempBtn = [self.btnList objectAtIndex:i];
        
        if (i == self.curSelectedIndex)
        {
            [self changeBtn:tempBtn selected:YES];
        }
        else
        {
            [self changeBtn:tempBtn selected:NO];
        }
    }
}

- (void) setBtnsEnable:(BOOL) enable
{
    for (UIButton *btn in self.btnList)
    {
        btn.enabled = enable;
    }
}

#pragma mark - action

- (void) qualityBtnClick:(UIButton *) btn
{
    NSInteger index = btn.tag - QUALITY_BTN_BASE_FLAG;
    if (self.curSelectedIndex == index)
    {
        return;
    }
    
    if (self.selectCallback)
    {
        self.selectCallback(index);
    }
}

#pragma mark - view

- (void) createSubviews
{
    NSInteger count = self.qualityList.count;
    
    CGFloat perAreaWidth = CGRectGetWidth(self.frame)/count;
    CGFloat py = (CGRectGetHeight(self.frame) - BUTTON_HEIGHT)/2;
    CGFloat px = (perAreaWidth - BUTTON_WIDTH)/2;
    
    for (int i = 0; i < self.qualityList.count; i ++)
    {
        EOAVideoQualityInfo *qualityInfo = [self.qualityList objectAtIndex:i];
        CGRect frame = CGRectMake(i*perAreaWidth+px, py, BUTTON_WIDTH, BUTTON_HEIGHT);
        
        UIButton *btn = [self createBtnWithFrame:frame qualityInfo:qualityInfo];
        if (i == self.curSelectedIndex)
        {
            [self changeBtn:btn selected:YES];
        }
        
        [self addSubview:btn];
        [self.btnList addObject:btn];
    }
}

- (UIButton *) createBtnWithFrame:(CGRect) frame qualityInfo:(EOAVideoQualityInfo *) qualityInfo
{
    if (!qualityInfo)
    {
        return nil;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = QUALITY_BTN_BASE_FLAG + [self.qualityList indexOfObject:qualityInfo];
    [btn setTitle:qualityInfo.videoQualityName forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.layer.borderWidth = 0.0;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.cornerRadius = 5.0f;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(qualityBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void) changeBtn:(UIButton *) btn selected:(BOOL) selected
{
    btn.layer.borderWidth = selected?1.0:0.0;
}

@end
