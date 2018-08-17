//
//  EOAPlaybackViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/8.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAPlaybackViewController.h"
#import "EZOpenSDK.h"
#import "EZPlayer.h"
#import "EOAVerifyCodeManager.h"
#import "EOAVolumeUtil.h"
#import "EZAlarmInfo.h"
#import "EZDeviceRecordFile.h"
#import "EZCloudRecordFile.h"
#import "Toast+UIView.h"
#import "EOAWaitView.h"
#import "Masonry.h"

@interface EOAPlaybackViewController () <EZPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewBgView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *recordBar;
@property (weak, nonatomic) IBOutlet UIView *recordFlagView;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *playStatuBar;
@property (weak, nonatomic) IBOutlet UILabel *curFlowLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFlowLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UISlider *playTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *curPlayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPlayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (nonatomic,strong) EZAlarmInfo *mAlarmInfo;
@property (nonatomic,strong) EZPlayer *mPlayer;
@property (nonatomic,assign) BOOL isPlaying;//是否正在播放
@property (nonatomic,assign) CGFloat totalFlow;//合计流量
@property (nonatomic,copy) NSString *curVerifyCode;//当前验证码
@property (nonatomic,copy) NSString *recordFilePath;//录像文件路径，指定录像文件存储路径，并且用来判断当前是否正在录像
@property (nonatomic,strong) NSTimer *recordTimer;//录像定时器
@property (nonatomic,assign) NSInteger recordDuration;//录像时长
@property (nonatomic,strong) EZDeviceRecordFile *deviceFile;//设备录像文件
@property (nonatomic,strong) EZCloudRecordFile *cloudFile;//云存储路录像文件
@property (nonatomic,strong) CADisplayLink *mDisplayLink;
@property (nonatomic,assign) BOOL isFullScreen;//是否已全屏显示
@property (nonatomic,assign) BOOL loadEnd;//界面加载完成

@end

@implementation EOAPlaybackViewController

+ (void) showPlaybackViewFrom:(UIViewController *) fromVC alarmInfo:(EZAlarmInfo *) alarmInfo
{
    if (!fromVC || !alarmInfo)
    {
        return;
    }
    
    EOAPlaybackViewController *vc = [[EOAPlaybackViewController alloc] init];
    vc.mAlarmInfo = alarmInfo;
    EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
    
    [fromVC presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc
{
    [self.mPlayer destroyPlayer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"playback_title", @"回放");

    [self initData];
    [self initSubviews];
    [self addBarItem];
    [self addTouch];
    [self addNotifications];
    [self searchRecordFile];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //刷新进度条
    [self createDisplayLink];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.loadEnd = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopLocalRecord];//如果正在录像需停止录像
    
    [self stopPlay];
    self.isPlaying = NO;
    
    [self destroyDisplayLink];
    [self removeNotifications];
}

#pragma mark - actions

- (IBAction)recordBtnClick:(id)sender
{
    if (self.recordFilePath)
    {
        [self stopLocalRecord];
    }
    else
    {
        [self startLocalRecord];
    }
}

- (IBAction)captureBtnClick:(id)sender
{
    UIImage *image = [self.mPlayer capturePicture:100];
    [self saveImageToPhotosAlbumWithImage:image];
}

- (IBAction)fullScreenClick:(id)sender
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    if (self.isFullScreen)
    {
        value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    }
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)playBtnClick:(id)sender
{
    if (self.isPlaying)
    {
        [self pausePlay];
    }
    else
    {
        [self resumePlay];
    }
    
    self.isPlaying = !self.isPlaying;
}

- (IBAction)lowVolumeClick:(id)sender
{
    [[EOAVolumeUtil shareInstance] setSysVolume:0];
}

- (IBAction)highVolumeClick:(id)sender
{
    [[EOAVolumeUtil shareInstance]  setSysVolume:1];
}

- (IBAction)volumeChanged:(id)sender
{
    UISlider *slider = (UISlider *) sender;
    [[EOAVolumeUtil shareInstance]  setSysVolume:slider.value];
}

- (IBAction)playSliderChangeEnd:(id)sender
{
    [self seekToTimeOffset:self.playTimeSlider.value];
}

- (IBAction)playSliderChangeBegin:(id)sender
{
    if (!self.isPlaying)
    {
        return;
    }
    
    self.isPlaying = NO;
    [self pausePlay];
}

- (IBAction)playSliderValueChange:(id)sender
{
    [self updateCurPlayTime];
}

- (void) backBtnClick:(id) sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) previewTouched:(id) sender
{
    self.playStatuBar.hidden = !self.playStatuBar.hidden;
}

