//
//  NewPlayerView.m
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "NewPlayerView.h"
#import "XTools.h"
#import "UIColor+Hex.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#define xBTNWidth 44
#define xTimeWidth 50//显示时间的label宽度
#define xBottomHeight 74 //bottomview 的整体高度
#define xSliderHeight 30 //
@interface NewPlayerView ()<UIGestureRecognizerDelegate>
{
    float  _leftSide;
    float  _rightSide;
    float  _topSide;
    float  _bottomSide;
    NSInteger _panDirection;//滑动的方向，0开始，1，上下，2左右，。
    CGPoint   _beginPoint;//滑动开始的位置。
    float     _prePointY;//上一次滑动的y点。
    NSInteger      _currentO;
    BOOL           _isHideView;//隐藏按钮。
    NSInteger      _viewDirection;//界面方向，0，无方向，1竖屏，2横屏。
}
@property (nonatomic, strong)UITapGestureRecognizer *singleTap;//单击 显示空间
@property (nonatomic, strong)UITapGestureRecognizer *twoTap;//双击 暂停播放
@property (nonatomic, strong)UIPanGestureRecognizer *pan;//滑动调剂音量和亮度
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;//长按加速。
@property (nonatomic, strong)UISlider *volumeSlider;


@end
@implementation NewPlayerView

