//
//  AdviceViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdviceViewController.h"

@interface AdviceViewController ()<UITextViewDelegate>
@property (nonatomic ,strong)UIImage *upImage;
@property (nonatomic ,strong)NSString *url;
@end

@implementation AdviceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self createCustomNavigationBar:@"问题反馈"];
    self.AdviceTextView.delegate = self;
    [self.AddImageBtn setShowsTouchWhenHighlighted:YES];
    self.releaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.releaseButton.frame = CGRectMake(WIDTH - 60, 16, 60, 50);
    [self.releaseButton setImage:[UIImage imageNamed:@"btn_sendmessage_gray_non-1"]  forState:UIControlStateNormal];
   

    [self.releaseButton addTarget:self action:@selector(releaseInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.releaseButton];
    
}
- (void)releaseInfo{
    if (self.AdviceTextView.text.length == 0) {
        return;
    }
    if(self.upImage == nil){
        [self upAdviceImage:nil];
    }else{
        [self upPhoneImage];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.showLabel.hidden = NO;
        [self.releaseButton setImage:[UIImage imageNamed:@"btn_sendmessage_gray_non-1"]  forState:UIControlStateNormal];
    }else{
       [self.releaseButton setImage:[UIImage imageNamed:@"btn_sendmessage_gray"]  forState:UIControlStateNormal];
    }
}



- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        [self.releaseButton setImage:[UIImage imageNamed:@"btn_sendmessage_gray_non-1"]  forState:UIControlStateNormal];
    }else{
        [self.releaseButton setImage:[UIImage imageNamed:@"btn_sendmessage_gray"]  forState:UIControlStateNormal];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.AdviceTextView becomeFirstResponder];
    self.showLabel.hidden = YES;
}

#pragma mark - UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark ------- 拍照
- (IBAction)choseImageAction:(UIButton *)sender {
    [self.AdviceTextView resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    if (self.upImage != nil) {
        view.deleImageBtn.hidden = NO;
    }
    view.uploadImageViewImage = ^(UIImage *image){
        weakSelf.upImage = image;
        [weakSelf.AddImageBtn setBackgroundImage:image forState:UIControlStateNormal];
    };
    view.deleteloadImageViewType = ^(){
        self.upImage = nil;
        [self.AddImageBtn setBackgroundImage:[UIImage imageNamed:@"btn_wtfk_add"] forState:UIControlStateNormal];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

- (void)upPhoneImage{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"提交中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    UIImage *image = self.upImage;//[self.upImage scaleToSize:WIDTH-50];
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSString *str = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if([str isEqualToString:@"1"]){
            weakSelf.url = [responseObject objectForKey:@"msg"];
            [weakSelf upAdviceImage:hud];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
    }];
}

- (void)upAdviceImage:(MBProgressHUD*)hud{
    if(hud == nil){
        hud = [MBProgressHUD showMessag:@"提交中..." toView:self.view];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.url] forKey:@"picture"];
    [requestDict setObject:self.AdviceTextView.text forKey:@"remark"];
    [requestDict setObject:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId]forKey:@"userid"];
    
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_SUBMITQUESTION paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"提交成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"提交失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"提交失败" toView:weakSelf.view];
    }];

}

@end
