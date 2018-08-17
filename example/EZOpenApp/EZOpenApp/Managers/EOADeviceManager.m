//
//  EOADeviceManager.m
//  EZOpenApp
//
//  Created by linyong on 16/12/29.
//  Copyright © 2016年 linyong. All rights reserved.
//

#import "EOADeviceManager.h"
#import "EZOpenSDK.h"
#import "EZDeviceInfo.h"
#import "EZCameraInfo.h"
#import <Realm/Realm.h>
#import "EOADeviceInfo.h"
#import "EOACameraInfo.h"
#import "EOACameraCoverInfo.h"
#import "EOAModifyCameraNameRequest.h"
#import "EOAGetVoiceStateRequest.h"
#import "EOASetVoiceStateRequest.h"
#import "EOAGetCloudStateRequest.h"

#define DEVICE_PAGE_SIZE (20)

const NSNotificationName EOADeviceManagerListChanged = @"EOADeviceManagerListChanged";

@interface EOADeviceManager ()

@property (nonatomic,strong) RLMRealm *mRealm;
@property (nonatomic,copy) deviceListCallback mDeviceListCallback;
@property (nonatomic,strong) RLMNotificationToken *notificationToken;
@property (nonatomic,strong) NSMutableArray *tempDeviceArr;
@property (nonatomic,assign) BOOL autoClear;//是否为自动清理数据

@end

@implementation EOADeviceManager

+ (EOADeviceManager*) sharedInstance
{
    static EOADeviceManager *gDeviceManager = nil;
    static dispatch_once_t deviceOnceToken;
    dispatch_once(&deviceOnceToken, ^{
        gDeviceManager = [[EOADeviceManager alloc] init];
        gDeviceManager.tempDeviceArr = [NSMutableArray array];
        gDeviceManager.autoClear = NO;
    });
    return gDeviceManager;
}

- (void) getDeviceListWithCompletion:(deviceListCallback) completion
{
    self.mDeviceListCallback = completion;
    self.mRealm = [EOAHelper defaultRealm];
    
    self.mDeviceList = [EOADeviceInfo allObjectsInRealm:self.mRealm];
    
    __weak EOADeviceManager *weakSelf = self;
    //添加设备列表变化监测
    self.notificationToken = [self.mDeviceList addNotificationBlock:^(RLMResults * _Nullable results,
                                                                      RLMCollectionChange * _Nullable change,
                                                                      NSError * _Nullable error) {
        if ((change.deletions.count > 0 || change.insertions.count > 0 || change.modifications.count > 0) &&
             (!weakSelf.autoClear || weakSelf.mDeviceList.count > 0))
        {
            [weakSelf postListChangedNotification];
        }

        weakSelf.autoClear = NO;
    }];
    
    if (self.mDeviceList.count > 0 && self.mDeviceListCallback)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mDeviceListCallback(weakSelf.mDeviceList,YES);
            weakSelf.mDeviceListCallback = nil;//缓存数据给出后以通知方式通知外部数据有更新
        });
    }

    [self.tempDeviceArr removeAllObjects];
    //请求获取设备列表
    [self getDeviceListWithIndex:0];
}

- (void) captureCameraCoverWithSerial:(NSString *) deviceSerial
                             cameraNo:(NSInteger) cameraNo
                           completion:(captureCallback) completion
{
    if (!deviceSerial)
    {
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }
    __weak EOADeviceManager *weakSelf = self;
    [EZOpenSDK captureCamera:deviceSerial cameraNo:cameraNo completion:^(NSString *url, NSError *error) {
        if (!completion)
        {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                completion(nil);
            }
            else
            {
                [weakSelf updateCoverUrlWithSerial:deviceSerial
                                          cameraNo:cameraNo
                                          CoverUrl:url];
                completion(url);
            }
       });
    }];
}

