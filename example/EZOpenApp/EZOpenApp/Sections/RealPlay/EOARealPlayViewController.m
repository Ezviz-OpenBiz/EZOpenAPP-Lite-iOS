//
//  EOARealPlayViewController.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/8.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "EOARealPlayViewController.h"
#import "EOASettingViewController.h"
#import "EOADeviceManager.h"
#import "EOAVerifyCodeManager.h"
#import "EOACameraInfo.h"
#import "EOADeviceInfo.h"
#import "EZOpenSDK.h"
#import "EZPlayer.h"
#import "EZTalk.h"
#import "EOAVolumeUtil.h"
#import "EOAVideoQualitySelectView.h"
#import "EOAVideoQualityInfo.h"
#import "Toast+UIView.h"
#import "EOAWaitView.h"
#import "EOATalkView.H"
#import "Masonry.h"

#define QUALITY_VIEW_HEIGHT (45)

@interface EOARealPlayViewController () <EZPlayerDelegate,EZTalkDelegate>
@property (weak, nonatomic) IBOutlet UIView *previewBgView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *statuBar;
@property (weak, nonatomic) IBOutlet UILabel *curFlowLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFlowLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIView *recordTimerBar;
@property (weak, nonatomic) IBOutlet UIView *recordFlagView;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (nonatomic,strong) EOAVideoQualitySelectView *videoQualityView;

@property (nonatomic,strong) EOACameraInfo *mCameraInfo;
@property (nonatomic,strong) EOADeviceInfo *mDeviceInfo;
@property (nonatomic,strong) EZPlayer *mPreviewPlayer;//预览播放器
@property (nonatomic,strong) EZTalk *mTalkPlayer;//对讲播放器
@property (nonatomic,assign) BOOL isPlaying;//是否正在播放
@property (nonatomic,assign) CGFloat totalFlow;//合计流量
@property (nonatomic,copy) NSString *curVerifyCode;//当前验证码
@property (nonatomic,copy) NSString *recordFilePath;//录像文件路径，指定录像文件存储路径，并且用来判断当前是否正在录像
@property (nonatomic,strong) NSTimer *recordTimer;//录像定时器
@property (nonatomic,assign) NSInteger recordDuration;//录像时长
@property (nonatomic,assign) BOOL isFullScreen;//是否已全屏显示
@property (nonatomic,assign) BOOL loadEnd;//界面加载完成
@property (nonatomic,assign) BOOL needRefresh;

@end

@implementation EOARealPlayViewController

+ (void) showRealPlayViewFrom:(UIViewController *) fromVC cameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!fromVC || !cameraInfo)
    {
        return;
    }
    EOARealPlayViewController *vc = [[EOARealPlayViewController alloc] init];
    vc.mCameraInfo = cameraInfo;
    EOABaseNavigationController *nav = [[EOABaseNavigationController alloc] initWithRootViewController:vc];
    
    [fromVC presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc
{
    [self releasePlayers];
    [self removeNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"device_title_preview", @"预览");
    
    [self initData];
    [self initSubviews];
    [self addBarItem];
    [self addTouch];
    [self addNotifications];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.needRefresh)
    {
        self.needRefresh = NO;
        [self updateLabels];
        [self releasePlayers];
    }
    
    [self startPlay];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.loadEnd = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopLocalRecord];

    [self stopPlay];
    self.isPlaying = NO;
}

#pragma mark - actions

- (void) backBtnClick:(id) sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
        [self stopLocalRecord];
        [self stopPlay];
    }
    else
    {
        [self startPlay];
    }
}

- (IBAction)talkBtnClick:(id)sender
{
    [EOAWaitView showWaitViewInView:self.view frame:self.view.bounds];
    [self startVoiceTalk];
}

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
    UIImage *image = [self.mPreviewPlayer capturePicture:100];
    [self saveImageToPhotosAlbumWithImage:image];
}

