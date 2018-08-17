//
//  EZWifiConfigViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZWifiConfigViewController.h"
#import "EDHelper.h"
#import "Toast+UIView.h"
#import "EZAddDeviceViewController.h"

@interface EZWifiConfigViewController ()

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadIndicator;

@end

@implementation EZWifiConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    
    [self configWifi];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[EZWiFiConfigManager sharedInstance] stopWifiConfig];
}

#pragma mark - action

- (void) addBtnClick
{
    EZAddDeviceViewController *vc = [[EZAddDeviceViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - view

- (void) initSubviews
{
    [self createAddBtn];

    [self changeMsgWithText:NSLocalizedString(@"ad_wifi_configing", @"配置网络中...")];
}

- (void) createAddBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ad_wifi_add_device_title", @"添加设备")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) enableAddBtn
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) showLoading
{
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];
}

- (void) hideLoading
{
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
}

- (void) changeMsgWithText:(NSString *) text
{
    self.msgLabel.text = text;
}

- (void) showToastWithText:(NSString *) text
{
    if (!text)
    {
        return;
    }
    
    [self.view makeToast:text duration:2.0 position:@"center"];
}


#pragma mark - support

- (void) configWifi
{
    [self showLoading];
    [[EZWiFiConfigManager sharedInstance] startWifiConfigWithWifiSsid:self.wifiSsid
                                                              wifiPwd:self.wifiPwd
                                                         deviceSerial:[EDHelper sharedInstance].deviceSerial
                                                                 mode:self.configMode
                                                               reuslt:^(EZWifiConfigStatus status, NSString *deviceSerial, NSError *error) {
                                                                   
                                                                   if (error)
                                                                   {
                                                                       [[EZWiFiConfigManager sharedInstance] stopWifiConfig];
                                                                       [self hideLoading];
                                                                       [self showToastWithText:[error description]];
                                                                       return;
                                                                   }
                                                                   
                                                                   if (status == DEVICE_WIFI_CONNECTING)
                                                                   {
                                                                       [self changeMsgWithText:NSLocalizedString(@"ad_device_conneting", @"Wi-Fi连接中...")];
                                                                   }
                                                                   else if (status == DEVICE_WIFI_CONNECTED)
                                                                   {
                                                                       [self changeMsgWithText:NSLocalizedString(@"ad_device_conneted", @"Wi-Fi连接成功")];
                                                                   }
                                                                   else if (status == DEVICE_PLATFORM_REGISTED)
                                                                   {
                                                                       [[EZWiFiConfigManager sharedInstance] stopWifiConfig];

                                                                       [self changeMsgWithText:NSLocalizedString(@"ad_device_registered", @"注册平台成功")];
                                                                       [self hideLoading];
                                                                       [self enableAddBtn];
                                                                   }
                                                                   else
                                                                   {
                                                                       
                                                                   }
                                                                       
                                                               }];
}


@end
