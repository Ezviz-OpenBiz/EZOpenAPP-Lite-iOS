//
//  EOAHomeViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/1.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAHomeViewController.h"
#import "EOAUserManager.h"
#import "EZOpenSDK.h"

@interface EOAHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic,copy) void(^resultCallback)(BOOL result);

@end

@implementation EOAHomeViewController

+ (void) loginFrom:(UIViewController *) controller rsult:(void(^)(BOOL result)) resultCallback
{
    if (!controller || [EOAUserManager sharedInstance].isLogin)
    {
        return;
    }
    
    EOAHomeViewController *homeVC = [[EOAHomeViewController alloc] init];
    homeVC.resultCallback = resultCallback;
    [controller presentViewController:homeVC animated:NO completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionLabel.text = [NSString stringWithFormat:@"V%@(SDK %@)",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [EZOpenSDK getVersion]];
    
    [self.loginBtn setTitle:NSLocalizedString(@"user_btn_login",@"登录") forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //如果已登录则自动移除本身，如果未登录自动展示登录页
    if ([EZOpenSDK isLogin])
    {
        [self dismissSelf];
    }
    else
    {
        [self showLoginViewController];
    }
}

#pragma mark - actions

- (IBAction)loginBtnClick:(id)sender
{
    [self showLoginViewController];
}


#pragma mark - support

- (void) dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showLoginViewController
{
    if ([EOAUserManager sharedInstance].isLogin)
    {
        return;
    }
    __weak EOAHomeViewController *weakSelf = self;
    [[EOAUserManager sharedInstance] loginWithResult:^(BOOL result) {
        if (result)
        {
            if (weakSelf.resultCallback)
            {
                weakSelf.resultCallback(result);
            }
        }
    }];
}


@end
