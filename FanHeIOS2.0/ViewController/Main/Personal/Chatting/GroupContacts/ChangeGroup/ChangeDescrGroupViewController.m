
//
//  ChangeDescrGroupViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/15.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeDescrGroupViewController.h"
#define kMaxLength  100
@interface ChangeDescrGroupViewController ()
@property (nonatomic   ,strong) UIButton *settingBtn;
@property (nonatomic   ,strong)  UITextView *descriptionView;
@property (nonatomic   ,strong) UILabel *titleCount;
@end

@implementation ChangeDescrGroupViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     [self createCustomNavigationBar:@"编辑群简介"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingBtn.frame = CGRectMake(WIDTH-80, 20, 80, 44);
    [self.settingBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.settingBtn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateNormal];
    [self.settingBtn addTarget:self action:@selector(saveDescrAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingBtn];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 74, 200, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.text = @"群简介";
    [self.view addSubview:titleLabel];
    
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, 96, WIDTH, 258) backColor:@"FFFFFF"];
    [self.view addSubview:backView];
     self.descriptionView = [[UITextView alloc]initWithFrame:CGRectMake(16, 16, WIDTH - 32, 200)];
    self.descriptionView.font = [UIFont systemFontOfSize:17];
      self.descriptionView.text = self.descriptionStr;
    [backView addSubview:  self.descriptionView];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChangedName:)name:@"UITextViewTextDidChangeNotification"object:self.descriptionView];
    self.titleCount = [UILabel createLabel:CGRectMake(WIDTH - 90, 240, 80, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FFFFFF"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    self.titleCount.textAlignment = NSTextAlignmentRight;
    self.titleCount.text = [NSString stringWithFormat:@"%ld/100",self.descriptionStr.length];
    [backView addSubview:self.titleCount];


}
- (void)textViewEditChangedName:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if (toBeString.length <= 0) {
        self.titleCount.text = [NSString stringWithFormat:@"%ld/100",toBeString.length];
        
    }
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            //            [self.searchArray removeAllObjects];
            if (toBeString.length >= kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                
            }
        self.titleCount.text = [NSString stringWithFormat:@"%ld/100",textField.text.length];

        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        //        [self.searchArray removeAllObjects];
        if (toBeString.length >= kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
             self.titleCount.text = @"100/100";
        
        }
//        if (toBeString.length < kMaxLength &&toBeString.length > 0 ) {
//            self.titleCount.text = [NSString stringWithFormat:@"%ld/100",toBeString.length];
//        }
    }
    

}
- (void)saveDescrAction:(UIButton *)btn{
    EMError *error = nil;
    // 修改群描述
[[EMClient sharedClient].groupManager changeDescription:self.descriptionView.text forGroup:self.groupID error:&error];
    if (!error) {
        NSLog(@"修改成功");
         [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSLog(@"%@",error.errorDescription);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [  self.descriptionView resignFirstResponder];
    return YES;
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
       [self.descriptionView resignFirstResponder];
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
