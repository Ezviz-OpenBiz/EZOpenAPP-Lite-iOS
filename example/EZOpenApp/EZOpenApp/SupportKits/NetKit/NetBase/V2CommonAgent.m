//
//  V2CommonAgent.m
//  YSNetwork
//
//  Created by qiandong on 7/13/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "V2CommonAgent.h"

@implementation V2CommonAgent

+ (YSNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        //可以在这里定制NSURLSessionConfiguration
        self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer]; //JSON ResponseSerializer
        
        [self taskLevelChallengeForHttpDNS];
    }
    return self;
}


//HTTPS下，服务器证书的校验：域名切换ip后，需要在服务器证书校验阶段HOOK，让域名去校验，而不是IP。
//重要：这里是task-level的challenge，所以需要把AFURLSessionManager.m 里的 URLSession:didReceiveChallenge:completionHandler:（session-level） 注释掉，否则不会进入task-level的challenge。
- (void)taskLevelChallengeForHttpDNS
{
    __weak typeof(self) weakSelf = self;
    
    [self.manager setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        
        NSString *host = [[task.originalRequest allHTTPHeaderFields] objectForKey:@"host"]; //将域名从host字段中取出来
        if (!host)
        {
            host = task.originalRequest.URL.host;
        }
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        {
            if ([weakSelf evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host])
            {
                disposition = NSURLSessionAuthChallengeUseCredential;
                *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            }
            else
            {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }
        else
        {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        return disposition;
    }];
}


- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
    /* * 创建证书校验策略 */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    
    /* * 绑定校验策略到服务端的证书上 */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    
    /* * 评估当前serverTrust是否可信任， * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html * 关于SecTrustResultType的详细信息请参考SecTrust.h */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

@end
