//
//  EOASettingViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOASettingViewController.h"
#import "EOASettingInfo.h"
#import "EOADeviceManager.h"
#import "EOADeviceInfo.h"
#import "UIImageView+WebCache.h"
#import "EOASettingTableViewCell.h"
#import "EOAModifyNameViewController.h"
#import "Toast+UIView.h"
#import "EOAWaitView.h"
#import "EZOpenSDK.h"
#import "EZStorageInfo.h"
#import "EDHelper.h"

#define SETTING_TABLE_CELL_ID @"SETTING_TABLE_CELL_ID"
#define SETTING_TABLE_CELL_HEIGHT (50.0f)
#define SETTING_TABLE_HEAD_HEIGHT (20.0f)
#define TOAST_DURATION (1.5)

@interface EOASettingViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UILabel *addTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@property (nonatomic,strong) EOADeviceInfo *mDeviceInfo;
@property (nonatomic,strong) NSMutableArray *dataList;//元素为数组对象
@property (nonatomic,copy) NSString *bgImageName;
@property (nonatomic,assign) BOOL isBePresented;//是否为模态展示
@property (nonatomic,assign) BOOL voiceStatus;//YES:开启，NO:关闭
@property (nonatomic,assign) BOOL supportVoice;//YES:支持，NO:不支持
@property (nonatomic,assign) NSInteger cloudStatus;//-2:设备不支持，-1:未开通云存储，0:未激活，1:激活，2:过期，默认：-2不支持，不进行显示
@property (nonatomic,copy) NSString *storageMsg;//存储状态提示语

@end

@implementation EOASettingViewController

