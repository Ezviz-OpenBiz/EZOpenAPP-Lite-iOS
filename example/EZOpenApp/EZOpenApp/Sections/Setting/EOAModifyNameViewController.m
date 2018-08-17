//
//  EOAModifyNameViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/6.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAModifyNameViewController.h"
#import "EOADeviceInfo.h"
#import "EOACameraInfo.h"
#import "EOADeviceManager.h"

#define NAME_LIMIT_COUNT (50)//设备名称字数限制
#define INDICATOR_WH (60.0f)//等待动画宽高

@interface EOAModifyNameViewController () <UITextFieldDelegate>

@property (nonatomic,strong) EOADeviceInfo* deviceInfo;
@property (nonatomic,strong) EOACameraInfo* cameraInfo;
@property (nonatomic,assign) BOOL isPresent;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (nonatomic,strong) UIView *waitingBGView;
@property (nonatomic,strong) UIActivityIndicatorView *waitingAnimationView;

@end

@implementation EOAModifyNameViewController

+ (void) showModifyNameViewControllerFrom:(UIViewController *) fromVC cameraInfo:(EOACameraInfo *) cameraInfo isPresent:(BOOL) isPresent
{
    if (!fromVC || !cameraInfo)
    {
        return;
    }
    
    EOAModifyNameViewController *vc = [[EOAModifyNameViewController alloc] init];
    vc.cameraInfo = cameraInfo;
    vc.isPresent = isPresent;
    
    if (isPresent)
    {
        EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
        
        [fromVC presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        [fromVC.navigationController pushViewController:vc animated:YES];
    }
}

+ (void) showModifyNameViewControllerFrom:(UIViewController *) fromVC deviceInfo:(EOADeviceInfo *) deviceInfo isPresent:(BOOL) isPresent
{
    if (!fromVC || !deviceInfo)
    {
        return;
    }
    
    EOAModifyNameViewController *vc = [[EOAModifyNameViewController alloc] init];
    vc.deviceInfo = deviceInfo;
    vc.isPresent = isPresent;
    
    if (isPresent)
    {
        EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
        
        [fromVC presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        [fromVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.cameraInfo)
    {
        self.title = NSLocalizedString(@"setting_modify_camera_name_title", @"通道名称");
    }
    else
    {
        self.title = NSLocalizedString(@"setting_modify_device_name_title", @"设备名称");
    }
    
    [self addBarItems];
    [self addTouch];
    [self initSubviews];
    [self addNotifications];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //需在界面元素显示完成后再设置焦点，不然会引起界面异常
    [self.nameTextField becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self hideWaitingView];
}

#pragma mark - actions

- (void) backBtnClick:(id) sender
{
    [self.nameTextField resignFirstResponder];
    [self backProcess];
}

- (void) saveBtnClick:(id) sender
{
    [self.nameTextField resignFirstResponder];

    NSString *originalName = self.deviceInfo?self.deviceInfo.deviceName:self.cameraInfo.cameraName;

    //相同时，直接返回
    if ([self.nameTextField.text isEqualToString:originalName])
    {
        [self backProcess];
    }
    
    [self showWaitingView];
    __weak EOAModifyNameViewController *weakSelf = self;
    
    if (self.deviceInfo)
    {
        [[EOADeviceManager sharedInstance] changeDeviceNameWithSerial:self.deviceInfo.deviceSerial newName:self.nameTextField.text result:^(BOOL result) {
            
            [weakSelf hideWaitingView];
            
            if (result)
            {
                [weakSelf backProcess];
            }
        }];
    }
    else
    {
        [[EOADeviceManager sharedInstance] changeCameraNameWithSerial:self.cameraInfo.deviceSerial
                                                             cameraNo:self.cameraInfo.cameraNo
                                                              newName:self.nameTextField.text
                                                               result:^(BOOL result) {
                                                                   [weakSelf hideWaitingView];

                                                                   if (result)
                                                                   {
                                                                       [weakSelf backProcess];
                                                                   }
                                                               }];
    }
}

- (void) tapCallback:(UITapGestureRecognizer *) tap
{
    [self.nameTextField resignFirstResponder];
}

#pragma mark - notification

-(void)textFieldEditChanged:(NSNotification *) obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > NAME_LIMIT_COUNT)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:NAME_LIMIT_COUNT];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:NAME_LIMIT_COUNT];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, NAME_LIMIT_COUNT)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    else// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    {
        if (toBeString.length > NAME_LIMIT_COUNT)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:NAME_LIMIT_COUNT];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:NAME_LIMIT_COUNT];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, NAME_LIMIT_COUNT)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

#pragma mark - view

- (void) addBarItems
{
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_return"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backBtnClick:)];
    [leftBarBtnItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
    
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"setting_save",@"保存")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(saveBtnClick:)];
    [rightBarButtonItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void) initSubviews
{
    self.nameTextField.text = self.deviceInfo?self.deviceInfo.deviceName:self.cameraInfo.cameraName;
    self.tipLabel.text = NSLocalizedString(@"setting_modify_tip", @"50个字以内");
}

- (void) showWaitingView
{
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.waitingBGView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.waitingBGView.backgroundColor = [UIColor clearColor];
    [keyWindow addSubview:self.waitingBGView];
    
    self.waitingAnimationView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, INDICATOR_WH, INDICATOR_WH)];
    self.waitingAnimationView.center = self.waitingBGView.center;
    [self.waitingBGView addSubview:self.waitingAnimationView];
    [self.waitingAnimationView startAnimating];
    
    __weak EOAModifyNameViewController *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.waitingBGView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.4];
    }];
}

- (void) hideWaitingView
{
    if (self.waitingAnimationView)
    {
        [self.waitingAnimationView stopAnimating];
        [self.waitingAnimationView removeFromSuperview];
    }
    
    if (self.waitingBGView)
    {
        [self.waitingBGView removeFromSuperview];
    }
}

#pragma mark - support

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:self.nameTextField];
}

- (void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCallback:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void) backProcess
{
    if (self.isPresent || [self isEqual:[self.navigationController.viewControllers firstObject]])
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
