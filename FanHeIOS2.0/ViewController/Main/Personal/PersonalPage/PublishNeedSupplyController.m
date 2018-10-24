//
//  PublishNeedSupplyController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PublishNeedSupplyController.h"
#import "GoodAtViewController.h"
#import "ChoiceNeedSupplyController.h"

@interface PublishNeedSupplyController ()<UITextViewDelegate, UITextFieldDelegate, TZImagePickerControllerDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *sendbtn;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, weak) IBOutlet UITextView *contentTextView;
@property (nonatomic, weak) IBOutlet UIView *imagesView;
@property (nonatomic, weak) IBOutlet UITextField *tagsTextField;

@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *tagsArray;

@end

@implementation PublishNeedSupplyController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isNeed){
        self.titleLabel.text = @"发布需求";
        [self.placeholderLabel setParagraphText:@"请详细描述您需要的产品信息、项目信息等\n如:\n①我有个XX项目,急需资金方.[附上项目图文描述]\n②现自有资金,寻求靠谱项目." lineSpace:5];
        self.titleTextField.placeholder = @"请用一句话概括你的需求";
        self.tagsTextField.placeholder = @"请填写需求标签";
    }else{
        self.titleLabel.text = @"发布供应";
        [self.placeholderLabel setParagraphText:@"请详细描述您提供的产品信息、项目信息等\n如：\n①现自有资金,寻求靠谱项目.\n②提供XXX产品服务" lineSpace:5];
        self.titleTextField.placeholder = @"请用一句话概括你提供的服务";
        self.tagsTextField.placeholder = @"请填写供应标签";
    }
    [self.titleTextField.subviews[0] removeFromSuperview];
    [self.tagsTextField.subviews[0] removeFromSuperview];
    self.imagesArray = [NSMutableArray array];
    self.tagsArray = [NSMutableArray array];
    [self createImageViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)justifySendButtonEnabled:(NSString*)str isCotent:(BOOL)isCotent{
    NSString *otherStr;
    if(isCotent){
        otherStr = self.titleTextField.text;
    }else{
        otherStr = self.contentTextView.text;
    }
    if(str.length && otherStr.length && self.tagsTextField.text.length){
        self.sendbtn.enabled = YES;
    }else{
        self.sendbtn.enabled = NO;
    }
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)publishButtonClicked:(id)sender{
    [self uploadImageHttp:nil];
}

- (IBAction)tagButtonClicked:(id)sender{
    GoodAtViewController *vc = [[GoodAtViewController alloc]init];
    vc.array = [self.tagsArray mutableCopy];
    vc.needSupplyTagsSuccess = ^(NSMutableArray *tagsArray) {
        if(tagsArray.count){
            self.tagsArray = tagsArray;
            self.tagsTextField.text = [NSString stringWithFormat:@"#%@#",[tagsArray componentsJoinedByString:@"#  #"]];
            [self justifySendButtonEnabled:self.contentTextView.text isCotent:YES];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)choiseImageButtonClicked:(UITapGestureRecognizer*)tap{
    int tag = tap.view.tag;
    if(self.imagesArray.count > tag){
        [self photoButtonClicked:tag];
    }else{
        [self openPhoto];
    }
}

- (void)deleteButtonClicked:(UIButton*)sender{
    if(self.imagesArray.count > sender.tag){
        [self.imagesArray removeObjectAtIndex:sender.tag];
        [self createImageViews];
    }
}

#pragma mark - 图片选择view
- (void)createImageViews{
    for(UIView *view in self.imagesView.subviews){
        [view removeFromSuperview];
    }
    for(int i=0; i<self.imagesArray.count+1; i++){
        if(i==3){
            break;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*81, 9, 72, 72)];
        imageView.tag = i;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [CommonMethod viewAddGuestureRecognizer:imageView tapsNumber:1 withTarget:self withSEL:@selector(choiseImageButtonClicked:)];
        [self.imagesView addSubview:imageView];
        
        if(self.imagesArray.count>i){
            if([self.imagesArray[i] isKindOfClass:[UIImage class]]){
                imageView.image = self.imagesArray[i];
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:self.imagesArray[i]] placeholderImage:KSquareImageDefault];
            }
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(i*81+63, 0, 18, 18);
            deleteBtn.tag = i;
            [deleteBtn setBackgroundImage:kImageWithName(@"btn_work_dele") forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.imagesView addSubview:deleteBtn];
        }else{
            imageView.image = kImageWithName(@"btn_add_img_b");
        }
    }
}