+ (void) showSettingViewFrom:(UIViewController *) fromVC
                  deviceInfo:(EOADeviceInfo *) deviceInfo
                 bgImageName:(NSString *) imageName
                 needPresent:(BOOL)needPresent
{
    if (!fromVC || !deviceInfo)
    {
        return;
    }
    
    EOASettingViewController *vc = [[EOASettingViewController alloc] init];
    vc.mDeviceInfo = deviceInfo;
    vc.bgImageName = imageName;
    vc.isBePresented = needPresent;

    if (needPresent)
    {
        EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
        [fromVC presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        [fromVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cloudStatus = -2;
    self.voiceStatus = NO;
    self.supportVoice = NO;

    self.title = NSLocalizedString(@"setting_nav_title", @"详细设置");
    [self addBarItems];
    [self initSettingInfos];
    [self initSubviews];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshTableView];
    
    [self getVoiceStatus];
    
    [self getStorageStatus];
    
    [self getCloudStatus];
}


#pragma mark - actions

- (void) backBtnClick:(id) sender
{
    [self backToPreController];
}


- (void) motionSwitch:(id) sender
{
    [EOAWaitView showWaitViewInView:self.view frame:self.view.bounds];
    UISwitch *tempSwitch = (UISwitch*)sender;
    __weak EOASettingViewController *weakSelf = self;
    [[EOADeviceManager sharedInstance] switchCameraMotionDetectWithSerial:self.mDeviceInfo.deviceSerial
                                                                     isOn:tempSwitch.on
                                                                   result:^(BOOL result) {
                                                                       [EOAWaitView hideWaitView];
                                                                       if (!result)
                                                                       {
                                                                           tempSwitch.on = !tempSwitch.on;
                                                                       }
                                                                       else
                                                                       {
                                                                           [weakSelf refreshTableView];
                                                                       }
                                                                   }];
}

- (void) encryptSwitch:(id) sender
{
    UISwitch *tempSwitch = (UISwitch*)sender;
    
    if (tempSwitch.on)
    {
        [self setEncryptOn:tempSwitch.on verifyCode:nil];
    }
    else
    {
        [self showNeedVerifyCodeAlert];
    }
}

- (void) voiceSwitch:(id) sender
{
    UISwitch *tempSwitch = (UISwitch*)sender;
    [self setVoiceStatusWith:tempSwitch.on];
}

#pragma mark - delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataList objectAtIndex:section];
    return arr.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.01;//不可设置为0，设置为0时将采用默认高度
    }
    else
    {
        return SETTING_TABLE_HEAD_HEIGHT;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_TABLE_CELL_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;//不可设置为0，设置为0时将采用默认高度
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    else
    {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                    CGRectGetWidth(self.settingTableView.frame),
                                                                    SETTING_TABLE_HEAD_HEIGHT)];
        headView.backgroundColor = [UIColor clearColor];
        return headView;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSArray *arr = [self.dataList objectAtIndex:section];
    EOASettingInfo *info = [arr objectAtIndex:row];
    
    EOASettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTING_TABLE_CELL_ID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.titleLabel.hidden = NO;
    cell.switchView.hidden = YES;
    cell.subTitleLabel.hidden = YES;
    cell.deleteLabel.hidden = YES;
    
    cell.titleLabel.textColor = info.titleColor;
    cell.subTitleLabel.textColor = info.desColor;
    
    switch (info.type)
    {
        case SETTING_CELL_TYPE_MODIFY:
        {
            cell.subTitleLabel.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.titleLabel.text = info.title;
            cell.subTitleLabel.text = info.desMessage;
            
            break;
        }
            
        case SETTING_CELL_TYPE_DISPLAY:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.subTitleLabel.hidden = NO;
            cell.titleLabel.text = info.title;
            cell.subTitleLabel.text = info.desMessage;
            break;
        }
            
        case SETTING_CELL_TYPE_ACTION:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.subTitleLabel.hidden = NO;
            cell.titleLabel.text = info.title;
            cell.subTitleLabel.text = info.desMessage;
            break;
        }
            
        case SETTING_CELL_TYPE_SWITCH:
        {
            cell.switchView.hidden = NO;
            cell.switchView.on = info.switchValue;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.switchView removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
            [cell.switchView addTarget:self action:info.switchCallback forControlEvents:UIControlEventValueChanged];
            cell.titleLabel.text = info.title;
            
            break;
        }
            
        case SETTING_CELL_TYPE_DELETE:
        {
            cell.titleLabel.hidden = YES;
            cell.deleteLabel.hidden = NO;
            cell.deleteLabel.text = info.title;
            cell.deleteLabel.textColor = info.titleColor;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSArray *arr = [self.dataList objectAtIndex:section];
    EOASettingInfo *info = [arr objectAtIndex:row];
    
    if (info.type != SETTING_CELL_TYPE_SWITCH && info.cellSelectedCallback)
    {
        info.cellSelectedCallback();
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - support

- (void) initSettingInfos
{
    self.dataList = [NSMutableArray array];
    
    __weak EOASettingViewController *weakSelf = self;
    
    //section 0
    NSMutableArray *tempArray = [NSMutableArray array];
    EOASettingInfo *tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_MODIFY
                                                  title:NSLocalizedString(@"setting_table_name", @"名称")
                                                message:self.mDeviceInfo.deviceName];
    tempInfo.cellSelectedCallback = ^{
        [weakSelf go2ModifyNameController];
    };
    [tempArray addObject:tempInfo];
    [self.dataList addObject:tempArray];
    
    if (self.mDeviceInfo.status == 1)//设备在线才显示
    {
        //section 1
        tempArray = [NSMutableArray array];
        tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_SWITCH
                                      title:NSLocalizedString(@"setting_table_motion", @"活动检测提醒")
                                    message:nil];
        tempInfo.switchValue = self.mDeviceInfo.defence == 1;
        tempInfo.switchCallback = @selector(motionSwitch:);
        [tempArray addObject:tempInfo];
        
        if (self.supportVoice)
        {
            tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_SWITCH
                                          title:NSLocalizedString(@"setting_table_voice", @"设备语音提示")
                                        message:nil];
            tempInfo.switchValue = self.voiceStatus;
            tempInfo.switchCallback = @selector(voiceSwitch:);
            [tempArray addObject:tempInfo];
        }
        
        tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_SWITCH
                                      title:NSLocalizedString(@"setting_table_encrypt", @"视频/图片加密")
                                    message:nil];
        tempInfo.switchValue = self.mDeviceInfo.isEncrypt;
        tempInfo.switchCallback = @selector(encryptSwitch:);
        [tempArray addObject:tempInfo];
        
        [self.dataList addObject:tempArray];
        
        //section 2
        tempArray = [NSMutableArray array];
        tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_DISPLAY
                                      title:NSLocalizedString(@"setting_table_tf_card", @"TF卡")
                                    message:self.storageMsg];
        tempInfo.cellSelectedCallback = ^{
            
        };
        [tempArray addObject:tempInfo];
        
        tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_ACTION
                                      title:NSLocalizedString(@"setting_table_cloud", @"云存储")
                                    message:[self getCloudMessageWithStatus:self.cloudStatus]];
        tempInfo.cellSelectedCallback = ^{
            if (weakSelf.cloudStatus != -2)
            {
                [EZOpenSDK openCloudPage:self.mDeviceInfo.deviceSerial];
            }
        };
        [tempArray addObject:tempInfo];
        
        tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_DISPLAY
                                      title:NSLocalizedString(@"setting_table_rom", @"固件版本")
                                    message:self.mDeviceInfo.deviceVersion];
        tempInfo.cellSelectedCallback = ^{
            
        };
        [tempArray addObject:tempInfo];
        
        [self.dataList addObject:tempArray];
    }
    //section 3
    tempArray = [NSMutableArray array];
    tempInfo = [self createInfoWithType:SETTING_CELL_TYPE_DELETE
                                  title:NSLocalizedString(@"setting_table_delete", @"删除设备")
                                message:nil];
    tempInfo.titleColor = [UIColor redColor];
    tempInfo.cellSelectedCallback = ^{
        [weakSelf showDeleteAlert];
    };
    [tempArray addObject:tempInfo];
    [self.dataList addObject:tempArray];
}

