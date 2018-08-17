//
//  YSNetworkAgent.m
//  YSNetwork
//
//  Created by qiandong on 6/24/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSNetworkAgent.h"
#import "YSNetworkHelper.h"

static dispatch_queue_t ys_request_creation_queue() {
    static dispatch_queue_t ys_request_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ys_request_creation_queue = dispatch_queue_create("com.ezviz.network.request.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return ys_request_creation_queue;
}

#define CUSTOM_REQUEST_PARAMS @"定制Request不打印参数"

@implementation YSNetworkAgent
{
    NSMutableDictionary *_requestsRecord;
}

//模拟抽象类的方法:子类必须重载该方法，且不能调用[super method];
+ (YSNetworkAgent *)sharedInstance
{
    
    NSException *exception = [NSException exceptionWithName:@"sharedInstance方法被没有重载"
                                                     reason:@"sharedInstance方法被没有重载"
                                                   userInfo:nil];
    @throw exception;

    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark **************主要逻辑**************
- (void)addRequest:(YSBaseRequest *)request
{
    dispatch_async(ys_request_creation_queue(), ^{
        
        YSHttpMethod method = [request httpMethod]; //GET/POST/HEAD
        NSString *fullUrl = [self buildRequestFullUrl:request]; //完整url(GET请求不包含参数)
        id params =  [request realRequestParams]; //真正的请求参数
        YSConstructingBlock constructingBlock = [request constructingBodyBlock]; //富文本formdata
        
        //Request合成器
        AFHTTPRequestSerializer *requestSerializer = nil;
        if (request.requestSerializerType == YSRequestSerializerTypeHTTP)
        {
            requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        else if (request.requestSerializerType == YSRequestSerializerTypeJSON)
        {
            requestSerializer = [AFJSONRequestSerializer serializer];
        }
        //    _manager.requestSerializer = requestSerializer; //因没有用到AFHTTPSessionManager，所以暂时注释掉
        
        requestSerializer.timeoutInterval = [request timeoutInterval]; //超时设置
        
//        //response合成器
//        if (request.responseSerializerType == YSResponseSerializerTypeHTTP)
//        {
//            _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        }
//        else if (request.responseSerializerType == YSResponseSerializerTypeJSON)
//        {
//            _manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        }
//        else if (request.responseSerializerType == YSResponseSerializerTypePropertyList)
//        {
//            _manager.responseSerializer = [AFPropertyListResponseSerializer serializer];
//        }else{
//            NSAssert(NO, @"responseSerializer类型不支持");
//        }
        
        // 如果服务器需要http basic authorization
        NSArray *authorizationHeader = [request requestAuthorizationHeader];
        if (authorizationHeader != nil)
        {
            [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeader.firstObject password:(NSString *)authorizationHeader.lastObject];
        }
        
        // 如果接口需要定制的http header
        NSDictionary *customHeader = [request requestCustomHeader];
        if (customHeader != nil) {
            for (id httpHeaderField in customHeader.allKeys)
            {
                id value = customHeader[httpHeaderField];
                if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]])
                {
                    [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
                }
                else
                {
                    NSAssert(FALSE, @"Http Header Field 必须是 NSString");
                }
            }
        }
        
        NSMutableURLRequest *customUrlRequest= [[request buildCustomUrlRequest] mutableCopy]; //定制的NSURLRequest
        if (customUrlRequest)
        {
            customUrlRequest = (NSMutableURLRequest *)[request interceptBeforeRequestLoading:customUrlRequest];
            [self logRequest:customUrlRequest];
            
            __block NSURLSessionTask *task = nil;
            task = [_manager dataTaskWithRequest:customUrlRequest uploadProgress:request.uploadProgress downloadProgress:request.downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                [self logResponseWithRequest:customUrlRequest response:response responseObject:responseObject error:error]; //Log Custom请求的response
                [self handleRequestResult:task response:response responseObject:responseObject error:error];
            }];
            request.task = task;
            [request.task resume];
        }
        else
        {
            if (method == YSHttpMethodGet)
            {
                if (request.downloadFilePath)   //下载
                {
                    request.task = [self downloadTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request downloadFilePath:request.downloadFilePath];
                    [request.task resume];
                }
                else                            //普通Get
                {
                    request.task = [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                    [request.task resume];
                }
            }
            else if (method == YSHttpMethodPost)
            {
                if (constructingBlock != nil)   //上传
                {
                    //request.task = [self uploadTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request constructingBlock:constructingBlock];
                    //[request.task resume];
                    
                    ///因为NSURLSession的bug，这里request.task的赋值、[request.task resume]、[self addTask:request]移动到方法内去做。
                    // 并且提早return;
                    [self uploadTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request constructingBlock:constructingBlock];
                    return;
                }
                else                            //普通Post
                {
                    request.task = [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                    [request.task resume];
                }
            }
            else if (method == YSHttpMethodHead)
            {
                request.task = [self dataTaskWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                [request.task resume];
            }
            else if (method == YSHttpMethodPut)
            {
                request.task = [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                [request.task resume];
            }
            else if (method == YSHttpMethodDelete)
            {
                request.task = [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                [request.task resume];
            }
            else if (method == YSHttpMethodPatch)
            {
                request.task = [self dataTaskWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:fullUrl parameters:params request:request];
                [request.task resume];
            }
            else
            {
                NSAssert(FALSE, @"错误，不支持该Http Method");
                return;
            }
        }
        
        // retain operation
        [self addTask:request];
    });
}

#pragma mark **************组织请求的全路径**************
- (NSString *)buildRequestFullUrl:(YSBaseRequest *)request
{
    NSString *detailUrl = request.apiUrl;
    if ([detailUrl hasPrefix:@"http"] || [detailUrl hasPrefix:@"https"] ) {
        return detailUrl;
    }
    //    // filter url
    //    NSArray *filters = [_config urlFilters];
    //    for (id<YSUrlFilterProtocol> f in filters) {
    //        detailUrl = [f filterUrl:detailUrl withRequest:request];
    //    }
    
    NSString *baseUrl;
    if ([request useCDN] && [request cdnUrl].length > 0) // 使用cdnUrl
    {
        baseUrl = [request cdnUrl];
    }
    else if ([request baseUrl].length > 0) // 使用baseUrl
    {
        baseUrl = [request baseUrl];
    }
    
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

#pragma mark **************组织dataTask、uploadTask、downloadTask**************
- (NSURLSessionDataTask*)dataTaskWithHTTPMethod:(NSString *)method
                              requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                      URLString:(NSString *)fullUrl
                                     parameters:(id)parameters
                                        request:(YSBaseRequest *)request
{
    NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:method URLString:fullUrl parameters:parameters error:&serializationError];
    if (serializationError) {
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil response:nil responseObject:nil error:nil];
        });
        return nil;
    }
    
    urlRequest = (NSMutableURLRequest *)[request interceptBeforeRequestLoading:urlRequest];
    [self logRequest:urlRequest params:parameters];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:urlRequest uploadProgress:request.uploadProgress downloadProgress:request.downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self logResponseWithRequest:urlRequest response:response responseObject:responseObject error:error]; //Log Response
        [self handleRequestResult:dataTask response:response responseObject:responseObject error:error]; //处理结果
    }];

    return dataTask;
}

