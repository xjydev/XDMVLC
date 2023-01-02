//
//  NSDictionary+XDExt.m
//  xidodev
//
//  Created by XiaoDev on 2020/9/3.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import "NSDictionary+XDExt.h"

@implementation NSDictionary (XDExt)
- (nullable NSArray *)xd_ArrayForKey:(NSString *)aKey {
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSArray class]])
    {
        return obj;
    }
    return nil;
}
- (nullable NSString *)xd_StringForKey:(NSString *)aKey {
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    else if([obj isKindOfClass:[NSNumber class]]){
        return [obj stringValue];
    }
    return nil;
}
- (nullable NSDictionary *)xd_DictForKey:(NSString *)aKey {
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        return obj;
    }
    
    return nil;
}
- (nullable NSNumber *)xd_NumberForKey:(NSString *)aKey {
    id obj = [self objectForKey:aKey];
    if ([obj isKindOfClass:[NSNumber class]])
    {
        return obj;
    }
    return nil;
}
- (BOOL)xd_BoolForKey:(NSString *)aKey {
    id obj = [self objectForKey:aKey];
    if ([obj respondsToSelector:@selector(boolValue)])
    {
        return [obj boolValue];
    }
    return NO;
}
- (NSInteger)xd_IntegerForKey:(NSString *)aKey {
   id obj = [self objectForKey:aKey];
   if ([obj respondsToSelector:@selector(integerValue)])
   {
       return [obj integerValue];
   }
   return 0;
}
- (NSString *)xd_JSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from dictionary: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *jsonStr = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonStr;
}
@end

@implementation NSMutableDictionary (XDExt)

- (void)xd_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey {
    if (aKey == nil)
    {
        return;
    }
    if (anObject) {
        [self setObject:anObject forKey:aKey];
    }
    else {
        [self removeObjectForKey:aKey];
    }
}

@end
