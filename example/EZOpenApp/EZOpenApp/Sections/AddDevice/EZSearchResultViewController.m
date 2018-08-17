//
//  EZSearchResultViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//

#import "EZSearchResultViewController.h"
#import "EZAddDeviceViewController.h"
#import "EZWifiInfoViewController.h"
#import "EDHelper.h"

#import "EZOpenSDK.h"
#import "EZDefine.h"
#import "EZProbeDeviceInfo.h"
#import "EZWiFiConfigManager.h"

@interface EZSearchResultViewController ()

@property (weak, nonatomic) IBOutlet UIButton *wifiConfigBtn;
@property (weak, nonatomic) IBOutlet UIButton *addDeviceBtn;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic,assign) BOOL supportApMode;
@property (nonatomic,assign) BOOL supportSmartMode;
@property (nonatomic,assign) BOOL supportSoundMode;

@end

@implementation EZSearchResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubViews];

    [self searchDevice];
}

#pragma mark - actions

- (IBAction)wifiConfigBtnClick:(id)sender
{
    [self showConfigSelectView];
}

- (IBAction)addDeviceBtnClick:(id)sender
{
    [self gotoAddDeviceView];
}

#pragma mark - view

- (void) initSubViews
{
    self.msgLabel.text = NSLocalizedString(@"ad_get_device_info_msg", @"正在查询设备信息，请稍后...");
    [self.wifiConfigBtn setTitle:NSLocalizedString(@"ad_search_config_btn", @"配置网络") forState:UIControlStateNormal];
    [self.addDeviceBtn setTitle:NSLocalizedString(@"ad_search_add_btn", @"添加设备") forState:UIControlStateNormal];
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

- (void) showConfigSelectView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:NSLocalizedString(@"ad_config_mode_select_tip", @"请选择配网方式")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *line = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_config_mode_line", @"有线连接")
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     
                                                 }];
    
    [alert addAction:line];

    
    if (self.supportSmartMode)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_config_mode_smart",@"smart配网")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self gotoWifiInfoViewWithMode:EZWiFiConfigSmart];
                                                       }];
        
        [alert addAction:action];
    }
    
    if (self.supportSoundMode)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_config_mode_sound",@"声波配网")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self gotoWifiInfoViewWithMode:EZWiFiConfigWave];
                                                       }];
        
        [alert addAction:action];
    }
    
    if (self.supportApMode)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_config_mode_ap",@"热点配网")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self gotoWifiInfoViewWithApMode];
                                                       }];
        
        [alert addAction:action];
    }
    
    if (self.supportSoundMode && self.supportSmartMode)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"ad_config_mode_smart_sound",@"smart和声波配网")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self gotoWifiInfoViewWithMode:EZWiFiConfigSmart|EZWiFiConfigWave];
                                                       }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel", @"取消")
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) changeMsgLabelWithMsg:(NSString *) msg
{
    if (!msg)
    {
        return;
    }
    
    self.msgLabel.text = msg;
}

- (void) btnConfigMode
{
    self.wifiConfigBtn.hidden = NO;
    self.addDeviceBtn.hidden = YES;
}

- (void) btnAddMode
{
    self.wifiConfigBtn.hidden = YES;
    self.addDeviceBtn.hidden = NO;
}

- (void) btnNoMode
{
    self.wifiConfigBtn.hidden = YES;
    self.addDeviceBtn.hidden = YES;
}

#pragma mark - support

- (void) returnDeviceList
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) gotoWifiInfoViewWithMode:(EZWiFiConfigMode) mode
{
    EZWifiInfoViewController *vc = [[EZWifiInfoViewController alloc] init];
    vc.configMode = mode;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) gotoWifiInfoViewWithApMode
{
    EZWifiInfoViewController *vc = [[EZWifiInfoViewController alloc] init];
    vc.isApMode = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) gotoAddDeviceView
{
    EZAddDeviceViewController *vc = [[EZAddDeviceViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) searchDevice
{
    [self showLoading];
    [EZOpenSDK probeDeviceInfo:[EDHelper sharedInstance].deviceSerial
                    deviceType:[EDHelper sharedInstance].deviceType
                    completion:^(EZProbeDeviceInfo *deviceInfo, NSError *error) {
                       
                        [self hideLoading];
                        NSString *msg = nil;

                        if (error)
                        {
                            switch (error.code)
                            {
                                case EZ_HTTPS_DEVICE_ONLINE_ADDED:
                                {
                                    msg = NSLocalizedString(@"ad_already_added", @"您已添加过此设备");
                                    [self btnNoMode];
                                    break;
                                }
                                   
                                case EZ_HTTPS_DEVICE_ONLINE_IS_ADDED:
                                {
                                    msg = NSLocalizedString(@"ad_added_by_others", @"此设备已被别人添加");
                                    [self btnNoMode];
                                    break;
                                }
                                   
                                case EZ_HTTPS_DEVICE_OFFLINE_NOT_ADDED:
                                case EZ_HTTPS_DEVICE_OFFLINE_IS_ADDED:
                                case EZ_HTTPS_DEVICE_OFFLINE_IS_ADDED_MYSELF:
                                {
                                    msg = NSLocalizedString(@"ad_search_offline",@"设备不在线，请配置网络。");
                                    [self btnConfigMode];
                                   
                                    if (deviceInfo)
                                    {
                                        self.supportApMode = deviceInfo.supportAP == 1;
                                        self.supportSmartMode = deviceInfo.supportWifi == 3;
                                        self.supportSoundMode = deviceInfo.supportSoundWave == 1;
                                    }
                                    else
                                    {
                                        //无信息则都支持，根据设备上的闪灯情况进行人工选择模式
                                        self.supportApMode = YES;
                                        self.supportSmartMode = YES;
                                        self.supportSoundMode = YES;
                                    }
                                   
                                    break;
                                }
                                   
                                default:
                                    msg = [error description];
                                    [self btnNoMode];
                                    break;
                            }
                           
                            [self changeMsgLabelWithMsg:msg];
                            return;
                        }

                        msg = NSLocalizedString(@"ad_search_online",@"设备已在线，可进行添加操作。");
                        [self changeMsgLabelWithMsg:msg];
                        [self btnAddMode];
                    }];
}

@end
