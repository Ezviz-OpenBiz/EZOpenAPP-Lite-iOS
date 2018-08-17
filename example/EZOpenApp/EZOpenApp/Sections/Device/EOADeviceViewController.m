//
//  EOADeviceViewController.m
//  EZOpenApp
//
//  Created by linyong on 16/12/27.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOADeviceViewController.h"
#import "EZOpenSDK.h"
#import "EZAccessToken.h"
#import <Realm/Realm.h>
#import "EOAUserInfo.h"
#import "EOADeviceInfo.h"
#import "EOACameraInfo.h"
#import "EOADeviceManager.h"
#import "EOAUserManager.h"
#import "EOAScrollBar.h"
#import "EOAPreviewTableViewCell.h"
#import "EOADeviceTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "EOAHomeViewController.h"
#import "EOAModifyNameViewController.h"
#import "EOASettingViewController.h"
#import "EOARealPlayViewController.h"
#import "EZQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EDHelper.h"

#define DEVICE_PAGE_SIZE (10)
#define TABLEVIEW_OFFSET (5.0)
#define PREVIEW_TABLE_CELL_HEIGHT (EOA_SCREEN_WIDTH*9/16)
#define DEVCIE_TABLE_CELL_HEIGHT (190)

#define PREVIEW_TABLE_CELL_ID @"PREVIEW_TABLE_CELL_ID"
#define DEVICE_TABLE_CELL_ID @"DEVICE_TABLE_CELL_ID"


@interface EOADeviceViewController () <UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,EOAScrollBarDelegate,EOAPreviewCellDelegate>

@property (nonatomic,strong) RLMResults *mDeviceList;//设备信息列表
@property (nonatomic,strong) NSMutableArray *mCameraList;//通道信息列表
@property (nonatomic,strong) EOAScrollBar *titleView;//导航栏标题视图
@property (nonatomic,strong) UIScrollView *mainScroll;//主要滚动视图
@property (nonatomic,strong) UITableView *previewTable;//预览标签展示tableView
@property (nonatomic,strong) UITableView *deviceTable;//设备标签展示tableView
@property (nonatomic,strong) UITableView *curTableView;//记录当前展示的tableView
@property (nonatomic,assign) BOOL needRefreshCover;//是否需要刷新封面，获取camera列表时使用
@end

@implementation EOADeviceViewController


- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.needRefreshCover = YES;
    self.mCameraList = [NSMutableArray array];
    [self addNotifications];
    [self addAddDeviceBtn];
    [self createViews];
    
    if ([EOAUserManager sharedInstance].isLogin)
    {
        [self getDeviceList];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([EOAUserManager sharedInstance].isLogin)
    {
        if ((self.mDeviceList && self.mDeviceList.count <= 0) || [EDHelper sharedInstance].needRefreshDeviceList)
        {
            [EDHelper sharedInstance].needRefreshDeviceList = NO;
            [self.curTableView.mj_header beginRefreshing];
        }
    }
    else
    {
        [self login];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self requestCamera];
}

#pragma mark - action
- (void) addDeviceBtnClick:(id) sender
{
    EZQRCodeViewController *vc = [[EZQRCodeViewController alloc] init];
    EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - notificaitons

- (void) deviceListChanged:(NSNotification *) notification
{
    [self makeCameraList];
    [self refreshTableView];
}

- (void) logoutNotify:(NSNotification *) notification
{
    //注销时，清空数据，再次进入该界面时进行刷新
    [self.mCameraList removeAllObjects];
    [[EOADeviceManager sharedInstance] clearSavedDeviceInfo];
}

#pragma mark - delegate

- (void) tabButtonClickByIndex:(NSInteger) index
{
    [self.titleView selectAtIndex:index];
    
    CGPoint bgOffset = CGPointMake(self.mainScroll.frame.size.width*index, self.mainScroll.contentOffset.y);
    [self.mainScroll setContentOffset:bgOffset animated:YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.mainScroll])
    {
        [self.titleView flagScrollToOffset:scrollView.contentOffset.x/scrollView.contentSize.width];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.mainScroll])
    {
        NSInteger index = (NSInteger)scrollView.contentOffset.x/scrollView.frame.size.width;
        
        if (index == 0)
        {
            self.curTableView = self.previewTable;
        }
        else
        {
            self.curTableView = self.deviceTable;
        }
        
        [self.titleView selectAtIndex:index];
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.previewTable])
    {
        return PREVIEW_TABLE_CELL_HEIGHT;
    }
    else
    {
        return DEVCIE_TABLE_CELL_HEIGHT;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.mDeviceList)
    {
        return 0;
    }
    
    if ([tableView isEqual:self.previewTable])
    {
        return self.mCameraList.count;
    }
    else
    {
        return self.mDeviceList.count;
    }
}

- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (![tableView isEqual:self.previewTable] || self.mCameraList.count <= 0)
    {
        return;
    }
    
    if ([indexPath row] >= self.mCameraList.count)
    {
        return;
    }
    
    EOACameraInfo *cameraInfo = [self.mCameraList objectAtIndex:[indexPath row]];
    cameraInfo.hasRefreshCover = YES;
    
    self.needRefreshCover = NO;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.previewTable])
    {
        return [self previewTableMakeCellWithIndexPath:indexPath];
    }
    else
    {
        return [self deviceTableMakeCellWithIndexPath:indexPath];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.mDeviceList || self.mDeviceList.count <= 0)//无数据情况下不作处理，刷新列表是点击会触发该情况
    {
        return;
    }
    
    if ([tableView isEqual:self.previewTable])
    {
        [self showRealPlayViewWithDeviceInfo:[self.mCameraList objectAtIndex:[indexPath row]]];
    }
    else
    {
        [self showSettinViewWithDeviceInfo:[self.mDeviceList objectAtIndex:[indexPath row]]];
    }
}

- (void) previewCellClickSettingBtn:(EOAPreviewTableViewCell *) cell
{
    [self showSettingSheetWithCameraInfo:cell.cameraInfo];
}

#pragma mark - views

- (void) createViews
{
    [self createTitleBar];
    [self createMainScroll];
    [self createPreviewTable];
    [self createDeviceTable];
}

- (void) createTitleBar
{
    self.titleView = [[EOAScrollBar alloc] initWithTarget:self
                                                    frame:CGRectMake(0, 0, EOA_SCREEN_WIDTH/2, NAVIGATION_BAR_HEIGHT_WITHOUT_STATUSBAR)
                                                   titles:@[NSLocalizedString(@"device_title_preview", @"预览"),
                                                            NSLocalizedString(@"device_title_devicelist",@"设备")]
                                            selectedIndex:0];
    self.titleView.backgroundColor = [UIColor clearColor];
    [self.titleView setTabTitleFont:[UIFont systemFontOfSize:15.0]];
    [self.titleView setTabTitleIndicatorColor:UIColorFromRGB(0xf37f4c, 1.0)];
    [self.titleView setTabTitleColor:UIColorFromRGB(0x646464, 1.0) forState:UIControlStateNormal];
    [self.titleView setTabTitleColor:UIColorFromRGB(0xf37f4c, 1.0) forState:UIControlStateSelected];
    [self.titleView setTabTitleColor:UIColorFromRGB(0xf37f4c, 1.0) forState:UIControlStateHighlighted];
    
    self.navigationItem.titleView = self.titleView;
}

- (void) createMainScroll
{
    self.mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     EOA_SCREEN_WIDTH + TABLEVIEW_OFFSET,
                                                                     EOA_SCREEN_HEIGHT - TAB_BAR_HEIGHT)];
    self.mainScroll.showsVerticalScrollIndicator = NO;
    self.mainScroll.showsHorizontalScrollIndicator = NO;
    self.mainScroll.delegate = self;
    self.mainScroll.pagingEnabled = YES;
    self.mainScroll.contentSize = CGSizeMake(CGRectGetWidth(self.mainScroll.frame)*2,
                                             CGRectGetHeight(self.mainScroll.frame)-NAVIGATION_BAR_HEIGHT_WITH_STATUSBAR);
    [self.view addSubview:self.mainScroll];
}

- (void) createPreviewTable
{
    self.previewTable = [self createTableViewWithFrame:CGRectMake(0, 0,
                                                                  CGRectGetWidth(self.mainScroll.frame)-TABLEVIEW_OFFSET,
                                                                  CGRectGetHeight(self.mainScroll.frame)-NAVIGATION_BAR_HEIGHT_WITH_STATUSBAR)];
    [self.previewTable registerNib:[UINib nibWithNibName:@"EOAPreviewTableViewCell" bundle:nil]
            forCellReuseIdentifier:PREVIEW_TABLE_CELL_ID];
    self.previewTable.backgroundColor = [UIColor clearColor];
    [self.mainScroll addSubview:self.previewTable];
    
    self.curTableView = self.previewTable;//初始显示previewTable
    
    __weak EOADeviceViewController *weakSelf = self;
    self.previewTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateDeviceList];
    }];
}

