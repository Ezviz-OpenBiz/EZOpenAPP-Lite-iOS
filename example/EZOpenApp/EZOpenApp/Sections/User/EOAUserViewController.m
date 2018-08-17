//
//  EOAUserViewController.m
//  EZOpenApp
//
//  Created by linyong on 16/12/27.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOAUserViewController.h"
#import "EOAUserManager.h"
#import "EZOpenSDK.h"
#import "EOAHomeViewController.h"

#define USER_TABLEVIEW_ID @"USER_TABLEVIEW_ID"
#define USER_TABLEVIEW_CELL_HEIGHT (50)
#define USER_TABLEVIEW_COUNT (1)

@interface EOAUserViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation EOAUserViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //布局完成后，重新设置tableview的frame
    [self relocateViews];
}


#pragma mark - actions

- (IBAction)loginBtnClick:(id)sender
{
    if ([EOAUserManager sharedInstance].isLogin)
    {
        [self showLogoutAlert];
    }
}


#pragma mark - tableView delegate & dataSource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_TABLEVIEW_CELL_HEIGHT;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return USER_TABLEVIEW_COUNT;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_TABLEVIEW_ID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch ([indexPath row])
    {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"user_table_password", @"修改密码");
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath row])
    {
        case 0:
        {
            [[EOAUserManager sharedInstance] changePassword];
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - views

- (void) initSubviews
{
    self.versionLabel.text = [NSString stringWithFormat:@"V%@(SDK %@)",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [EZOpenSDK getVersion]];
    self.textLabel.text = NSLocalizedString(@"user_app_description",@"Lite版本基于“萤石云开放平台”的SDK\r\n完整体验，请使用萤石云视频");
    self.companyLabel.text = NSLocalizedString(@"user_company",@"©2017杭州萤石网络有限公司");
    [self.loginBtn setTitle:NSLocalizedString(@"user_btn_switch",@"切换帐号") forState:UIControlStateNormal];
    
    [self initTableView];
}

- (void) initTableView
{
    self.mainTable.dataSource = self;
    self.mainTable.delegate = self;
    self.mainTable.scrollEnabled = NO;
    self.mainTable.tableFooterView = [[UIView alloc] init];
    [self.mainTable registerClass:[UITableViewCell class] forCellReuseIdentifier:USER_TABLEVIEW_ID];
}

- (void) relocateViews
{
    CGRect rect = self.mainTable.frame;
    self.mainTable.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect),
                                      CGRectGetWidth(rect), USER_TABLEVIEW_COUNT*USER_TABLEVIEW_CELL_HEIGHT);
}

- (void) showLogoutAlert
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_alert_title",@"确定退出")
                                                                    message:NSLocalizedString(@"user_alert_message",@"退出后将需要重新登录，确定要退出？")
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_cancel",@"取消")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_ok",@"确定")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [[EOAUserManager sharedInstance] logout];
                                                              
                                                              [EOAHomeViewController loginFrom:self rsult:^(BOOL result) {
                                                                  
                                                              }];
                                                          }];

    
    [alertC addAction:cancelAction];
    [alertC addAction:confirmAction];
    
    [self presentViewController:alertC animated:YES completion:nil];
}


@end