//相册选择器
- (void)openPhoto{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:3-self.imagesArray.count delegate:self];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1))];
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray *photos, NSArray *assets, BOOL success) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        for (UIImage *image in photos) {
            UIImage *newImage = image;
            //旋转
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp){
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [self.imagesArray addObject:newImage];
            [self createImageViews];
        }
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

//点击图片
- (void)photoButtonClicked:(NSUInteger)index{
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = YES;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.autoPlayOnAppear = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:index];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imagesArray.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo;
    if([self.imagesArray[index] isKindOfClass:[UIImage class]]){
        photo = [MWPhoto photoWithImage:self.imagesArray[index]];
    }else{
        NSURL *url = [NSURL URLWithString:self.imagesArray[index]];
        photo = [MWPhoto photoWithURL:url];
    }
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 上传图片
- (void)uploadImageHttp:(MBProgressHUD*)hud{
    UIImage *image;
    NSInteger index = 0;
    for(id param in self.imagesArray){
        if([param isKindOfClass:[UIImage class]]){
            image = param;
            break;
        }
        index++;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if(image){
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [requestDict setObject:imageData forKey:@"pphoto"];
        if(hud==nil){
            hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
        }
    }else{
        if(hud){
            [hud hideAnimated:YES];
        }
        [self publishNeedSupply];
        return;
    }
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            weakSelf.imagesArray[index] = urlStr;
            [weakSelf uploadImageHttp:hud];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showMessag:@"图片上传失败，请重试！" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        
    }];
}

#pragma mark - 发布供需
- (void)publishNeedSupply{
    if([self.contentTextView.text filterHTML].length==0){
        self.contentTextView.text = @"";
        [self.view showToastMessage:@"描述不能为空"];
        return;
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.isNeed?@(2):@(1) forKey:@"type"];
    [requestDict setObject:self.titleTextField.text forKey:@"title"];
    [requestDict setObject:[self.contentTextView.text filterHTML] forKey:@"intro"];
    if(self.imagesArray.count){
        [requestDict setObject:[self.imagesArray componentsJoinedByString:@","] forKey:@"image"];
    }
    [requestDict setObject:[self.tagsArray componentsJoinedByString:@","] forKey:@"tag"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SENDGX paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.publishNeedSupplySuccess){
                weakSelf.publishNeedSupplySuccess(self.isNeed);
            }
            [[AppDelegate shareInstance] updateMenuNewMsgNum];
            [MBProgressHUD showSuccess:@"发布成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSArray *vcs = weakSelf.navigationController.viewControllers;
                for(int i=vcs.count-2; i>=0; i--){
                    UIViewController *vc = vcs[i];
                    if(![vc isKindOfClass:[ChoiceNeedSupplyController class]]){
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        if(str.length==0){
            self.placeholderLabel.hidden = NO;
            [self justifySendButtonEnabled:@"" isCotent:YES];
        }
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        self.placeholderLabel.hidden = str.length>0;
        [self justifySendButtonEnabled:str isCotent:YES];
        if(str.length>500){
            self.contentTextView.text = [str substringToIndex:500];
            return NO;
        }else{
        }
    }
    return YES;
}

#pragma mark --UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [[textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string] filterHTML];
        [self justifySendButtonEnabled:str isCotent:NO];
        if(str.length>50){
            self.titleTextField.text = [str substringToIndex:50];
            return NO;
        }else{
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