- (NSURLSessionUploadTask*)uploadTaskWithHTTPMethod:(NSString *)method
                                  requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                          URLString:(NSString *)fullUrl
                                         parameters:(id)parameters
                                            request:(YSBaseRequest *)request
                                  constructingBlock:(YSConstructingBlock)constructingBlock
{
    NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:fullUrl parameters:parameters constructingBodyWithBlock:constructingBlock error:nil];
    if (serializationError) {
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil response:nil responseObject:nil error:nil];
        });
        return nil;
    }
    
    urlRequest = (NSMutableURLRequest *)[request interceptBeforeRequestLoading:urlRequest];
    [self logRequest:urlRequest params:parameters];
    
    //There is a bug in `NSURLSessionTask` that causes requests to not send a `Content-Length` header when streaming contents from an HTTP body in IOS7
    //所以这里ios8和7分开处理
    //https://github.com/AFNetworking/AFNetworking/issues/1398 和 http://www.jianshu.com/p/0a3820d6a951
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        __block NSURLSessionUploadTask *uploadTask = nil;
        uploadTask = [_manager uploadTaskWithStreamedRequest:urlRequest progress:request.uploadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            [self logResponseWithRequest:urlRequest response:response responseObject:responseObject error:error]; //Log Response
            [self handleRequestResult:uploadTask response:response responseObject:responseObject error:error]; //处理结果
        }];
        request.task = uploadTask;
        [uploadTask resume];
        [self addTask:request];
    }
    else //ios7
    {
        // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
        // bug in NSURLSessionTask.
        NSString *tmpFileName = [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];
        NSURL *tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName]];
        
        // Dump multipart request into the temporary file.
        [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:urlRequest writingStreamContentsToFile:tmpFileUrl completionHandler:^(NSError * _Nullable error) {
            
            // Once the multipart form is serialized into a temporary file, we can initialize the actual HTTP request using session manager.
            // Here note that we are submitting the initial multipart request. We are, however, forcing the body stream to be read from the temporary file.
            __block NSURLSessionUploadTask *uploadTask = nil;
            uploadTask = [_manager uploadTaskWithRequest:urlRequest fromFile:tmpFileUrl progress:request.uploadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                // Cleanup: remove temporary file.
                [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                
                [self logResponseWithRequest:urlRequest response:response responseObject:responseObject error:error]; //Log Response
                [self handleRequestResult:uploadTask response:response responseObject:responseObject error:error]; //处理结果
            }];
            request.task = uploadTask;
            [uploadTask resume];
            [self addTask:request];
        }];
    }
    return nil; //肯定不返回
}

