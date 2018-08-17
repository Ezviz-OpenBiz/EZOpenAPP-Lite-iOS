//
//  EZWifiInfoViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/29.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZWifiInfoViewController.h"
#import "EZWifiConfigViewController.h"
#import "EZAPWiFiConfigViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>


#define WIFI_PREFROOT_URL @"prefs:root=WIFI"
#define WIFI_IOS10_WIFI_URL @"App-Prefs:root=WIFI"

@interface EZWifiInfoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiSsidField;
@property (weak, nonatomic) IBOutlet UITextField *wifiPwdField;


@end

@implementation EZWifiInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    
    [self checkWiFiInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeNotifications];
}

#pragma mark - action

- (void) nextBtnClick
{
    if (self.isApMode)
    {
        EZAPWiFiConfigViewController *vc = [[EZAPWiFiConfigViewController alloc] init];
        vc.ssid = self.wifiSsidField.text;
        vc.password = self.wifiPwdField.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        EZWifiConfigViewController *vc = [[EZWifiConfigViewController alloc] init];
        vc.configMode = self.configMode;
        vc.wifiSsid = self.wifiSsidField.text;
        vc.wifiPwd = self.wifiPwdField.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - notification

- (void) applicationDidBecomeActive
{
    [self showWifiInfo];
    
    [self checkWiFiInfo];
}


#pragma mark - support

- (void)addNotifications
{
    [self removeNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *) getWiFiName
{
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    for (NSString *ifnam in interfaces)
    {
        NSDictionary *info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        if (info)
        {
            return info[@"SSID"];
        }
    }
    
    return nil;
}


- (void) checkWiFiInfo
{
    if (!self.wifiSsidField.text || self.wifiSsidField.text.length <= 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self showJumpSettingTip];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


#pragma mark - view

- (void) initSubviews
{
    [self createNextBtn];

    self.tipLabel.text = NSLocalizedString(@"ad_wifi_info_tip", @"如果你使用的是双频路由器，请不要让摄像机连接5G频段的Wi-Fi。");
    self.wifiPwdField.delegate = self;
    [self showWifiInfo];
}

- (void) showWifiInfo
{
    self.wifiSsidField.text = [self getWiFiName];
}

- (void) createNextBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"eoa_next", @"下一步")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(nextBtnClick)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) showJumpSettingTip
{
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:NSLocalizedString(@"eoa_alert_title",@"提示")
                                        message:NSLocalizedString(@"ad_wifi_info_no_wifi_msg", @"未连接Wi-Fi,请设置合适的Wi-Fi")
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel",@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_wifi_info_setting",@"设置")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         NSString *urlStr = [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0?WIFI_IOS10_WIFI_URL:WIFI_PREFROOT_URL;
                                                         
                                                         NSURL * url = [NSURL URLWithString:urlStr];
                                                         if([[UIApplication sharedApplication] canOpenURL:url])
                                                         {
                                                             [[UIApplication sharedApplication] openURL:url];
                                                         }
                                                     }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
