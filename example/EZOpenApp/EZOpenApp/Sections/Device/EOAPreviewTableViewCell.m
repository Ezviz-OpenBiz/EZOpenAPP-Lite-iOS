//
//  EOAPreviewTableViewCell.m
//  EZOpenApp
//
//  Created by linyong on 17/1/3.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAPreviewTableViewCell.h"

@implementation EOAPreviewTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)settingBtnClick:(id)sender
{
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(previewCellClickSettingBtn:)])
    {
        [self.mDelegate previewCellClickSettingBtn:self];
    }
}


@end
