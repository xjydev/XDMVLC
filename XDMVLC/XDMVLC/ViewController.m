//
//  ViewController.m
//  XDMVLC
//
//  Created by jingyuan5 on 2023/1/1.
//

#import "ViewController.h"
#import "NewVideoViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)playButtonAction:(UIButton *)sender {
    NewVideoViewController *vc = [NewVideoViewController allocFromStoryBoard];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.videoPath = @"v3.wmv";
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