#pragma mark - delegate

- (void)player:(EZPlayer *)player didPlayFailed:(NSError *) error
{
    NSLog(@"playback error:%@",error);
    
    [EOAWaitView hideWaitView];

    switch (error.code)
    {
        //34错误特殊处理，重启播放器
        case 34:
        {
            [self restartPlay];
            break;
        }
            
        case EZ_SDK_NEED_VALIDATECODE:
        {
            self.isPlaying = NO;
            [self showNeedVerifyCodeAlert];
            break;
        }
            
        case EZ_SDK_VALIDATECODE_NOT_MATCH:
        {
            self.isPlaying = NO;
            [self showRetryVerifyCodeAlert];
            break;
        }
            
        default:
        {
            [self.view makeToast:NSLocalizedString(@"realplay_play_fail", @"播放失败")  duration:1.5 position:@"center"];
            self.isPlaying = NO;
            break;
        }
    }
}

- (void)player:(EZPlayer *)player didReceivedMessage:(EZMessageCode) messageCode
{
    switch (messageCode)
    {
        case EZ_PLAYBACK_START:
        {
            [EOAWaitView hideWaitView];
            
            self.isPlaying = YES;
            [self updatePlayTotalTime];
            [self updateVerifyCode];
            break;
        }
            
        case EZ_PLAYBACK_STOP:
        {
            self.isPlaying = NO;
            [self playSliderFinished];//播放自然停止时，将播放状态置为结束状态
            [self stopLocalRecord];//如果正在录像需停止录像
            break;
        }

        default:
            break;
    }
}

- (void)player:(EZPlayer *)player didReceivedDataLength:(NSInteger) dataLength
{
    [self updateFlowInfoWith:dataLength];
}

- (void)player:(EZPlayer *)player didReceivedDisplayHeight:(NSInteger) height displayWidth:(NSInteger) width
{
    
}

#pragma mark - orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.loadEnd?UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGRect frame = CGRectZero;
    
    __weak EOAPlaybackViewController *weakSelf = self;
    
    if (size.height > size.width)
    {
        self.isFullScreen = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        frame = CGRectMake(0, 64,size.width,size.width*9/16);
    }
    else
    {
        self.isFullScreen = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        frame = CGRectMake(0, 0,size.width,size.height);
    }
    
    if (self.isFullScreen)
    {
        [self.view bringSubviewToFront:self.previewBgView];
    }
    else
    {
        [self.view sendSubviewToBack:self.previewBgView];
    }
    
    [self.previewBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@(CGRectGetMinY(frame)));
    }];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        weakSelf.previewBgView.frame = frame;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}



#pragma mark - notifications

- (void)systemVolumeChanged:(NSNotification *)notification
{
    self.volumeSlider.value = [[EOAVolumeUtil shareInstance] getSysVolume];
}


#pragma mark - support

- (void) setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    
    [self updateBtns];
}

- (void) initData
{
    self.recordFilePath = nil;
    self.isPlaying = NO;
    self.isFullScreen = NO;
    self.loadEnd = NO;
}

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemVolumeChanged:)
                                                 name:EOASysVolumeChanged
                                               object:nil];
}

- (void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) createDisplayLink
{
    [self destroyDisplayLink];
    
    self.mDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayCallback)];
    self.mDisplayLink.frameInterval = 30;//每秒刷新2次
    [self.mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) destroyDisplayLink
{
    if (!self.mDisplayLink)
    {
        return;
    }
    
    [self.mDisplayLink invalidate];
    self.mDisplayLink = nil;
}

- (void) displayCallback
{
    if (!self.mPlayer || !self.isPlaying)
    {
        return;
    }
    
    NSDate *playDate = [self.mPlayer getOSDTime];
    NSTimeInterval interval = 0;
    if (self.cloudFile)
    {
        interval = [playDate timeIntervalSinceDate:self.cloudFile.startTime];
    }
    else
    {
        interval = [playDate timeIntervalSinceDate:self.deviceFile.startTime];
    }
    
    if (interval < 0)
    {
        return;
    }
    
    self.playTimeSlider.value = interval;
    [self updateCurPlayTime];
}

