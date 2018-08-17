//
//  EOADeviceTableViewCell.h
//  EZOpenApp
//
//  Created by linyong on 17/1/3.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOADeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deviceTypeImage;
@property (weak, nonatomic) IBOutlet UILabel *deviceRootTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *offlineTip;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerTimeLabel;

@end
