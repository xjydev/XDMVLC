//
//  NSDictionary+XDExt.h
//  xidodev
//
//  Created by XiaoDev on 2020/9/3.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (XDExt)
- (nullable NSArray *)xd_ArrayForKey:(NSString *)aKey;
- (nullable NSString *)xd_StringForKey:(NSString *)aKey;
- (nullable NSDictionary *)xd_DictForKey:(NSString *)aKey;

- (nullable NSNumber *)xd_NumberForKey:(NSString *)aKey;
- (BOOL)xd_BoolForKey:(NSString *)aKey;
- (NSInteger)xd_IntegerForKey:(NSString *)aKey;

- (NSString *)xd_JSONString;

@end

@interface NSMutableDictionary (XDExt)
- (void)xd_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey;
@end

NS_ASSUME_NONNULL_END
