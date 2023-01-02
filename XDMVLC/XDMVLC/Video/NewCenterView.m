//
//  NewCenterView.m
//  FileManager
//
//  Created by XiaoDev on 2018/6/24.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import "NewCenterView.h"
@interface NewCenterView ()

@property (nonatomic, strong) UIImageView        *backImage;
@property (nonatomic, strong) UILabel            *title;
@property (nonatomic, strong) UIView            *brightnessLevelView;
@property (nonatomic, strong) NSMutableArray    *tipArray;
@property (nonatomic, strong) NSTimer            *timer;
@property (nonatomic, strong) UILabel           *timeLabel;
@property (nonatomic, assign) BOOL               isForward;
@property (nonatomic, strong) UIToolbar         *toolbar;
@end
@implementation NewCenterView
- (void)forwardSeconds:(int)second withShowString:(NSAttributedString *)showStr {
    self.isForward = YES;
   
    if (second>0) {
        self.title.text = [NSString stringWithFormat:@"+ %d s",second];
        [self.backImage setImage:[UIImage imageNamed:@"video_forward"]];
    }
    else
    {
        self.title.text = [NSString stringWithFormat:@"%d s",second];
        [self.backImage setImage:[UIImage imageNamed:@"video_back"]];
    }
    self.timeLabel.attributedText = showStr;
    
}
- (void)setIsForward:(BOOL)isForward {
    _isForward = isForward;
    if (isForward) {
        self.toolbar.hidden = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.title.font = [UIFont boldSystemFontOfSize:20];
        self.title.textColor = [UIColor whiteColor];
        self.brightnessLevelView.hidden = YES;
        self.timeLabel.hidden = NO;
    }
    else
    {
        self.title.font = [UIFont boldSystemFontOfSize:16];
        self.title.text = @"亮度";
        self.title.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        self.backgroundColor = [UIColor whiteColor];
        self.toolbar.hidden = NO;
        self.brightnessLevelView.hidden = NO;
        self.timeLabel.hidden = YES;
         [self.backImage setImage:[UIImage imageNamed:@"video_bright"]];
    }
    [self autoFadeoutCenterView];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        
        // 毛玻璃效果
        [self addSubview:self.toolbar];
        
        [self addSubview:self.backImage];
        [self addSubview:self.title];
        [self addSubview:self.brightnessLevelView];
        [self addSubview:self.timeLabel];
        self.hidden = YES;//默认隐藏
        [self createTips];
        [self addKVOObserver];
    }
    return self;
}
- (UIToolbar *)toolbar {
    if (!_toolbar) {
      _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    }
    return _toolbar;
}
-(UILabel *)title {
    if (!_title) {
        _title   = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        _title.font  = [UIFont boldSystemFontOfSize:16];
        _title.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.text   = @"亮度";
    }
    return _title;
}

- (UIImageView *)backImage {
    
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(39.5, 39.5, 76, 76)];
        _backImage.image  = [UIImage imageNamed:@"video_bright"];
    }
    return _backImage;
}
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 155, 50)];
        _timeLabel.font = [UIFont systemFontOfSize:17];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _timeLabel.hidden = YES;
        
    }
    return _timeLabel;
}
-(UIView *)brightnessLevelView {
    
    if (!_brightnessLevelView) {
        _brightnessLevelView  = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        _brightnessLevelView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        [self addSubview:_brightnessLevelView];
    }
    return _brightnessLevelView;
}
- (void)createTips {
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    CGFloat tipW = (self.brightnessLevelView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX   = i * (tipW + 1) + 1;
        UIView *image    = [[UIView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.brightnessLevelView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateBrightnessLevel:[UIScreen mainScreen].brightness];
}

- (void)addKVOObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"brightness"]) {
        self.isForward = NO;
        CGFloat levelValue = [change[@"new"] floatValue];
        
        [self autoFadeoutCenterView];
        [self updateBrightnessLevel:levelValue];
    }
   
}



#pragma mark - Brightness显示 隐藏
- (void)disAppearCenterView {
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

#pragma mark - 定时器
- (void)autoFadeoutCenterView {
    if (self.hidden) {
        self.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            [self cancelAutoFadeOutCenterView];
            [self performSelector:@selector(disAppearCenterView) withObject:nil afterDelay:1.0];
        }];
    }
    else
    {
        [self cancelAutoFadeOutCenterView];
        [self performSelector:@selector(disAppearCenterView) withObject:nil afterDelay:1.0];
    }
}

- (void)cancelAutoFadeOutCenterView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disAppearCenterView) object:nil];
}

#pragma mark - 更新亮度值
- (void)updateBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat stage = 1 / 15.0;
    NSInteger level = brightnessLevel / stage;
    for (int i = 0; i < self.tipArray.count; i++) {
        UIView *img = self.tipArray[i];
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

#pragma mark - 更新布局
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.superview bringSubviewToFront:self];
    self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
}


#pragma mark - 销毁
- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
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
