//
//  XTools.m
//  FileManager
//
//  Created by xiaodev on Nov/18/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "XTools.h"
#import "AppDelegate.h"
#import "NewVideoViewController.h"

#define kBiometry @"kBiometryvalue"
static XTools *tools = nil;

@interface XTools()
@property (nonatomic, strong)UIActivityIndicatorView   *activityView;
@property (nonatomic, strong)UILabel                   *activityLabel;
@property (nonatomic, strong)UIView                    *loadingView;
//@property (nonatomic, strong)GADBannerView             *bannerView;//谷歌横条广告
@property (nonatomic, strong)UILabel *alertLabel;

@end
@implementation XTools
+ (instancetype)shareXTools {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[XTools alloc] init];
        
    });
    return tools;
}
+ (NSString *)localizedStr:(NSString *)str {
    return  NSLocalizedString(str,nil);
}
+ (XDCurrentApp)currentApp {
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if ([bundleName isEqualToString:@"cn.xiaodev.XPlayer"]) {//cn.xiaodev.XPlayer
        return XDCurrentAppPlayer;
    }
    if ([bundleName isEqualToString:@"cn.xiaodev.Wenjian"]) {//cn.xiaodev.Wenjian
        return XDCurrentAppWenjian;
    }
    return XDCurrentAppFileManager;
}

+ (BOOL)isiPhoneX {
    if ([UIWindow instancesRespondToSelector:@selector(safeAreaInsets)]) {
        return [self xtsafeAreaInsets].bottom > 0;
    }
    return (CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(375, 812)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(812, 375)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 896)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(896, 414)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(390, 844)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(844, 390)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(428, 926)) ||
            CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(926, 428)));
}
+ (UIEdgeInsets)xtsafeAreaInsets {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    if (![window isKeyWindow]) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (CGRectEqualToRect(keyWindow.bounds, [UIScreen mainScreen].bounds)) {
            window = keyWindow;
        }
    }
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = [window safeAreaInsets];
        return insets;
    }
    return UIEdgeInsetsZero;
}
- (NSString *)appendStringDocumentPath:(NSString *)path  {
    //其他应用的
    if (![path hasPrefix:KDocumentP] ) {
        path = [KDocumentP stringByAppendingPathComponent:path];
    }
    return path;
}
- (NSDateFormatter *)dateFormater {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"YYYY-MM-dd HH:mm:ss"]) {
            [_dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        }
    return _dateFormater;
}
- (NSString *)dateStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"YYYYMMDDHHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"YYYYMMDDHHmmss"]) {
            [_dateFormater setDateFormat:@"YYYYMMDDHHmmss"];
        }
    
    NSDate *date = [NSDate date];
    _dateStr = [_dateFormater stringFromDate:date];
    return _dateStr;
}
- (NSString *)timeStr {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc]init];
        [_dateFormater setDateFormat:@"HHmmss"];
        [_dateFormater setTimeZone:[NSTimeZone systemTimeZone]];
        [_dateFormater setLocale:[NSLocale autoupdatingCurrentLocale]];
    }
    else
        if (![_dateFormater.dateFormat isEqualToString:@"HHmmss"]) {
            [_dateFormater setDateFormat:@"HHmmss"];
        }
    NSDate *date = [NSDate date];
    _timeStr = [_dateFormater stringFromDate:date];
    return _timeStr;
}
#pragma mark - 播放文件
- (BOOL)playFileWithPath:(NSString *)path OrigionalWiewController:(UIViewController *)origionalWiewController; {
    
    return YES;
}

- (UILabel *)alertLabel {
    if (!_alertLabel) {
        _alertLabel = [[UILabel alloc]init];
        _alertLabel.bounds = CGRectMake(0, 0, 100, 40);
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.75];
        _alertLabel.textColor = [UIColor whiteColor];
        _alertLabel.layer.cornerRadius = 10;
        _alertLabel.layer.masksToBounds = YES;
        _alertLabel.hidden = YES;
        //        AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication];
        _alertLabel.center = [UIApplication sharedApplication].keyWindow.center;
        [[UIApplication sharedApplication].keyWindow addSubview:_alertLabel];
    }
    return _alertLabel;
}
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(10, 0, 80, 80);
        _activityView.color = [UIColor whiteColor];
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

