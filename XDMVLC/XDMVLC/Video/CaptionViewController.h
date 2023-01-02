//
//  CaptionViewController.h
//  FileManager
//
//  Created by XiaoDev on 2018/7/27.
//  Copyright © 2018 xiaodev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptionViewController : UIViewController
+ (instancetype)allocFromStoryBoard;
@property (nonatomic, strong)NSArray *subTitleArray;
@property (nonatomic, assign)NSInteger delayTime;
@property (nonatomic, copy)void (^captionSelectCompletion)(int time,NSObject * subTitleObject);//第一个是时间，第二个是选择的字幕地址，或者index。
@end
