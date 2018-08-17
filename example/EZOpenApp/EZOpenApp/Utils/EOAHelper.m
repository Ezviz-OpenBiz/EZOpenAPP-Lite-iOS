//
//  EOAHelper.m
//  EZOpenApp
//
//  Created by linyong on 16/12/27.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOAHelper.h"
#import <Realm/Realm.h>
#import <CoreImage/CoreImage.h>

#define EOA_CACHE_DIR @"cache"
#define EOA_DEFAULT_DB_NAME @"eoaDefaultDB"
#define EOA_DB_VERSION (0)

@implementation EOAHelper

+ (RLMRealm *) defaultRealm
{
    static RLMRealm *gRealm = nil;
    static dispatch_once_t realmOnceToken;
    dispatch_once(&realmOnceToken, ^{
        NSString *cachePath = [EOAHelper cachePath];
        NSAssert(cachePath, @"create cache dir failed!");
        
        //以下为reaml的数据迁移，暂时不实现
//        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
//        // 设置新的架构版本。这个版本号必须高于之前所用的版本号（如果您之前从未设置过架构版本，那么这个版本号设置为 0）
//        config.schemaVersion = EOA_DB_VERSION;
//        
//        // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
//        config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion)
//        {
//            // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
//            if (oldSchemaVersion < EOA_DB_VERSION)
//            {
//                // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
//            }
//        };
//        
//        // 告诉 Realm 为默认的 Realm 数据库使用这个新的配置对象
//        [RLMRealmConfiguration setDefaultConfiguration:config];
        
        NSString *dbFilePath = [NSString stringWithFormat:@"%@/%@",cachePath,EOA_DEFAULT_DB_NAME];
        gRealm = [RLMRealm realmWithURL:[NSURL fileURLWithPath:dbFilePath]];
    });
    return gRealm;
}



+ (NSString *) documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    return docPath;
}

+ (NSString *) cachePath
{
    NSString *docPath = [EOAHelper documentsPath];
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@",docPath,EOA_CACHE_DIR];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:cachePath])
    {
        NSError *error;
        if (![fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"create cache path error:%@",error);
            return nil;
        }
    }
    
    return cachePath;
}

+ (NSDateFormatter *) getDateFormatterWithFormatterString:(NSString *) formatterString;
{
    static NSDateFormatter *defaultFormatter;
    static dispatch_once_t formatterOnceToken;
    dispatch_once(&formatterOnceToken, ^{
        defaultFormatter = [[NSDateFormatter alloc] init];
    });
    
    if (formatterString && formatterString.length > 0)
    {
        [defaultFormatter setDateFormat:formatterString];
    }
    return defaultFormatter;
}

+ (UIImage *)applyBlurRadius:(CGFloat) radius toImage:(UIImage *)image
{
    if (!image)
    {
        return nil;
    }
    
    if (radius < 0)
    {
        radius = 0;
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:kCIInputRadiusKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}

@end
