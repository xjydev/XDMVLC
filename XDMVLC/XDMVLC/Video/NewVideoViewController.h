//
//  NewVideoViewController.h
//  FileManager
//
//  Created by XiaoDev on 15/05/2018.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VLCMedia;
@interface NewVideoViewController : UIViewController
+ (instancetype)allocFromStoryBoard;

@property (nonatomic, copy)NSString *videoPath;
- (void)setVideoArray:(NSArray *)videoArray WithIndex:(NSInteger)index;
- (void)setURLMedia:(VLCMedia *)urlMedia;
@end
