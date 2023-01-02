//
//  NSArray+XDExt.h
//  xidodev
//
//  Created by XiaoDev on 2020/9/3.
//  Copyright © 2020 Xiaodev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (XDExt)
- (id)xd_objectAtIndex:(NSUInteger)index;
- (NSString *)xd_JSONString;

@end

@interface NSMutableArray (XDExt)
- (void)xd_addObject:(NSObject *)anObject;
- (void)xd_removeObjectAtIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