- (void) createDeviceTable
{
    self.deviceTable = [self createTableViewWithFrame:CGRectMake(CGRectGetWidth(self.mainScroll.frame), 0,
                                                                 CGRectGetWidth(self.mainScroll.frame)-TABLEVIEW_OFFSET,
                                                                 CGRectGetHeight(self.mainScroll.frame)-NAVIGATION_BAR_HEIGHT_WITH_STATUSBAR)];
    self.deviceTable.backgroundColor = [UIColor clearColor];
    [self.deviceTable registerNib:[UINib nibWithNibName:@"EOADeviceTableViewCell" bundle:nil]
            forCellReuseIdentifier:DEVICE_TABLE_CELL_ID];
    [self.mainScroll addSubview:self.deviceTable];
    
    __weak EOADeviceViewController *weakSelf = self;
    self.deviceTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf updateDeviceList];
    }];
}

- (UITableView *) createTableViewWithFrame:(CGRect) frame
{
    UITableView *destTable = [[UITableView alloc] initWithFrame:frame];
    destTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    destTable.delegate = self;
    destTable.dataSource = self;
    destTable.showsVerticalScrollIndicator = NO;
    destTable.showsHorizontalScrollIndicator = NO;
    destTable.tableFooterView = [[UIView alloc] init];

    return destTable;
}

- (void) refreshTableView
{
    if (self.previewTable)
    {
        [self.curTableView.mj_header endRefreshing];
        [self.previewTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (self.deviceTable)
    {
        [self.deviceTable.mj_header endRefreshing];
        [self.deviceTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (UITableViewCell *) previewTableMakeCellWithIndexPath:(NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    EOAPreviewTableViewCell *cell = (EOAPreviewTableViewCell*)[self.previewTable dequeueReusableCellWithIdentifier:PREVIEW_TABLE_CELL_ID forIndexPath:indexPath];
    EOACameraInfo *cameraInfo = [self.mCameraList objectAtIndex:row];
    
    cell.mDelegate = self;
    cell.cameraInfo = cameraInfo;
    cell.motionBtn.selected = cameraInfo.status == 1 && cameraInfo.defence == 1;//设备在线并且已为布防状态
    NSString *tempCover = [[EOADeviceManager sharedInstance] getCoverUrlWithSerial:cameraInfo.deviceSerial cameraNo:cameraInfo.cameraNo];
    if (tempCover)
    {
        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:tempCover]
                            placeholderImage:nil
                                     options:SDWebImageDelayPlaceholder | SDWebImageAvoidAutoSetImage
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                       //判断cell是否已被重用
                                       if ([cell.cameraInfo.deviceSerial isEqualToString:cameraInfo.deviceSerial])
                                       {
                                           cell.bgImageView.image = image;
                                       }
                                   }];
    }
    else
    {
        [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:cameraInfo.cameraCover]];
    }
    
    NSString *tempSerial = cameraInfo.deviceSerial;
    NSInteger tempCameraNo = cameraInfo.cameraNo;
    
    //刷新预览封面
    if (!cameraInfo.hasRefreshCover)
    {
        [[EOADeviceManager sharedInstance] captureCameraCoverWithSerial:tempSerial
                                                               cameraNo:tempCameraNo
                                                             completion:^(NSString *coverUrl) {
                                                                 //获取到抓图地址后，要判断cell是否已被重用
                                                                 if (coverUrl && [cell.cameraInfo.deviceSerial isEqualToString:cameraInfo.deviceSerial])
                                                                 {
                                                                     [cell.bgImageView sd_setImageWithURL:[NSURL URLWithString:coverUrl]
                                                                                         placeholderImage:nil
                                                                                                  options:SDWebImageDelayPlaceholder | SDWebImageAvoidAutoSetImage
                                                                                                completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                                                                    //判断cell是否已被重用
                                                                                                    if ([cell.cameraInfo.deviceSerial isEqualToString:cameraInfo.deviceSerial])
                                                                                                    {
                                                                                                        cell.bgImageView.image = image;
                                                                                                    }
                                                                                                }];
                                                                 }

                                                             }];
    }
    
    cell.cameraNameLabel.text = cameraInfo.cameraName;
    cell.offlineBgView.hidden = cameraInfo.status == 1;
    cell.offlineLabel.hidden = cameraInfo.status == 1;
    cell.deviceTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",cameraInfo.category,cameraInfo.deviceSerial];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *) deviceTableMakeCellWithIndexPath:(NSIndexPath *) indexPath
{
    NSInteger row = [indexPath row];
    EOADeviceTableViewCell *cell = (EOADeviceTableViewCell*)[self.deviceTable dequeueReusableCellWithIdentifier:DEVICE_TABLE_CELL_ID forIndexPath:indexPath];
    EOADeviceInfo *deviceInfo = [self.mDeviceList objectAtIndex:row];
    cell.moreBtn.hidden = YES;
    cell.bgImageView.image = [UIImage imageNamed:[[EOADeviceManager sharedInstance] getDeviceBgImageNameWithIndex:row]];
//    cell.deviceTypeImage.image = [UIImage imageNamed:@"device_other"];
    [cell.deviceTypeImage sd_setImageWithURL:[NSURL URLWithString:[[EOADeviceManager sharedInstance] getDeviceImageUrlWithType:deviceInfo.deviceType]]];
    cell.deviceRootTypeLabel.text = deviceInfo.category;
    cell.deviceNameLabel.text = deviceInfo.deviceName;
    cell.deviceTypeLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"device_type_header", @"型号："),deviceInfo.deviceType];
    cell.serialLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"device_serial_header", @"序列号："),deviceInfo.deviceSerial];
    NSDateFormatter *dateFormatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyy-MM-dd HH:mm:ss"];
    cell.registerTimeLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"device_time_header", @"添加于："),
                                   [dateFormatter stringFromDate:deviceInfo.addTime]];
