//
//  CGNetHandle.m
//  CGNetHandle
//
//  Created by 郭成功 on 16/1/5.
//  Copyright © 2016年 郭成功. All rights reserved.
//

#import "CGNetHandle.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AFNetworkReachabilityManager.h"
#import "Reachability.h"

@implementation CGNetHandle

+(void)GetDataFromNetWorkWithURLStr:(NSString *)urlStr par:(NSDictionary *)dic data:(void (^)(id))respon
{
    // 获取完整存储路径名字(网址作为这个文件名)
    NSString *path = [CGNetHandle getPathWithURL:urlStr];
    
    // 判断有没有网络
    BOOL statusnumber = [self getNetWorkStatus];
    
    AFNetworkReachabilityManager *netWorkManager = [AFNetworkReachabilityManager sharedManager];
    
//    NSString *url_string = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url_string = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/javascript",@"text/html",nil];
    
    // 支持的接口类型
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/json",@"application/json",@"text/javascript",@"text/html",nil];
    
    if (statusnumber) { // 如果有网
        
        [session GET:url_string parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [netWorkManager stopMonitoring];
            
            NSLog(@"使用AFN进行get请求成功");
            
            respon(responseObject);
            
            // 写入本地
            [NSKeyedArchiver archiveRootObject:responseObject toFile:path];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSLog(@"失败==== %@",error);
            
            return;
            
        }];
        
    } else { // 无网络
        
        NSLog(@"当前无网络");
        
        NSFileManager *fileMana = [NSFileManager defaultManager];
        
        // 先判断这个文件在不在
        if ([fileMana fileExistsAtPath:path]) {
            
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            // 加保护
            if (dic != nil) {
                
                respon(dic);
                
            } else if (arr != nil) {
                
                respon(arr);
                
            }
            
        } else {
            
            respon(nil);
          
        }
        
    }
}

+ (NSString *)getPathWithURL:(NSString *)url
{
    
    // 1. 获取cache文件夹路径
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    cachePath = [cachePath stringByAppendingPathComponent:@"CGNetHandleFolder"];
    
    NSFileManager *folder = [NSFileManager defaultManager];
    
    //如果没有这个文件夹，就创建
    if (![folder fileExistsAtPath:cachePath]) {
        [folder createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 2. MD5加密转换网址成一串数字
    NSString *urlFile = [NSString stringWithFormat:@"%@", [CGNetHandle cachedFileNameForKey:url]];
    
    // 3. 拼接
    cachePath = [cachePath stringByAppendingPathComponent:urlFile];
    
    return cachePath;
    
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}
// 判断网络
+ (BOOL)getNetWorkStatus
{
    Reachability *reMan = [Reachability reachabilityForInternetConnection];
    
    return reMan.currentReachabilityStatus;
}

@end
