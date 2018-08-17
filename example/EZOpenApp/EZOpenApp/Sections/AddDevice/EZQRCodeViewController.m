//
//  EZQRCodeViewController.m
//  EZOpenSDKDemo
//
//  Created by linyong on 2018/6/28.
//  Copyright © 2018年 linyong. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "EZQRCodeViewController.h"
#import "EZInputDeviceInfoViewController.h"
#import "EZSearchResultViewController.h"
#import "EZQRView.h"
#import "Toast+UIView.h"
#import "EDHelper.h"

#define SCAN_SIZE_WH (240.0)

@interface EZQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (assign, nonatomic) AVAuthorizationStatus authStatus;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (weak, nonatomic) IBOutlet EZQRView *qrView;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation EZQRCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initSubViews];
    [self checkCaptureAuth];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [EDHelper sharedInstance].deviceSerial = nil;
    [EDHelper sharedInstance].verifyCode = nil;
    
    if (self.authStatus == AVAuthorizationStatusDenied ||
        self.authStatus == AVAuthorizationStatusRestricted)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        [self hideLoading];
    }
    else
    {
        [self showLoading];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showScan];
}

#pragma mark - actions

- (void)inputBtnClick:(id)sender
{
    EZInputDeviceInfoViewController *vc = [[EZInputDeviceInfoViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) quitClick:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)torchButtonClicked:(id)sender
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch])
    {
        int nTorchMode = captureDevice.torchMode;
        nTorchMode ++;
        nTorchMode = nTorchMode > 1 ? 0 : nTorchMode;
        
        [captureDevice lockForConfiguration:nil];
        captureDevice.torchMode = nTorchMode;
        [captureDevice unlockForConfiguration];
        
        switch (nTorchMode)
        {
            case 0:
            {
                self.torchBtn.selected = NO;
            }
                break;
            case 1:
            {
                self.torchBtn.selected = YES;
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate Methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] > 0)
    {
        //停止扫描
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [self checkQRCode:stringValue];
}

#pragma mark - view

- (void) initSubViews
{
    self.title = NSLocalizedString(@"ad_scan_qr_title", @"扫描二维码");
    [self createQuitBtn];
    [self createInputBtn];

    self.qrView.hidden = YES;
    self.qrView.clearSize = CGSizeMake(SCAN_SIZE_WH, SCAN_SIZE_WH);
    self.tipLabel.text = NSLocalizedString(@"ad_device_qr",@"设备二维码");
    
    [self.torchBtn setImage:[UIImage imageNamed:@"open"] forState:UIControlStateNormal];
    [self.torchBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateSelected];
}

- (void)createQuitBtn
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"eoa_quit", @"退出")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(quitClick:)];
}

- (void)createInputBtn
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(inputBtnClick:)];
}

- (void) showScan
{
    if (self.authStatus == AVAuthorizationStatusDenied ||
        self.authStatus == AVAuthorizationStatusRestricted)
    {
        return;
    }
    
    if (self.session)
    {
        [self.session startRunning];
    }
    
    self.preview.frame = CGRectMake(0, 64, self.qrView.bounds.size.width, self.qrView.bounds.size.height);
    
    //修正扫描区域
    CGFloat screenHeight = self.qrView.frame.size.height;
    CGFloat screenWidth = self.qrView.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - SCAN_SIZE_WH)/2, (screenHeight - SCAN_SIZE_WH)/3, SCAN_SIZE_WH, SCAN_SIZE_WH);
    
    [self.output setRectOfInterest:CGRectMake(cropRect.origin.y/screenHeight, cropRect.origin.x/screenWidth, cropRect.size.height/screenHeight, cropRect.size.width/screenWidth)];
    
    [self addLineAnimation];
    [self hideLoading];
    self.qrView.hidden = NO;
}

- (void) showLoading
{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

- (void) hideLoading
{
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
}

- (void)addLineAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64.0;
    animation.fromValue = @(height/3.0 - SCAN_SIZE_WH);
    animation.toValue = @(height/3.0 - 80);
    animation.duration = 3.0f;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    [self.lineImageView.layer addAnimation:animation forKey:nil];
}

- (void) showAllowAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"eoa_alert_title", @"提示")
                                                                   message:NSLocalizedString(@"ad_allow_camera",@"请在设备的`设置-隐私-相机`中允许访问相机。")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *done = [UIAlertAction actionWithTitle:NSLocalizedString(@"eoa_ok",@"确定")
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) showToastWithText:(NSString *) text
{
    if (!text)
    {
        return;
    }
    
    [self.view makeToast:text duration:2.0 position:@"center"];
}

#pragma mark - qr

- (void) checkCaptureAuth
{
    self.authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (self.authStatus == AVAuthorizationStatusAuthorized)
    {
        [self qrSetup];
    }
    else if (self.authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted)
                                     {
                                         [self qrSetup];
                                         [self.session startRunning];
                                     }
                                 }];
    }
    else
    {
        [self showAllowAlert];
    }
}

- (void)qrSetup
{
    if(!self.device)
    {
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // Input
    if(!self.input)
    {
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    
    // Output
    if(!self.output)
    {
        self.output = [[AVCaptureMetadataOutput alloc] init];
    }
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    if(!self.session)
    {
        self.session = [[AVCaptureSession alloc] init];
    }
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    AVCaptureConnection *outputConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    outputConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 条码类型 AVMetadataObjectTypeQRCode
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // Preview
    if(!self.preview)
    {
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    self.preview.videoGravity = AVLayerVideoGravityResize;
    self.preview.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    self.preview.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
}

#pragma mark - support

- (void) gotoSearchViewController
{
    EZSearchResultViewController *vc = [[EZSearchResultViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)checkQRCode:(NSString *)strQRcode
{
    NSArray *arrString = [strQRcode componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if(arrString.count >= 4)
    {
        [EDHelper sharedInstance].deviceSerial = arrString[1];
        [EDHelper sharedInstance].verifyCode = arrString[2];
        [EDHelper sharedInstance].deviceType = arrString[3];
        [self gotoSearchViewController];
    } else
    {
        [self showToastWithText:NSLocalizedString(@"ad_not_support_scan", @"不支持的二维码类型，转用手动输入")];
        [self inputBtnClick:nil];
    }
}



@end