//    cell.offlineTip.hidden = deviceInfo.status == 1;
    cell.offlineTip.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void) showSettingSheetWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return;
    }
    
    __weak EOADeviceViewController *weakSelf = self;
    UIColor *titleColor = [UIColor darkGrayColor];
    
    UIAlertController *settingSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel", @"取消") style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *modifyNameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"device_modify_name", @"修改名称")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [weakSelf actionSheetModifyNameProcessWithCameraInfo:cameraInfo];
                                                             }];
    
    UIAlertAction *refreshCoverAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"device_refresh_cover", @"刷新封面")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                                                                   [weakSelf actionSheetRefreshCoverProcessWithCameraInfo:cameraInfo];
                                                               }];
    BOOL isMotionOpen = cameraInfo.defence == 1;
    NSString *motionActionTitle = NSLocalizedString(@"device_motion_close", @"关闭活动检测提醒");
    if (!isMotionOpen)
    {
        motionActionTitle = NSLocalizedString(@"device_motion_open", @"开启活动检测提醒");
    }
    UIAlertAction *motionAction = [UIAlertAction actionWithTitle:motionActionTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [weakSelf actionSheetMotionProcessWithCameraInfo:cameraInfo];
                                                         }];
    
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"device_more_setting", @"更多设置")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [weakSelf actionSheetMoreProcessWithCameraInfo:cameraInfo];
                                                       }];
    
    
    [cancelAction setValue:titleColor forKey:@"titleTextColor"];
    [modifyNameAction setValue:titleColor forKey:@"titleTextColor"];
    [refreshCoverAction setValue:titleColor forKey:@"titleTextColor"];
    [motionAction setValue:titleColor forKey:@"titleTextColor"];
    [moreAction setValue:titleColor forKey:@"titleTextColor"];
    
    [settingSheet addAction:cancelAction];
    [settingSheet addAction:modifyNameAction];
    if (cameraInfo.status == 1)//设备在线时才可刷新封面和开关活动检测
    {
        [settingSheet addAction:refreshCoverAction];
        [settingSheet addAction:motionAction];
    }
    [settingSheet addAction:moreAction];
    
    [self presentViewController:settingSheet animated:YES completion:nil];
}

- (void) addAddDeviceBtn
{
    self.navigationItem.rightBarButtonItem = [self createBarButtonWithNormalImage:[UIImage imageNamed:@"btn_add_normal"]
                                                                   hilightedImage:[UIImage imageNamed:@"btn_add_highlight"]
                                                                           target:self
                                                                           action:@selector(addDeviceBtnClick:)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor darkGrayColor]];
}

- (UIBarButtonItem *) createBarButtonWithNormalImage:(UIImage *) normalImage
                                      hilightedImage:(UIImage *) hilightImage
                                              target:(id) target
                                              action:(SEL) selector
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    CGFloat offset = -13.0;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -offset, 0, +offset);
    if (normalImage)
    {
        [btn setImage:normalImage forState:UIControlStateNormal];
    }
    
    if (hilightImage)
    {
        [btn setImage:hilightImage forState:UIControlStateHighlighted];
    }
    
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *destItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    return destItem;
}

