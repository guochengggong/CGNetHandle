//
//  CGNetHandle.h
//  CGNetHandle
//
//  Created by 郭成功 on 16/1/5.
//  Copyright © 2016年 郭成功. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGNetHandle : NSObject

+ (void)GetDataFromNetWorkWithURLStr:(NSString *)urlStr par:(NSDictionary *)dic data:(void(^)(id responseObject))respon;

@end
