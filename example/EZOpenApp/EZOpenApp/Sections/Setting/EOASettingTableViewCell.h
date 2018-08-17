//
//  EOASettingTableViewCell.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/7.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EOASettingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;

@end