- (void)setIsNetURL:(BOOL)isNetURL {
    _isNetURL = isNetURL;
    if (isNetURL) {
        self.prevButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.listenButton.hidden = YES;
        self.cycleButton.hidden = YES;
    }
    else {
       self.prevButton.hidden = NO;
       self.nextButton.hidden = NO;
       self.listenButton.hidden = NO;
       self.cycleButton.hidden = NO;
    }
}
- (void)setListenVideo:(BOOL)listenVideo {
    if (_listenVideo != listenVideo) {
        _listenVideo = listenVideo;
        if (listenVideo) {
            self.back15SButton.hidden = NO;
            self.forward15sButton.hidden = NO;
            self.bigCenterPlayButton.hidden = NO;
            self.contentView.hidden = YES;
            [self.listenButton setImage:[UIImage imageNamed:@"video_look"] forState:UIControlStateNormal];
            
        }
        else {
            self.back15SButton.hidden = YES;
            self.forward15sButton.hidden = YES;
            self.bigCenterPlayButton.hidden = YES;
            self.contentView.hidden = NO;
            [self.listenButton setImage:[UIImage imageNamed:@"video_listen"] forState:UIControlStateNormal];
            
        }
        
    }
}
- (void)setLockView:(BOOL)lockView {
    _lockView = lockView;
    if (_lockView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if ([self.playerViewdelegate respondsToSelector:@selector(playerViewWillShowOrHidden:)]) {
                [self.playerViewdelegate playerViewWillShowOrHidden:YES];
            }
            self.topView.alpha = 0.0;
            self.bottomView.alpha = 0.0;
            self.screenShotButton.alpha = 0.0;
            self.captionButton.alpha = 0.0;
            self.cycleButton.alpha = 0.0;
            
            //        self.bigCenterPlayButton.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
    else{
        _isHideView = YES;
    }
    
    [self autoFadeOutControlBar];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.rotateStatus = XDRotateOrientationInit;//初始化一个值,8也是上下结构。
    [self setupViews];
    [self setupNotification];
}
- (void)setupViews {
    self.backgroundColor = [UIColor blackColor];
   
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    [self addSubview:self.captionButton];
    [self addSubview:self.screenShotButton];
    [self addSubview:self.lockButton];
    [self addSubview:self.cycleButton];
    
    [self.topView addSubview:self.closeButton];
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.listenButton];
    
    [self.bottomView addSubview:self.playButton];
    [self.bottomView addSubview:self.prevButton];
    [self.bottomView addSubview:self.nextButton];
    [self.bottomView addSubview:self.rateButton];
    [self.bottomView addSubview:self.ratioButton];
    [self.bottomView addSubview:self.rotateButton];
    
    [self.bottomView addSubview:self.timeLabel];
    [self.bottomView addSubview:self.totalTimeLabel];
    [self.bottomView addSubview:self.progressSlider];
    
    [self addSubview:self.bigCenterPlayButton];
    [self addSubview:self.centerView];
    [self addSubview:self.back15SButton];
    [self addSubview:self.forward15sButton];
}
- (void)setupNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationHandler:)                                        name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterBackNotification)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appActivityNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    
}
- (void)appActivityNotification {
    
    [self rotateScreenWithStatus:XDRotateOrientationUnknow];
}
- (void)appEnterBackNotification {
    _currentO = self.rotateStatus;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layout ======= %@",@(self.rotateStatus));
    if (self.rotateStatus == XDRotateOrientationLandscapeLeft || self.rotateStatus == XDRotateOrientationLandscapeRight) {//横屏
        if (kDevice_Is_iPhoneX) {
            _leftSide = 34;
            _rightSide = 34.0f;
            _bottomSide = 0.0f;
            _topSide = 0.0f;
        }
        else {
            _leftSide = 5.0;
            _rightSide = 5.0f;
            _bottomSide = 0.0f;
            _topSide = 20.0f;
        }
    }
    else {
        if (kDevice_Is_iPhoneX) {
            _topSide = 34;
            _bottomSide = 34.0f;
        }
        else
        {
            _topSide = 20.0f;
            _bottomSide = 0.0f;
        }
        _leftSide = 5.0f;
        _rightSide = 5.0f;
    }
    self.captionButton.frame = CGRectMake(CGRectGetWidth(self.bounds)- _rightSide -xBTNWidth, CGRectGetHeight(self.bounds)/2-20-xBTNWidth, xBTNWidth, xBTNWidth);
    self.screenShotButton.frame = CGRectMake(CGRectGetWidth(self.bounds)- _rightSide -xBTNWidth, CGRectGetHeight(self.bounds)/2+20, xBTNWidth, xBTNWidth);
    self.lockButton.frame = CGRectMake(CGRectGetMinX(self.bounds) + _rightSide,CGRectGetHeight(self.bounds)/2-20-xBTNWidth, xBTNWidth, xBTNWidth);
    self.cycleButton.frame = CGRectMake(CGRectGetMinX(self.bounds) + _rightSide,CGRectGetHeight(self.bounds)/2+20, xBTNWidth, xBTNWidth);
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.topView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), xBTNWidth+_topSide);
    self.closeButton.frame = CGRectMake(_leftSide, _topSide, xBTNWidth, xBTNWidth);
    self.titleLabel.frame = CGRectMake(_leftSide+xBTNWidth, _topSide, CGRectGetWidth(self.topView.bounds) - 2*xBTNWidth - _leftSide - _rightSide, xBTNWidth);
    self.listenButton.frame = CGRectMake(CGRectGetWidth(self.topView.bounds)-_rightSide-xBTNWidth, _topSide, xBTNWidth, xBTNWidth);
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-xBottomHeight - _bottomSide, CGRectGetWidth(self.bounds), _bottomSide + xBottomHeight);
    self.playButton.frame = CGRectMake(_leftSide, xSliderHeight, xBTNWidth, xBTNWidth);
    self.prevButton.frame = CGRectMake(_leftSide+10+xBTNWidth, xSliderHeight, xBTNWidth, xBTNWidth);
    self.nextButton.frame = CGRectMake(_leftSide+20+2*xBTNWidth, xSliderHeight, xBTNWidth, xBTNWidth);
    self.rateButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds)-_rightSide - 20-3*xBTNWidth, xSliderHeight, xBTNWidth, xBTNWidth);
    self.ratioButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds)-_rightSide - 10-2*xBTNWidth, xSliderHeight, xBTNWidth, xBTNWidth);
    self.rotateButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.bounds)-_rightSide - xBTNWidth, xSliderHeight, xBTNWidth, xBTNWidth);
    self.timeLabel.frame = CGRectMake(0, 7, 50, 20);
    self.totalTimeLabel.frame = CGRectMake(CGRectGetWidth(self.bottomView.frame) - 50, 7,50 , 20);
    self.progressSlider.frame = CGRectMake(50, 0, CGRectGetWidth(self.bottomView.frame) - 100, 35);
    self.bigCenterPlayButton.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    self.centerView.center =CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
////    if (self.listenVideo) {
       self.back15SButton.center = CGPointMake(CGRectGetWidth(self.bounds)/2-100, CGRectGetHeight(self.bounds)/2);
        self.forward15sButton.center = CGPointMake(CGRectGetWidth(self.bounds)/2+100, CGRectGetHeight(self.bounds)/2);
