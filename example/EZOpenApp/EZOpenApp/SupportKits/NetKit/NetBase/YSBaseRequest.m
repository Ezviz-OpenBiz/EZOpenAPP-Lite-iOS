//
//  YSBaseRequest.m
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSBaseRequest.h"
#import "YSNetworkAgent.h"
#import <objc/runtime.h>

@interface YSBaseRequest ()
{
    NSString *_apiUrl;
}
@end

@implementation YSBaseRequest

#pragma mark **************Http相关可查询属性**************

-(NSDictionary *)responseHeaders
{
    return ((NSHTTPURLResponse *)self.response).allHeaderFields;
}

-(NSInteger)responseStatusCode
{
    return ((NSHTTPURLResponse *)self.response).statusCode;
}

#pragma mark **************start、stop、suspend、resume**************
- (void)startWithSuccess:(YSNetSuccessBlock)success
                     failure:(YSNetFailureBlock)failure
{
    _successBlock = success;
    _failureBlock = failure;
    _uploadProgress = nil;
    _downloadProgress = nil;
    [self start];
}

- (void)startWithUploadProgress:(YSNetProgress)uploadProgress
                   downloadProgress:(YSNetProgress)downloadProgress
                            success:(YSNetSuccessBlock)success
                            failure:(YSNetFailureBlock)failure
{
    _successBlock = success;
    _failureBlock = failure;
    _uploadProgress = uploadProgress;
    _downloadProgress = downloadProgress;
    [self start];
}

- (void)start
{
    [[self networkAgent] addRequest:self];
}

- (void)stop
{
    [[self networkAgent] cancelRequest:self];
}

- (void)suspend
{
    [self.task suspend];
}

- (void)resume
{
    [self.task resume];
}


- (YSNetworkAgent *)networkAgent
{
    NSException *exception = [NSException exceptionWithName:@"networkAgent方法没有重载"
                                                     reason:@"networkAgent方法没有重载"
                                                   userInfo:nil];
    @throw exception;
    return  nil;
}

#pragma mark **************可重载的**************

- (NSString *)apiUrl;
{
    return _apiUrl;
}

- (NSString *)cdnUrl
{
    return @"";
}

- (NSString *)baseUrl
{
    return @"";
}

- (BOOL)useCDN
{
    return NO;
}

- (NSTimeInterval)timeoutInterval
{
    return 20;
}

- (id)customRequestParams
{
    return nil;
}

- (id)commonParams
{
    return nil;
}

- (YSHttpMethod)httpMethod
{
    return YSHttpMethodPost;
}

- (YSRequestSerializerType)requestSerializerType
{
    return YSRequestSerializerTypeHTTP;
}

//- (YSResponseSerializerType)responseSerializerType
//{
//    return YSResponseSerializerTypeJSON;
//}

- (NSArray *)requestAuthorizationHeader
{
    return nil;
}

- (NSDictionary *)requestCustomHeader
{
    return nil;
}

- (YSConstructingBlock)constructingBodyBlock
{
    return nil;
}

- (NSString *)downloadFilePath
{
    return nil;
}

- (id)jsonValidator
{
    return nil;
}

- (BOOL)statusCodeValidator
{
    //304系统会自动处理，取缓存返回200
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

//- (BOOL)responseObjectValidator
//{
//    if ([self responseSerializerType] == YSResponseSerializerTypeJSON && [self.responseObject isKindOfClass:[NSData class]])
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

- (NSURLRequest *)buildCustomUrlRequest
{
    return nil;
}

//属性不是请求参数【可被重载】
-(BOOL)isNotRequestParams:(NSString *)key
{
//    if ([@[@"attr1",@"attr2"] containsObject:key]) { //不参与请求的数组
//        return YES;
//    }
    return NO;
}

- (void) requestSuccessHandler
{
}

- (NSMutableURLRequest *)interceptBeforeRequestLoading:(NSMutableURLRequest *)urlRequest
{
    return urlRequest;
}

- (YSBaseRequest *)interceptAfterResponseArrived:(YSBaseRequest *)request
{
    return request;
}

#pragma mark **************真正的请求参数**************

- (NSDictionary *)realRequestParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    if ([self customRequestParams]) //定制的请求参数
    {
        params = [self customRequestParams];
    }else                           //由属性自动合成的请求参数
    {
        [params addEntriesFromDictionary:[self commonParams]];
        [params addEntriesFromDictionary:[self generatedParams]];
    }
    return [params copy];
}

#pragma mark **************自动生成的请求参数【若重载了customRequestParams方法，则其失效】**************

- (NSDictionary *)generatedParams
{
    NSDictionary *params = [NSMutableDictionary dictionary];
    unsigned int nCount = 0;
    objc_property_t *popertylist = class_copyPropertyList([self class],&nCount);
    for (int i = 0; i < nCount; i++)
    {
        objc_property_t property = popertylist[i];
        
        id key = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];

        if ([self isNotRequestParams:key] ||
            !([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
            )  //只接受NSString和NSNumber（int、float、bool等）
        {
            continue;
        }
        if (value)
        {
            [params setValue:value forKey:key];
        }
        else
        {
            [params setValue:@"" forKey:key];
        }
    }
    free(popertylist);
    popertylist = NULL;
    
    return params;
}

#pragma mark **************外面不要调用**************
- (void)clearBlock_Inner
{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.uploadProgress = nil;
    self.downloadProgress = nil;
}

#pragma mark **************私有**************
-(void)setApiUrl:(NSString *)apiUrl
{
    _apiUrl = apiUrl;
}




@end