- (NSArray *) getCameraList
{
    NSMutableArray *cameraList = [NSMutableArray array];
    if (!self.mDeviceList || self.mDeviceList.count <= 0)
    {
        return cameraList;
    }
    
    for (int i = 0; i < self.mDeviceList.count; i++)
    {
        EOADeviceInfo *deviceInfo = [self.mDeviceList objectAtIndex:i];
        for (int j = 0; j < deviceInfo.cameraList.count; j++)
        {
            EOACameraInfo *cameraInfo = [deviceInfo.cameraList objectAtIndex:j];
            [cameraList addObject:cameraInfo];
        }
    }
    
    return cameraList;
}

- (NSString *) getCoverUrlWithSerial:(NSString *) deviceSerial cameraNo:(NSInteger) camaeraNo
{
    if (!deviceSerial || !self.mRealm)
    {
        return nil;
    }
    
    EOACameraCoverInfo *cameraCoverInfo = [EOACameraCoverInfo objectInRealm:self.mRealm
                                                              forPrimaryKey:[NSString stringWithFormat:@"%@_%ld",
                                                                             deviceSerial,
                                                                             camaeraNo]];
    
    if (!cameraCoverInfo)
    {
        return nil;
    }
    
    return cameraCoverInfo.coverUrl;
}

- (void) updateCoverUrlWithSerial:(NSString *) deviceSerial
                         cameraNo:(NSInteger) camaeraNo
                         CoverUrl:(NSString *) coverUrl
{
    if (!deviceSerial || !self.mRealm)
    {
        return;
    }
    
    EOACameraCoverInfo *cameraCoverInfo = [EOACameraCoverInfo objectInRealm:self.mRealm
                                                              forPrimaryKey:[NSString stringWithFormat:@"%@_%ld",
                                                                             deviceSerial,
                                                                             camaeraNo]];
    if (!cameraCoverInfo)
    {
        return;
    }
    
    [self.mRealm beginWriteTransaction];
    [cameraCoverInfo updateWithCoverUrl:coverUrl];
    [self.mRealm commitWriteTransaction];
}

- (void) updateDeviceList
{
    self.autoClear = YES;
    //清除缓存的设备信息
    [self clearSavedDeviceInfo];
    
    [self.tempDeviceArr removeAllObjects];

    //请求获取设备列表
    [self getDeviceListWithIndex:0];
}

- (void) clearSavedDeviceInfo
{
    [self.mRealm beginWriteTransaction];
    [self.mRealm deleteObjects:self.mDeviceList];
    [self.mRealm commitWriteTransaction];
//    self.mDeviceList = nil;
}

- (void) switchCameraMotionDetectWithSerial:(NSString *) serial isOn:(BOOL) isOn result:(resultCallback) result
{
    if (!serial)
    {
        if (result)
        {
            result(NO);
        }
        return;
    }
    __weak EOADeviceManager *weakSelf = self;

    [EZOpenSDK setDefence:isOn?EZDefenceStatusOn:EZDefenceStatusOffOrSleep deviceSerial:serial completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if (result)
                {
                    result(NO);
                }
            }
            else
            {
                EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:serial];
                EOACameraInfo *cameraInfo = [weakSelf findeCameraInfoWithSerial:serial deviceInfo:tempDevInfo];
                
                [weakSelf.mRealm beginWriteTransaction];
                tempDevInfo.defence = isOn?EZDefenceStatusOn:EZDefenceStatusOffOrSleep;
                if (cameraInfo)
                {
                    cameraInfo.defence = isOn?EZDefenceStatusOn:EZDefenceStatusOffOrSleep;
                }
                [weakSelf.mRealm commitWriteTransaction];
                
                if (result)
                {
                    result(YES);
                }
            }
        });
    }];
}

