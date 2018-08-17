//
//  EOAMessageViewController.m
//  EZOpenApp
//
//  Created by linyong on 16/12/27.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOAMessageViewController.h"
#import "EOAMessageManager.h"
#import "EZAlarmInfo.h"
#import "EOAMessageTypeInfo.h"
#import "EOAMessageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "EOAImageManager.h"
#import "EOAVerifyCodeManager.h"
#import "EOAUserManager.h"
#import "EOAPlaybackViewController.h"
#import "EOADisplayImageView.h"

#define MESSAGE_TABLE_CELL_ID @"MESSAGE_TABLE_CELL_ID"
#define MESSAGE_TABLE_CELL_HEIGHT (96.0)
#define MESSAGE_TABLE_HEIGHT_HEIGHT (35.0)
#define ALARM_TYPE_OTHER_ID (99999)//其他报警类型约定为99999

@interface EOAMessageViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic,strong) NSMutableArray *headList;//tableView各section的header title
@property (nonatomic,strong) NSMutableDictionary *messageDic;//按日期分类的报警消息
@property (nonatomic,strong) NSDictionary *messageTypeInfoDic;//报警类别信息 EOAMessageTyepInfo
@property (nonatomic,strong) EZAlarmInfo *curAlarmInfo;

@end

@implementation EOAMessageViewController

- (void)dealloc
{
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    [self initSubviews];
    [self addNotifications];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.headList.count <= 0)
    {
        [self getAlarmData];
    }
}

#pragma mark - actions


#pragma mark - notifications

- (void) logoutNotify:(NSNotification *) notification
{
    //注销时，清空数据，再次进入该界面时进行刷新
    [self clearData];
    [self refreshTableView];
}

- (void) verifyCodeChanged:(NSNotification *) notification
{
    [self refreshTableView];
}

#pragma mark - tableView delegate & dataSource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MESSAGE_TABLE_CELL_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return MESSAGE_TABLE_HEIGHT_HEIGHT;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.headList.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.headList.count <= section)
    {
        return 0;
    }
    
    NSArray *tempArray = [self.messageDic objectForKey:[self.headList objectAtIndex:section]];
    
    if (!tempArray)
    {
        return 0;
    }
    
    return tempArray.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, CGRectGetWidth(self.mainTable.frame), MESSAGE_TABLE_HEIGHT_HEIGHT);
    header.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(10, 0, CGRectGetWidth(header.frame)-10, CGRectGetHeight(header.frame));
    headerLabel.text = [self.headList objectAtIndex:section];
    headerLabel.backgroundColor = [UIColor clearColor];
    [header addSubview:headerLabel];
    
    return header;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EOAMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MESSAGE_TABLE_CELL_ID forIndexPath:indexPath];
    EZAlarmInfo *alarmInfo = [[self.messageDic objectForKey:[self.headList objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    EOAMessageTypeInfo *typeInfo = [self.messageTypeInfoDic objectForKey:[NSNumber numberWithInteger:alarmInfo.alarmType]];
    if (!typeInfo || [typeInfo isKindOfClass:[NSNull class]])
    {
        //其他报警类型约定为ALARM_TYPE_OTHER_ID
        typeInfo = [self.messageTypeInfoDic objectForKey:[NSNumber numberWithInteger:ALARM_TYPE_OTHER_ID]];
    }
    
    cell.typeImageView.image = [UIImage imageNamed:typeInfo.imageName];
    cell.typeLabel.text = typeInfo.typeName;
    cell.typeLabel.textColor = typeInfo.color;
    cell.deviceNameLabel.text = alarmInfo.deviceName;
    cell.deviceTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",alarmInfo.category,alarmInfo.deviceSerial];
    NSDateFormatter *formatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyy-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [formatter stringFromDate:alarmInfo.alarmStartTime];
    cell.imageUrl = alarmInfo.alarmPicUrl;
    if ([alarmInfo.alarmPicUrl containsString:@"isEncrypted=1"])//根据图片URL信息判断是否加密，图片的加密状态与设备的加密状态并不一致
    {
        cell.contentImageView.image = [UIImage imageNamed:@"alarm_encrypt_image_mid"];
        NSString *verifyCode = [[EOAVerifyCodeManager sharedInstance] getVerifyCodeWithSerial:alarmInfo.deviceSerial];
        if (verifyCode)//缓存中有验证码时才进行解密
        {
            [[EOAImageManager sharedInstance] decodeImageWithUrl:alarmInfo.alarmPicUrl
                                                      verifyCode:verifyCode
                                                      completion:^(UIImage *image,NSString *sourceUrl) {
                                                          //图片解密成功并且url匹配，防止cell重用导致图片不匹配
                                                          if (image && [cell.imageUrl isEqualToString:sourceUrl])
                                                          {
                                                              cell.contentImageView.image = image;
                                                          }
                                                      }];
        }
    }
    else
    {
        cell.contentImageView.image = [UIImage imageNamed:@"device_other"];//设置默认图片，防止重用时图片不匹配
        [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:alarmInfo.alarmPicUrl]
                                 placeholderImage:nil
                                          options:SDWebImageAvoidAutoSetImage | SDWebImageCacheMemoryOnly | SDWebImageDelayPlaceholder
                                        completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                            //图片获取成功并且url匹配，防止cell重用导致图片不匹配
                                            if (image && [cell.imageUrl isEqualToString:imageURL.absoluteString])
                                            {
                                                cell.contentImageView.image = image;
                                            }
                                        }];
    }

    cell.videoFlagView.hidden = alarmInfo.recState == 0;//recState为0则表示无录像存储，仅有图片
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView
//commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZAlarmInfo *alarmInfo = [[self.messageDic objectForKey:[self.headList objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];
    if (!alarmInfo)
    {
        return;
    }
    __weak EOAMessageViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (alarmInfo.recState == 0)//recState为0则表示无录像存储，仅有图片
        {
            if ([alarmInfo.alarmPicUrl containsString:@"isEncrypted=1"])//根据图片URL信息判断是否加密，图片的加密状态与设备的加密状态并不一致
            {
                NSString *verifyCode = [[EOAVerifyCodeManager sharedInstance] getVerifyCodeWithSerial:alarmInfo.deviceSerial];
                if (verifyCode)
                {
                    [[EOAImageManager sharedInstance] decodeImageWithUrl:alarmInfo.alarmPicUrl
                                                              verifyCode:verifyCode
                                                              completion:^(UIImage *image,NSString *sourceUrl) {
                                                                  [weakSelf showDisplayImageViewWithImage:image];
                                                              }];
                }
                else
                {
                    self.curAlarmInfo = alarmInfo;
                    [self showNeedVerifyCodeAlert];
                }
            }
            else
            {
                [weakSelf showDisplayImageViewWithUrl:alarmInfo.alarmPicUrl];
            }
        }
        else
        {
            [EOAPlaybackViewController showPlaybackViewFrom:self alarmInfo:alarmInfo];
        }
    });
}

