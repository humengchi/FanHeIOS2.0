//
//  RegisterNameViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/1.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RegisterNameViewController.h"
#import "RegisterPhoneViewController.h"

@interface RegisterNameViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *inputIsRightBtn;
@property (weak, nonatomic) IBOutlet UILabel *showErrorLabel;

@end

@implementation RegisterNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIGestureRecognizer *ges in self.view.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [self.view removeGestureRecognizer:ges];
        }
    }
    self.textField.layer.borderColor = HEX_COLOR(@"F9F9F9").CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.masksToBounds = YES;
    [self.textField becomeFirstResponder];
    [self.textField setValue:HEX_COLOR(@"AFB6C1") forKeyPath:@"_placeholderLabel.textColor"];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonClicked:(UIButton *)sender {
    [self.textField resignFirstResponder];
    UserModel *userModel = [[UserModel alloc] init];
    userModel.realname = self.textField.text;
    [DataModelInstance shareInstance].userModel = userModel;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:[CommonMethod getVCFromNib:[RegisterPhoneViewController class]] animated:YES];
    });
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(self.nextBtn.enabled){
        [self nextButtonClicked:self.nextBtn];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    self.showErrorLabel.hidden = YES;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        if(str.length >= 1){
            self.inputIsRightBtn.hidden = NO;
            if(str.length <= 10){
                self.inputIsRightBtn.selected = NO;
                self.nextBtn.enabled = YES;
            }else{
                self.inputIsRightBtn.selected = YES;
                self.showErrorLabel.hidden = NO;
                self.nextBtn.enabled = YES;
                self.textField.text = [str substringToIndex:10];
                return NO;
            }
        }else{
            self.inputIsRightBtn.hidden = YES;
            self.nextBtn.enabled = NO;
        }
    }
    return YES;
}

@end
