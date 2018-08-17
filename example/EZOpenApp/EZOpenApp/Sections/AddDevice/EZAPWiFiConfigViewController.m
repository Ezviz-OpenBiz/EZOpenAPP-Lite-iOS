//
//  EZAPWiFiConfigViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/4.
//  Copyright © 2018年 hikvision. All rights reserved.
//

#import "EZAPWiFiConfigViewController.h"
#import "EZAddDeviceViewController.h"
#import "EDHelper.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "EZWiFiConfigManager.h"
#import "Toast+UIView.h"

#define WIFI_PREFROOT_URL @"prefs:root=WIFI"
#define WIFI_IOS10_WIFI_URL @"App-Prefs:root=WIFI"

@interface EZAPWiFiConfigViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepTwoLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *processingIndicator;

@property (nonatomic,copy) NSString *devicWifiName;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation EZAPWiFiConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ad_ap_wifi_connect",@"连接到设备Wi-Fi");

    [self initSubviews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startTimer];
    [self addNotifications];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
    [self stopConfigWifi];
    [self removeNotifications];
}

#pragma mark - views

- (void) initSubviews
{
    [self createAddBtn];
    
    self.processingIndicator.hidden = YES;
    self.devicWifiName = [NSString stringWithFormat:@"EZVIZ_%@",[EDHelper sharedInstance].deviceSerial];
    self.wifiNameLabel.text = self.devicWifiName;
    self.wifiPwdLabel.text = [NSString stringWithFormat:@"EZVIZ_%@",[EDHelper sharedInstance].verifyCode];
    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"ad_ap_step_two_msg",@"进入手机系统Wi-Fi设置界面，选择名称为%@的网络，用提示的密码进行连接"),self.devicWifiName];
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    //关键字符颜色调整
    [aStr addAttribute:NSForegroundColorAttributeName
                 value:[UIColor orangeColor]
                 range:[str rangeOfString:self.devicWifiName]];
    
    //行间距调整
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [aStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aStr length])];
    
    self.stepTwoLabel.attributedText = aStr;
}

- (void) createAddBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ad_wifi_add_device_title", @"添加设备")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addBtnClick:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(void) startAction
{
    self.processingIndicator.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.processingIndicator startAnimating];
}

- (void) stopAction
{
    [self.processingIndicator stopAnimating];
    self.processingIndicator.hidden = YES;
}


#pragma mark - notification

- (void) applicationDidBecomeActive
{
    [self startTimer];
}

- (void) applicationWillResignActive
{
    [self stopTimer];
}

#pragma mark - actions

- (IBAction)enterSettingBtnClick:(id)sender
{
    NSString *urlStr = [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0?WIFI_IOS10_WIFI_URL:WIFI_PREFROOT_URL;
    NSURL * url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)copyPwdBtnClick:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.wifiPwdLabel.text;
    
    [self.view makeToast:NSLocalizedString(@"ad_copy_done", @"复制完成") duration:1.5 position:@"center"];
}

- (void)addBtnClick:(id)sender
{
    EZAddDeviceViewController *vc = [[EZAddDeviceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - support

- (void) configWifi
{
    [[EZWiFiConfigManager sharedInstance] startAPWifiConfigWithWifiName:self.ssid
                                                                wifiPwd:self.password
                                                           deviceSerial:[EDHelper sharedInstance].deviceSerial
                                                             verifyCode:[EDHelper sharedInstance].verifyCode
                                                                 reuslt:^(BOOL ret) {
                                                                     if (ret)
                                                                     {
                                                                         [self configSuccess];
                                                                     }
                                                                     else
                                                                     {
                                                                         [self configFailed];
                                                                         NSLog(@"config failed");
                                                                     }
                                                                     
                                                                     [self stopConfigWifi];
                                                                 }];
}

- (void) stopConfigWifi
{
    [[EZWiFiConfigManager sharedInstance] stopAPWifiConfig];
}

- (void) configSuccess
{
    [self stopAction];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) configFailed
{
    [self stopAction];
    
    [self.view makeToast:@"config wifi fail" duration:1.5 position:@"center"];
}

- (void)addNotifications
{
    [self removeNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) startTimer
{
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void) stopTimer
{
    if (!self.timer)
    {
        return;
    }
    
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void) timerCallback
{
    if (![self checkSsid])
    {
        return;
    }
    
    [self stopTimer];
    
    [self startAction];
    
    [self configWifi];
}

- (NSString *) currentSsid
{
    NSString *currentSsid = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (__bridge NSDictionary *)(myDict);
            currentSsid = [dict valueForKey:@"SSID"];
        }
    }
    return currentSsid;
}

- (BOOL) checkSsid
{
    NSString *ssid = [self currentSsid];
    
    if (ssid && [ssid isEqualToString:self.devicWifiName])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

@end
