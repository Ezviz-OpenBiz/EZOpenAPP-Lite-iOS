//
//  AppDelegate.m
//  EZOpenApp
//
//  Created by linyong on 16/12/22.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "AppDelegate.h"
#import "EOADeviceViewController.h"
#import "EOAMessageViewController.h"
#import "EOAUserViewController.h"
#import "EZOpenSDK.h"
#import <UserNotifications/UserNotifications.h>

#define OPENSDK_APPKEY @"your appkey"

#define BASE_TAG (770)
#define DEVICE_CONTROLLER_TAG (BASE_TAG+1)
#define MESSAGE_CONTROLLER_TAG (BASE_TAG+2)
#define USER_CONTROLLER_TAG (BASE_TAG+3)


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [EZOpenSDK setDebugLogEnable:YES];

    [EZOpenSDK initLibWithAppKey:OPENSDK_APPKEY];//初始化SDK
    
    NSLog(@"==== EZOpenSDK version:%@ ====",[EZOpenSDK getVersion]);
    
    self.window.rootViewController = [self makeRootViewController];

    // Override point for customization after application launch.
    return YES;
}

- (UIViewController *) makeRootViewController
{
    EOADeviceViewController *devVC = [[EOADeviceViewController alloc] init];
    EOABaseNavigationController *devNavc = [[EOABaseNavigationController alloc] initWithRootViewController:devVC];
    devNavc.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_dev_title", @"资源")
                                                       image:[self makeTabbarImageWithName:@"resource_normal"]
                                                         tag:DEVICE_CONTROLLER_TAG];
    devNavc.tabBarItem.selectedImage = [self makeTabbarImageWithName:@"resource_selected"];
    
    EOAMessageViewController *mesVC = [[EOAMessageViewController alloc] init];
    mesVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_mes_title", @"消息")
                                                       image:[self makeTabbarImageWithName:@"message_normal"]
                                                         tag:MESSAGE_CONTROLLER_TAG];
    mesVC.tabBarItem.selectedImage = [self makeTabbarImageWithName:@"message_selected"];
    
    EOAUserViewController *userVC = [[EOAUserViewController alloc] init];
    userVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_user_title", @"我的")
                                                        image:[self makeTabbarImageWithName:@"me_normal"]
                                                          tag:USER_CONTROLLER_TAG];
    userVC.tabBarItem.selectedImage = [self makeTabbarImageWithName:@"me_selected"];
    
    EOABaseTabbarController *tabController = [[EOABaseTabbarController alloc] init];

    tabController.viewControllers = @[devNavc,mesVC,userVC];
    tabController.tabBar.translucent = NO;

    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0],
                                                       NSForegroundColorAttributeName:UIColorFromRGB(0x686880,1.0)}
                                            forState:UIControlStateNormal];
    
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11.0],
                                                       NSForegroundColorAttributeName:UIColorFromRGB(0xf37f4c,1.0)}
                                            forState:UIControlStateSelected];
    
    return tabController;
}


- (UIImage *) makeTabbarImageWithName:(NSString *) imageName
{
    if (!imageName)
    {
        return nil;
    }
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
