//
//  YSRequest.m
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSRequest.h"
#import "YSNetworkHelper.h"

@interface YSRequest()

@property (strong, nonatomic) id cacheJson; //缓存的数据

@end

@implementation YSRequest
{
    BOOL _isDataFromCache;
}


- (NSInteger)cacheTimeInSeconds
{
    return -1;
}

- (long long)cacheVersion
{
    return 0;
}


- (id)cacheNameForRequestParams:(id)params
{
    return params;
}


- (void)start {
    
    // 如果缓存时间是否<0，则请求网络
    if ([self cacheTimeInSeconds] < 0) {
        [super start];
        return;
    }
    
    //如果本次请求用户要忽略缓存，则请求网络
    if (self.ignoreCache) {
        [super start];
        return;
    }
    
    // 如果缓存版本已过期（如APP版本更新，老缓存就可能不能使用了），则请求网络
    long long cacheVersionFileContent = [self cacheVersionFileContent];
    if (cacheVersionFileContent != [self cacheVersion]) {
        [super start];
        return;
    }
    
    // 如果缓存文件不存在，则请求网络
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        [super start];
        return;
    }
    
    // 如果缓存文件已过期，则请求网络
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        [super start];
        return;
    }
    
    // 如果缓存文件内容为空，则请求网络
    _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_cacheJson == nil) {
        [super start];
        return;
    }
    
    //否则，返回缓存
    
    _isDataFromCache = YES;
    
    //Log
    YSLog(@"\n\n\n ===================【DATA FROM CACHE - START】==================== \n 【URL】:%@ \n【PARAM】:%@ \n【RESPONSE】: %@ \n ===================【DATA FROM CACHE - END】==================== \n\n\n",[NSString stringWithFormat:@"%@%@",[self baseUrl],[self apiUrl]], [self realRequestParams], self.responseObject);
    
    [self requestSuccessHandler]; 
    
    dispatch_async(dispatch_get_main_queue(), ^{
        YSRequest *strongSelf = self;
        if (strongSelf.successBlock) {
            strongSelf.successBlock(strongSelf,strongSelf.responseObject);
        }
        [strongSelf clearBlock_Inner]; //设置block为nil
    });
}

//内部方法，请求成功,拿到数据后的处理（目前实现是cache数据)
- (void)requestSuccessHandler {
    [super requestSuccessHandler];
    [self saveResponseObjectToCacheFile:[super responseObject]];
}

- (BOOL)isDataFromCache {
    return _isDataFromCache;
}

//YSBaseReqeust的属性。 有cache，返回cache，否则返回responseObject
- (id)responseObject {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        return [super responseObject];
    }
}

//用于返回cache的数据
- (id)cacheJson {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }
}

//读取cacheVersion
- (long long)cacheVersionFileContent {
    NSString *path = [self cacheVersionFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return [version longLongValue];
    } else {
        return 0;
    }
}

//cache文件已存储多久（当前时间-cache文件存储修改时间）
- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        YSLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

#pragma mark **************将请求的response写入缓存（cacheFile和cacheVersion） **************
- (void)saveResponseObjectToCacheFile:(id)responseObject {
    //只有缓存时间大于0，并且本次请求的数据是网络数据才缓存文件（意味着如果从缓存读取数据，不刷新缓存文件及时间）
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = responseObject;
        if (json != nil) {
            [NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]];
            [NSKeyedArchiver archiveRootObject:@([self cacheVersion]) toFile:[self cacheVersionFilePath]];
        }
    }
}

#pragma mark **************该次请求的cacheFile和cacheVersion的文件路径 **************

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (NSString *)cacheVersionFilePath {
    NSString *cacheVersionFileName = [NSString stringWithFormat:@"%@.version", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheVersionFileName];
    return path;
}

//cache KEY
- (NSString *)cacheFileName {
    NSString *apiUrl = [self apiUrl];
    NSString *baseUrl = [self baseUrl];
    
    id argument = [self cacheNameForRequestParams:[self realRequestParams]];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@",
                             (long)[self httpMethod], baseUrl, apiUrl, argument, [YSNetworkHelper appVersionString]];
    return [YSNetworkHelper md5StringFromString:requestInfo];
}

#pragma mark **************所有Request的cache的基础文件夹路径 **************

- (NSString *)cacheBasePath
{
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    
    //    // filter cache base path
    //    NSArray *filters = [[YSNetworkConfig sharedInstance] cacheDirPathFilters];
    //    if (filters.count > 0) {
    //        for (id<YSCacheDirPathFilterProtocol> f in filters) {
    //            path = [f filterCacheDirPath:path withRequest:self];
    //        }
    //    }
    
    [self checkDirectory:path];
    return path;
}

//检查文件夹是否存在，没有则创建；如果是文件，则删除该文件，并创建文件夹
- (void)checkDirectory:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createDirectoryAtPath:path];
        }
    }
}

- (void)createDirectoryAtPath:(NSString *)path
{
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        YSLog(@"create cache directory failed, error = %@", error);
    } else {
        [YSNetworkHelper notBackupWithPath:path];
    }
}



@end