- (void) changeDeviceNameWithSerial:(NSString *) deviceSerial newName:(NSString *) newName result:(resultCallback) result
{
    if (!deviceSerial || !newName || newName.length <= 0)
    {
        if (result)
        {
            result(NO);
        }
        return;
    }
    __weak EOADeviceManager *weakSelf = self;

    [EZOpenSDK setDeviceName:newName deviceSerial:deviceSerial completion:^(NSError *error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if (result)
                {
                    result(NO);
                }
            }
            else
            {
                //目前修改设备名称会自动修改该设备下的所有通道名称
                EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:deviceSerial];
                EOACameraInfo *cameraInfo = [weakSelf findeCameraInfoWithSerial:deviceSerial deviceInfo:tempDevInfo];
                
                [weakSelf.mRealm beginWriteTransaction];
                tempDevInfo.deviceName = newName;
                if (cameraInfo)
                {
                    cameraInfo.cameraName = newName;
                }
                [weakSelf.mRealm commitWriteTransaction];

                if (result)
                {
                    result(YES);
                }
            }
        });

    }];
}

- (void) changeCameraNameWithSerial:(NSString *) cameraSerial
                           cameraNo:(NSInteger) cameraNo
                            newName:(NSString *) newName
                             result:(resultCallback) result
{
    if (!cameraSerial || !newName || newName.length <= 0)
    {
        if (result)
        {
            result(NO);
        }
        return;
    }
    __weak EOADeviceManager *weakSelf = self;
    
    EOAModifyCameraNameRequest *request = [[EOAModifyCameraNameRequest alloc] init];
    request.deviceSerial = cameraSerial;
    request.channelNo = cameraNo;
    request.name = newName;
    [request startWithCustomBLock:^(NSMutableDictionary *dictionary) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!dictionary)
            {
                if (result)
                {
                    result(NO);
                }
                return;
            }
            
            NSNumber *resultCode = [dictionary objectForKey:RESULT_CODE_KEY];
            if (!resultCode || [resultCode isKindOfClass:[NSNull class]])
            {
                if (result)
                {
                    result(NO);
                }
            }
            else
            {
                NSInteger code = [resultCode integerValue];
                if (code == DEFAULT_SUCCESS_CODE)
                {
                    EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:cameraSerial];
                    EOACameraInfo *cameraInfo = [weakSelf findeCameraInfoWithSerial:cameraSerial deviceInfo:tempDevInfo];
                    if (cameraInfo)
                    {
                        [weakSelf.mRealm beginWriteTransaction];
                        cameraInfo.cameraName = newName;
                        [weakSelf.mRealm commitWriteTransaction];
                    }
                    
                    if (result)
                    {
                        result(YES);
                    }
                }
                else
                {
                    if (result)
                    {
                        result(NO);
                    }
                }
                
            }
        });
    }];
}

- (NSString *) getDeviceImageUrlWithType:(NSString *) typeStr
{
    NSArray *typeArr = [typeStr componentsSeparatedByString:@"-"];
    
    if (typeArr.count < 2)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"https://statics.ys7.com/openweb/device/%@-%@/2.png",[typeArr firstObject],[typeArr objectAtIndex:1]];
    
//    return [NSString stringWithFormat:@"https://statics.ys7.com/device/image/%@/2.png",typeStr];
}

- (EOADeviceInfo *) getDeviceInfoWithCameraInfo:(EOACameraInfo *) cameraInfo
{
    if (!cameraInfo)
    {
        return nil;
    }
    
    for (int i = 0; i < self.mDeviceList.count; i ++)
    {
        EOADeviceInfo *tempDeviceInfo = [self.mDeviceList objectAtIndex:i];
        for (int j = 0; j < tempDeviceInfo.cameraList.count; j ++)
        {
            EOACameraInfo *tempCameraInfo = [tempDeviceInfo.cameraList objectAtIndex:j];
            if ([tempCameraInfo isEqual:cameraInfo])
            {
                return tempDeviceInfo;
            }
        }
    }
    
    return nil;
}

- (NSString *) getDeviceBgImageNameWithIndex:(NSInteger) index
{
    return [NSString stringWithFormat:@"bg_b%ld",index%10+1];
}

