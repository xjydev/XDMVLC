//
//  CaptionViewController.m
//  FileManager
//
//  Created by XiaoDev on 2018/7/27.
//  Copyright © 2018 xiaodev. All rights reserved.
//srt、smi、ssa

#import "CaptionViewController.h"
#import "VideoAudioPlayer.h"
#import "XTools.h"
#import "NSArray+XDExt.h"
@interface CaptionViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL  _allFiles;//是不是全部文件。
    NSInteger  _selectedRow;
}

@property (weak, nonatomic) IBOutlet UITextField *delayTextField;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong)NSArray *allFilesArray;
@property (nonatomic, strong)NSMutableArray *captionArray;
@property (weak, nonatomic) IBOutlet UITextField *volumeTextField;
@end

@implementation CaptionViewController

+ (instancetype)allocFromStoryBoard {
    UIStoryboard *mediaStory = [UIStoryboard storyboardWithName:@"MediaSB" bundle:nil];
    CaptionViewController *VC = [mediaStory instantiateViewControllerWithIdentifier:@"CaptionViewController"];
    return VC;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedRow = -1;
    UILabel *rlabel = [[ UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 30)];
    rlabel.text = @"s ";
    rlabel.textColor = [UIColor blackColor];
    self.delayTextField.rightViewMode = UITextFieldViewModeAlways;
    self.delayTextField.rightView = rlabel;
    self.delayTextField.text = [NSString stringWithFormat:@"%@",@(self.delayTime)];
    if (@available(iOS 15.0, *)) {
        self.mainTableView.sectionHeaderTopPadding = 0;
    }
    
    UILabel *vrlabel = [[ UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 30)];
    vrlabel.text = @"% ";
    vrlabel.textColor = [UIColor blackColor];
    self.volumeTextField.rightViewMode = UITextFieldViewModeAlways;
    self.volumeTextField.rightView = vrlabel;
    
    self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
    NSError *error = nil;
    NSArray *array = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:KDocumentP error:&error];
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSArray *marry = [array sortedArrayUsingComparator:^(NSString * obj1, NSString * obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
        
    }];
    self.allFilesArray = marry;
    [self.captionArray removeAllObjects];
    NSArray *extenArray = @[@"srt",@"smi",@"ssa",@"ass"];
    for (NSString *name in self.allFilesArray) {
        NSString *extension = [[name pathExtension]lowercaseString];
        if ([extenArray containsObject:extension] ) {
            [self.captionArray addObject:name];
        }
    }
}
- (NSMutableArray *)captionArray {
    if (!_captionArray) {
        _captionArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _captionArray;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        if (_allFiles) {
            return self.allFilesArray.count;
        }
        else
        {
            return self.captionArray.count;
        }
    }
    else if (section == 2){
        return [VideoAudioPlayer defaultPlayer].mediaArray.count;
    }
    else {
      return [VideoAudioPlayer defaultPlayer].audioTrackNames.count;
    }
    
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"delaycellid" forIndexPath:indexPath];
    if (indexPath.section == 1) {
        if (_allFiles) {
            NSString *name = @"";
            if(self.allFilesArray.count > indexPath.row){
                name =self.allFilesArray[indexPath.row];
            }
            cell.textLabel.text = name.lastPathComponent;
        }
        else
        {
            NSString *name =@"";
            if (self.captionArray.count > indexPath.row) {
                name = self.captionArray[indexPath.row];
            }
            cell.textLabel.text = name.lastPathComponent;
        }
        if (indexPath.row == _selectedRow) {
            cell.detailTextLabel.text = @"✅";
        }
        else
        {
            cell.detailTextLabel.text = @"";
        }
    }
    else if (indexPath.section == 2){
        NSObject *object = [[VideoAudioPlayer defaultPlayer].mediaArray xd_objectAtIndex:indexPath.row];
        NSString *name ;
        name = (NSString *)object;
        cell.textLabel.text = name.lastPathComponent;
    }
    else {
        NSString *name = @"";
        if ([VideoAudioPlayer defaultPlayer].audioTrackNames.count > indexPath.row) {
            name = [VideoAudioPlayer defaultPlayer].audioTrackNames[indexPath.row];
        }
        NSObject *index0 = nil;
        if ([VideoAudioPlayer defaultPlayer].audioTrackIndexes.count > indexPath.row) {
            index0 = [VideoAudioPlayer defaultPlayer].audioTrackIndexes[indexPath.row];
        }
        if ([NSString stringWithFormat:@"%@",index0].intValue == [VideoAudioPlayer defaultPlayer].currentAudioTrackIndex) {
            cell.textLabel.textColor = [UIColor blueColor];
        }
        else {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        cell.textLabel.text = name;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 30)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    if (section == 1) {
        label.text = @"      字幕文件";
    }
    else if (section == 2) {
        label.text = @"      选集";
    }
    else {
        label.text = @"      声道切换";
    }
    return label;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == _selectedRow) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.detailTextLabel.text = @"";
            _selectedRow = -1;
            return;
        }
        if (_allFiles) {
            if (_selectedRow >=0 && _selectedRow<self.allFilesArray.count) {
                UITableViewCell *celled = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
                celled.detailTextLabel.text = @"";
            }
        }
        else
        {
            if (_selectedRow >=0 && _selectedRow<self.captionArray.count) {
                UITableViewCell *celled = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedRow inSection:0]];
                celled.detailTextLabel.text = @"";
            }
        }
        _selectedRow = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = @"✅";
    }
    else if (indexPath.section == 2){
        [VideoAudioPlayer defaultPlayer].index = indexPath.row;
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else {
        if ([VideoAudioPlayer defaultPlayer].audioTrackIndexes.count > indexPath.row) {
            NSObject *indexo = [VideoAudioPlayer defaultPlayer].audioTrackIndexes[indexPath.row];
            int index = [NSString stringWithFormat:@"%@",indexo].intValue;
            [VideoAudioPlayer defaultPlayer].currentAudioTrackIndex =index;
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//音量
- (IBAction)volumeMinusButtonAction:(id)sender {
    [[VideoAudioPlayer defaultPlayer].audio volumeDown];
    self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
    [kUSerD synchronize];
}
- (IBAction)volumeAddButtonAction:(id)sender {
    [[VideoAudioPlayer defaultPlayer].audio volumeUp];
    self.volumeTextField.text = [NSString stringWithFormat:@"%d",[VideoAudioPlayer defaultPlayer].audio.volume];
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
    [kUSerD synchronize];
}
- (IBAction)volumeTextFieldValueChanged:(UITextField *)sender {
    [VideoAudioPlayer defaultPlayer].audio.volume = sender.text.intValue;
    [kUSerD setInteger:[VideoAudioPlayer defaultPlayer].audio.volume forKey:kVolume];
       [kUSerD synchronize];
}

//加减反了
- (IBAction)minusDelayTimeButton:(id)sender {
   self.delayTextField.text = [NSString stringWithFormat:@"%d",[self.delayTextField.text intValue]+1];
}
- (IBAction)addDelayTimeButtonAction:(id)sender {
    self.delayTextField.text = [NSString stringWithFormat:@"%d",[self.delayTextField.text intValue]-1];
}
- (IBAction)allFilesButtonAction:(UIButton *)sender {
    _allFiles = !_allFiles;
    [sender setTitle:(_allFiles?@"字幕文件":@"全部文件") forState:UIControlStateNormal];
    [self.mainTableView reloadData];
}
- (IBAction)commitButtonAction:(id)sender {
    NSString *selectedStr = nil;
    if (_allFiles) {
        if (_selectedRow>=0&&_selectedRow<self.allFilesArray.count) {
            selectedStr = self.allFilesArray[_selectedRow];
        }
        
    }
    else
    {
        if (_selectedRow>=0&&_selectedRow<self.captionArray.count) {
            selectedStr = self.captionArray[_selectedRow];
        }
    }
    if (self.captionSelectCompletion) {
        self.captionSelectCompletion([self.delayTextField.text intValue], selectedStr);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)cancleButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (BOOL)shouldAutorotate {
    [self dismissViewControllerAnimated:NO completion:nil];
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
