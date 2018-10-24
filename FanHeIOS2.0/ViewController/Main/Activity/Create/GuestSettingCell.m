//
//  GuestSettingCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GuestSettingCell.h"
#import "UploadImageTypeView.h"
#import "GuestSettingViewController.h"

@interface GuestSettingCell ()<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *dict;

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UITextView *remarkTextView;
@property (nonatomic, weak) IBOutlet UILabel *remarkPlaceholder;

@end

@implementation GuestSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:31 borderWidth:0 borderColor:nil];
    [CommonMethod viewAddGuestureRecognizer:self.headerImageView tapsNumber:1 withTarget:self withSEL:@selector(uploadheaderImageView)];
    self.remarkTextView.delegate = self;
    self.nameTextField.delegate = self;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisply:(NSMutableDictionary *)dict{
    self.dict = [dict mutableCopy];
    __weak typeof(self) weakSelf = self;
    self.nameTextField.text = self.dict[@"name"];
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.dict[@"image"]]] placeholderImage:kImageWithName(@"icon_jb_mr")];
    self.remarkTextView.text = self.dict[@"intro"];
    
    [self.remarkTextView.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.remarkPlaceholder.hidden = text.length>0;
    }];
}

- (IBAction)deleteGuestButtonClicked:(id)sender{
    [self endEditing:YES];
    if(self.deleteGuest){
        self.deleteGuest(self);
    }
}

- (void)uploadheaderImageView{
    [self endEditing:YES];
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    view.uploadImageViewImage = ^(UIImage *image){
        [weakSelf uploadHeadImage:image];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

//上传图片
- (void)uploadHeadImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud =
    [MBProgressHUD showMessag:@"上传图片中..." toView:[self viewController].view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [[self viewController] requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            [weakSelf.dict setObject:urlStr forKey:@"image"];
            [weakSelf.headerImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:KHeadImageDefault];
            if(weakSelf.guestParamEdit){
                weakSelf.guestParamEdit(weakSelf.dict, self);
            }
        }else{
            [MBProgressHUD showError:@"图片上传失败" toView:[weakSelf viewController].view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:[weakSelf viewController].view];
    }];
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        if(str.length>60){
            self.remarkTextView.text = [str substringToIndex:60];
            [self.dict setObject:self.remarkTextView.text forKey:@"intro"];
            if(self.guestParamEdit){
                self.guestParamEdit(self.dict, self);
            }
            return NO;
        }else{
            [self.dict setObject:str forKey:@"intro"];
            if(self.guestParamEdit){
                self.guestParamEdit(self.dict, self);
            }
        }
    }
    return YES;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.nameTextField){
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if(position && (range.length==0 || string.length==0)){
            return YES;
        }else{
            NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
            if(str.length>30){
                self.nameTextField.text = [str substringToIndex:30];
                [self.dict setObject:self.nameTextField.text forKey:@"name"];
                if(self.guestParamEdit){
                    self.guestParamEdit(self.dict, self);
                }
                return NO;
            }else{
                [self.dict setObject:str forKey:@"name"];
                if(self.guestParamEdit){
                    self.guestParamEdit(self.dict, self);
                }
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    GuestSettingViewController *vc = (GuestSettingViewController*)[self viewController];
    [vc.tableView scrollRectToVisible:CGRectMake(0, self.tag*169, WIDTH, 169) animated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    GuestSettingViewController *vc = (GuestSettingViewController*)[self viewController];
    [vc.tableView scrollRectToVisible:CGRectMake(0, self.tag*169, WIDTH, 169) animated:YES];
}


@end
