//
//  VideoAudioPlayer.m
//  FileManager
//
//  Created by xiaodev on Dec/11/16.
//  Copyright © 2016 xiaodev. All rights reserved.
//

#import "VideoAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "XTools.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSDictionary+XDExt.h"
#import "NSArray+XDExt.h"
static VideoAudioPlayer *_player = nil;

@implementation VideoAudioPlayer
+ (instancetype)defaultPlayer {
    if (!_player) {
        _player = [[VideoAudioPlayer alloc]init];
        int volumeInt = (int)[kUSerD integerForKey:kVolume];
        if (volumeInt == 0) {
            volumeInt = 100;
        }
        _player.audio.volume = volumeInt;//用户反馈音量低，音量加大
        //播放即创建远程控制
        [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
        [[UIApplication sharedApplication]becomeFirstResponder];

        [kNOtificationC addObserver:_player selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];//耳机
        
        [kNOtificationC addObserver:_player selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];//接听电话
        [kNOtificationC addObserver:_player selector:@selector(playerStateChanged:) name:VLCMediaPlayerStateChanged object:_player];
        [kNOtificationC addObserver:_player selector:@selector(playerTimeChanged:) name:VLCMediaPlayerTimeChanged object:_player];
    }
    return _player;
}
- (instancetype)init {
    self = [super init];
    [self configRemoteCommandCenter];
    return self;
}
+(void)playerRelease {
    //
    [_player updateModel];
    
    //对象release关闭远程控制
    if (!_player.isVideo) {
        [[UIApplication sharedApplication]resignFirstResponder];
        [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    }
    
    [kNOtificationC removeObserver:_player];
    
    [_player stop];
    _player.playerDelegate = nil;
    _player.delegate = nil;
    _player = nil;
    
}
- (NSDictionary *)mediaOptionDict {
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    [mdict xd_setObject:[kUSerD objectForKey:KDecode] forKey:@"codec"];//软硬件解码
    return mdict;
}
- (void)updateModel {
    
}
#pragma mark -- 监听
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    NSLog(@"routeChange===%@",dic);
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"] || [portDescription.portType isEqualToString:@"BluetoothA2DPOutput"]|| [portDescription.portType isEqualToString:@"BluetoothHFP"]) {
            if (_player.isPlaying) {
                [_player pause];
            }
        }
    }
}

