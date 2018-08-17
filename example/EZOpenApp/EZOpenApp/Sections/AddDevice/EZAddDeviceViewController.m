//
//  EZAddDeviceViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZAddDeviceViewController.h"
#import "EDHelper.h"
#import "Toast+UIView.h"

#import "EZOpenSDK.h"

@interface EZAddDeviceViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation EZAddDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addDevice];
}
- (void) showLoading
{
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void) hideLoading
{
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

- (void) showToastWithText:(NSString *) text
{
    if (!text)
    {
        return;
    }
    
    [self.view makeToast:text duration:2.0 position:@"center"];
}

- (void) showSuccessAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"eoa_alert_title", @"提示")
                                                                   message:NSLocalizedString(@"ad_add_device_success",@"添加设备成功，返回设备列表。")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_ok",@"确定")
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [self returnToDeviceList];
                                                 }];
    
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) returnToDeviceList
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) addDevice
{
    [self showLoading];
    [EZOpenSDK addDevice:[EDHelper sharedInstance].deviceSerial
              verifyCode:[EDHelper sharedInstance].verifyCode
              completion:^(NSError *error) {
                 
                  [self hideLoading];
                 
                  if (error)
                  {
                      [self showToastWithText:[error description]];
                      return;
                  }
                 
                  [EDHelper sharedInstance].needRefreshDeviceList = YES;
                  [self showSuccessAlert];
              }];
}

@end