- (void) setVideoLevelWithSerial:(NSString *) deviceSerial
                        cameraNo:(NSInteger) cameraNo
                      videoLevel:(NSInteger) videoLevel
                          result:(resultCallback) resultCallback
{
    if (!deviceSerial)
    {
        if (resultCallback)
        {
            resultCallback(NO);
        }
        return;
    }
    __weak EOADeviceManager *weakSelf = self;
    
    [EZOpenSDK setVideoLevel:deviceSerial cameraNo:cameraNo videoLevel:videoLevel completion:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error)
            {
                EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:deviceSerial];
                EOACameraInfo *cameraInfo = [weakSelf findeCameraInfoWithSerial:deviceSerial deviceInfo:tempDevInfo];
                if (cameraInfo)
                {
                    [weakSelf.mRealm beginWriteTransaction];
                    cameraInfo.videoLevel = videoLevel;
                    [weakSelf.mRealm commitWriteTransaction];
                }
            }
            
            if (resultCallback)
            {
                resultCallback(error?NO:YES);
            }
        });

    }];
}

- (void) deleteDeviceWithSerial:(NSString *) deviceSerial result:(resultCallback) resultCallback
{
    if (!deviceSerial)
    {
        if (resultCallback)
        {
            resultCallback(NO);
        }
        return;
    }
    
    __weak EOADeviceManager *weakSelf = self;
    [EZOpenSDK deleteDevice:deviceSerial completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if (resultCallback)
                {
                    resultCallback(NO);
                }
            }
            else
            {
                EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:deviceSerial];
                EOACameraInfo *cameraInfo = [weakSelf findeCameraInfoWithSerial:deviceSerial deviceInfo:tempDevInfo];
                
                [weakSelf.mRealm beginWriteTransaction];
                if (cameraInfo)
                {
                    [weakSelf.mRealm deleteObject:cameraInfo];
                }
                [weakSelf.mRealm deleteObject:tempDevInfo];
                [weakSelf.mRealm commitWriteTransaction];
                
                if (resultCallback)
                {
                    resultCallback(YES);
                }
            }
        });
    }];
}

- (void) setDeviceEncryptWithSerial:(NSString *) serial
                         verifyCode:(NSString *) verifyCode
                              value:(BOOL) value
                             result:(resultCallback) resultCallback
{
    if (!serial || (!value && !verifyCode))
    {
        if (resultCallback)
        {
            resultCallback(NO);
        }
        return;
    }
    
    __weak EOADeviceManager *weakSelf = self;
    
    [EZOpenSDK setDeviceEncryptStatus:serial verifyCode:verifyCode encrypt:value completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if (resultCallback)
                {
                    resultCallback(NO);
                }
            }
            else
            {
                EOADeviceInfo *tempDevInfo = [weakSelf findDeviceInfoWithSerial:serial];
                if (tempDevInfo)
                {
                    [weakSelf.mRealm beginWriteTransaction];
                    tempDevInfo.isEncrypt = value;
                    [weakSelf.mRealm commitWriteTransaction];
                }
                
                if (resultCallback)
                {
                    resultCallback(YES);
                }
            }
        });
    }];
}

