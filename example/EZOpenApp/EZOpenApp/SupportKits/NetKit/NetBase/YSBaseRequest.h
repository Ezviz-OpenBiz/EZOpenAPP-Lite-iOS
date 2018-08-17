//
//  YSBaseRequest.h
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "NSNULL+XYExtension.h"

#define YS_NET_ERROR_MESSAGE @"YS_NET_ERROR_MESSAGE"

@class YSNetworkAgent;

typedef NS_ENUM(NSInteger , YSHttpMethod) { //Http请求方式 Get/Post/Head/Put/Delete/Patch
    YSHttpMethodGet = 0,
    YSHttpMethodPost,
    YSHttpMethodHead,
    YSHttpMethodPut,
    YSHttpMethodDelete,
    YSHttpMethodPatch,
};

typedef NS_ENUM(NSInteger , YSRequestSerializerType) { //Request组成方式， 有其他类型的话，以后添加
    YSRequestSerializerTypeHTTP = 0,
    YSRequestSerializerTypeJSON,
};

//typedef NS_ENUM(NSInteger , YSResponseSerializerType) { //Response解析方式， 有其他类型的话，以后添加
//    YSResponseSerializerTypeHTTP = 0,
//    YSResponseSerializerTypeJSON,
//    YSResponseSerializerTypePropertyList
//};

//Block类型定义
@class YSBaseRequest;
typedef void (^YSConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^YSNetSuccessBlock)(__kindof YSBaseRequest *request, id responseObject); //下载任务中，responseObject是下载文件路径(NSURL)
typedef void (^YSNetFailureBlock)(__kindof YSBaseRequest *request, NSError *error);
typedef void (^YSNetProgress)(__kindof NSProgress *progress);


/*
 YSBaseRequest 定义了基础属性和方法
 */

@interface YSBaseRequest : NSObject

#pragma mark **************apiUrl**************
/*
 *子类可以重载getter方法，也可以生成子类的实例后，用xxxRequest.apiUrl=@"..." 设置
 *但两者不要一起用（如果一起用，只有重载的getter方法生效）
 */
@property (nonatomic, copy) NSString *apiUrl;
@property (nonatomic, assign) NSInteger retryCount; //重试次数，请求失败（fail），重试次数。默认为0. retryCount=1表示重试一次。

#pragma mark **************实际的请求参数**************
//请求参数由2种方式组成：
//1）通常：request的子类里自定义的NSString和NSNumber（int、float、bool)属性，及基类中的公共参数，会自动组织成请求参数。
//2）完全自定义：重载customRequestParams方法
@property (nonatomic, strong, readonly) NSDictionary *realRequestParams;

#pragma mark **************task属性**************
@property (nonatomic, strong) NSURLSessionTask *task;

#pragma mark **************Response相关属性**************
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong) id responseObject; 
@property (nonatomic, strong) NSError *responseError;
@property (nonatomic, strong) NSURLResponse *response;

#pragma mark **************回调block**************
@property (nonatomic, copy) YSNetSuccessBlock successBlock;
@property (nonatomic, copy) YSNetFailureBlock failureBlock;
@property (nonatomic, copy) YSNetProgress uploadProgress;
@property (nonatomic, copy) YSNetProgress downloadProgress;

#pragma mark **************唯一标识和附带数据UserInfo**************
@property (nonatomic) NSInteger netTag; // Tag
@property (nonatomic, strong) NSDictionary *netUserInfo; // User info

#pragma mark -
#pragma mark -
#pragma mark **************start、stop、suspend、resume**************
- (void)startWithSuccess:(YSNetSuccessBlock)success
                     failure:(YSNetFailureBlock)failure;

//上传任务可实现uploadProgress，下载任务可实现downloadProgress
- (void)startWithUploadProgress:(YSNetProgress)uploadProgress
                   downloadProgress:(YSNetProgress)downloadProgress
                            success:(YSNetSuccessBlock)success
                            failure:(YSNetFailureBlock)failure;

- (void)suspend;
- (void)resume;


- (void)start;
- (void)stop;

#pragma mark **************可重载的**************
- (NSString *)apiUrl; // apiURL,部分路径。也可以是全路径（全路径会忽略baseUrl）
- (NSString *)cdnUrl; // 请求的CdnURL
- (NSString *)baseUrl; // 请求的BaseURL
- (BOOL)useCDN; // 是否使用CDN的host地址
- (NSTimeInterval)timeoutInterval; // 超时时间，默认为60秒
- (id)customRequestParams; // 自定义请求参数，如果重载了，则请求参数完全由其确定，其他都不起作用。
- (id)commonParams; //公共参数。会将公共参数和子类属性合并为realRequestParams（如果customRequestParams返回nil）

- (YSHttpMethod)httpMethod; // Http请求的方法, 默认Post
- (YSRequestSerializerType)requestSerializerType; // 请求的SerializerType, 默认Http
//- (YSResponseSerializerType)responseSerializerType; // response的SerializerType, 默认JSON
- (NSArray *)requestAuthorizationHeader; // BASIC Authorization.格式@[@"user",@"pwd"]
- (NSDictionary *)requestCustomHeader; // 在HTTP报头添加的自定义参数

- (YSConstructingBlock)constructingBodyBlock; // 上传富文本内容，如果返回非空，则这个任务被定义为upload任务，请求方式应该为POST.
- (NSString *)downloadFilePath; // 文件下载地址，如果返回非空，则这个任务被定义为download任务，请求方式应为GET。

- (id)jsonValidator; // 用于检查JSON是否合法的对象
- (BOOL)statusCodeValidator; // 用于检查Status Code是否正常的方法
//- (BOOL)responseObjectValidator; // 用于检查responseObject类型是否合法

- (void)requestSuccessHandler; // 请求成功拿到数据后的处理（目前在YSRequest里的实现是cache数据）。

// 构建自定义的UrlRequest，
// 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType等。
- (NSURLRequest *)buildCustomUrlRequest;

-(BOOL)isNotRequestParams:(NSString *)key; //如果自定义的属性不是请求参数，则重载。

- (NSMutableURLRequest *)interceptBeforeRequestLoading:(NSMutableURLRequest *)urlRequest; //拦截器：在request被放入URLLoadingSystem前。
- (YSBaseRequest *)interceptAfterResponseArrived:(YSBaseRequest *)request; //拦截器：获得response后。


//模拟抽象类的方法:一般是基类重载该方法（重载时不要调用super方法），表明用某个YSNetworkAgent的子类来做agent。
- (YSNetworkAgent *)networkAgent;



#pragma mark **************外面不要调用**************
- (void)clearBlock_Inner; // 内部方法，请求结束后，把block置nil来打破循环引用【4个block外面使用时，可以使用self，不需要weakself】


@end
