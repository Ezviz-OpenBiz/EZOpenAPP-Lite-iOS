//
//  V2CommonRequest.h
//  YSNetwork
//
//  Created by qiandong on 7/13/16.
//  Copyright © 2016 hikvision. All rights reserved.
//

#import "YSRequest.h"
#import "MJExtension.h"

#define DEFAULT_ERROR_CODE (-1)
#define DEFAULT_SUCCESS_CODE (200)
#define RESULT_CODE_KEY @"code"
#define RESULT_DESC_KEY @"msg"

@interface V2CommonRequest : YSRequest

- (NSMutableDictionary *)failDictionaryWithError:(NSError *)error;

- (NSMutableDictionary *)successDictionaryWithResponse:(id)response;

@end