- (void) getDeviceVoiceStateWithSerial:(NSString *) serial result:(void(^)(BOOL result,BOOL status)) resultCallback
{
    if (!serial)
    {
        if (resultCallback)
        {
            resultCallback(NO,NO);
        }
        return;
    }
    
    EOAGetVoiceStateRequest *request = [[EOAGetVoiceStateRequest alloc] init];
    request.deviceSerial = serial;
    
    [request startWithCustomBLock:^(NSMutableDictionary *dictionary) {
        
        if (!dictionary)
        {
            if (resultCallback)
            {
                resultCallback(NO,NO);
            }
            return;
        }
        
        if ([[dictionary objectForKey:RESULT_CODE_KEY] integerValue] == DEFAULT_SUCCESS_CODE)
        {
            NSNumber *enable = [dictionary objectForKey:@"enable"];
            if (enable && ![enable isKindOfClass:[NSNull class]])
            {
                if ([enable integerValue] == 1)
                {
                    if (resultCallback)
                    {
                        resultCallback(YES,YES);
                    }
                }
                else
                {
                    if (resultCallback)
                    {
                        resultCallback(YES,NO);
                    }
                }
            }
            else
            {
                if (resultCallback)
                {
                    resultCallback(NO,NO);
                }
            }
        }
        else
        {
            if (resultCallback)
            {
                resultCallback(NO,NO);
            }
        }
    }];
}

- (void) getDeviceCloudStateWithSerial:(NSString *) serial result:(void(^)(BOOL result,NSInteger status)) resultCallback
{
    if (!serial)
    {
        if (resultCallback)
        {
            resultCallback(NO,-1);
        }
        return;
    }
    
    EOAGetCloudStateRequest *request = [[EOAGetCloudStateRequest alloc] init];
    request.deviceSerial = serial;
    
    [request startWithCustomBLock:^(NSMutableDictionary *dictionary) {
        
        if (!dictionary)
        {
            if (resultCallback)
            {
                resultCallback(NO,-1);
            }
            return;
        }
        
        if ([[dictionary objectForKey:RESULT_CODE_KEY] integerValue] == DEFAULT_SUCCESS_CODE)
        {
            NSDictionary *dataDic = [dictionary objectForKey:@"data"];
            if (!dataDic)
            {
                if (resultCallback)
                {
                    resultCallback(NO,-1);
                }
                return;
            }
            NSNumber *statusNum = [dataDic objectForKey:@"status"];
            if (statusNum && ![statusNum isKindOfClass:[NSNull class]])
            {
                NSInteger status = [statusNum integerValue];
                if (resultCallback)
                {
                    resultCallback(YES,status);
                }
            }
            else
            {
                if (resultCallback)
                {
                    resultCallback(NO,-1);
                }
            }
        }
        else
        {
            if (resultCallback)
            {
                resultCallback(NO,-1);
            }
        }
    }];
}

- (void) setDeviceVoiceStateWithSerial:(NSString *) serial state:(NSInteger) state result:(resultCallback) callback
{
    if (!serial)
    {
        return;
    }
    
    EOASetVoiceStateRequest *request = [[EOASetVoiceStateRequest alloc] init];
    request.deviceSerial = serial;
    request.enable = state;
    request.channelNo = 0;
    [request startWithCustomBLock:^(NSMutableDictionary *dictionary) {
        if (!dictionary)
        {
            if (callback)
            {
                callback(NO);
            }
            return;
        }
        
        if ([[dictionary objectForKey:RESULT_CODE_KEY] integerValue] == DEFAULT_SUCCESS_CODE)
        {
            if (callback)
            {
                callback(YES);
            }
        }
        else
        {
            if (callback)
            {
                callback(NO);
            }
        }
    }];
}

#pragma mark - support

- (EOADeviceInfo *) findDeviceInfoWithSerial:(NSString *) serial
{
    if (!self.mDeviceList)
    {
        return nil;
    }
    
    RLMResults *deviceList = [self.mDeviceList objectsWhere:@"deviceSerial = %@",serial];
    if (deviceList.count > 0)
    {
        return [deviceList firstObject];
    }

    return nil;
}

- (EOACameraInfo *) findeCameraInfoWithSerial:(NSString *) serial deviceInfo:(EOADeviceInfo *) deviceInfo
{
    if (!deviceInfo || !deviceInfo.cameraList)
    {
        return nil;
    }
    
    RLMResults *cameraList = [deviceInfo.cameraList objectsWhere:@"deviceSerial = %@",serial];
    
    if (cameraList.count > 0)
    {
        return [cameraList firstObject];
    }
    
    return nil;
}

