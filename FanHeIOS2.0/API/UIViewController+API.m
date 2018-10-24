//
//  UIViewController+API.m
//  ChannelPlus
//
//  Created by Peter on 14/12/23.
//  Copyright (c) 2014年 Peter. All rights reserved.
//

#import "UIViewController+API.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFSecurityPolicy.h"


static const int kTimeoutInterval = 10;

@implementation UIViewController (API)

#pragma mark - 同步、异步调用接口

- (void)cancelAllRequest{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
}

// 通过方法名获取接口链接
- (NSString *)getUrl:(NSString *)apiName
{
    return [NSString stringWithFormat:@"%@%@", API_HEADER, apiName];
}

// 请求异步调用，传递字典
- (void)requstType:(RequestType)requestType apiName:(NSString *)apiName
        paramDict:(NSMutableDictionary *)paramDict
              hud:(MBProgressHUD *)hud
          success:(SUCCESS_BLOCK)success
          failure:(FAILURE_BLOCK)failure
{
    if(![CommonMethod webIsLink]){
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSError *error = [NSError errorWithDomain:@"无法连接到网络" code:520 userInfo:nil];
        failure(nil, error, hud);
    }else{
        //在向服务端发送请求状态栏显示网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        BOOL containt = ![apiName isEqualToString:API_NAME_ACCESS_TOKEN];
        if(requestType == RequestType_Post){
            [self postWithUrl:[self getUrl:apiName] headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else if(requestType == RequestType_UPLOAD_IMG){
            [self postImageWithUrl:[self getUrl:apiName] headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else if(requestType == RequestType_Delete){
            [self deleteWithUrl:[self getUrl:apiName] headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else{
            [self getWithUrl:[self getUrl:apiName] headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }
    }
}


#pragma mark - AFNetworking 请求封装
// 异步调用，参数对象为字典
- (void)postWithUrl:(NSString *)urlstring
headerContaintAuthorization:(BOOL)containt
          paramDict:(NSDictionary *)paramDict
                hud:(MBProgressHUD *)hud
            success:(SUCCESS_BLOCK)success
            failure:(FAILURE_BLOCK)failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = kTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    if(containt){
        if([DataModelInstance shareInstance].tokenStr == nil || [DataModelInstance shareInstance].tokenStr.length == 0){
            [self accessTokenInValid:RequestType_Post urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            return;
        }else{
            [manager.requestSerializer setValue:[DataModelInstance shareInstance].tokenStr forHTTPHeaderField:@"Authorization"];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    __weak typeof(self) weakSelf = self;
    [manager POST:urlstring parameters:paramDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if([CommonMethod isKindOfDictionary:responseObject] && ((NSNumber*)[responseObject objectForKey:@"error_code"]).intValue == 401){
            [weakSelf accessTokenInValid:RequestType_Post urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else{
            success(operation, responseObject, hud);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
        failure(operation, error, hud);
       
    }];
}

- (void)postImageWithUrl:(NSString *)urlstring
headerContaintAuthorization:(BOOL)containt
          paramDict:(NSDictionary *)paramDict
                hud:(MBProgressHUD *)hud
            success:(SUCCESS_BLOCK)success
            failure:(FAILURE_BLOCK)failure
{
    NSString *filename = @"test.png";
    NSData *imagedata = [paramDict objectForKey:@"pphoto"];
    NSString *name = @"pphoto";
    if(!imagedata){
        imagedata = [paramDict objectForKey:@"cardpic"];
        name = @"cardpic";
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = kTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    if(containt){
        if([DataModelInstance shareInstance].tokenStr ==nil || [DataModelInstance shareInstance].tokenStr.length == 0){
            [self accessTokenInValid:RequestType_UPLOAD_IMG urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            return;
        }else{
            [manager.requestSerializer setValue:[DataModelInstance shareInstance].tokenStr forHTTPHeaderField:@"Authorization"];
        }
    }
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    __weak typeof(self) weakSelf = self;
    [manager POST:urlstring parameters:paramDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [formData appendPartWithFileData:imagedata name:name fileName:filename mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if([CommonMethod isKindOfDictionary:responseObject] && ((NSNumber*)[responseObject objectForKey:@"error_code"]).intValue == 401){
            [weakSelf accessTokenInValid:RequestType_UPLOAD_IMG urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else{
            success(operation, responseObject, hud);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        failure(operation, error, hud);
    }];
}

- (void)getWithUrl:(NSString *)urlstring
headerContaintAuthorization:(BOOL)containt
          paramDict:(NSDictionary *)paramDict
                hud:(MBProgressHUD *)hud
            success:(SUCCESS_BLOCK)success
            failure:(FAILURE_BLOCK)failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = kTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if(containt){
        if([DataModelInstance shareInstance].tokenStr ==nil || [DataModelInstance shareInstance].tokenStr.length == 0){
            [self accessTokenInValid:RequestType_Get urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            return;
        }else{
            [manager.requestSerializer setValue:[DataModelInstance shareInstance].tokenStr forHTTPHeaderField:@"Authorization"];
        }
    }
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    if(paramDict && paramDict[@"param"]){
        urlstring = [urlstring stringByAppendingString:paramDict[@"param"]];
    }
    urlstring = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    [manager GET:urlstring parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if([CommonMethod isKindOfDictionary:responseObject] && ((NSNumber*)[responseObject objectForKey:@"error_code"]).intValue == 401){
            [weakSelf accessTokenInValid:RequestType_Get urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else{
            success(operation, responseObject, hud);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        failure(operation, error, hud);
    }];
}

- (void)deleteWithUrl:(NSString *)urlstring
headerContaintAuthorization:(BOOL)containt
         paramDict:(NSDictionary *)paramDict
               hud:(MBProgressHUD *)hud
           success:(SUCCESS_BLOCK)success
           failure:(FAILURE_BLOCK)failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = kTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if(containt){
        if([DataModelInstance shareInstance].tokenStr == nil || [DataModelInstance shareInstance].tokenStr.length == 0){
            [self accessTokenInValid:RequestType_Delete urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            return;
        }else{
            [manager.requestSerializer setValue:[DataModelInstance shareInstance].tokenStr forHTTPHeaderField:@"Authorization"];
        }
    }
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    if(paramDict && paramDict[@"param"]){
        urlstring = [urlstring stringByAppendingString:paramDict[@"param"]];
    }
    urlstring = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    [manager DELETE:urlstring parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if([CommonMethod isKindOfDictionary:responseObject] && ((NSNumber*)[responseObject objectForKey:@"error_code"]).intValue == 401){
            [weakSelf accessTokenInValid:RequestType_Delete urlString:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
        }else{
            success(operation, responseObject, hud);
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //请求结束状态栏隐藏网络活动标志：
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        failure(operation, error, hud);
    }];
}


//token过期重新获取
- (void)accessTokenInValid:(RequestType)requestType
                 urlString:(NSString *)urlstring
headerContaintAuthorization:(BOOL)containt
                 paramDict:(NSDictionary *)paramDict
                       hud:(MBProgressHUD *)hud
                   success:(SUCCESS_BLOCK)success
                   failure:(FAILURE_BLOCK)failure
{
    static int i = 0;
    static int j = 0;
    if(i++ - j == 3){
        j = i++;
        return;
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:@"auth_token" forKey:@"grant_type"];
    [requestDict setObject:@"hmc" forKey:@"client_id"];
    [requestDict setObject:@"123456" forKey:@"client_secret"];
    
    [self requstType:RequestType_Post apiName:API_NAME_ACCESS_TOKEN paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isKindOfDictionary:responseObject]){
            [DataModelInstance shareInstance].tokenStr = [NSString stringWithFormat:@"%@ %@",responseObject[@"token_type"], responseObject[@"access_token"]];
            if(requestType == RequestType_Post){
                [self postWithUrl:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            }else if(requestType == RequestType_Delete){
                [self deleteWithUrl:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            }else if(requestType == RequestType_UPLOAD_IMG){
                [self postImageWithUrl:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            }else{
                [self getWithUrl:urlstring headerContaintAuthorization:containt paramDict:paramDict hud:hud success:success failure:failure];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        failure(operation, error, hud);
    }];
}


@end
