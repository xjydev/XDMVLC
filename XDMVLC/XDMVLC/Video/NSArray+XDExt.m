//
//  NSArray+XDExt.m
//  xidodev
//
//  Created by XiaoDev on 2020/9/3.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import "NSArray+XDExt.h"

@implementation NSArray (XDExt)
- (id)xd_objectAtIndex:(NSUInteger)index {
    if (index <self.count) {
        return [self objectAtIndex:index];
    }else{
        return nil;
    }
}
- (NSString *)xd_JSONString {
    if (self == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
#ifdef DEBUG
        NSLog(@"fail to get JSON from array: %@, error: %@", self, error);
#endif
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    return jsonString;
}

@end

@implementation NSMutableArray (XDExt)
- (void)xd_addObject:(NSObject *)anObject {
    if (anObject) {
        [self addObject:anObject];
    }
}
- (void)xd_removeObjectAtIndex:(NSInteger)index {
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}
@end
