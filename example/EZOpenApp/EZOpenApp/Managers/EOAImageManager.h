//
//  EOAImageManager.h
//  EZOpenApp
//
//  Created by linyong on 2017/3/31.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///主要解决加密图片的解密过程，进行内存缓存
@interface EOAImageManager : NSObject


/**
 获取图片管理単例
 
 @return 图片管理単例
 */
+ (EOAImageManager*) sharedInstance;

/**
 图片解密

 @param urlStr 图片url地址
 @param verifyCode 图片加密密码
 @param completion 解密完成回调
 */
- (void) decodeImageWithUrl:(NSString *) urlStr
                 verifyCode:(NSString *) verifyCode
                 completion:(void(^)(UIImage *image,NSString *sourceUrl)) completion;

@end
