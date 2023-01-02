//
//  UIColor+Hex.h
//
//  Created by wangyuehong on 15/9/6.
//  Copyright (c) 2015年 Oradt. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMainCOLOR [UIColor ora_colorWithHex:0x1b67f1]

#define kDarkCOLOR(xcolor) [UIColor ora_darkColorWithHex:xcolor andAlpha:1.0]
#define kCOLOR(xcolor,xdarkColor) [UIColor ora_colorWithHex:xcolor darkHex:xdarkColor]
#define kRGBColor(r,g,b) [UIColor colorWithRed:r green:g blue:b alpha:1.0]
@interface UIColor (ora_Hex)

//根据16进制颜色值和alpha值生成UIColor
+ (UIColor *)ora_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
+ (UIColor *)ora_darkColorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;
//根据16进制颜色值和alpha为1生成UIColor
+ (UIColor *)ora_colorWithHex:(UInt32)hex;
+ (UIColor *)ora_colorWithHex:(UInt32)hex darkHex:(UInt32)darkHex;

//根据16进制颜色字符串生成UIColor
// hexString 支持格式为 OxAARRGGBB / 0xRRGGBB / #AARRGGBB / #RRGGBB / AARRGGBB / RRGGBB
+ (UIColor *)ora_colorWithHexString:(NSString *)hexString;
+ (UIColor *)ora_colorWithHexString:(NSString *)hexString andAlpha:(CGFloat)alpha;

//返回当前对象的16进制颜色值
- (UInt32)ora_hexValue;

+ (UIColor *) colorWithHexString: (NSString *)color;
+ (UIColor *) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;

@end