//获取所有设备，递归调用
- (void) getDeviceListWithIndex:(NSInteger) index
{
    __weak EOADeviceManager *weakSelf = self;
    [EZOpenSDK getDeviceList:index
                    pageSize:DEVICE_PAGE_SIZE
                  completion:^(NSArray *deviceList, NSInteger totalCount, NSError *error) {
                      if (error)
                      {
                          NSLog(@"get device list error:%@",error);
                          if (weakSelf.mDeviceListCallback)
                          {
                              weakSelf.mDeviceListCallback(nil,NO);
                          }
                          return;
                      }
                      
                      [weakSelf.tempDeviceArr addObjectsFromArray:deviceList];
                      
                      if (totalCount > weakSelf.tempDeviceArr.count)
                      {
                          [weakSelf getDeviceListWithIndex:index+1];
                      }
                      else
                      {
                          weakSelf.autoClear = YES;
                          [weakSelf clearSavedDeviceInfo];
                          [weakSelf makeAndCacheDeviceInfoWithList:weakSelf.tempDeviceArr];
                          [weakSelf makeAndCachCameraCoverInfoWithList:weakSelf.tempDeviceArr];
                          
                          if (weakSelf.mDeviceListCallback)
                          {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  weakSelf.mDeviceListCallback(weakSelf.mDeviceList,YES);
                              });
                          }
                          else//以通知方式通知外部数据有更新,已注册过数据变化通知
                          {
//                              [weakSelf postListChangedNotification];
                          }
                      }
                  }];
}

- (void) makeAndCacheDeviceInfoWithList:(NSArray *) deviceList
{
    if (!deviceList)
    {
        return;
    }
    
    for (EZDeviceInfo *devInfo in deviceList)
    {
        RLMResults *tempList = [self.mDeviceList objectsWhere:@"deviceSerial = %@",devInfo.deviceSerial];
        
        if (tempList.count > 0)
        {
            EOADeviceInfo *tempDevInfo = [tempList firstObject];
            [self.mRealm beginWriteTransaction];
            [tempDevInfo updateWithInfo:devInfo];
            [self.mRealm commitWriteTransaction];
        }
        else
        {
            EOADeviceInfo *deviceInfo = [EOADeviceInfo deviceInfoWithInfo:devInfo];
            [self.mRealm beginWriteTransaction];
            [self.mRealm addOrUpdateObject:deviceInfo];
            [self.mRealm commitWriteTransaction];
        }
    }
}

- (void) makeAndCachCameraCoverInfoWithList:(NSArray *) deviceList
{
    if (!deviceList)
    {
        return;
    }
    
    for (EZDeviceInfo *devInfo in deviceList)
    {
        if (!devInfo.cameraInfo || devInfo.cameraInfo.count <= 0)
        {
            continue;
        }
        
        for (EZCameraInfo *cameraInfo in devInfo.cameraInfo)
        {
            EOACameraCoverInfo *cameraCoverInfo = [EOACameraCoverInfo objectInRealm:self.mRealm
                                                                      forPrimaryKey:[NSString stringWithFormat:@"%@_%ld",
                                                                                     cameraInfo.deviceSerial,
                                                                                     cameraInfo.cameraNo]];
            if (!cameraCoverInfo)//如存在则不需修改，如不存在则添加
            {
                EOACameraCoverInfo * coverInfo = [EOACameraCoverInfo cameraCoverInfoWithSerial:cameraInfo.deviceSerial
                                                                                      cameraNo:cameraInfo.cameraNo
                                                                                      coverUrl:cameraInfo.cameraCover];
                [self.mRealm beginWriteTransaction];
                [self.mRealm addObject:coverInfo];
                [self.mRealm commitWriteTransaction];
            }
        }
    }
}


- (void) postListChangedNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EOADeviceManagerListChanged object:nil];
    });
}


@end