- (void) selfUpdateSettingInfos
{
    [self initSettingInfos];
}

- (EOASettingInfo *) createInfoWithType:(SettingCellType) type title:(NSString *) title message:(NSString *) message
{
    EOASettingInfo *destInfo = [[EOASettingInfo alloc] init];
    destInfo.title = title;
    destInfo.type = type;
    destInfo.desMessage = message;
    destInfo.titleColor = [UIColor blackColor];
    destInfo.desColor = UIColorFromRGB(0xD2D2D2, 1.0);
    
    return destInfo;
}

- (EOASettingInfo *) findEncryptInfo
{
    if (self.dataList.count < 2)
    {
        return nil;
    }
    NSArray *arr = [self.dataList objectAtIndex:1];
    for (EOASettingInfo *info in arr)
    {
        if ([info.title isEqualToString:NSLocalizedString(@"setting_table_encrypt", @"视频/图片加密")])
        {
            return info;
        }
    }
    
    return nil;
}

- (void) backToPreController
{
    if (self.isBePresented)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) allBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) go2ModifyNameController
{
    [EOAModifyNameViewController showModifyNameViewControllerFrom:self deviceInfo:self.mDeviceInfo isPresent:NO];
}

- (void) deleteDevice
{
    __weak EOASettingViewController *weakSelf = self;
    
    [EOAWaitView showWaitViewInView:[UIApplication sharedApplication].keyWindow frame:[UIApplication sharedApplication].keyWindow.bounds];
    [[EOADeviceManager sharedInstance] deleteDeviceWithSerial:self.mDeviceInfo.deviceSerial result:^(BOOL result) {
        [EOAWaitView hideWaitView];
        if (result)
        {
            [EDHelper sharedInstance].needRefreshDeviceList = YES;
            [weakSelf.view makeToast:NSLocalizedString(@"setting_delete_success", @"删除成功") duration:TOAST_DURATION position:@"center"];
            [weakSelf performSelector:@selector(allBack) withObject:nil afterDelay:TOAST_DURATION];
        }
        else
        {
            [weakSelf.view makeToast:NSLocalizedString(@"setting_delete_fail", @"删除失败") duration:TOAST_DURATION position:@"center"];
        }
    }];
}