////    }
    
}
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        [_playButton addTarget:self action:@selector(playOrPauseAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _playButton;
}
- (UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_prevButton setImage:[UIImage imageNamed:@"video_pre"] forState:UIControlStateNormal];
        _prevButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        
    }
    return _prevButton;
}
- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"video_next"] forState:UIControlStateNormal];
        _nextButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        
    }
    return _nextButton;
}
- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rateButton setTitle:@"X1.0" forState:UIControlStateNormal];
        _rateButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        
    }
    return _rateButton;
}
- (UIButton *)ratioButton {
    if (!_ratioButton) {
        _ratioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        float f_ar = kScreen_Width / kScreen_Height;
        NSString *reoStr = kLocalized(@"Ratio");
        if (f_ar == (float)(640./1136.)) // iPhone 5 aka 16:9.01
            reoStr = @"16:9";
        else if (f_ar == (float)(2./3.)) // all other iPhones
            reoStr = @"16:10"; // libvlc doesn't support 2:3 crop
        else if (f_ar == .75) // all iPads
            reoStr = @"4:3";
        else if (f_ar == .5625) // AirPlay
        {
            reoStr = @"16:9";
        }
       
        [_ratioButton setTitle:reoStr forState:UIControlStateNormal];
        _ratioButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        _ratioButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
    }
    return _ratioButton;
}
- (UIButton *)rotateButton {
    if (!_rotateButton) {
        _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotateButton setImage:[UIImage imageNamed:@"video_rotate"] forState:UIControlStateNormal];
        _rotateButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        [_rotateButton addTarget:self action:@selector(rotateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotateButton;
}
- (void)rotateButtonAction {
    
    [self rotateScreenWithStatus:XDRotateOrientationUnknow];
    
}
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"video_close"] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        
    }
    return _closeButton;
}
- (UIButton *)listenButton {
    if (!_listenButton) {
        _listenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listenButton setImage:[UIImage imageNamed:@"video_listen"] forState:UIControlStateNormal];
        _listenButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        
    }
    return _listenButton;
}
- (UIButton *)captionButton {
    if (!_captionButton) {
        _captionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_captionButton setImage:[UIImage imageNamed:@"video_cc"] forState:UIControlStateNormal];
        _captionButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);

    }
    return _captionButton;
}
- (UIButton *)screenShotButton {
    if (!_screenShotButton) {
        _screenShotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenShotButton setImage:[UIImage imageNamed:@"video_crop"] forState:UIControlStateNormal];
        _screenShotButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        [_screenShotButton addSubview:self.screenShotIndicatorView];
    }
    return _screenShotButton;
}
- (UIActivityIndicatorView *)screenShotIndicatorView {
    if (!_screenShotIndicatorView) {
        _screenShotIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _screenShotIndicatorView.hidesWhenStopped = YES;
        _screenShotIndicatorView.frame = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
    }
    return _screenShotIndicatorView;
}
- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lockButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        [_lockButton setImage:[UIImage imageNamed:@"video_open"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage imageNamed:@"video_lock"] forState:UIControlStateSelected];
    }
    return _lockButton;
}
- (UIButton *)cycleButton {
    if (!_cycleButton) {
        _cycleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cycleButton.bounds = CGRectMake(0, 0, xBTNWidth, xBTNWidth);
        [_cycleButton setImage:[UIImage imageNamed:@"video_cycle"] forState:UIControlStateNormal];
        [_cycleButton setImage:[UIImage imageNamed:@"video_single"] forState:UIControlStateSelected];
        
    }
    return _cycleButton;
}
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _bottomView;
}
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds))];
        _contentView.backgroundColor = [UIColor blackColor];
       
        [_contentView addGestureRecognizer:self.pan];
        [_contentView addGestureRecognizer:self.singleTap];
        [_contentView addGestureRecognizer:self.twoTap];
        [_contentView addGestureRecognizer:self.longPress];
        [_singleTap requireGestureRecognizerToFail:self.twoTap];
        [self addSubview:_contentView];
    }
    
    [self insertSubview:_contentView belowSubview:self.topView];
    return _contentView;
}
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44)];
        _topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        }
    return _topView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(xBTNWidth+10, 0, CGRectGetWidth(self.bounds) - 2* xBTNWidth, xBTNWidth)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xTimeWidth, xBTNWidth)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}
- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, xTimeWidth, xBTNWidth)];
        _totalTimeLabel.backgroundColor = [UIColor clearColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:15];
        _totalTimeLabel.adjustsFontSizeToFitWidth = YES;
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.textColor = [UIColor whiteColor];
    }
    return _totalTimeLabel;
}
- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc]init];
        [_progressSlider setMinimumTrackTintColor:kMainCOLOR];
        [_progressSlider setMaximumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setBackgroundColor:[UIColor clearColor]];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_slider"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_slidered"] forState:UIControlStateHighlighted];
        _progressSlider.value = 0.0f;
        _progressSlider.continuous = YES;
        
    } 
    return _progressSlider;
}
- (UIButton *)bigCenterPlayButton {
    if (!_bigCenterPlayButton) {
        _bigCenterPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bigCenterPlayButton setImage:[UIImage imageNamed:@"video_playcenter"] forState:UIControlStateNormal];
        _bigCenterPlayButton.bounds = CGRectMake(0, 0, 80, 80);
        [_bigCenterPlayButton addTarget:self action:@selector(playOrPauseAction) forControlEvents:UIControlEventTouchUpInside];
        _bigCenterPlayButton.hidden = YES;
    }
    return _bigCenterPlayButton;
    
}
- (UIButton *)back15SButton {
    if (!_back15SButton) {
        _back15SButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_back15SButton setImage:[UIImage imageNamed:@"pre_15"] forState:UIControlStateNormal];
        _back15SButton.bounds = CGRectMake(0, 0, 80, 80);
        [_back15SButton addTarget:self action:@selector(back15SButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _back15SButton.hidden = YES;
    }
    return _back15SButton;
}
- (UIButton *)forward15sButton {
    if (!_forward15sButton) {
        _forward15sButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forward15sButton setImage:[UIImage imageNamed:@"nex_15"] forState:UIControlStateNormal];
        _forward15sButton.bounds = CGRectMake(0, 0, 80, 80);
        [_forward15sButton addTarget:self action:@selector(forward15sButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _forward15sButton.hidden = YES;
    }
    return _forward15sButton;
}
- (NewCenterView *)centerView {
    if (!_centerView) {
        _centerView = [[NewCenterView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 155)/2, (kScreen_Height - 155)/2, 155, 155)];
    }
    return _centerView;
}
- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _pan.delegate = self;
    }
    return _pan;
}
- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    }
    return _singleTap;
}
- (UITapGestureRecognizer *)twoTap {
    if (!_twoTap) {
        _twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoTapAction:)];
        _twoTap.numberOfTapsRequired = 2;
        
    }
    return _twoTap;
}
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        _longPress.minimumPressDuration = 0.5;
    }
    return _longPress;
}
- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIControl *view in volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider *)view;
            }
        }
    }
    return _volumeSlider;
}
#pragma mark -- 事件
- (void)back15SButtonAction {
    if (self.playerViewdelegate && [self.playerViewdelegate respondsToSelector:@selector(playerViewDidJumpFormard:)]) {
       
        [self.playerViewdelegate playerViewDidJumpFormard:-15];
    }
}
- (void)forward15sButtonAction {
    if (self.playerViewdelegate && [self.playerViewdelegate respondsToSelector:@selector(playerViewDidJumpFormard:)]) {
        
        [self.playerViewdelegate playerViewDidJumpFormard:15];
    }
}
//单击
- (void)tapAction:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) { 
        if (_isHideView) {//
            [self autoFadeOutControlBar];
        }
        else {
            [self animateHide];
        }
    }
}
- (void)twoTapAction:(UITapGestureRecognizer *)twoTap {
    if (twoTap.state == UIGestureRecognizerStateEnded) {
        [self playOrPauseAction];
    }
}
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if ([self.playerViewdelegate respondsToSelector:@selector(playerViewQuickPlayStart:)]) {
        if (longPress.state == UIGestureRecognizerStateBegan) {
            [self.playerViewdelegate playerViewQuickPlayStart:YES];
        }
        else if(longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateEnded) {
            [self.playerViewdelegate playerViewQuickPlayStart:NO];
        }
    }
}
- (void)playOrPauseAction {
    if (self.playerViewdelegate && [self.playerViewdelegate respondsToSelector:@selector(playerViewPlayorPauseMedia)]) {
        [self.playerViewdelegate playerViewPlayorPauseMedia];
    }
}
- (void)panAction:(UIPanGestureRecognizer *)pan {
    if (self.lockView) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            _beginPoint = [pan locationInView:self];
            _panDirection = 0;
            _prePointY = _beginPoint.y;
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [pan locationInView:self];
            // 判断方向45°角，向上左是亮度右是音量，水平是播放时间。
            if (fabs(currentPoint.x - _beginPoint.x) > fabs(currentPoint.y - _beginPoint.y)) {//播放时间
                if (_panDirection == 0) {
                    _panDirection = 1;
                }
                if (_panDirection == 1) {
                    if (self.playerViewdelegate && [self.playerViewdelegate respondsToSelector:@selector(playerViewForwardSeconds:)]) {
                        [self.playerViewdelegate playerViewForwardSeconds:(int)(currentPoint.x - _beginPoint.x)];
                    }
                    
                }
                

            }else {
                if (_panDirection == 0) {
                    _panDirection = 2;
                }
                if (_panDirection == 2) {
                    if (_beginPoint.x > CGRectGetWidth(self.bounds) / 2) {
                        // 改变音量
                        CGFloat voulumeValue =(currentPoint.y - _prePointY)*0.002;
                        [self.volumeSlider setValue: (self.volumeSlider.value - voulumeValue) animated:NO];
                        
                        
                    }else {
                        // 改变显示亮度
                        [UIScreen mainScreen].brightness += (_prePointY - currentPoint.y)*0.002;
                        
                    }
                }
                
                _prePointY = currentPoint.y;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            if (_panDirection == 1) {
                
                if (self.playerViewdelegate && [self.playerViewdelegate respondsToSelector:@selector(playerViewDidJumpFormard:)]) {
                    CGPoint currentPoint = [pan locationInView:self];
                    [self.playerViewdelegate playerViewDidJumpFormard:(int)(currentPoint.x - _beginPoint.x)];
                }
            }
           
        }
            break;
        default:
            break;
    }
            
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    if([touch.view isKindOfClass:[UISlider class]]) {
        
        return NO;
        
    }else{
        return YES;
    }
}
- (void)pauseStatus;
{
    self.bigCenterPlayButton.hidden = NO;
    [self.playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [self.bigCenterPlayButton setImage:[UIImage imageNamed:@"video_playcenter"] forState:UIControlStateNormal];
    [self cancelAutoFadeOutControlBar];
    
}
- (void)playStatus {
   [self.playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
    if (!self.listenVideo) {
       self.bigCenterPlayButton.hidden = YES;
    }
    [self.bigCenterPlayButton setImage:[UIImage imageNamed:@"video_pauseCenter"] forState:UIControlStateNormal];
    [self autoFadeOutControlBar];
}
#pragma mark -- 转屏
//监控
- (void)orientationHandler:(NSNotification *)notification {
    
    NSLog(@"orientation == %@ == %@",@([UIDevice currentDevice].orientation),@([UIApplication sharedApplication].statusBarOrientation));
    
}
//强制
- (void)rotateScreenWithStatus:(XDRotateOrientation)status {
    NSLog(@"rotastatus ===========2 == %@   %@",@([UIApplication sharedApplication].statusBarOrientation),@(self.rotateStatus));
    if (status == XDRotateOrientationUnknow) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            {
                if (kDevice_Is_iPhoneX) {
                    if (self.rotateStatus == XDRotateOrientationUpsideDown) {//如果是left来到竖屏，就转右边。
                        self.rotateStatus = XDRotateOrientationLandscapeRight;
                    }
                    else {
                        self.rotateStatus = XDRotateOrientationLandscapeLeft;
                    }
                }
                else {
                    self.rotateStatus = XDRotateOrientationLandscapeLeft;
                }
                
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            {
                self.rotateStatus = XDRotateOrientationUpsideDown;
            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                self.rotateStatus = XDRotateOrientationLandscapeRight;
            }
                break;
            case UIInterfaceOrientationLandscapeRight:
            {
                self.rotateStatus = XDRotateOrientationPortrait;
            }
                break;
                
            default: {
                self.rotateStatus += 1;
            }
                break;
        }
    } else {
        self.rotateStatus = status;
    }
    
    
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
//    if (IsPad) {
//       orientation = UIInterfaceOrientationPortrait;
//    }
//    else
//    {
        switch (self.rotateStatus) {
            case XDRotateOrientationPortrait:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
            case XDRotateOrientationLandscapeLeft:
            {
                orientation = UIInterfaceOrientationLandscapeLeft;
            }
                break;
            case XDRotateOrientationUpsideDown:
            {
                if (kDevice_Is_iPhoneX) {//iPhone X不支持到屏幕。
                   orientation = UIInterfaceOrientationPortrait;
                }
                else
                {
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                }
                
            }
                break;
            case XDRotateOrientationLandscapeRight:
            {
                orientation = UIInterfaceOrientationLandscapeRight;
            }
                break;
                
            default:
                break;
        }
//    }
    
    NSLog(@"rotastatus =========== %@ ==%@",@(orientation),@(self.rotateStatus));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self interfaceOrientation:orientation];
    });
    
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (@available(iOS 16.0, *)) {
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        if (array.count <= 0) return;
        UIWindowScene *ws = (UIWindowScene *)array.firstObject;
        if (!ws) return;
        if (self.viewController && [self.viewController respondsToSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)]) {
            [self.viewController performSelector:@selector(setNeedsUpdateOfSupportedInterfaceOrientations)];
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
- (void)setRotateStatus:(XDRotateOrientation)rotateStatus {
    NSLog(@"width ==%@ -- %@",@(kScreen_Width),@([UIScreen mainScreen].bounds.size.width));
    NSLog(@"rote=====%@ == %@",@(rotateStatus),@([UIApplication sharedApplication].statusBarOrientation));
    if (rotateStatus!=_rotateStatus) {
        _rotateStatus = rotateStatus;
    }
//        if (rotateStatus%2 == 0) {//竖屏
//            if (IsPad) {
//                if (self.frame.size.height != kScreen_Height) {
//                    self.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
//                    [self layoutIfNeeded];
//                }
//            }
//            else
//            {
//                if (self.frame.size.height != kScreen_Height) {
//                    self.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
//                    [self layoutIfNeeded];
//                }
//            }
//        }
//        else
//        {
//            if (IsPad) {
//                if (self.frame.size.height != kScreen_Width) {
//                    self.frame = CGRectMake(0, 0, kScreen_Height, kScreen_Width);
//                    [self layoutIfNeeded];
//                }
//            }
//            else
//            {
//                if (self.frame.size.height != kScreen_Width) {
//                    self.frame = CGRectMake(0, 0, kScreen_Height, kScreen_Width);
//                    [self layoutIfNeeded];
//                }
//            }
//
//
//        }
//    }
}
- (void)autoFadeOutControlBar {
    if (self.listenVideo) {
        return;
    }
    if (_isHideView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if (self.lockView) {
                self.lockButton.alpha = 1.0;
                self.cycleButton.alpha = 0.0;
                self.topView.alpha = 0.0;
                self.bottomView.alpha = 0.0;
                self.screenShotButton.alpha = 0.0;
                self.captionButton.alpha = 0.0;
            }
            else
            {
                if ([self.playerViewdelegate respondsToSelector:@selector(playerViewWillShowOrHidden:)]) {
                    [self.playerViewdelegate playerViewWillShowOrHidden:NO];
                }
                self.topView.alpha = 1.0;
                self.bottomView.alpha = 1.0;
                self.screenShotButton.alpha = 1.0;
                self.captionButton.alpha = 1.0;
                self.lockButton.alpha = 1.0;
                self.cycleButton.alpha = 1.0;
            }

        }completion:^(BOOL finished) {
            self->_isHideView = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
            [self performSelector:@selector(animateHide) withObject:nil afterDelay:4.0];
        }];
        
    }
    else
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
        [self performSelector:@selector(animateHide) withObject:nil afterDelay:4.0];
    }
    
}
- (void)cancelAutoFadeOutControlBar {
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    if (_isHideView) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (self.lockView) {
                self.lockButton.alpha = 1.0;
            }
            else
            {
                self.topView.alpha = 1.0;
                self.bottomView.alpha = 1.0;
                self.screenShotButton.alpha = 1.0;
                self.captionButton.alpha = 1.0;
                self.lockButton.alpha = 1.0;
                self.cycleButton.alpha = 1.0;
                if ([self.playerViewdelegate respondsToSelector:@selector(playerViewWillShowOrHidden:)]) {
                    [self.playerViewdelegate playerViewWillShowOrHidden:NO];
                }
            }

        }completion:^(BOOL finished) {
            self->_isHideView = NO;
        }];
    }
}
- (void)animateHide {
    if ([self.playerViewdelegate respondsToSelector:@selector(playerViewWillShowOrHidden:)]) {
        [self.playerViewdelegate playerViewWillShowOrHidden:YES];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
        self.topView.alpha = 0.0;
        self.bottomView.alpha = 0.0;
        self.screenShotButton.alpha = 0.0;
        self.captionButton.alpha = 0.0;
        self.lockButton.alpha = 0.0;
        self.cycleButton.alpha = 0.0;
        //        self.bigCenterPlayButton.alpha = 0;
    } completion:^(BOOL finished) {
        self->_isHideView = YES;
    }];
}
- (void)dealloc {
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
