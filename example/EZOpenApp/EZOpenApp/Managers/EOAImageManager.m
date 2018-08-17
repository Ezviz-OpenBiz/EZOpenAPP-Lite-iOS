//
//  EOAImageManager.m
//  EZOpenApp
//
//  Created by linyong on 2017/3/31.
//  Copyright © 2017年 linyong. All rights reserved.
//

#import "EOAImageManager.h"
#import "EZOpenSDK.h"


@interface EOAImageManager ()

@property (nonatomic,strong) NSMutableDictionary *imageCacheDic;
@property (nonatomic,strong) dispatch_queue_t decodeQueue;

@end


@implementation EOAImageManager


+ (EOAImageManager*) sharedInstance
{
    static EOAImageManager *gImageManager = nil;
    static dispatch_once_t imageManagerOnceToken;
    dispatch_once(&imageManagerOnceToken, ^{
        gImageManager = [[EOAImageManager alloc] init];
    });
    return gImageManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.imageCacheDic = [NSMutableDictionary dictionary];
        self.decodeQueue = dispatch_queue_create([@"eoa_image_decode_queue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void) decodeImageWithUrl:(NSString *) urlStr
                 verifyCode:(NSString *) verifyCode
                 completion:(void(^)(UIImage *image,NSString *sourceUrl)) completion
{
    __block UIImage *image = [self.imageCacheDic objectForKey:urlStr];
    
    if (image && completion)
    {
        completion(image,urlStr);
        return;
    }

    __weak EOAImageManager *weakSelf = self;
    dispatch_async(self.decodeQueue, ^{
       
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
        if (!data)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(nil,urlStr);
                }
            });
        }
        else
        {
            NSData *imageData = [EZOpenSDK decryptData:data verifyCode:verifyCode];
            if (!imageData)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(nil,urlStr);
                    }
                });
            }
            else
            {
                image = [UIImage imageWithData:imageData];
                [weakSelf.imageCacheDic setObject:image forKey:urlStr];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(image,urlStr);
                    }
                });
            }
        }
    });
}

@end
