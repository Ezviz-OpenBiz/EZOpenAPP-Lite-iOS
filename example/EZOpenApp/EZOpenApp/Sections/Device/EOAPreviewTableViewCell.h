//
//  EOAPreviewTableViewCell.h
//  EZOpenApp
//
//  Created by linyong on 17/1/3.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EOACameraInfo.h"

@class EOAPreviewTableViewCell;

@protocol EOAPreviewCellDelegate <NSObject>

@optional
- (void) previewCellClickSettingBtn:(EOAPreviewTableViewCell *) cell;

@end


@interface EOAPreviewTableViewCell : UITableViewCell

@property (nonatomic,weak) id<EOAPreviewCellDelegate> mDelegate;
@property (nonatomic,strong) EOACameraInfo *cameraInfo;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *motionBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIView *offlineBgView;
@property (weak, nonatomic) IBOutlet UILabel *offlineLabel;

@end
