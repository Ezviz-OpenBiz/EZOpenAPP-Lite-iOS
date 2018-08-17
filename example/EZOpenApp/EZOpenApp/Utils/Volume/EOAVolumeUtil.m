//
//  EOAVolumeUtil.m
//  EZOpenApp
//
//  Created by linyong on 2017/4/10.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAVolumeUtil.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

const NSNotificationName EOASysVolumeChanged = @"EOASysVolumeChanged";//系统音量变更通知

@interface EOAVolumeUtil ()

@property (nonatomic,assign) float mVolumeValue;
@property (nonatomic,strong) MPVolumeView *volumeView;
@property (nonatomic,strong) UISlider *volumeSlider;

@end

@implementation EOAVolumeUtil

+ (EOAVolumeUtil *) shareInstance
{
    static EOAVolumeUtil *gVolumeUtil = nil;
    
    static dispatch_once_t volumeOnceToken;
    dispatch_once(&volumeOnceToken, ^{
        gVolumeUtil = [[EOAVolumeUtil alloc] init];
    });
    
    return gVolumeUtil;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initVolume];
        [self addNotification];
    }
    return self;
}

- (void)dealloc
{
    [self removeNotification];
}

- (float) getSysVolume
{
    return self.mVolumeValue;
}

- (void) setSysVolume:(float) volumeValue
{
    if (!self.volumeSlider)
    {
        return;
    }
    
    self.volumeSlider.value = volumeValue;
}

#pragma mark notification

- (void)volumeChangedNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    float value = [[userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    if (value == self.mVolumeValue)
    {
        return;
    }
    
    self.mVolumeValue = value;
    [self postVolumeChangedNotification];
}

#pragma mark - support

- (void) initVolume
{
    float volume = [[AVAudioSession sharedInstance] outputVolume];
    self.mVolumeValue = volume;
    
    if (!self.volumeView)
    {
        self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 100, 100)];
        [self.volumeView sizeToFit];
        self.volumeView.hidden = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    }
    
    if (!self.volumeSlider)
    {
        for (UIView *subView in self.volumeView.subviews)
        {
            if ([[[subView class] description] isEqualToString:@"MPVolumeSlider"])
            {
                self.volumeSlider = (UISlider*)subView;
                break;
            }
        }
    }
}

- (void) postVolumeChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EOASysVolumeChanged object:nil];
}

- (void) addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChangedNotification:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
}

- (void) removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