- (NSURLSessionDownloadTask*)downloadTaskWithHTTPMethod:(NSString *)method
                                      requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                              URLString:(NSString *)fullUrl
                                             parameters:(id)parameters
                                                request:(YSBaseRequest *)request
                                       downloadFilePath:(NSString *)downloadFilePath
{
    NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:method URLString:fullUrl parameters:parameters error:&serializationError];
    if (serializationError) {
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil response:nil responseObject:nil error:nil];
        });
        return nil;
    }
    
    urlRequest = (NSMutableURLRequest *)[request interceptBeforeRequestLoading:urlRequest];
    [self logRequest:urlRequest params:parameters];
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [_manager downloadTaskWithRequest:urlRequest progress:request.downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        return [NSURL fileURLWithPath:downloadFilePath];//[NSURL URLWithString:downloadFilePath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {

        [self logResponseWithRequest:urlRequest response:response responseObject:filePath error:error]; //Log Response
        [self handleRequestResult:downloadTask response:response responseObject:filePath error:error]; //处理结果
    }];
    
    return downloadTask;
}

#pragma mark **************处理Response结果**************

- (void)handleRequestResult:(NSURLSessionTask *)task response:(NSURLResponse *) response responseObject:(id)responseObject error:(NSError *)error
{
    NSString *key = [self requestHashKey:task];
    YSBaseRequest *request = _requestsRecord[key];
    request.responseObject = responseObject;
    request.responseError = error;
    request.response = response;
    
    //如果发生网络错误，并且retryCount>0，则重试
    if (request.retryCount > 0 && error)
    {
        YSLog(@"request retryCount: %ld",request.retryCount);
        request.retryCount--;
        [self removeTask:task];
//        [request clearBlock_Inner];  // 与钱老板确认后重试request不需要置空回调
        [self addRequest:request];
        return;
    }
    
    request = [request interceptAfterResponseArrived:request]; //拦截器：response获取后
    
    if (request)
    {
        NSError *customError = nil;
        BOOL succeed = [self checkResult:request error:&customError];
        if (succeed)
        {
            [request requestSuccessHandler]; //请求成功拿到数据后的处理（目前在YSRequest里的实现是cache数据）。
            
            if (request.successBlock)
            {
                request.successBlock(request,responseObject);
            }
        }
        else
        {
            if (request.failureBlock)
            {
                if (!error) //如果非http error，则返回自定义的错误
                {
                    error = customError;
                }
                //这里实现很丑陋。应用层需要这个玩意。如果不需要，干掉即可。
                NSMutableDictionary *mUserInfo = [error.userInfo mutableCopy];
                [mUserInfo setObject:@"连接服务器失败" forKey:NSLocalizedDescriptionKey];
                NSError *err = [NSError errorWithDomain:error.domain code:error.code userInfo:mUserInfo];
                request.failureBlock(request,err);
            }
        }
    }
    [self removeTask:task];
    [request clearBlock_Inner];
}

