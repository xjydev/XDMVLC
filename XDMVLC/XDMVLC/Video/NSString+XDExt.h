//
//  NSString+XDExt.h
//  HuaNong
//
//  Created by XiaoDev on 2020/9/20.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XDExt)
///是否为空字符串
- (BOOL)xd_isNil;
+ (BOOL)xd_isNilWithStr:(NSString *)str;
+ (NSString *)xd_string:(NSString *)str;
/// 如果字符串为空，返回@“”；
- (NSString *)xd_string;

- (NSString *)xd_SHA1;
- (NSString *)xd_MD5;

@end

NS_ASSUME_NONNULL_END