- (void) setEncryptOn:(BOOL) isOn verifyCode:(NSString *) verifyCode
{
    [EOAWaitView showWaitViewInView:self.view frame:self.view.bounds];
    [[EOADeviceManager sharedInstance] setDeviceEncryptWithSerial:self.mDeviceInfo.deviceSerial
                                                       verifyCode:verifyCode
                                                            value:isOn
                                                           result:^(BOOL result) {
                                                               [self refreshTableView];
                                                               [EOAWaitView hideWaitView];
                                                           }];
}

- (NSString *) getCloudMessageWithStatus:(NSInteger) status
{
    NSString *message = nil;
    switch (status)
    {
        case -2:
            message = NSLocalizedString(@"setting_cloud_no_support", @"设备不支持云存储");
            break;
            
        case -1:
            message = NSLocalizedString(@"setting_cloud_no_open", @"未开通云存储");
            break;
            
        case 0:
            message = NSLocalizedString(@"setting_cloud_no_active", @"未激活");;
            break;
            
        case 1:
            message = NSLocalizedString(@"setting_cloud_active", @"使用中");;
            break;
            
        case 2:
            message = NSLocalizedString(@"setting_cloud_expired", @"已过期");;
            break;
            
        default:
            break;
    }
    
    return message;
}

- (void) processStorageWithStatus:(NSInteger) status
{
    NSString *message = nil;
    switch (status)
    {
        case 0:
            message = NSLocalizedString(@"setting_storage_normal", @"使用中");
            break;
            
        case 1:
            message = NSLocalizedString(@"setting_storage_none", @"无");
            break;
            
        case 2:
            message = NSLocalizedString(@"setting_storage_need_format", @"待初始化");
            break;
            
        case 3:
            message = NSLocalizedString(@"setting_storage_formatting", @"初始化中");
            break;
            
        default:
            break;
    }
    
    self.storageMsg = message;
    [self refreshTableView];
}

- (void) getStorageStatus
{
    __weak EOASettingViewController *weakSelf = self;
    [EZOpenSDK getStorageStatus:self.mDeviceInfo.deviceSerial completion:^(NSArray *storageStatus, NSError *error) {
        if (error)
        {
            [weakSelf processStorageWithStatus:1];
        }
        else
        {
            if (storageStatus.count > 0)
            {
                EZStorageInfo *info = [storageStatus firstObject];
                [weakSelf processStorageWithStatus:info.status];
            }
            else
            {
                [weakSelf processStorageWithStatus:1];
            }
        }
    }];
}

- (void) getVoiceStatus
{
    __weak EOASettingViewController *weakSelf = self;

    [[EOADeviceManager sharedInstance] getDeviceVoiceStateWithSerial:self.mDeviceInfo.deviceSerial result:^(BOOL result,BOOL status) {
        weakSelf.supportVoice = result;
        weakSelf.voiceStatus = status;
        [weakSelf refreshTableView];
    }];
}

- (void) getCloudStatus
{
    __weak EOASettingViewController *weakSelf = self;
    
    [[EOADeviceManager sharedInstance] getDeviceCloudStateWithSerial:self.mDeviceInfo.deviceSerial result:^(BOOL result, NSInteger status) {
        weakSelf.cloudStatus = status;
        [weakSelf refreshTableView];
    }];
}