- (void) searchRecordFile
{
    if (!self.mAlarmInfo)
    {
        return;
    }
    
    NSDate *beginTime = [self.mAlarmInfo.alarmStartTime dateByAddingTimeInterval:-self.mAlarmInfo.preTime];
    NSDate *endTime = [self.mAlarmInfo.alarmStartTime dateByAddingTimeInterval:self.mAlarmInfo.delayTime];
    __weak EOAPlaybackViewController *weakSelf = self;

    //萤石云或百度云
    if (self.mAlarmInfo.recState == 1 || self.mAlarmInfo.recState == 2)
    {
        [EZOpenSDK searchRecordFileFromCloud:self.mAlarmInfo.deviceSerial
                                    cameraNo:self.mAlarmInfo.cameraNo
                                   beginTime:beginTime
                                     endTime:endTime
                                  completion:^(NSArray *couldRecords, NSError *error) {
                                      if (error)
                                      {
                                          NSLog(@"playback search file fail:%@",error);
                                          [weakSelf showNoFile];
                                      }
                                      else
                                      {
                                          if(!couldRecords || couldRecords.count == 0)
                                          {
                                              [weakSelf showNoFile];
                                              return;
                                          }
                                          
                                          weakSelf.cloudFile = [couldRecords firstObject];
                                          
                                          //获取到的文件起始时间早于查询起始时间，则视频起始时间取查询的起始时间
                                          if ([[beginTime laterDate:weakSelf.cloudFile.startTime] isEqualToDate:beginTime])
                                          {
                                              weakSelf.cloudFile.startTime = beginTime;
                                          }
                                          
                                          //获取到的文件结束时间晚于查询结束时间，则视频结束时间取查询的结束时间
                                          if ([[endTime earlierDate:weakSelf.cloudFile.stopTime] isEqualToDate:endTime])
                                          {
                                              weakSelf.cloudFile.stopTime = endTime;
                                          }
                                          
                                          [weakSelf startPlay];
                                      }
                                  }];
    }
    else
    {
        [EZOpenSDK searchRecordFileFromDevice:self.mAlarmInfo.deviceSerial
                                     cameraNo:self.mAlarmInfo.cameraNo
                                    beginTime:beginTime
                                      endTime:endTime
                                   completion:^(NSArray *deviceRecords, NSError *error) {
                                       if (error)
                                       {
                                           NSLog(@"playback search file fail:%@",error);
                                           [weakSelf showNoFile];
                                       }
                                       else
                                       {
                                           if(!deviceRecords || deviceRecords.count == 0)
                                           {
                                               [weakSelf showNoFile];
                                               return;
                                           }
                                           
                                           weakSelf.deviceFile = [deviceRecords firstObject];
                                           
                                           //获取到的文件起始时间早于查询起始时间，则视频起始时间取查询的起始时间
                                           if ([[beginTime laterDate:weakSelf.deviceFile.startTime] isEqualToDate:beginTime])
                                           {
                                               weakSelf.deviceFile.startTime = beginTime;
                                           }
                                           
                                           //获取到的文件结束时间晚于查询结束时间，则视频结束时间取查询的结束时间
                                           if ([[endTime earlierDate:weakSelf.deviceFile.stopTime] isEqualToDate:endTime])
                                           {
                                               weakSelf.deviceFile.stopTime = endTime;
                                           }
                                           
                                           [weakSelf startPlay];
                                       }
                                   }];
    }
}

- (void) updateVerifyCode
{
    if (!self.curVerifyCode)
    {
        return;
    }
    
    [[EOAVerifyCodeManager sharedInstance] updateVerifyCodeWithSerial:self.mAlarmInfo.deviceSerial code:self.curVerifyCode];
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTouched:)];
    
    [self.previewView addGestureRecognizer:tap];
}

- (void) startPlay
{
    if (!self.cloudFile && !self.deviceFile)
    {
        return;
    }
    [EOAWaitView showWaitViewInView:self.previewView frame:self.previewView.bounds];
    if (!self.mPlayer)
    {
        self.mPlayer = [EZPlayer createPlayerWithDeviceSerial:self.mAlarmInfo.deviceSerial cameraNo:self.mAlarmInfo.cameraNo];
        
        if (!self.mPlayer)
        {
            return;
        }
        
        [self.mPlayer setPlayerView:self.previewView];
        self.mPlayer.delegate = self;
        
        if (self.mAlarmInfo.isEncrypt)
        {
            NSString *verifyCode = [[EOAVerifyCodeManager sharedInstance] getVerifyCodeWithSerial:self.mAlarmInfo.deviceSerial];
            if (verifyCode)
            {
                [self.mPlayer setPlayVerifyCode:verifyCode];
                [self startPlay];
            }
            else
            {
                [EOAWaitView hideWaitView];
                [self showNeedVerifyCodeAlert];
            }
        }
        else
        {
            //萤石云
            if (self.cloudFile)
            {
                [self.mPlayer startPlaybackFromCloud:self.cloudFile];
            }
            else
            {
                [self.mPlayer startPlaybackFromDevice:self.deviceFile];
            }
            self.isPlaying = YES;
        }
    }
    else
    {
        //萤石云
        if (self.cloudFile)
        {
            [self.mPlayer startPlaybackFromCloud:self.cloudFile];
        }
        else
        {
            [self.mPlayer startPlaybackFromDevice:self.deviceFile];
        }
        self.isPlaying = YES;
    }
}