#pragma mark - views

- (void) initSubviews
{
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    [self.mainTable registerNib:[UINib nibWithNibName:@"EOAMessageTableViewCell" bundle:nil]
         forCellReuseIdentifier:MESSAGE_TABLE_CELL_ID];
    self.mainTable.tableFooterView = [UIView new];
    
    __weak EOAMessageViewController *weakSelf = self;
    self.mainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getMessageFromTop:YES];
    }];
    
    self.mainTable.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        if (![EOAMessageManager sharedInstance].noMore)
        {
            [weakSelf getMessageFromTop:NO];
        }
    }];
}

- (void) endRefresh
{
    if (self.mainTable.mj_header.state == MJRefreshStateRefreshing)
    {
        [self.mainTable.mj_header endRefreshing];
    }
    
    if (self.mainTable.mj_footer.state == MJRefreshStateRefreshing)
    {
        if ([EOAMessageManager sharedInstance].noMore)
        {
            [self.mainTable.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [self.mainTable.mj_footer endRefreshing];
        }
    }
}

- (void) refreshTableView
{
    [self.mainTable reloadData];
}

- (void) showDisplayImageViewWithImage:(UIImage *) image
{
    if (!image)
    {
        return;
    }
    
    EOADisplayImageView *displayView = [[EOADisplayImageView alloc] initWithFrame:self.view.bounds image:image];
    [displayView showInView:self.view];
}

- (void) showDisplayImageViewWithUrl:(NSString *) imageUrl
{
    if (!imageUrl)
    {
        return;
    }
    
    EOADisplayImageView *displayView = [[EOADisplayImageView alloc] initWithFrame:self.view.bounds imageUrl:imageUrl];
    [displayView showInView:self.view];
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
    __weak EOAMessageViewController *weakSelf = self;
    UIAlertController *verifyCodeAlert = [UIAlertController alertControllerWithTitle:title
                                                                             message:NSLocalizedString(@"verify_code_message", @"verify_code_message")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [verifyCodeAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel",@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_ok",@"确定")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              UITextField *textField =[verifyCodeAlert.textFields firstObject];
                                                              [[EOAImageManager sharedInstance] decodeImageWithUrl:weakSelf.curAlarmInfo.alarmPicUrl
                                                                                                        verifyCode:textField.text
                                                                                                        completion:^(UIImage *image,NSString *sourceUrl) {
                                                                                                            if (!image)
                                                                                                            {
                                                                                                                [weakSelf showRetryVerifyCodeAlert];
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                [weakSelf updateVerifyCode:textField.text deviceSerial:weakSelf.curAlarmInfo.deviceSerial];
                                                                                                                [weakSelf showDisplayImageViewWithImage:image];
                                                                                                                [weakSelf.mainTable reloadData];
                                                                                                            }
                                                                                                        }];
                                                          }];
    
    
    [verifyCodeAlert addAction:cancelAction];
    [verifyCodeAlert addAction:confirmAction];
    
    [self presentViewController:verifyCodeAlert animated:YES completion:nil];
}