- (IBAction)moreBtnClick:(id)sender
{
    NSInteger index = [[EOADeviceManager sharedInstance].mDeviceList indexOfObject:self.mDeviceInfo];

    [EOASettingViewController showSettingViewFrom:self
                                       deviceInfo:self.mDeviceInfo
                                      bgImageName:[[EOADeviceManager sharedInstance] getDeviceBgImageNameWithIndex:index]
                                      needPresent:NO];
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

- (void) previewTouched:(id) sender
{
    self.statuBar.hidden = !self.statuBar.hidden;
}

#pragma mark - delegate

- (void)player:(EZPlayer *)player didPlayFailed:(NSError *) error
{
    NSLog(@"realplay error:%@",error);
    
    [EOAWaitView hideWaitView];
    
    switch (error.code)
    {
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
            if ([player isEqual:self.mPreviewPlayer])
            {
                self.isPlaying = NO;
            }
            break;
        }
    }
}

- (void)player:(EZPlayer *)player didReceivedMessage:(EZMessageCode) messageCode
{
    switch (messageCode)
    {
        case EZ_REALPLAY_START:
        {
            [EOAWaitView hideWaitView];
            self.isPlaying = YES;
            [self updateVerifyCode];
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


- (void)talkPlayer:(EZTalk *)talk didPlayFailed:(NSError *)error
{
    NSLog(@"Voice talk error:%@",error);
    
    [EOAWaitView hideWaitView];
    
    [self stopVoiceTalk];
    [self.view makeToast:NSLocalizedString(@"realplay_talk_fail", @"对讲失败")  duration:1.5 position:@"center"];
}

- (void)talkPlayer:(EZTalk *)talk didReceivedMessage:(EZTalkMessageCode)messageCode
{
    switch (messageCode)
    {
        case EZ_VOICE_TALK_START:
        {
            if (self.mPreviewPlayer)
            {
                [self.mPreviewPlayer closeSound];
            }
            [EOAWaitView hideWaitView];
            [self showTalkView];
            break;
        }

        case EZ_VOICE_TALK_END:
        {
            if (self.mPreviewPlayer)
            {
                [self.mPreviewPlayer openSound];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.loadEnd?UIInterfaceOrientationMaskAll:UIInterfaceOrientationMaskPortrait;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    CGRect frame = CGRectZero;
    
    __weak EOARealPlayViewController *weakSelf = self;
    
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

- (void)deviceInfoChanged:(NSNotification *)notification
{
    self.needRefresh = YES;
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
    self.needRefresh = NO;
    self.mDeviceInfo = [[EOADeviceManager sharedInstance] getDeviceInfoWithCameraInfo:self.mCameraInfo];
}

- (void) updateVerifyCode
{
    if (!self.curVerifyCode)
    {
        return;
    }
    
    [[EOAVerifyCodeManager sharedInstance] updateVerifyCodeWithSerial:self.mCameraInfo.deviceSerial code:self.curVerifyCode];
}

- (void) addTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTouched:)];
    
    [self.previewView addGestureRecognizer:tap];
}

- (void) startPlay
{
    CGRect indicatorFrame;
    if ([UIScreen mainScreen].bounds.size.width != CGRectGetWidth(self.previewView.bounds))
    {
         indicatorFrame = CGRectMake(0, 0,
                                     [UIScreen mainScreen].bounds.size.width,
                                     [UIScreen mainScreen].bounds.size.width*9/16);
    }
    else
    {
        indicatorFrame = self.previewView.bounds;
    }
    
    [EOAWaitView showWaitViewInView:self.previewView frame:indicatorFrame];

    
    if (self.mPreviewPlayer)
    {
        [self.mPreviewPlayer startRealPlay];
        self.isPlaying = YES;
        return;
    }
    
    self.mPreviewPlayer = [EZPlayer createPlayerWithDeviceSerial:self.mCameraInfo.deviceSerial cameraNo:self.mCameraInfo.cameraNo];
    
    if (!self.mPreviewPlayer)
    {
        return;
    }
    
    [self.mPreviewPlayer setPlayerView:self.previewView];
    self.mPreviewPlayer.delegate = self;
    
    if (self.mDeviceInfo.isEncrypt)
    {
        NSString *verifyCode = [[EOAVerifyCodeManager sharedInstance] getVerifyCodeWithSerial:self.mCameraInfo.deviceSerial];
        if (verifyCode)
        {
            [self.mPreviewPlayer setPlayVerifyCode:verifyCode];
            [self.mPreviewPlayer startRealPlay];
            self.isPlaying = YES;
        }
        else
        {
            [EOAWaitView hideWaitView];
            [self showNeedVerifyCodeAlert];
        }
    }
    else
    {
        [self.mPreviewPlayer startRealPlay];
        self.isPlaying = YES;
    }
}

- (void) stopPlay
{
    self.isPlaying = NO;
    if (!self.mPreviewPlayer)
    {
        return;
    }
    
    [self.mPreviewPlayer stopRealPlay];
}

- (void) restartPlay
{
    [self stopPlay];
    [self startPlay];
}

- (void) startVoiceTalk
{
    __weak EOARealPlayViewController *wSelf = self;
    
    [self requestMicPermissionCompletion:^(BOOL ret) {
        if (!ret)
        {
            [EOAWaitView hideWaitView];
            [wSelf.view makeToast:NSLocalizedString(@"realplay_talk_no_mic_permisson", @"麦克风未授权")  duration:1.5 position:@"center"];
            return;
        }
        
        if (!wSelf.mTalkPlayer)
        {
            wSelf.mTalkPlayer = [EZTalk createTalkWithDeviceSerial:wSelf.mCameraInfo.deviceSerial
                                                          cameraNo:wSelf.mCameraInfo.cameraNo];
            wSelf.mTalkPlayer.delegate = self;
        }
        
        [wSelf.mTalkPlayer startVoiceTalk];
    }];
}

- (void) stopVoiceTalk
{
    if (!self.mTalkPlayer)
    {
        return;
    }
    
    [self.mTalkPlayer stopVoiceTalk];
}

- (void) addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceInfoChanged:)
                                                 name:EOADeviceManagerListChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(systemVolumeChanged:)
                                                 name:EOASysVolumeChanged
                                               object:nil];
}

- (void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) videoQualitySelectAtIndex:(NSInteger) index
{
    __weak EOARealPlayViewController *weakSelf = self;
    [EOAWaitView showWaitViewInView:self.view frame:self.view.bounds];
    
    EOAVideoQualityInfo *qualityInfo = [self.mCameraInfo.qualityList objectAtIndex:index];
    if (!qualityInfo)
    {
        return;
    }
    
    [[EOADeviceManager sharedInstance] setVideoLevelWithSerial:self.mCameraInfo.deviceSerial
                                                      cameraNo:self.mCameraInfo.cameraNo
                                                    videoLevel:qualityInfo.videoLevel
                                                        result:^(BOOL result) {
                                                            [EOAWaitView hideWaitView];
                                                            if (result)
                                                            {
                                                                [weakSelf.videoQualityView selectAtIndex:index];
                                                                //切换成功需要重启下播放器
                                                                [weakSelf restartPlay];
                                                            }
                                                        }];
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

- (void) startLocalRecord
{
    if (!self.mPreviewPlayer)
    {
        return;
    }
    
    self.recordFilePath = [self getLocalRecordFilePath];
    if (!self.recordFilePath)
    {
        return;
    }
    
    BOOL ret = [self.mPreviewPlayer startLocalRecordWithPath:self.recordFilePath];
    if (ret)
    {
        [self.videoQualityView setBtnsEnable:NO];
        self.recordDuration = 0;
        [self needShowRecordBar:YES];
        [self updateRecordTimerBar];
        [self startRecordTimer];
        self.recordBtn.selected = YES;
    }
}

- (void) stopLocalRecord
{
    if (!self.mPreviewPlayer || !self.recordFilePath)
    {
        return;
    }
    
    BOOL ret = [self.mPreviewPlayer stopLocalRecord];
    
    if (ret)
    {
        [self.videoQualityView setBtnsEnable:YES];
        [self needShowRecordBar:NO];
        [self stopRecordTimer];
        self.recordBtn.selected = NO;
        [self saveRecordToPhotosAlbumWithPath:self.recordFilePath];
    }

    self.recordFilePath = nil;
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
    self.recordDuration += 1;
    [self updateRecordTimerBar];
}

- (void) releasePlayers
{
    if (self.mPreviewPlayer)
    {
        [self.mPreviewPlayer destroyPlayer];
        self.mPreviewPlayer = nil;
    }
    
    if (self.mTalkPlayer)
    {
        [self.mTalkPlayer destroyTalk];
        self.mTalkPlayer = nil;
    }
}

- (void) requestMicPermissionCompletion:(void(^)(BOOL ret)) completion
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined:
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(granted);
                    }
                });
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized:
        {
            if (completion)
            {
                completion(YES);
            }
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        default:
            if (completion)
            {
                completion(NO);
            }
            break;
    }
}

