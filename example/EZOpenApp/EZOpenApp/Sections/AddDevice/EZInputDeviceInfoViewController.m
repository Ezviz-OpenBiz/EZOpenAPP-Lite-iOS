//
//  EZInputDeviceInfoViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZInputDeviceInfoViewController.h"
#import "EZSearchResultViewController.h"
#import "EDHelper.h"

@interface EZInputDeviceInfoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *serialTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;


@end

@implementation EZInputDeviceInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initSubviews];
}

#pragma mark - actions

- (void) nextBtnClick
{
    [EDHelper sharedInstance].deviceSerial = self.serialTextField.text;
    [EDHelper sharedInstance].verifyCode = self.codeTextField.text;
    
    [self gotoSearchViewController];
}

#pragma mark - view

- (void) initSubviews
{
    self.title = NSLocalizedString(@"ad_input_manual", @"手动输入");
    [self createNextBtn];

    self.serialTextField.placeholder = NSLocalizedString(@"ad_input_serial_hold", @"设备序列号");
    self.serialTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.serialTextField.leftViewMode = UITextFieldViewModeAlways;
    self.serialTextField.delegate = self;
    
    self.codeTextField.placeholder = NSLocalizedString(@"ad_input_code_hold", @"设备验证码");
    self.codeTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.codeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.codeTextField.delegate = self;
}

- (void) createNextBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"eoa_next", @"下一步")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(nextBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - support

- (void) gotoSearchViewController
{
    EZSearchResultViewController *vc = [[EZSearchResultViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) checkContent
{
    if (self.serialTextField.text.length == 9 && self.codeTextField.text.length == 6)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.serialTextField isEqual:textField])
    {
        [self checkContent];
        
        NSString *strTemp = [NSString stringWithFormat:@"%@%@", textField.text, string];
        if ([strTemp length] > 9)
        {
            return NO;
        }
    }
    else if ([self.codeTextField isEqual:textField])
    {
        [self checkContent];
        
        NSString *strTemp = [NSString stringWithFormat:@"%@%@", textField.text, string];
        if ([strTemp length] > 6)
        {
            return NO;
        }
    }
    
    return YES;
}


@end
