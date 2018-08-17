//
//  EOATalkView.h
//  EZOpenApp
//
//  Created by linyong on 2017/4/11.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <UIKit/UIKit.h>

//对讲模式，值对应SDK中的能力级值
typedef enum
{
    EOA_TALK_NONE = 0,//不支持对讲
    EOA_TALK_DOUBLE = 1,//全双工对讲
    EOA_TALK_SINGLE = 3,//半双工对讲
    EOA_TALK_MAX
    
}EOATalkMode;

@interface EOATalkView : UIView

+ (void) showTalkViewFromView:(UIView *) view
                        frame:(CGRect) frame
                     talkMode:(EOATalkMode) mode
               cancelCallback:(void(^)()) cancelCallback
                 talkCallback:(void(^)(BOOL pressed)) talkCallback;

+ (void) hideTalkView;



@end