#pragma mark - view

- (void) initSubviews
{
    self.nameLabel.text = self.mCameraInfo.cameraName;
    self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)",self.mCameraInfo.deviceType,self.mCameraInfo.deviceSerial];
    self.volumeSlider.value = [[EOAVolumeUtil shareInstance] getSysVolume];
    self.talkBtn.enabled = self.mDeviceInfo.supportTalkMode != 0;//不支持对讲则置灰
    self.recordTimerBar.layer.cornerRadius = CGRectGetHeight(self.recordTimerBar.frame)/4;
    self.recordTimerBar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.recordFlagView.layer.cornerRadius = CGRectGetWidth(self.recordFlagView.frame)/2;
    
    [self createVideoQualityView];
}

- (void) createVideoQualityView
{
    NSMutableArray *qualityArray = [NSMutableArray array];
    NSInteger index = 0;
    for (int i = 0 ; i < self.mCameraInfo.qualityList.count; i++)
    {
        EOAVideoQualityInfo *qualityInfo = [self.mCameraInfo.qualityList objectAtIndex:i];
        [qualityArray addObject:qualityInfo];
        if (self.mCameraInfo.videoLevel == qualityInfo.videoLevel)
        {
            index = i;
        }
    }
    
    __weak EOARealPlayViewController *weakSelf = self;
    self.videoQualityView = [[EOAVideoQualitySelectView alloc] initWithFrame:CGRectMake(0,
                                                                                        EOA_SCREEN_HEIGHT - QUALITY_VIEW_HEIGHT - 25,
                                                                                        EOA_SCREEN_WIDTH,
                                                                                        QUALITY_VIEW_HEIGHT)
                                                                 qualityList:qualityArray
                                                               selectedIndex:index
                                                              selectCallback:^(NSInteger selectIndex) {
                                                                  [weakSelf videoQualitySelectAtIndex:selectIndex];
                                                              }];
    
    [self.view addSubview:self.videoQualityView];
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

- (void) updateLabels
{
    self.nameLabel.text = self.mCameraInfo.cameraName;
    self.typeLabel.text = [NSString stringWithFormat:@"%@(%@)",self.mCameraInfo.deviceType,self.mCameraInfo.deviceSerial];
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
    __weak EOARealPlayViewController *weakSelf = self;
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
                                                              [weakSelf.mPreviewPlayer setPlayVerifyCode:textField.text];
                                                              [weakSelf startPlay];
                                                          }];
    
    
    [verifyCodeAlert addAction:cancelAction];
    [verifyCodeAlert addAction:confirmAction];
    
    [self presentViewController:verifyCodeAlert animated:YES completion:nil];
}

