//
//  EOAScrollBar.m
//  EZOpenApp
//
//  Created by linyong on 15/4/17.
//  Copyright (c) 2015年 hikvision. All rights reserved.
//

#import "EOAScrollBar.h"


#define FLAG_VIEW_HEIGHT (3)
#define SCROLL_BAR_BASE_TAG (445)

@implementation EOAScrollBar
{
    id<EOAScrollBarDelegate> _target;
    UIView *_flagView;
    NSArray *_titleList;
    CGFloat _originalOffset;
    NSInteger _selectedIndex;
}

@synthesize selectedIndex = _selectedIndex;
@synthesize titleList = _titleList;

- (id) initWithTarget:(id<EOAScrollBarDelegate>) target
                frame:(CGRect) frame
               titles:(NSArray *) titles
        selectedIndex:(NSInteger) selectedIndex
{
    self = [super init];
    if (self)
    {
        _selectedIndex = selectedIndex;
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        if (titles)
        {
           _titleList = [titles copy];
        }
        
        _target = target;
        _originalOffset = 0;
        [self createContentViews];
    }
    return self;
}

- (void) selectAtIndex:(NSInteger) index
{
    if (!_titleList || _titleList.count == 0)
    {
        return;
    }
    
    _selectedIndex = index;
    for (int i = 0; i < _titleList.count; i++)
    {
        UIButton *btn = [self getTabBtnByTag:SCROLL_BAR_BASE_TAG+i];
        if (!btn)
        {
            return;
        }
        
        btn.selected = NO;
        if (i == index)
        {
            btn.selected = YES;
        }
    }
}

- (void) flagScrollToOffset:(CGFloat) offset
{
    if (!_flagView)
    {
        return;
    }
    
    _flagView.frame = CGRectMake(_originalOffset + offset*(CGRectGetWidth(_flagView.frame)+2*_originalOffset)*_titleList.count,
                                 _flagView.frame.origin.y,
                                 _flagView.frame.size.width,
                                 _flagView.frame.size.height);
    
}

- (void) setTabTitleFont:(UIFont *) font
{
    if (!font)
    {
        return;
    }
    
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *) view;
            btn.titleLabel.font = font;
        }
    }
}

- (void) setTabTitleColor:(UIColor *) color forState:(UIControlState) state
{
    if (!color)
    {
        return;
    }
    
    for(UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *tempBtn = (UIButton*)view;
            [tempBtn setTitleColor:color forState:state];
        }
    }
}

- (void) setTabTitleIndicatorColor:(UIColor *) color
{
    if (!color)
    {
        return;
    }
    _flagView.backgroundColor = color;
}

#pragma mark - private method

- (void) createContentViews
{
    if (!_titleList || _titleList.count ==0)
    {
        return;
    }
    
    CGRect tempRect = CGRectZero;
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
//    backgroundView.backgroundColor = [UIColor clearColor];
//    backgroundView.image = [UIImage imageNamed:@""];
//    [self addSubview:backgroundView];
    
    
    CGFloat tempWidth = CGRectGetWidth(self.frame)/_titleList.count;
    CGFloat tempHeight = self.bounds.size.height - FLAG_VIEW_HEIGHT;
    
    for (int i = 0; i < _titleList.count; i++)
    {
        tempRect = CGRectMake(i*tempWidth, 0, tempWidth, tempHeight);
        [self addTabButtonByTitle:[_titleList objectAtIndex:i] frame:tempRect tag:SCROLL_BAR_BASE_TAG+i];
    }
    
    if (CGRectGetWidth(self.frame) >= EOA_SCREEN_WIDTH)
    {
        _originalOffset = tempWidth/5;
    }
    else
    {
        _originalOffset = 0;
    }
    
    tempRect = CGRectMake(_originalOffset+_selectedIndex*tempWidth, tempHeight, tempWidth-2*_originalOffset, FLAG_VIEW_HEIGHT);
    _flagView = [[UIView alloc] initWithFrame:tempRect];
    _flagView.backgroundColor = UIColorFromRGB(0xf08300,1.0);
    [self addSubview:_flagView];
}

- (void) addTabButtonByTitle:(NSString *) title frame:(CGRect) frame tag:(NSInteger) tag
{
    UIButton *tabBtn = [[UIButton alloc] initWithFrame:frame];
    tabBtn.tag = tag;
    if (tag == SCROLL_BAR_BASE_TAG + _selectedIndex)
    {
        tabBtn.selected = YES;
    }
    tabBtn.backgroundColor = [UIColor clearColor];
    tabBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    tabBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tabBtn setTitle:title forState:UIControlStateNormal];
    [tabBtn setTitleColor:UIColorFromRGB(0x404040, 1.0f) forState:UIControlStateNormal];
    [tabBtn setTitleColor:UIColorFromRGB(0xf08300,1.0) forState:UIControlStateSelected];
    [tabBtn setTitleColor:UIColorFromRGB(0xf08300,1.0) forState:UIControlStateHighlighted];
    [tabBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tabBtn];
}

- (UIButton *) getTabBtnByTag:(NSInteger) tag
{
    for (UIView *view in self.subviews)
    {
        if([view isKindOfClass:[UIButton class]] && view.tag == tag)
        {
            return (UIButton*)view;
        }
    }
    
    return nil;
}

#pragma mark - button callback
- (void) btnClick:(UIButton *) btn
{
    if ([_target respondsToSelector:@selector(tabButtonClickByIndex:)])
    {
        [_target tabButtonClickByIndex:btn.tag - SCROLL_BAR_BASE_TAG];
    }
}


@end
