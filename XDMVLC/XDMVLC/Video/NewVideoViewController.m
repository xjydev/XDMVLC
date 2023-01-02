//
//  NewVideoViewController.m
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "NewVideoViewController.h"
#import "NewPlayerView.h"
#import "VideoAudioPlayer.h"
#import "XTools.h"
#import "UIColor+Hex.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "CaptionViewController.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>
#import "NSDictionary+XDExt.h"

NSString *const kScreenshotSave = @"kscreenshotsave";
NSString *const kScreenshotAlert = @"kthumbanail";
@interface NewVideoViewController ()<VideoAudioPlayerDelegate,VLCMediaPlayerDelegate,VLCMediaDelegate,NewPlayerViewDelegate,UIPopoverPresentationControllerDelegate,VLCMediaThumbnailerDelegate>
{
    NSArray   *_videoArray;
    NSInteger  _videoIndex;
//    NewPlayerView *_playerView;
    UIInterfaceOrientationMask _lockMask;
    BOOL   _hiddenStatus;
   
}
@property (weak, nonatomic) IBOutlet NewPlayerView *playerView;

//@property (nonatomic, strong)MPVolumeView *volumeView;

@property (nonatomic, strong)VideoAudioPlayer *videoPlayer;
@property (nonatomic, strong)VLCMedia *netMeida;
@property (nonatomic, assign)BOOL isNetURL;//网络连接播放。
@end

@implementation NewVideoViewController

+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewVideoViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"NewVideoViewController"];
    return VC;
}

#pragma mark - Property

- (VideoAudioPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [VideoAudioPlayer defaultPlayer];
        if (!_videoPlayer.isPlaying) {//如果没有正在播放就设置为视频，不然就原来的状态
           _videoPlayer.isVideo = YES;
            _videoPlayer.playModelType = XPlayModelTypeCycle;
        }
        else{//如果正在播放的是视频文件，切换到视频状态。
            _videoPlayer.isVideo = YES;
            }
       
        _videoPlayer.playerDelegate = self;
        _videoPlayer.delegate = self;
    }
    return _videoPlayer;
}

- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index {
    self.isNetURL = NO;
    _videoArray = videoArray;
    _videoIndex = index;
}
- (void)setURLMedia:(VLCMedia *)urlMedia {
    self.isNetURL = YES;
    self.netMeida = urlMedia;
}
/**
 获取到视频同级别路径下所有视频，及此视频的位置

 @return 是否包含
 */