- (void) showTalkView
{
    __weak EOARealPlayViewController *weakSelf = self;
    [EOATalkView showTalkViewFromView:self.view
                                frame:CGRectMake(0,
                                                 CGRectGetMaxY(self.view.frame),
                                                 CGRectGetWidth(self.view.frame),
                                                 CGRectGetMaxY(self.view.frame)-CGRectGetMaxY(self.previewBgView.frame))
                             talkMode:(EOATalkMode)self.mDeviceInfo.supportTalkMode
                       cancelCallback:^{
                           //结束对讲
                           [weakSelf.mTalkPlayer stopVoiceTalk];
                           [EOATalkView hideTalkView];
                       }
                         talkCallback:^(BOOL pressed) {
                             //半双工对讲
                             if (weakSelf.mDeviceInfo.supportTalkMode == 3)
                             {
                                 [weakSelf.mTalkPlayer setVoiceTalkStatus:pressed];
                             }
                         }];
}

- (void) needShowRecordBar:(BOOL) needShow
{
    self.recordTimerBar.hidden = !needShow;
}

- (void) updateRecordTimerBar
{
    self.recordFlagView.hidden = self.recordDuration%2 == 0;
    
    NSInteger hour = 0,min = 0,sec = 0;
    
    sec = self.recordDuration % 60;
    min = (self.recordDuration / 60) % 60;
    hour = self.recordDuration / 3600;
 
    self.recordTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hour,min,sec];
}

@end