#pragma mark - support

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutNotify:)
                                                 name:EOAUserManagerLogout
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(verifyCodeChanged:)
                                                 name:EOAVerifyCodeChanged
                                               object:nil];
}

- (void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) getAlarmData
{
    [self.mainTable.mj_header beginRefreshing];
}

- (EOAMessageTypeInfo *) createMessageTypeInfoWithNum:(NSInteger) alarmNum image:(NSString *) imageName name:(NSString *) typeName color:(UIColor *) color
{
    EOAMessageTypeInfo *info = [[EOAMessageTypeInfo alloc] init];
    info.typeNum = alarmNum;
    info.imageName = imageName;
    info.typeName = typeName;
    info.color = color;
    
    return info;
}

- (void) getMessageFromTop:(BOOL) fromTop
{
    if (fromTop && self.mainTable.mj_footer.state == MJRefreshStateNoMoreData)
    {
        [self.mainTable.mj_footer resetNoMoreData];
    }
    
    __weak EOAMessageViewController *weakSelf = self;
    [[EOAMessageManager sharedInstance] getAlarmMessageFromTop:fromTop Completion:^(BOOL result) {
        [weakSelf endRefresh];
        if (result)
        {
            [weakSelf updateData];
            [weakSelf refreshTableView];
        }
    }];
}

- (void) clearData
{
    [self.headList removeAllObjects];

    [self.messageDic removeAllObjects];
}

- (void) updateData
{
    NSDateFormatter *formatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyy-MM-dd"];
    NSString *dateStr = nil;
    NSMutableArray *alarmList = nil;
    
    [self clearData];
    
    for (EZAlarmInfo *alarmInfo in [EOAMessageManager sharedInstance].messageList)
    {
        NSString *tempStr = [formatter stringFromDate:alarmInfo.alarmStartTime];
        
        if (dateStr && [dateStr isEqualToString:tempStr])
        {
            [alarmList addObject:alarmInfo];
        }
        else
        {
            if (dateStr)
            {
                [self.messageDic setObject:alarmList forKey:dateStr];
            }
            dateStr = tempStr;
            [self.headList addObject:dateStr];
            alarmList = [NSMutableArray array];
            [alarmList addObject:alarmInfo];
        }
    }
    
    if (alarmList)
    {
        [self.messageDic setObject:alarmList forKey:dateStr];
    }
}

- (void) initData
{
    self.headList = [NSMutableArray array];
    self.messageDic = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *typeInfo = [NSMutableDictionary dictionary];
    
    //红外报警
    [typeInfo setObject:[self createMessageTypeInfoWithNum:10000
                                                     image:@"message_infrared"
                                                      name:NSLocalizedString(@"message_infrared", @"红外感应")
                                                     color:UIColorFromRGB(0xe56180,1.0)]
                 forKey:[NSNumber numberWithInteger:10000]];
    //移动侦测报警
    [typeInfo setObject:[self createMessageTypeInfoWithNum:10002
                                                     image:@"message_move"
                                                      name:NSLocalizedString(@"message_move",@"移动侦测")
                                                     color:UIColorFromRGB(0x58cd72,1.0)]
                 forKey:[NSNumber numberWithInteger:10002]];
    //水侵报警
    [typeInfo setObject:[self createMessageTypeInfoWithNum:10008
                                                     image:@"message_water"
                                                      name:NSLocalizedString(@"message_water",@"水警")
                                                     color:UIColorFromRGB(0x7cb5f6,1.0)]
                 forKey:[NSNumber numberWithInteger:10008]];
    //热成像火点报警
    [typeInfo setObject:[self createMessageTypeInfoWithNum:10041
                                                     image:@"message_fire"
                                                      name:NSLocalizedString(@"message_fire",@"火点报警")
                                                     color:UIColorFromRGB(0xf87272,1.0)]
                 forKey:[NSNumber numberWithInteger:10041]];
    //其他报警
    [typeInfo setObject:[self createMessageTypeInfoWithNum:ALARM_TYPE_OTHER_ID
                                                     image:@"message_other"
                                                      name:NSLocalizedString(@"message_other",@"其他报警")
                                                     color:UIColorFromRGB(0x697389,1.0)]
                 forKey:[NSNumber numberWithInteger:ALARM_TYPE_OTHER_ID]];

    self.messageTypeInfoDic = typeInfo;
}

- (void) updateVerifyCode:(NSString *) verifyCode deviceSerial:(NSString *) deviceSerial
{
    if (!verifyCode || !deviceSerial)
    {
        return;
    }
    
    [[EOAVerifyCodeManager sharedInstance] updateVerifyCodeWithSerial:deviceSerial code:verifyCode];
}



@end