- (BOOL)getVideoArrayCurrentPath {
    return NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSInteger status = [kUSerD integerForKey:@"krotatestatus"];
    NSLog(@"open status == %@",@(status));
    if (status != 0) {
        [_playerView rotateScreenWithStatus:status];
    }
    if (IsPad) {
        _playerView.frame = self.view.bounds;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [XTOOLS hiddenLoading];
    NSLog(@"end status == %@",@(self.playerView.rotateStatus));
    [kUSerD setInteger:self.playerView.rotateStatus forKey:@"krotatestatus"];
    [kUSerD synchronize];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [XTOOLS setHintCenter];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.playerView.playerViewdelegate = self;
    self.playerView.viewController = self;
    self.playerView.isNetURL = self.isNetURL;
    self.videoPlayer.isNet = self.isNetURL;
    [self.videoPlayer setDrawable:self.playerView.contentView];
    if (!self.videoPlayer.isVideo) {//如果不是视频，就是在听视频。
        _playerView.listenVideo = YES;
        [_playerView.totalTimeLabel setText:[NSString stringWithFormat:@"%@",self.videoPlayer.media.length.stringValue]];
        [self.videoPlayer play];
    }
    if(!self.videoPlayer.isPlaying) {
        self.videoPlayer.allowStartTime = YES;
    }
    float rate = [kUSerD floatForKey:KVideoRate];
    if (rate == 0) {
        rate = 1.0;
    }
    [self.videoPlayer setRate:rate];
    [_playerView.rateButton setTitle:[NSString stringWithFormat:@"X%.2f",rate] forState:UIControlStateNormal];
    if (self.isNetURL) {
        [XTOOLS showLoading:@"加载中…" inView:self.view];
        self.playerView.bigCenterPlayButton.hidden = YES;
        [self.netMeida parseWithOptions:VLCMediaParseNetwork timeout:30];
        [self.videoPlayer setMedia:self.netMeida];
        self.netMeida.delegate = self;
        [self.videoPlayer play];
        if (self.title) {
            _playerView.titleLabel.text =self.title;
        }
        else {
            _playerView.titleLabel.text = self.netMeida.url.lastPathComponent;
        }
        
    }
    else {
        if (_videoArray.count >0) {
            self.videoPlayer.mediaArray = _videoArray;
            self.videoPlayer.index = _videoIndex;
        }
        else
            if (self.videoPath) {
                self.videoPlayer.currentPath = self.videoPath;
            }
    }
    
    [_playerView.closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.listenButton addTarget:self action:@selector(listenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.prevButton addTarget:self action:@selector(prevButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.rateButton addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.ratioButton addTarget:self action:@selector(ratioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderClick) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderChange:) forControlEvents:UIControlEventValueChanged];
    [_playerView.progressSlider addTarget:self action:@selector(progressSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    
    [_playerView.captionButton addTarget:self action:@selector(captionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.screenShotButton addTarget:self action:@selector(screenShotButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.lockButton addTarget:self action:@selector(lockButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView.cycleButton addTarget:self action:@selector(cycleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    if (self.videoPlayer.playModelType == XPlayModelTypeCycle) {
        [XTOOLS showMessage:@"顺序播放"];
        [_playerView.cycleButton setImage:[UIImage imageNamed:@"video_cycle"] forState:UIControlStateNormal];
    }
    else if (self.videoPlayer.playModelType == XPlayModelTypeSingle) {
        [XTOOLS showMessage:@"单个循环"];
        [_playerView.cycleButton setImage:[UIImage imageNamed:@"video_single"] forState:UIControlStateNormal];
        
    }
    else {
        [XTOOLS showMessage:@"单个播放"];
        [_playerView.cycleButton setImage:[UIImage imageNamed:@"video_singlebreak"] forState:UIControlStateNormal];
    }
    
//    [_playerView autoFadeOutControlBar];//初始化后开始计时隐藏
    
}
#pragma mark -- 按钮事件
//字幕
- (void)captionButtonAction:(UIButton *)button {
    [_playerView autoFadeOutControlBar];
    CaptionViewController *captionVC = [CaptionViewController allocFromStoryBoard];
    captionVC.delayTime = _videoPlayer.currentVideoSubTitleDelay;
    captionVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    captionVC.subTitleArray = _videoPlayer.videoSubTitlesNames;
    NSLog(@"==%@\n==%@",_videoPlayer.videoSubTitlesNames,_videoPlayer.videoSubTitlesIndexes);
    captionVC.popoverPresentationController.backgroundColor = [UIColor clearColor];
    captionVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    captionVC.captionSelectCompletion = ^(int time, NSObject *subTitleObject) {
        if (time!=0) {
            self->_videoPlayer.currentVideoSubTitleDelay = time;
        }
        if ([subTitleObject isKindOfClass:[NSString class]]) {
            NSString *filePath = (NSString *)subTitleObject;
            if (![filePath hasPrefix:KDocumentP]) {
                filePath = [KDocumentP stringByAppendingPathComponent:filePath];
            }
            int subInt = [self->_videoPlayer addPlaybackSlave:[NSURL URLWithString:filePath] type:VLCMediaPlaybackSlaveTypeSubtitle enforce:YES];
            if (subInt>0) {
               [XTOOLS showMessage:@"添加成功"];
            }
            else
            {
                [XTOOLS showMessage:@"添加失败"];
            }
            NSLog(@"subtitle ==%d",subInt);
        }
        else
            if ([subTitleObject isKindOfClass:[NSNumber class]]) {
                NSNumber *subTitleNumber = (NSNumber *)subTitleObject;
                self->_videoPlayer.currentVideoSubTitleIndex = [subTitleNumber intValue];
            }
    };
    [self presentViewController:captionVC animated:YES completion:^{
        
    }];
}
//截屏
- (void)screenShotButtonAction:(UIButton *)button {
    if (_videoPlayer.media.length.value.doubleValue>0) {
//        VLCMedia *m = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_videoPlayer.currentPath]];
        VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:_videoPlayer.media andDelegate:self];
        //注释掉，设置宽高没啥用。
//        NSInteger videoOrientation = 0;
//        for (NSDictionary *track in _videoPlayer.media.tracksInformation) {
//            if([track.allKeys containsObject:VLCMediaTracksInformationVideoOrientation]) {
//                videoOrientation = [track xd_IntegerForKey:VLCMediaTracksInformationVideoOrientation];
//            }
//        }
//        if (videoOrientation == VLCMediaOrientationRightTop) {
//            thumbnailer.thumbnailHeight = _videoPlayer.videoSize.width;
//            thumbnailer.thumbnailWidth = _videoPlayer.videoSize.height;
//        } else {
            thumbnailer.thumbnailHeight = _videoPlayer.videoSize.height;
            thumbnailer.thumbnailWidth = _videoPlayer.videoSize.width;
//        }
        thumbnailer.snapshotPosition =  _videoPlayer.time.value.doubleValue/_videoPlayer.media.length.value.doubleValue;
        [thumbnailer fetchThumbnail];
        button.enabled = NO;
        [_playerView.screenShotIndicatorView startAnimating];
    }
}
//锁
- (void)lockButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    _playerView.lockView = button.selected;
    
}
- (void)cycleButtonAction:(UIButton *)button {
    if (self.videoPlayer.playModelType == XPlayModelTypeCycle) {
        self.videoPlayer.playModelType = XPlayModelTypeSingle;
        [XTOOLS showMessage:@"单个循环"];
        [button setImage:[UIImage imageNamed:@"video_single"] forState:UIControlStateNormal];
    }
    else if (self.videoPlayer.playModelType == XPlayModelTypeSingle) {
        self.videoPlayer.playModelType = XPlayModelTypeSingleBreak;
        [XTOOLS showMessage:@"单个播放"];
        [button setImage:[UIImage imageNamed:@"video_singlebreak"] forState:UIControlStateNormal];
    }
    else {
        self.videoPlayer.playModelType = XPlayModelTypeCycle;
        [XTOOLS showMessage:@"顺序播放"];
        [button setImage:[UIImage imageNamed:@"video_cycle"] forState:UIControlStateNormal];
    }
}
- (void)closeButtonAction {
    if (self.videoPlayer.isVideo) {
        [VideoAudioPlayer playerRelease];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else {
        if (self.videoPlayer.isPlaying) {

        }
        else {
            self.videoPlayer.playerDelegate = nil;
            self.videoPlayer.delegate = nil;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if (!self.videoPlayer.playing) {
                [VideoAudioPlayer playerRelease];
                
            }
            
        }];
    }
    UIInterfaceOrientation orientation =  UIInterfaceOrientationPortrait;
    if (!IsPad) {//返回时，返回的时候非iPad要转回竖屏。
        if (@available(iOS 16.0, *)) {
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            if (array.count <= 0) return;
            UIWindowScene *ws = (UIWindowScene *)array.firstObject;
            if (!ws) return;
            if (self && [self respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]) {
                [self performSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)];
            }
            Class GeometryPreferences = NSClassFromString(@"UIWindowSceneGeometryPreferencesIOS");
            id geometryPreferences = [[GeometryPreferences alloc]init];
            [geometryPreferences setValue:@(1 << orientation) forKey:@"interfaceOrientations"];
            SEL sel_method = NSSelectorFromString(@"requestGeometryUpdateWithPreferences:errorHandler:");
            void (^ErrorBlock)(NSError *err) = ^(NSError *err){
                
            };
            if ([ws respondsToSelector:sel_method]) {
                (((void (*)(id, SEL,id,id))[ws methodForSelector:sel_method])(ws, sel_method,geometryPreferences,ErrorBlock));
            }
        } else {
            if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
                SEL selector  = NSSelectorFromString(@"setOrientation:");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:[UIDevice currentDevice]];
                int val = (int)orientation;
                // 从2开始是因为0 1 两个参数已经被selector和target占用
                [invocation setArgument:&val atIndex:2];
                [invocation invoke];
            }
        }
    }
   
}
- (void)listenButtonAction:(UIButton *)button {
   
    if (_playerView.listenVideo) {
        _playerView.listenVideo = NO;
        [button setImage:[UIImage imageNamed:@"video_listen"] forState:UIControlStateNormal];
        self.videoPlayer.isVideo = YES;
        [_playerView autoFadeOutControlBar];
    }
    else
    {
         
        _playerView.listenVideo = YES;
        self.videoPlayer.isVideo = NO; 
        [button setImage:[UIImage imageNamed:@"video_look"] forState:UIControlStateNormal];
        [_playerView cancelAutoFadeOutControlBar];
    }
    
}
- (void)nextButtonAction {
    self.videoPlayer.allowStartTime = YES;
     self.videoPlayer.index +=1;
//    [_playerView autoFadeOutControlBar];
}
- (void)prevButtonAction {
    self.videoPlayer.allowStartTime = YES;
    self.videoPlayer.index -=1;
//    [_playerView autoFadeOutControlBar];
}
- (void)rateButtonAction:(UIButton *)button {
  [_playerView autoFadeOutControlBar];
}

- (void)ratioButtonAction:(UIButton *)button {
  [_playerView autoFadeOutControlBar];
}
- (void)progressSliderClick {
    int targetIntvalue = (int)(_playerView.progressSlider.value * (float)self.videoPlayer.media.length.intValue);
    
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:targetIntvalue];
    
    [self.videoPlayer setTime:targetTime];
    
  [_playerView autoFadeOutControlBar];
}
- (void)progressSliderChange:(UISlider *)slider {
    int targetIntvalue = (int)(slider.value * self.videoPlayer.media.length.intValue)/1000;
    if (targetIntvalue/3600>0) {
        [_playerView.timeLabel setText:[NSString stringWithFormat:@"%d:%02d:%02d",targetIntvalue/3600,(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
    else
    {
        [_playerView.timeLabel setText:[NSString stringWithFormat:@"%02d:%02d",(targetIntvalue%3600)/60,targetIntvalue%60]];
    }
  [_playerView autoFadeOutControlBar];
}
- (void)progressSliderTouchDown {
 [_playerView autoFadeOutControlBar];
}
#pragma mark -- newPlayerview delegate
- (void)playerViewPlayorPauseMedia {
    if (self.videoPlayer.isPlaying) {
        [self.videoPlayer pause];
//        [_playerView cancelAutoFadeOutControlBar];
    }
    else
    {
        [self.videoPlayer play];
        if (!self.isNetURL) {
            if (self.videoPlayer.time.intValue >= self.videoPlayer.media.length.intValue - 2000) {//如果差两秒，点击播放就重新播放
                self.videoPlayer.currentPath = self.videoPlayer.currentPath;
                [self.videoPlayer play];
            }
            else
            {
                if (self.videoPlayer.backTime >0) {
                    [self.videoPlayer jumpBackward:self.videoPlayer.backTime];
                    self.videoPlayer.backTime = 0;
                }
            }
        }
    }
}
- (void)playerViewForwardSeconds:(int)second {
    int targetIntvalue = (int)(self.videoPlayer.time.intValue)/1000+second;
    NSString * timeStr = nil;
    targetIntvalue = MIN(targetIntvalue, self.videoPlayer.media.length.intValue/1000-2);
    targetIntvalue = MAX(targetIntvalue, 0);
    if (targetIntvalue/3600>0) {//大于一个小时
       timeStr = [NSString stringWithFormat:@"%d:%02d:%02d",targetIntvalue/3600,(targetIntvalue%3600)/60,targetIntvalue%60];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"%02d:%02d",(targetIntvalue%3600)/60,targetIntvalue%60];
    }
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ / %@",timeStr,_playerView.totalTimeLabel.text] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];//colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f
    [att setAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:kMainCOLOR} range:NSMakeRange(0, timeStr.length +1)];
   [_playerView.centerView forwardSeconds:(targetIntvalue - (int)(self.videoPlayer.time.intValue)/1000) withShowString:att];
}
- (void)playerViewDidJumpFormard:(int)second {
    
    int nowInt = -(int)self.videoPlayer.time.intValue/1000;
    int residueInt = (int)self.videoPlayer.media.length.intValue/1000 +nowInt-2 ;
    if (second < nowInt) {
        second = nowInt;
    }
    else
        if (second > residueInt) {
            second = residueInt;
        }
    
    if (second>0) {
        [self.videoPlayer jumpForward:second];
    }
    else
    {
        [self.videoPlayer jumpBackward:abs(second)];
    }
}
- (void)playerViewQuickPlayStart:(BOOL)isStart {
    if (isStart) {
        [self.videoPlayer setRate:3.0];
    }
    else {
        [self.videoPlayer setRate:1.0];
    }
}
#pragma mark -- 截图代理
- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    UIImage *pimage = [UIImage imageWithCGImage:thumbnail];
    if ([kUSerD boolForKey:kScreenshotSave]) {
        [self photoAuthorizationCompletion:^(PHAuthorizationStatus status) {
            [self saveToPhotoWithImage:pimage];
        }]; 
    }
    else {
        NSData *imageDate = UIImagePNGRepresentation(pimage);
        NSString * name =[NSString stringWithFormat:@"%@截图%@.png", [[self.videoPlayer.currentPath lastPathComponent]stringByDeletingPathExtension],_videoPlayer.time.stringValue];
        NSString *imageFile = [KDocumentP stringByAppendingPathComponent:name];
        [imageDate writeToFile:imageFile atomically:YES];
    }
    [self showScreenshotSuccess];
}
- (void)photoAuthorizationCompletion:(void (^)(PHAuthorizationStatus status))completion{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status != PHAuthorizationStatusAuthorized) {
                UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"没有权限" message:@"没有访问相册的权限，您可以去设置中设置" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    
                }];
                [alertc addAction:sureAction];
                [alertc addAction:cancelA];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertc animated:YES completion:^{
                    
                }];
            }
            else {
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIAlertController *alertc = [UIAlertController alertControllerWithTitle:@"设备无法打开相册" message:@"无法访问相册，您可以去设置中设置" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        
                    }];
                    [alertc addAction:sureAction];
                    [alertc addAction:cancelA];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertc animated:YES completion:^{
                        
                    }];
                } else {
                    if (completion) {
                        completion(PHAuthorizationStatusAuthorized);
                    }
                }
            }
        });
    }];
}
- (void)showScreenshotSuccess {
    if ([kUSerD boolForKey:kScreenshotAlert]) {
        [XTOOLS showMessage:@"截图成功"];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"截图成功" message:@"截图已存入到手机相册中" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [kUSerD setBool:YES forKey:kScreenshotAlert];
            [kUSerD synchronize];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }
    _playerView.screenShotButton.enabled = YES;
    [_playerView.screenShotIndicatorView stopAnimating];
}
- (void)saveToPhotoWithImage:(UIImage *)image {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//        if (location) {
//            request.location = location;
//        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self showScreenshotSuccess];
            } else if (error) {
                [XTOOLS showMessage:@"存储失败"];
                self->_playerView.screenShotButton.enabled = YES;
                [self->_playerView.screenShotIndicatorView stopAnimating];
            }
        });
    }];
}
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    [_playerView.screenShotIndicatorView stopAnimating];
    _playerView.screenShotButton.enabled = YES;
    [XTOOLS showMessage:@"截图失败"];
    NSLog(@"截图失败");
}
#pragma mark VLC delegate
#pragma mark == VLCMediaDelegate
- (void)mediaMetaDataDidChange:(VLCMedia *)aMedia {
    NSLog(@"mediastatus ======== %@",@(aMedia.parsedStatus));
}
- (void)mediaDidFinishParsing:(VLCMedia *)aMedia {
    NSLog(@"parsestatus ======== %@",@(aMedia.parsedStatus));
}
#pragma mark ==
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    switch (self.videoPlayer.state) {
        case VLCMediaPlayerStateStopped:
        {
            [_playerView pauseStatus];
            if (self.videoPlayer.media.state == VLCMediaStateNothingSpecial) {
                if (self.isNetURL) {
                    [XTOOLS showAlertTitle:@"加载失败" message:@"连接可能已加载失败，您也可以继续等待。" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
                        
                    }];
                }
                else {
//                    [XTOOLS showAlertTitle:@"播放完成" message:@"你选择的模式下已播放完成" buttonTitles:@[@"确定"] completionHandler:^(NSInteger num) {
//
//                    }];
                }
                
            }
        }
            break;
        case VLCMediaPlayerStateOpening:
        {
            
        }
            break;
        case VLCMediaPlayerStateBuffering:
        {
            if (self.videoPlayer.media.state == VLCMediaStatePlaying) {
                [XTOOLS hiddenLoading];
                [_playerView playStatus];
            }
            else {
                [XTOOLS showLoading:@"加载中…" inView:self.view];
                self.playerView.bigCenterPlayButton.hidden = YES;
                [_playerView pauseStatus];
            }
            
        }
            break;
        case VLCMediaPlayerStateEnded:
        {
            
        }
            break;
            
        case VLCMediaPlayerStateError:
        {
           if ([self.videoPlayer.currentPath.pathExtension isEqualToString:@"swf"]) {
                NSLog(@"swf === %@ %@",@(self.videoPlayer.state),@(self.videoPlayer.media.state));
                [self dismissViewControllerAnimated:YES completion:^{
                    [XTOOLS showAlertTitle:@"此文件可能不是视频文件" message:@"应用只支持swf格式的视频文件，你可以把此文件拖入到安装有flash插件的浏览器，进行浏览查看。" buttonTitles:@[@"确定"] completionHandler:nil];
                }];
            }
            else {
                [_playerView pauseStatus];
            }
        }
            break;
        case VLCMediaPlayerStatePlaying:
        {
            [_playerView playStatus];
        }
            break;
        case VLCMediaPlayerStatePaused:
        {
           [_playerView pauseStatus];
        }
            break;
        case VLCMediaPlayerStateESAdded:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    
    if (![_playerView.totalTimeLabel.text isEqualToString:self.videoPlayer.media.length.stringValue]) {
      [_playerView.totalTimeLabel setText:self.videoPlayer.media.length.stringValue];
    }
    
    if (_playerView.progressSlider.state != UIControlStateNormal) {//非操作状态下才可以
        return;
    }
    
    float precentValue = ([self.videoPlayer.time.value floatValue]) / ([self.videoPlayer.media.length.value floatValue]);
    
    [_playerView.progressSlider setValue:precentValue animated:YES];
    
    [_playerView.timeLabel setText:[NSString stringWithFormat:@"%@",self.videoPlayer.time.stringValue]];
    
}
- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext {
    _playerView.prevButton.enabled = hidePrev;
    _playerView.nextButton.enabled = hideNext;
    if (!self.isNetURL) {
        _playerView.titleLabel.text =[self.videoPlayer.currentPath lastPathComponent];
    }
}
- (void)playerViewWillShowOrHidden:(BOOL)ishidden {
    _hiddenStatus = ishidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark --旋转
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return YES;
//}
- (BOOL)shouldAutorotate
{
    return !_playerView.lockView;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    
    return _hiddenStatus;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}
- (BOOL)prefersHomeIndicatorAutoHidden{
    
    return YES;
}
#pragma mark == UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

- (void)dealloc {
    NSLog(@"dealloc ======= %@",NSStringFromClass(self.class));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