- (void) stopPlay
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer stopPlayback];
}

- (void) pausePlay
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer pausePlayback];
}

- (void) resumePlay
{
    if (!self.mPlayer)
    {
        return;
    }
    
    [self.mPlayer resumePlayback];
}

- (void) seekToTimeOffset:(float) offset
{
    if (!self.mPlayer)
    {
        return;
    }
    
    NSDate *beginDate = nil;
    if (self.cloudFile)
    {
        beginDate = self.cloudFile.startTime;
    }
    else
    {
        beginDate = self.deviceFile.startTime;
    }
    
    [self.mPlayer seekPlayback:[beginDate dateByAddingTimeInterval:offset]];
}

- (void) restartPlay
{
    [self stopPlay];
    [self startPlay];
}

- (void) startLocalRecord
{
    if (!self.mPlayer)
    {
        return;
    }
    
    self.recordFilePath = [self getLocalRecordFilePath];
    if (!self.recordFilePath)
    {
        return;
    }
    
    BOOL ret = [self.mPlayer startLocalRecordWithPath:self.recordFilePath];
    if (ret)
    {
        self.recordDuration = 0;
        [self needShowRecordBar:YES];
        [self updateRecordTimerBar];
        [self startRecordTimer];
        self.recordBtn.selected = YES;
    }
}

- (void) stopLocalRecord
{
    if (!self.mPlayer || !self.recordFilePath)
    {
        return;
    }
    
    BOOL ret = [self.mPlayer stopLocalRecord];
    
    if (ret)
    {
        [self needShowRecordBar:NO];
        [self stopRecordTimer];
        self.recordBtn.selected = NO;
        [self saveRecordToPhotosAlbumWithPath:self.recordFilePath];
    }
    
    self.recordFilePath = nil;
}

- (void) startRecordTimer
{
    [self stopRecordTimer];
    
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTimerCallback) userInfo:nil repeats:YES];
}

- (void) stopRecordTimer
{
    if (!self.recordTimer)
    {
        return;
    }
    
    if ([self.recordTimer isValid])
    {
        [self.recordTimer invalidate];
    }
    
    self.recordTimer = nil;
}

- (void) recordTimerCallback
{
    if (!self.isPlaying)
    {
        return;
    }
    self.recordDuration += 1;
    [self updateRecordTimerBar];
}

- (NSString *) getLocalRecordFilePath
{
    NSDateFormatter *dateFormatter = [EOAHelper getDateFormatterWithFormatterString:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4",[dateFormatter stringFromDate:[NSDate date]]];
    
    NSArray * docdirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docdir = [docdirs objectAtIndex:0];
    NSString * recordFilePath = [docdir stringByAppendingPathComponent:@"record"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:recordFilePath])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:recordFilePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    
    NSString *destFilePath = [recordFilePath stringByAppendingPathComponent:fileName];
    
    return destFilePath;
}

- (void)saveImageToPhotosAlbumWithImage:(UIImage *) savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)saveRecordToPhotosAlbumWithPath:(NSString *) path
{
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = nil;
    if (!error)
    {
        message = NSLocalizedString(@"realplay_save_sucess", @"保存成功");
    }
    else
    {
        message = NSLocalizedString(@"realplay_save_fail", @"保存失败");
    }
    
    [self.view makeToast:message duration:1.5 position:@"center"];
}


#pragma mark - view

- (void) initSubviews
{
    self.deviceNameLabel.text = self.mAlarmInfo.deviceName;
    self.deviceTypeLabel.text = [NSString stringWithFormat:@"%@(%@)",self.mAlarmInfo.category,self.mAlarmInfo.deviceSerial];
    self.volumeSlider.value = [[EOAVolumeUtil shareInstance] getSysVolume];
    
    self.recordBar.layer.cornerRadius = CGRectGetHeight(self.recordBar.frame)/4;
    self.recordBar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.recordFlagView.layer.cornerRadius = CGRectGetWidth(self.recordFlagView.frame)/2;
    
    [self.playTimeSlider setThumbImage:[UIImage imageNamed:@"btn_little_round"] forState:UIControlStateNormal];
}