- (void)handleInterreption:(NSNotification *)sender {
    if(_player.isPlaying) {
        [_player pause];
        _player.backTime = 3;//播放时向前跳3秒。
    }//中断完成
    else if ([[sender.userInfo objectForKey:AVAudioSessionInterruptionOptionKey] intValue] == 1) {
        if (_player.backTime > 0) {
            [_player play];
            _player.backTime = 0;
        }
    }
}
- (void)playerStateChanged:(NSNotification *)notifi {
    NSLog(@"notifi1======%@---%@",notifi.userInfo,@(_player.state));
    if (!self.isNet) {
        switch (_player.state) {
            case VLCMediaPlayerStateStopped:
            {
                if (_player.media.state == VLCMediaStateNothingSpecial) {
                    if ([self.currentPath.pathExtension isEqualToString:@"swf"]) {//如果无法识别的swf文件
                        return;
                    }
                    //如果单曲循环就重新播放，不然就下一首
                    //                [self updateModel];//暂停和结束更新状态，其他不更新。
                    if (self.playModelType == XPlayModelTypeSingle) {
                        self.currentPath = self.currentPath;
                        [XTOOLS showMessage:@"开始重播"];
                    }
                    else if (self.playModelType == XPlayModelTypeSingleBreak){
                        [self pause];
                    }
                    else
                        if (self.playModelType == XPlayModelTypeRandom) {
                            self.index = arc4random()%self.mediaArray.count;
                        }
                        else
                        {
                            if (self.mediaArray.count>0) {
                                if (!self.isVideo) {
                                    self.index +=1;
                                }
                                else
                                {
                                    if (self.index >= self.mediaArray.count -1) {//如果是视频最后一个就停止部分
//                                        [self pause];
                                        [XTOOLS showMessage:@"已播完一遍"];
                                        self.index = 0;//重新第一个播放
                                    }
                                    else
                                    {
                                        self.index +=1;
                                    }
                                }
                            }
                            else {
                                [self pause];
                            }
                        }
                    
                }
            }
                break;
            case VLCMediaPlayerStateEnded:
            case VLCMediaPlayerStateError:
            {
                [self updateModel];
                
                if (self.playModelType == XPlayModelTypeSingle) {
                    self.currentPath = self.currentPath;
                    [XTOOLS showMessage:@"开始重播"];
                }
                else
                    if (self.playModelType == XPlayModelTypeRandom) {
                        self.index = arc4random()%self.mediaArray.count;
                    }
                    else
                    {
                        if (self.mediaArray.count>0) {
                            if (!self.isVideo) {
                                self.allowStartTime = NO;
                                self.index +=1;
                            }
                            else
                            {
                                if (self.index >= self.mediaArray.count -1) {//如果是视频最后一个就停止部分
                                    if (self.playModelType == XPlayModelTypeSingleBreak){
                                        [self pause];
                                    }
                                    else if (self.playModelType == XPlayModelTypeSingle){
                                        self.index = _index;
                                    }
                                    else {
                                        [XTOOLS showMessage:@"已播完一遍"];
                                        self.index = 0;
                                    }
                                }
                                else
                                {
                                    if (self.playModelType == XPlayModelTypeSingleBreak){
                                        [XTOOLS showMessage:@"单个播完"];
                                        [self pause];
                                    }
                                    else {
                                        self.allowStartTime = NO;
                                        self.index +=1;
                                    }
                                   
                                }
                            }
                        }
                        else
                        {
                            self.currentPath = self.currentPath;
                        }
                    }
                
            }
                break;
            case VLCMediaPlayerStatePlaying:
            {
                if (!self.isVideo) {
                    [self.nowPlayingInfo setValue:@(self.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                }
                
            }
                break;
            case VLCMediaPlayerStatePaused:
            {
                if (!self.isVideo) {
                    [self.nowPlayingInfo setValue:@(self.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.nowPlayingInfo];
                }
                [self updateModel];
                
            }
                break;
            default:
                break;
        }
    }
}
- (void)playerTimeChanged:(NSNotification *)notifi {
    if (!self.isVideo) {
        
        [self.nowPlayingInfo setValue:@([XTOOLS timeStrToSecWithStr:_player.media.length.stringValue]) forKey:MPMediaItemPropertyPlaybackDuration];
        [self.nowPlayingInfo setValue:@([XTOOLS timeStrToSecWithStr:_player.time.stringValue]) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:self.nowPlayingInfo];
        
    }
    if (self.stopDate) {//如果有停止时间
        NSDate *nowDate = [NSDate date];
        if ([nowDate compare:self.stopDate] != NSOrderedAscending) {
            self.stopDate = nil;
            [_player pause];
            
//           [VideoAudioPlayer playerRelease];
        }
    }
    if (self.allowStartTime) {
        [self setPlayTime];
        self.allowStartTime = NO;//每次过后都设置为NO，防止应该下下次。
    }
}
//- (void)setPlayerDelegate:(id<VideoAudioPlayerDelegate>)playerDelegate {
//    _player.delegate = (id)playerDelegate;
//    _playerDelegate = playerDelegate;
//}
- (void)setMediaArray:(NSArray *)mediaArray {
    _mediaArray = mediaArray;
}
- (void)setIndex:(NSInteger)index {
    if (self.mediaArray.count>0) {
        if (index>=0 && index<self.mediaArray.count) {
            _index = index;
            
        }
        else
        {
            _index = 0;
        }
        NSObject *object = [self.mediaArray xd_objectAtIndex:_index];
        self.currentPath = (NSString *)object;
    }
    else
    {
//        self.currentPath = self.currentPath;
    }
    
}
- (void)setCurrentPath:(NSString *)currentPath {
    if (currentPath == nil) {
        [XTOOLS showMessage:@"文件为空"];
        return;
    }
    currentPath = kAppendDocument(currentPath);
//    if (![currentPath hasPrefix:KDocumentP]) {
//        currentPath = [KDocumentP stringByAppendingPathComponent:currentPath];
//    }
    if ([_currentPath isEqualToString:currentPath]) {//如果相同就展厅
        VLCMedia *locaMedia = [[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_currentPath]];
        [locaMedia parseWithOptions:VLCMediaParseLocal|VLCMediaFetchLocal];
        [locaMedia addOptions:self.mediaOptionDict];
        _player.media = locaMedia;
        NSLog(@"media == %@",_player.media.metaDictionary);
        //如果是高清影视就调低
        if (self.isVideo) {
            if (self.playModelType == XPlayModelTypeSingle) {
                [XTOOLS showMessage:@"开始重播"];
                [_player play];
            }
            else {
                [_player pause];
            }
            
        }
        else {
            [_player play];
        }
    }
    else {
        if (_currentPath.length >0) {//更新一下上一个的播放记录
            [self updateModel];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:currentPath]) {//如果不能找到文件
            [XTOOLS showAlertTitle:@"文件丢失" message:@"找不到文件或者文件已被删除了，是否删除此条记录？" buttonTitles:@[kLocalized(@"Cancel"),kLocalized(@"Delete")] completionHandler:^(NSInteger num) {
                
            }];
        }
        else {
            _currentPath = currentPath;//能找到文件后判断有没有上一个下一个
            BOOL isPrev = NO;
            BOOL isNext = NO;
            if (self.mediaArray.count>1) {
                if (self.index == 0) {
                    isPrev = NO;
                    isNext = YES;
                }
                else
                    if (self.index >0 && self.index < self.mediaArray.count-1) {
                        isPrev = YES;
                        isNext = YES;
                    }
                    else
                        if (self.index == self.mediaArray.count - 1) {
                            isPrev = YES;
                            isNext = NO;
                            
                        }
            }
            _player.equalizerEnabled = YES;//启用均衡器
            if (_player&&[NSURL fileURLWithPath:_currentPath] != _player.media.url) {
                 
                VLCMedia *locaMedia =[[VLCMedia alloc] initWithURL:[NSURL fileURLWithPath:_currentPath]];
                [locaMedia parseWithOptions:VLCMediaParseLocal|VLCMediaFetchLocal];//VLCMediaParseNetwork|VLCMediaFetchNetwork
                [locaMedia addOptions:self.mediaOptionDict];
                _player.media =locaMedia;
                NSLog(@"media == %@",_player.media.metaDictionary);
                //如果是高清影视就调低
               
                if (!self.isVideo) {
                    [self reloadNowPlayInfo];
                }
                else
                {
                    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
                    
                }
                
                [_player play];
                
            }
            
            if (self.playerDelegate&&[self.playerDelegate respondsToSelector:@selector(playerHidePrev:HideNext:) ]) {
                [self.playerDelegate playerHidePrev:isPrev HideNext:isNext];
            }
        }
        
    }
}
//- (NSString *)screenAspectRatio
//{
//    UIScreen *screen = [[UIDevice currentDevice] VLCHasExternalDisplay] ? [UIScreen screens][1] : [UIScreen mainScreen];
//    return [NSString stringWithFormat:@"%d:%d", (int)screen.bounds.size.width, (int)screen.bounds.size.height];
//}
- (void)setIsVideo:(BOOL)isVideo {
    _isVideo = isVideo;
    if (_isVideo) {//如果是视频就隐藏音乐的播放按钮
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];

    }
    else
    {
        [self reloadNowPlayInfo];
    }
}
//设置播放时间
- (void)setPlayTime {
    float num = 5;
    NSLog(@"progress == %@",@(num));
    NSLog(@"track ==%@",_player.audioTrackNames);
    NSLog(@"chancel == %d",_player.audioChannel);
    if (num>0) {
        [_player jumpForward:num];
    }
}
- (NSMutableDictionary *)nowPlayingInfo {
    if (!_nowPlayingInfo) {
      _nowPlayingInfo = [[NSMutableDictionary alloc]init];
    }
    return _nowPlayingInfo;
}
#pragma mark -- 锁屏后显示的信息
//刷新锁屏内容。
- (void)reloadNowPlayInfo {
    self.mediaImage = nil;
    self.mediaImage = [_player.media.metaDictionary objectForKey:VLCMetaInformationArtwork];
    if (!self.mediaImage) {
        self.mediaImage = [UIImage imageNamed:[NSString stringWithFormat:@"a%d",rand()%9+1]];
    }
    NSString *title = _player.currentPath.lastPathComponent.stringByDeletingPathExtension;
    if (!title) {
        title = _player.currentPath.lastPathComponent;
    }
    NSString *artistName = [_player.media.metaDictionary objectForKey:VLCMetaInformationArtist];
    if (!artistName) {
        artistName = @"";
    }
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:self.mediaImage];
    
    [self.nowPlayingInfo setValue:title forKey:MPMediaItemPropertyTitle];
    [self.nowPlayingInfo setValue:artistName forKey:MPMediaItemPropertyArtist];
    [self.nowPlayingInfo setValue:artWork forKey:MPMediaItemPropertyArtwork];
    [self.nowPlayingInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
}
#pragma mark --  远程操作播放进度，
- (void)configRemoteCommandCenter {
    MPRemoteCommandCenter *center =[MPRemoteCommandCenter sharedCommandCenter];
    MPRemoteCommand *pauseCommand = [center pauseCommand];
    [pauseCommand setEnabled:YES];
    @weakify(self);
    [pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        [self pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand *playCommand = [center playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        [self play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand *nextCommand = [center nextTrackCommand];
    [nextCommand setEnabled:YES];
    [nextCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        self.index+=1;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    MPRemoteCommand *previousCommand = [center previousTrackCommand];
    [previousCommand setEnabled:YES];
    [previousCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        @strongify(self);
        self.index-=1;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    MPRemoteCommand *togglePlayPauseCommand = [center togglePlayPauseCommand];
    [togglePlayPauseCommand setEnabled:YES];
    [togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.isPlaying) {
            [self pause];
        }
        else {
            [self play];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
     if (@available(iOS 9.1, *)) {
      MPChangePlaybackPositionCommand *changePositionCommand = [center changePlaybackPositionCommand];
         [changePositionCommand setEnabled:YES];
         [changePositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
             if ([event isKindOfClass:[MPChangePlaybackPositionCommandEvent class]]) {
                 MPChangePlaybackPositionCommandEvent *changeEvent = (MPChangePlaybackPositionCommandEvent *)event;
                 @strongify(self);
                 VLCTime *targetTime = [[VLCTime alloc] initWithInt:(int)(changeEvent.positionTime*1000)];
                 [self setTime:targetTime];
             }
             return MPRemoteCommandHandlerStatusSuccess;
         }];
    }
}
@end
