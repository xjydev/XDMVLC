//
//  NewPlayerView.h
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewCenterView.h"

typedef NS_ENUM(NSInteger, XDRotateOrientation) {
    XDRotateOrientationUnknow,
    XDRotateOrientationPortrait,
    XDRotateOrientationLandscapeLeft,
    XDRotateOrientationUpsideDown,
    XDRotateOrientationLandscapeRight,
    XDRotateOrientationInit,
};

@protocol NewPlayerViewDelegate <NSObject>
- (void)playerViewPlayorPauseMedia;
- (void)playerViewForwardSeconds:(int)second;
- (void)playerViewDidJumpFormard:(int)second;
- (void)playerViewWillShowOrHidden:(BOOL)ishidden;
- (void)playerViewQuickPlayStart:(BOOL)isStart;
@end
@interface NewPlayerView : UIView
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak)id<NewPlayerViewDelegate> playerViewdelegate;
@property (nonatomic, assign)BOOL      isNetURL;
@property (nonatomic, assign)BOOL      listenVideo;//
@property (nonatomic, assign)BOOL       lockView;//锁住屏幕，不旋转不显示。
@property (nonatomic, assign)XDRotateOrientation rotateStatus;
@property (nonatomic, strong)UIView   *contentView;
@property (nonatomic, strong)UIView   *topView;//
@property (nonatomic, strong)UIView   *bottomView;//

@property (nonatomic, strong)UIButton *prevButton;//上一个
@property (nonatomic, strong)UIButton *playButton;//播放
@property (nonatomic, strong)UIButton *nextButton;//下一个
@property (nonatomic, strong)UIButton *rateButton;//速度
@property (nonatomic, strong)UIButton *ratioButton;//宽高比
@property (nonatomic, strong)UIButton *rotateButton;//旋转
@property (nonatomic, strong)UILabel  *timeLabel;//当前时间
@property (nonatomic, strong)UILabel  *titleLabel;
@property (nonatomic, strong)UILabel  *totalTimeLabel;//总时间
@property (nonatomic, strong)UISlider *progressSlider;//进度

@property (nonatomic, strong)UIButton *closeButton;//关闭
@property (nonatomic, strong)UIButton *listenButton;//听看转换按钮

@property (nonatomic, strong)UIButton *captionButton;//字幕
@property (nonatomic, strong)UIButton *screenShotButton;//截屏。
@property (nonatomic, strong)UIActivityIndicatorView *screenShotIndicatorView;
@property (nonatomic, strong)UIButton *lockButton;//锁屏。
@property (nonatomic, strong)UIButton *cycleButton;//循环播放。

@property (nonatomic, strong)UIButton *bigCenterPlayButton;
@property (nonatomic, strong)NewCenterView *centerView;
@property (nonatomic, strong)UIButton *back15SButton;
@property (nonatomic, strong)UIButton *forward15sButton;

//@property (nonatomic, strong)UIButton *airplayButton;//
//

- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;
- (void)rotateScreenWithStatus:(XDRotateOrientation)status;
- (void)pauseStatus;
- (void)playStatus;
@end