- (void) setVoiceStatusWith:(BOOL) status
{
    [EOAWaitView showWaitViewInView:self.view frame:self.view.bounds];
    __weak EOASettingViewController *weakSelf = self;
    [[EOADeviceManager sharedInstance] setDeviceVoiceStateWithSerial:self.mDeviceInfo.deviceSerial
                                                               state:status?1:0
                                                              result:^(BOOL result) {
                                                                  
                                                                  [EOAWaitView hideWaitView];
                                                                  if (result)
                                                                  {
                                                                      weakSelf.voiceStatus = status;
                                                                  }
                                                                  
                                                                  [weakSelf refreshTableView];
                                                              }];
}

#pragma mark - views

- (void) initSubviews
{
    NSString *imageName = @"bg_b3";
    if (self.bgImageName && self.bgImageName.length > 0)
    {
        imageName = self.bgImageName;
    }

    self.bgImageView.image = [UIImage imageNamed:imageName];
    self.typeLabel.text = self.mDeviceInfo.category;
    self.serialLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"device_serial_header", @"序列号："),self.mDeviceInfo.deviceSerial];
    NSDateFormatter *dateFormatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyy-MM-dd HH:mm:ss"];
    self.addTimeLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"device_time_header", @"添加于："),
                              [dateFormatter stringFromDate:self.mDeviceInfo.addTime]];
    [self.typeImageView sd_setImageWithURL:[NSURL URLWithString:[[EOADeviceManager sharedInstance] getDeviceImageUrlWithType:self.mDeviceInfo.deviceType]]];
    
    [self initTableView];
}

- (void) initTableView
{
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    [self.settingTableView registerNib:[UINib nibWithNibName:@"EOASettingTableViewCell" bundle:nil]
                forCellReuseIdentifier:SETTING_TABLE_CELL_ID];
    self.settingTableView.tableFooterView = [UIView new];
}

- (void) addBarItems
{
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_return"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backBtnClick:)];
    [leftBarBtnItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
}

- (void) refreshTableView
{
    [self selfUpdateSettingInfos];
    [self.settingTableView reloadData];
}

- (void) showNeedVerifyCodeAlert
{
    [self showVerifyCodeAlertWithTitle:NSLocalizedString(@"need_verify_code", @"请输入设备验证码")];
}

- (void) showRetryVerifyCodeAlert
{
    [self showVerifyCodeAlertWithTitle:NSLocalizedString(@"verify_code_error", @"设备验证码错误")];
}

- (void) showVerifyCodeAlertWithTitle:(NSString *) title
{
    __weak EOASettingViewController *weakSelf = self;
    UIAlertController *verifyCodeAlert = [UIAlertController alertControllerWithTitle:title
                                                                             message:NSLocalizedString(@"setting_close_encrypt_message", @"setting_close_encrypt_message")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [verifyCodeAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel",@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             //取消时，加密处于关闭状态
                                                             EOASettingInfo *info = [weakSelf findEncryptInfo];
                                                             if (info)
                                                             {
                                                                 info.switchValue = YES;
                                                                 [weakSelf.settingTableView reloadData];
                                                             }
                                                         }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_ok",@"确定")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              UITextField *textField =[verifyCodeAlert.textFields firstObject];
                                                              [weakSelf setEncryptOn:NO verifyCode:textField.text];
                                                          }];
    
    
    [verifyCodeAlert addAction:cancelAction];
    [verifyCodeAlert addAction:confirmAction];
    
    [self presentViewController:verifyCodeAlert animated:YES completion:nil];
}

- (void) showDeleteAlert
{
    __weak EOASettingViewController *weakSelf = self;
    UIAlertController *verifyCodeAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"setting_delete_alert", @"是否删除设备")
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel",@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {

                                                         }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"setting_delete_confirm",@"删除")
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [weakSelf deleteDevice];
                                                          }];
    
    
    [verifyCodeAlert addAction:cancelAction];
    [verifyCodeAlert addAction:confirmAction];
    
    [self presentViewController:verifyCodeAlert animated:YES completion:nil];
}


@end