- (void) addBarItem
{
    UIBarButtonItem *leftBarBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_return"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backBtnClick:)];
    [leftBarBtnItem setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.leftBarButtonItem = leftBarBtnItem;
}

- (void) playSliderFinished
{
    self.playTimeSlider.value = self.playTimeSlider.maximumValue;
    
    self.curPlayTimeLabel.text = self.totalPlayTimeLabel.text;
}

- (void) updateBtns
{
    self.recordBtn.userInteractionEnabled = self.isPlaying;
    self.captureBtn.userInteractionEnabled = self.isPlaying;
    [self updatePlayBtn];
}

- (void) updatePlayBtn
{
    if (self.isPlaying)
    {
        [self.playBtn setImage:[UIImage imageNamed:@"btn_stop_n"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playBtn setImage:[UIImage imageNamed:@"btn_play_n"] forState:UIControlStateNormal];
    }
}

- (void) updateFlowInfoWith:(NSInteger) dataLength
{
    self.totalFlow += dataLength;
    
    //小于1MB
    if (dataLength < 1024 * 1024)
    {
        self.curFlowLabel.text = [NSString stringWithFormat:@"%@%.1fKB/s",
                                  NSLocalizedString(@"realplay_flow_current", @"当前："),
                                  dataLength/1024.0];
    }
    //大于1MB
    else
    {
        self.curFlowLabel.text = [NSString stringWithFormat:@"%@%.1fMB/s",
                                  NSLocalizedString(@"realplay_flow_current", @"当前："),
                                  dataLength/1024.0/1024];
    }
    
    //小于1MB
    if (self.totalFlow < 1024 * 1024)
    {
        self.totalFlowLabel.text = [NSString stringWithFormat:@"%@%.1fKB",
                                    NSLocalizedString(@"realplay_flow_total", @"合计："),
                                    self.totalFlow/1024];
    }
    //小于1GB
    else if (self.totalFlow < 1024 * 1024 * 1024)
    {
        self.totalFlowLabel.text = [NSString stringWithFormat:@"%@%.3fMB",
                                    NSLocalizedString(@"realplay_flow_total", @"合计："),
                                    self.totalFlow/1024/1024];
    }
    //大于1GB
    else
    {
        self.totalFlowLabel.text = [NSString stringWithFormat:@"%@%.3fGB",
                                    NSLocalizedString(@"realplay_flow_total", @"合计："),
                                    self.totalFlow/1024/1024/1024];
    }
}


- (void) needShowRecordBar:(BOOL) needShow
{
    self.recordBar.hidden = !needShow;
}

- (void) updateRecordTimerBar
{
    self.recordFlagView.hidden = self.recordDuration%2 == 0;
    
    self.recordTimeLabel.text = [self makePlayTimeWithInterval:self.recordDuration needHour:YES];
}

- (void) updateCurPlayTime
{
    self.curPlayTimeLabel.text = [self makePlayTimeWithInterval:(NSInteger)self.playTimeSlider.value needHour:NO];
}

- (void) updatePlayTotalTime
{
    NSTimeInterval totalDuration = 0;
    
    if (self.cloudFile)
    {
        totalDuration = [self.cloudFile.stopTime timeIntervalSinceDate:self.cloudFile.startTime];
    }
    else
    {
        totalDuration = [self.deviceFile.stopTime timeIntervalSinceDate:self.deviceFile.startTime];
    }
    
    self.playTimeSlider.maximumValue = totalDuration;
    
    self.totalPlayTimeLabel.text = [self makePlayTimeWithInterval:(NSInteger)totalDuration needHour:NO];
}


- (NSString *) makePlayTimeWithInterval:(NSInteger) timeInterval needHour:(BOOL) needHour
{
    NSInteger hour = 0,min = 0,sec = 0;
    
    sec = timeInterval % 60;
    
    if (needHour)
    {
        min = (timeInterval / 60) % 60;
        hour = timeInterval / 3600;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,min,sec];
    }
    else
    {
        min = timeInterval / 60;
        return [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
    }
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
    __weak EOAPlaybackViewController *weakSelf = self;
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
                                                              weakSelf.curVerifyCode = textField.text;
                                                              [weakSelf.mPlayer setPlayVerifyCode:textField.text];
                                                              [weakSelf startPlay];
                                                          }];
    
    
    [verifyCodeAlert addAction:cancelAction];
    [verifyCodeAlert addAction:confirmAction];
    
    [self presentViewController:verifyCodeAlert animated:YES completion:nil];
}

- (void) showNoFile
{
    [self.view makeToast:NSLocalizedString(@"playback_search_fail", @"未找到视频文件")
                duration:1.5
                position:@"center"];
}


@end