- (BOOL)checkResult:(YSBaseRequest *)request error:(NSError **)error
{
    if (request.responseError)  //HTTP Error校验
    {
        return NO;
    }
    
    if (![request statusCodeValidator]) //statusCode校验
    {
        *error = [NSError errorWithDomain:@"HttpStatsCode校验不通过" code:9997 userInfo:nil];
        return NO;
    }
    
//    if (![request responseObjectValidator]) //responseObject类型校验
//    {
//        *error = [NSError errorWithDomain:@"responseObject类型不允许" code:9998 userInfo:nil];
//        return NO;
//    }
    
    id validator = [request jsonValidator]; //JSON格式校验
    if (validator != nil)
    {
        id json = request.responseObject;
        if (![YSNetworkHelper checkJson:json withValidator:validator])
        {
            *error = [NSError errorWithDomain:@"JSON校验不通过" code:9999 userInfo:nil];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark **************取消baseRequest**************
- (void)cancelRequest:(YSBaseRequest *)request
{
    [request.task cancel];
    [self removeTask:request.task];
    [request clearBlock_Inner];
}

- (void)cancelAllRequests
{
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        YSBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

#pragma mark **************持有管理baseRequest（add和remove ）**************
- (NSString *)requestHashKey:(NSURLSessionTask *)task
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)[task hash]];
}

- (void)addTask:(YSBaseRequest *)request
{
    if (request.task != nil) {
        NSString *key = [self requestHashKey:request.task];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeTask:(NSURLSessionTask *)task
{
    NSString *key = [self requestHashKey:task];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    YSLog(@"_requestsRecord count: %lu", (unsigned long)[_requestsRecord count]);
}

#pragma mark **************request 和 response的打印**************
//log customRequest
- (void)logRequest:(NSURLRequest *)urlRequest;
{
    YSLog(@"\n \
          ====================REQUEST START======================== \n \
          [URL]:     %@ \n \
          [METHOD]:  %@ \n \
          [PARAMS]:  %@ \n \
          [Headers]: %@ \n \
          ========================================================= \n\n",urlRequest.URL.absoluteString, urlRequest.HTTPMethod, [[NSString alloc] initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding], urlRequest.allHTTPHeaderFields);
}
//log request
- (void)logRequest:(NSURLRequest *)urlRequest params:(id)params
{
    YSLog(@"\n \
          ====================REQUEST START======================== \n \
          [URL]:     %@ \n \
          [METHOD]:  %@ \n \
          [PARAMS]:  %@ \n \
          [Headers]: %@ \n \
          ========================================================= \n\n",urlRequest.URL.absoluteString, urlRequest.HTTPMethod, params, urlRequest.allHTTPHeaderFields);
}

- (void)logResponseWithRequest:(NSURLRequest *)urlRequest
                      response:(NSURLResponse *)response
                responseObject:(id)responseObject
                         error:(NSError *)error
{
    YSLog(@"\n \
          ====================RESPONSE START======================== \n \
          [RESPONSE]:       %@ \n \
          [RESPONSEOBJECT]: %@ \n \
          [ERROR]:          %@ \n \
          ========================================================== \n\n",response, [YSNetworkHelper dictToJson:responseObject] , error);
}

@end
