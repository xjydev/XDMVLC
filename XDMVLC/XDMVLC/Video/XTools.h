//
//  XTools.h
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+Hex.h"
typedef NS_ENUM(NSInteger ,SHUDType) {
    SHUDTypeLoading,
    SHUDTypeSuccess,
    SHUDTypeFaile,
    SHUDTypeForward,
    SHUDTypeBack,
};
typedef NS_ENUM(NSInteger , XDBiometryType){
    XDBiometryTypeNone = 1,//没有
    XDBiometryTypeFaceID,
    XDBiometryTypeTouchID,
};
typedef NS_ENUM(NSInteger , XDCurrentApp){
    XDCurrentAppFileManager = 1,//悦览播放
    XDCurrentAppWenjian,//保密文件
    XDCurrentAppPlayer,//播放
};
#define XTOOLS [XTools shareXTools]

#define kAppendDocument(p) [[XTools shareXTools] appendStringDocumentPath:p]
//userDefaults
#define kUSerD [NSUserDefaults standardUserDefaults]
//观察者
#define kNOtificationC [NSNotificationCenter defaultCenter]

//单例Application
#define APPSHAREAPP [UIApplication sharedApplication]
//是ipad
#define IsPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//系统版本号
#define IOSSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_CURRENT_Name [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define kStatusBar_Height [UIApplication sharedApplication].statusBarFrame.size.height
//屏幕的宽度,支持旋转屏幕
#define kScreen_Width  (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

#define kSizeWidth [UIScreen mainScreen].bounds.size.width
#define KSizeHeight [UIScreen mainScreen].bounds.size.height

//屏幕的高度,支持旋转屏幕
#define kScreen_Height                                                                                  \
(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) \
? [UIScreen mainScreen].bounds.size.width                                               \
: [UIScreen mainScreen].bounds.size.height)

#define KNavitionbarHeight ([UIApplication sharedApplication].statusBarFrame.size.height + 44) // 适配iPhone x 导航高度

#define KBottomSafebarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0) // 适配
#define kDevice_Is_iPhoneX [XTools isiPhoneX]
#define KUIFontNR(font) [UIFont fontWithName:@"PingFangSC-Regular" size:(font)]
#define KUIFontNM(font) [UIFont fontWithName:@"PingFangSC-Medium" size:(font)]
#define KUIFontNS(font) [UIFont fontWithName:@"PingFangSC-Semibold" size:(font)]
#define KUIFontNL(font) [UIFont fontWithName:@"PingFangSC-Light" size:(font)]

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n", \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], \
__LINE__, \
[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif
/*弱引用宏*/
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif


#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#define kNoTrace @"knotracerecod"//是否留下记录
#define KUIFontNR(font) [UIFont fontWithName:@"PingFangSC-Regular" size:(font)]
#define KUIFontNM(font) [UIFont fontWithName:@"PingFangSC-Medium" size:(font)]
#define KUIFontNS(font) [UIFont fontWithName:@"PingFangSC-Semibold" size:(font)]

#define kLocalized(s)  [XTools localizedStr:s]
#define KDocumentP [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kVolume @"123"
@interface XTools : NSObject
+ (instancetype)shareXTools;
+ (BOOL)isiPhoneX;
+ (XDCurrentApp)currentApp;
/**
 屏幕旋转方向
 */
//@property (nonatomic, assign)UIInterfaceOrientationMask orientationMask;
//是否可以转屏,默认是YES，可以旋转。
//@property (nonatomic, assign)BOOL isCanRotation;
@property (nonatomic, copy) NSString *hiddenFilePath;
@property (nonatomic, strong)NSDateFormatter *dateFormater;
@property (nonatomic, strong)NSString *dateStr;
@property (nonatomic, strong)NSString *timeStr;
@property (nonatomic, assign)XDBiometryType biometryType;//生物识别类型。
- (NSString *)appendStringDocumentPath:(NSString *)path;
+ (NSString *)localizedStr:(NSString *)str ;
/**
 播放文件

 @param path 文件路径
 @param origionalWiewController 开始播放前的界面
 @return 是否播放成功
 */
- (BOOL)playFileWithPath:(NSString *)path OrigionalWiewController:(UIViewController *)origionalWiewController;

/**
 判断文件类型

 @param path 文件路径
 @return 文件类型
 */
//- (int)fileFormatWithPath:(NSString *)path;

- (void)showMessage:(NSString *)title;
- (void)showLoading:(NSString *)title;
- (void)showMessage:(NSString *)title inView:(UIView *)inView;
- (void)showLoading:(NSString *)title inView:(UIView *)inView;
- (void)setHintCenter;
- (void)hiddenLoading;
- (void)showAlertTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num))completionHandler;
- (void)showAlertTextField:(NSString *)text placeholder:(NSString *)placeHolder title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num,NSString *textValue))completionHandler;
//时间和秒之间字符串的转换
- (double)timeStrToSecWithStr:(NSString *)str;
- (NSString *)timeSecToStrWithSec:(double)sec;


- (NSString *)timeStrFromDate:(NSDate *)date;
- (NSString *)hmtimeStrFromDate:(NSDate *)date;
- (BOOL)openURLStr:(NSString *)urlStr;
- (UIViewController *)topViewController;
- (UIViewController *)visableController;
/// 是否可以转屏
- (BOOL)canAutorotate;
@end
