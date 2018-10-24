//
//  ChangeGroupNameViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeGroupNameViewController.h"
#import "JobTextFile.h"
#define kMaxLength  15
@interface ChangeGroupNameViewController ()<UITextFieldDelegate>
@property (nonatomic,strong) JobTextFile *textFile;
@property (nonatomic   ,strong) UIButton *settingBtn;
@property (nonatomic   ,strong) UILabel *titleCount;
@end

@implementation ChangeGroupNameViewController
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
    [self createCustomNavigationBar:@"修改群名称"];
    
    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingBtn.frame = CGRectMake(WIDTH-80, 20, 80, 44);
    [self.settingBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.settingBtn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateNormal];
    [self.settingBtn addTarget:self action:@selector(saveNameAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingBtn];

    
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 74, 200, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.text = @"群聊名称";
    [self.view addSubview:titleLabel];
    
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, 96, WIDTH, 50) backColor:@"FFFFFF"];
    [self.view addSubview:backView];
    self.textFile = [[JobTextFile alloc]initWithFrame:CGRectMake(16, 16, WIDTH - 32, 17)];
    self.textFile.font = [UIFont systemFontOfSize:17];
    self.textFile.text = self.groupName;
    self.textFile.delegate = self;
    self.textFile.backgroundColor = [UIColor whiteColor];
    
    self.textFile.returnKeyType = UIReturnKeySearch;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChangedName:)name:@"UITextFieldTextDidChangeNotification"object:self.textFile];
   
    [backView addSubview:self.textFile];
    self.titleCount = [UILabel createLabel:CGRectMake(WIDTH - 70, 156, 50, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    self.titleCount.text = [NSString stringWithFormat:@"%ld/15",self.groupName.length];
    
    [self.view addSubview:self.titleCount];
    // Do any additional setup after loading the view.
}
- (void)saveNameAction:(UIButton *)btn{
    EMError *error = nil;
    // 修改群名称
    

    [[EMClient sharedClient].groupManager changeGroupSubject:self.textFile.text forGroup:self.groupID error:&error];
    if (!error) {
        NSString *title = [NSString stringWithFormat:@"%@修改群名称为%@",[DataModelInstance shareInstance].userModel.realname ,self.textFile.text];
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"joinGroup",@"money_type_special",title,@"title", nil];
        EMMessage *message = [EaseSDKHelper sendTextMessage:title to:self.groupID  messageType:EMChatTypeGroupChat messageExt:dic];
        message.chatType = EMChatTypeGroupChat;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
            if (!aError) {
                [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                self.tableView.userInteractionEnabled = YES;
            }else{
                [MBProgressHUD showError:@"发送失败" toView:self.view];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }else{
        NSLog(@"%@",error.errorDescription);
    }
}
- (void)textFiledEditChangedName:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
        if (toBeString.length <= 0) {
             self.titleCount.text = [NSString stringWithFormat:@"%ld/15",toBeString.length];
    
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
//                 self.titleCount.text = [NSString stringWithFormat:@"%ld/15",toBeString.length];
            }
            self.titleCount.text = [NSString stringWithFormat:@"%ld/15",textField.text.length];
            
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
            self.titleCount.text = @"15/15";
    
        }
//        if (toBeString.length <= kMaxLength &&toBeString.length > 0 ) {
//             self.titleCount.text = [NSString stringWithFormat:@"%/15",toBeString.length];
//        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//点击return 按钮 去掉
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFile resignFirstResponder];
    return YES;
}
//点击屏幕空白处去掉键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textFile resignFirstResponder];
    [self.textFile resignFirstResponder];
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
