//
//  EOAMessageManager.m
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOAMessageManager.h"
#import "EZOpenSDK.h"
#import "EZAlarmInfo.h"


#define DAY_INTERVAL (-3600*24*7)//消息保存7天，获取最近7天的所有报警消息
#define MESSAGE_PAGE_SIZE (20)//一页的消息条数

@interface EOAMessageManager ()

@property (nonatomic,strong) NSDate *currentStartTime;//当前开始获取起始时间点
@property (nonatomic,assign) NSInteger currentPageIndex;//当前开始消息页索引

@end

@implementation EOAMessageManager

+ (EOAMessageManager*) sharedInstance
{
    static EOAMessageManager *gMessageManager = nil;
    static dispatch_once_t messageOnceToken;
    dispatch_once(&messageOnceToken, ^{
        gMessageManager = [[EOAMessageManager alloc] init];
    });
    return gMessageManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _messageList = [NSMutableArray array];
        _noMore = NO;
    }
    return self;
}

- (void) getAlarmMessageFromTop:(BOOL) fromTop Completion:(void(^)(BOOL result)) completion
{
    if (fromTop || !self.currentStartTime)//从顶部获取时更新起始时间
    {
        _noMore = NO;
        self.currentStartTime = [NSDate date];
        self.currentPageIndex = 0;
        [self.messageList removeAllObjects];
    }
    __weak EOAMessageManager *weakSelf = self;
    [EZOpenSDK getAlarmList:nil
                  pageIndex:self.currentPageIndex
                   pageSize:MESSAGE_PAGE_SIZE
                  beginTime:[self.currentStartTime dateByAddingTimeInterval:DAY_INTERVAL]
                    endTime:self.currentStartTime
                 completion:^(NSArray *alarmList, NSInteger totalCount, NSError *error) {
                     BOOL result = YES;
                     if (error)
                     {
                         result = NO;
                     }
                     else
                     {
                         weakSelf.currentPageIndex ++;
                         [weakSelf.messageList addObjectsFromArray:alarmList];
                         
                         if (totalCount <= MESSAGE_PAGE_SIZE)
                         {
                             _noMore = YES;
                         }
                         result = YES;
                     }
                     
                     if (completion)
                     {
                         completion(result);
                     }
                     
                 }];
}


@end
