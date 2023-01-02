//
//  VideoAudioPlayer.h
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//音频视频播放的对象

#import <Foundation/Foundation.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <UIKit/UIKit.h>

#define KVideoRate @"keyvideoratefloat"//播放速率
#define KAudioRate @"keyaudioratefload"
#define KDecode @"khardwaredecode" //软解码硬解码
typedef NS_ENUM(NSInteger , XPlayModelType) {
    XPlayModelTypeCycle,//循环播放，默认
    XPlayModelTypeSingle,//单曲循环
    XPlayModelTypeSingleBreak,//只播放单曲。
    XPlayModelTypeRandom,//随机播放
};

typedef void (^XVideoPlayerBackImage)(UIImage * image,NSError * error);

@protocol VideoAudioPlayerDelegate <NSObject>

@optional

/**
 上一个下一个按钮是否可点。每次更换路径后判断。

 @param hidePrev 上一个是否可点
 @param hideNext 下一个是否可点
 */
- (void)playerHidePrev:(BOOL)hidePrev HideNext:(BOOL)hideNext;

@end
@interface VideoAudioPlayer : VLCMediaPlayer

+ (instancetype)defaultPlayer;

@property (nonatomic, weak)id<VideoAudioPlayerDelegate> playerDelegate;
@property (nonatomic, copy)NSString *currentPath;
@property (nonatomic, strong)NSArray *mediaArray;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign)BOOL    isVideo;
@property (nonatomic, assign)BOOL    allowStartTime;//运行设置初始化时间。
@property (nonatomic,strong) NSMutableDictionary  *nowPlayingInfo;//锁屏时显示的内容，暂停播放时要处理速率，显示的时候要处理播放时间，改变内容的时候要改变标题等。
@property (nonatomic, assign)XPlayModelType    playModelType;
@property (nonatomic, assign)int backTime;//非手动暂停的时候，开始播放会向后跳几秒。

@property (nonatomic, strong)NSDate   * stopDate;//定时关机时间；

@property (nonatomic, strong)UIImage  *mediaImage;
@property (nonatomic, strong)NSDictionary *mediaOptionDict;//配置

@property (nonatomic, assign)BOOL  isNet;
+ (void)playerRelease;

@end
