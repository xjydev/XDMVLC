//
//  NSString+XDExt.m
//  HuaNong
//
//  Created by XiaoDev on 2020/9/20.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import "NSString+XDExt.h"
#import <CommonCrypto/CommonDigest.h>

#define DKey @"B+T//eeJw8NPNnjwWiyZca3rk7uSsNwL"
//07E4FFFDE789C3C34F3678F05A2C9971ADEB93BB92B0DC0B
@implementation NSString (XDExt)

+ (NSString *)xd_string:(NSString *)str {
   if (str == nil) {
        return @"";
    }
    if (![str isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    if (str == NULL) {
        return @"";
    }
    
    if ([str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if ([[str  xd_trim] length] == 0) {
        return @"";
    }
    
    return str;
}
+ (BOOL)xd_isNilWithStr:(NSString *)str {
    if (str == nil) {
         return YES;
     }
     if (![str isKindOfClass:[NSString class]]) {
         return YES;
     }

     if (str == NULL) {
         return YES;
     }

     if ([str isKindOfClass:[NSNull class]]) {
         return YES;
     }

     if ([[str xd_trim] length] == 0) {
         return YES;
     }

     return NO;
}
- (BOOL)xd_isNil {
   if (self == nil) {
        return YES;
    }
    if (![self isKindOfClass:[NSString class]]) {
        return YES;
    }

    if (self == NULL) {
        return YES;
    }

    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }

    if ([[self xd_trim] length] == 0) {
        return YES;
    }

    return NO;
}
- (NSString *)xd_string {
   if (self == nil) {
        return @"";
    }
    if (![self isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    if (self == NULL) {
        return @"";
    }
    
    if ([self isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if ([[self  xd_trim] length] == 0) {
        return @"";
    }
    
    return self;
}
- (NSString *)xd_trim {
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return result;
}
- (NSString *)xd_SHA1 {
  const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];

    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    NSString *upstr = [output uppercaseString];
    return upstr;
}
- (NSString *)xd_MD5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    NSString *upstr = [output uppercaseString];
    return upstr;
}
@end