- (UILabel *)activityLabel {
    if (!_activityLabel) {
        _activityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, 100, 20)];
        _activityLabel.textAlignment = NSTextAlignmentCenter;
        _activityLabel.font = [UIFont systemFontOfSize:14];
        _activityLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
    }
    return _activityLabel;
}
- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        //               AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication].delegate;
        _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        //               _loadingView.center =CGPointMake(app.window.center.x, app.window.center.y-40);
        _loadingView.layer.cornerRadius = 10;
        _loadingView.layer.masksToBounds = YES;
        [_loadingView addSubview:self.activityView];
        [_loadingView addSubview:self.activityLabel];
    }
    return _loadingView;
}
- (void)showMessage:(NSString *)title {
    NSLog(@"%@",title);
}
- (void)showMessage:(NSString *)title inView:(UIView *)inView {
    if (inView == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddAlertLabel) object:nil];
        self.alertLabel.center = CGPointMake(inView.center.x, inView.center.y-40);
        self.alertLabel.bounds = CGRectMake(0, 0, 16*title.length+30, 40);
        [inView bringSubviewToFront:self.alertLabel];
        self.alertLabel.hidden = NO;
        self.alertLabel.text = title;
        float maxDelay = MIN(3.0, title.length * 0.2);
        [self performSelector:@selector(hiddAlertLabel) withObject:nil afterDelay:maxDelay];
    });
}
- (void)showLoading:(NSString *)title {
    AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication].delegate;
    [self showLoading:title inView:app.window];
}
- (void)showLoading:(NSString *)title inView:(UIView *)inView {
    if (inView == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.center = inView.center;
        [inView addSubview:self.loadingView];
        [inView bringSubviewToFront:self.loadingView];
        self.loadingView.hidden = NO;
        self.activityLabel.text = title;
        self.activityView.hidden = NO;
        self.activityLabel.hidden = NO;
        [self.activityView startAnimating];
    });
}
- (void)hiddenLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
    self.loadingView.hidden = YES;
    [self.activityView stopAnimating];
    });
}
- (void)setHintCenter {
    if (!self.alertLabel.hidden) {
        self.alertLabel.center =CGPointMake(self.alertLabel.superview.center.x, self.alertLabel.superview.center.y-40);
    }
    if (!self.loadingView.hidden) {
        self.loadingView.center = self.loadingView.superview.center;
    }
}
- (void)hiddAlertLabel {
    [UIView animateWithDuration:0.2 animations:^{
        self.alertLabel.alpha = 0;
    } completion:^(BOOL finished) {
       self.alertLabel.hidden = YES;
        self.alertLabel.alpha = 1;
    }];
}
//completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler
- (void)showAlertTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSInteger i= 0; i<buttonTitles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
              completionHandler(i);
            }
        }];
        [alert addAction:action];
    }
       [self.topViewController presentViewController:alert animated:YES completion:^{
        
    }];
}
- (void)showAlertTextField:(NSString *)text placeholder:(NSString *)placeHolder title:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles completionHandler:(void (^)(NSInteger num,NSString *textValue))completionHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        UITextField *firstTextF = alert.textFields.firstObject;
        firstTextF.placeholder = placeHolder;
        firstTextF.text = text;
        for (NSInteger i= 0; i<buttonTitles.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (completionHandler) {
                    completionHandler(i,firstTextF.text);
                }
            }];
            [alert addAction:action];
        }
        
        [self.topViewController presentViewController:alert animated:YES completion:^{
            
        }];
    });
}

- (double)timeStrToSecWithStr:(NSString *)str {
    double timeSec = 0;
    NSArray *array = [str componentsSeparatedByString:@":"]; 
    for (NSInteger i = 0; i<array.count; i++) {
        NSString *time = [array objectAtIndex:i];
        
       timeSec = timeSec *60 + labs([time integerValue]);
    }
    
    return timeSec;
}
- (NSString *)timeSecToStrWithSec:(double)sec {
    if (sec/3600>0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d",((int)sec)/3600,(((int)sec)%3600)/60,((int)sec)%60];
    }
    return [NSString stringWithFormat:@"%02d:%02d",(((int)sec)%3600)/60,((int)sec)%60];
    
}


- (NSString *)timeStrFromDate:(NSDate *)date {
    if (date) {
        NSTimeInterval timeInter2 = [[NSDate date] timeIntervalSinceDate:date];
        if (timeInter2<60*60) {
            return @"刚刚";
        }
        else
            if (timeInter2<=24*60*60) {
                return [NSString stringWithFormat:@"%.f小时前",timeInter2/(60.0*60.0)];
            }
            else
            {
                if (![self.dateFormater.dateFormat isEqualToString: @"MM-dd HH:mm"]) {
                    [self.dateFormater setDateFormat:@"MM-dd HH:mm"];
                    
                }
                return [self.dateFormater stringFromDate:date];
            }
    }
    return @"";
    
}
- (NSString *)hmtimeStrFromDate:(NSDate *)date {
    if (![self.dateFormater.dateFormat isEqualToString: @"YYYY-MM-dd HH:mm:ss"]) {
        [self.dateFormater setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
    }
    NSString *timestr = [self.dateFormater stringFromDate:date];
    if (timestr.length>16) {
        return [timestr substringWithRange:NSMakeRange(11, 5)];
    }
    else
    {
        return @"--:--";
    }
    
}
- (BOOL)openURLStr:(NSString *)urlStr {
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:urlStr]]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            BOOL isOpen = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]];
            return isOpen;
        }
        return YES;
    }
    return NO;
}
- (UIViewController *)topViewController {
    AppDelegate *app =[[UIApplication sharedApplication] delegate];
    UIViewController *topVC =app.window.rootViewController;
    if (topVC.presentedViewController) {
        return topVC.presentedViewController;
    }
    else { 
        return topVC;
    }
}
- (UIViewController *)visableController {
    UIViewController *topVC =[[UIApplication sharedApplication] delegate].window.rootViewController;
    if ([topVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)topVC;
        topVC = tabVC.selectedViewController;
    }
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)topVC;
        topVC = nav.visibleViewController;
    }
    if (topVC.presentedViewController) {
        return topVC.presentedViewController;
    }
    else {
        return topVC;
    }
}

/// ipad 全部支持转屏，iPhone写到里面的页面支持转屏
- (BOOL)canAutorotate {
    if (IsPad) {
        return YES;
    }
    return YES;
   
}
@end