#pragma mark support

- (void) actionSheetMotionProcessWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return;
    }
    
    BOOL isMotionOpen = cameraInfo.defence == 1;
    [[EOADeviceManager sharedInstance] switchCameraMotionDetectWithSerial:cameraInfo.deviceSerial
                                                                     isOn:!isMotionOpen
                                                                   result:^(BOOL result) {
                                                                        //此处不需要进行刷新界面，在数据库更新数据的通知里进行刷新
                                                                   }];
}

- (void) actionSheetRefreshCoverProcessWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return;
    }
    
    __weak EOADeviceViewController *weakSelf = self;
    [[EOADeviceManager sharedInstance] captureCameraCoverWithSerial:cameraInfo.deviceSerial cameraNo:cameraInfo.cameraNo completion:^(NSString *coverUrl) {
        if (coverUrl)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //先获取图片再刷新tableview
                UIImageView *tempImageView = [[UIImageView alloc] init];
                [tempImageView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    tempImageView.image = image;
                    NSInteger index = [weakSelf.mCameraList indexOfObject:cameraInfo];
                    [weakSelf.previewTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                                 withRowAnimation:UITableViewRowAnimationFade];
                }];
            });
        }
    }];
}

- (void) actionSheetModifyNameProcessWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return;
    }
    
    [EOAModifyNameViewController showModifyNameViewControllerFrom:self cameraInfo:cameraInfo isPresent:YES];
}

- (void) actionSheetMoreProcessWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return;
    }
    
    EOADeviceInfo *deviceInfo = [[EOADeviceManager sharedInstance] getDeviceInfoWithCameraInfo:cameraInfo];
    if (!deviceInfo)
    {
        return;
    }
    
    [self showSettinViewWithDeviceInfo:deviceInfo];
}

- (void) showRealPlayViewWithDeviceInfo:(EOACameraInfo *) cameraInfo
{
    //无通道信息或通道不在线时，直接返回
    if (!cameraInfo || cameraInfo.status != 1)
    {
        return;
    }
    
    [EOARealPlayViewController showRealPlayViewFrom:self cameraInfo:cameraInfo];
}

- (void) showSettinViewWithDeviceInfo:(EOADeviceInfo *) deviceInfo
{
    if (!deviceInfo)
    {
        return;
    }
    
    NSInteger index = [self.mDeviceList indexOfObject:deviceInfo];
    
    [EOASettingViewController showSettingViewFrom:self
                                       deviceInfo:deviceInfo
                                      bgImageName:[[EOADeviceManager sharedInstance] getDeviceBgImageNameWithIndex:index]
                                      needPresent:YES];
}

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceListChanged:)
                                                 name:EOADeviceManagerListChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutNotify:)
                                                 name:EOAUserManagerLogout
                                               object:nil];
}

- (void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) login
{
    __weak EOADeviceViewController *weakSelf = self;
    [EOAHomeViewController loginFrom:self rsult:^(BOOL result) {
        if (result)
        {
            [weakSelf getDeviceList];
        }
    }];
}

- (void) getDeviceList
{
    self.needRefreshCover = YES;
    __weak EOADeviceViewController *weakSelf = self;
    [[EOADeviceManager sharedInstance] getDeviceListWithCompletion:^(RLMResults *deviceList, BOOL result) {
        if(!result)
        {
            [weakSelf.curTableView.mj_header endRefreshing];
            return;
        }
        
        weakSelf.mDeviceList = deviceList;
        [weakSelf makeCameraList];
        [weakSelf refreshTableView];
    }];
}

- (void) updateDeviceList
{
    self.needRefreshCover = YES;
    [[EOADeviceManager sharedInstance] updateDeviceList];
}

- (void) makeCameraList
{
    [self.mCameraList removeAllObjects];
    
    [self.mCameraList addObjectsFromArray:[[EOADeviceManager sharedInstance] getCameraList]];
    
    for (EOACameraInfo *cameraInfo in self.mCameraList)
    {
        cameraInfo.hasRefreshCover = !self.needRefreshCover;
    }
}

- (void) requestCamera
{
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    //摄像头已授权
    if (authorizationStatus == AVAuthorizationStatusAuthorized)
    {
        return;
    }
    
    //摄像头未授权
    if (authorizationStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:nil];
        return;
    }
    
    //摄像头受限
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"device_camra_limited", @"摄像头访问受限")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:NSLocalizedString(@"device_know",@"知道了")
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
        [alert addAction:action];
    }
}

@end
