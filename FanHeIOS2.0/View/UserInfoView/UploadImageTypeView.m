//
//  UploadImageTypeView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "UploadImageTypeView.h"

@interface UploadImageTypeView ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, weak) IBOutlet UIButton *btn1;
@property (nonatomic, weak) IBOutlet UIButton *btn2;

@property (nonatomic, weak) IBOutlet UILabel  *bkView;

@property (nonatomic, assign) UploadImageTypeViewType type;

@property (nonatomic, strong) UIImageView *imageview;

@end

@implementation UploadImageTypeView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.deleImageBtn.hidden = YES;
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(removeView)];
}

- (void)setUploadImageTypeViewType:(UploadImageTypeViewType)type{
    self.type = type;
    if(type == UploadImageTypeViewType_UploadVideo){
        [_btn1 setTitle:@"拍视频" forState:UIControlStateNormal];
        [_btn2 setTitle:@"从手机视频选择" forState:UIControlStateNormal];
    }
}

- (void)showShareNormalView{
    __weak typeof(self) weakSelf = self;
    self.bkView.alpha = 0;
    if(self.isIndentify){
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(25, -(HEIGHT-210), WIDTH-50, HEIGHT-210)];
        self.imageview.contentMode = UIViewContentModeScaleAspectFit;
        self.imageview.image = kImageWithName(@"bg_wrz_ts");
        self.bkView.backgroundColor = [HEX_COLOR(@"41464E") colorWithAlphaComponent:0.8];
        [self addSubview:self.imageview];
    }
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, -220, WIDTH, HEIGHT+220);
        if(weakSelf.isIndentify){
            weakSelf.imageview.frame = CGRectMake(25, 240, WIDTH-50, HEIGHT-210);
        }
        weakSelf.bkView.alpha = 1;
    } completion:nil];
}

- (void)removeView{
    if(self.cancleLoadImageViewType){
        self.cancleLoadImageViewType();
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+220);
        if(weakSelf.isIndentify){
            weakSelf.imageview.frame = CGRectMake(25, -(HEIGHT-210), WIDTH-50, HEIGHT-210);
        }
        weakSelf.bkView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)hideView{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+220);
        if(weakSelf.isIndentify){
            weakSelf.imageview.frame = CGRectMake(25, -(HEIGHT-210), WIDTH-50, HEIGHT-210);
        }
        weakSelf.bkView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf setHidden:YES];
    }];
}

#pragma mark - 按钮点击
- (IBAction)buttonClicked:(UIButton*)sender{
    if(sender.tag == 203){
        [self removeView];
    }else if(sender.tag == 204){
        [self removeView];
        if(self.deleteloadImageViewType){
            self.deleteloadImageViewType();
        }
    }else{
        if(sender == _btn1){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeView];
                        [[UIApplication sharedApplication] setStatusBarHidden:NO];
                    });
                    [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                    } confirm:^{
                        if(IOS_X >= 10){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                        }
                    }];
                    return;
                }
            }];
        }else{
            ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
                [self removeView];
                [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                } confirm:^{
                    if(IOS_X >= 10){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                    }
                }];
                return;
            }
        }
        if(self.type == UploadImageTypeViewType_UploadVideo){
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(self.uploadVideoViewType){
                            self.uploadVideoViewType(sender.tag);
                        }
                        [self removeView];
                    });
                } else {
                    [self removeView];
                    [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>麦克风”选项中，允许3号圈访问你的麦克风" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                    } confirm:^{
                        if(IOS_X >= 10){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                        }
                    }];
                    return;
                }
            }];
        }else{
            [self hideView];
            [self choiceType:sender.tag];
        }
    }
}

- (void)choiceType:(NSInteger)type{
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    if(self.type != UploadImageTypeViewType_UploadNoEditImage){
        ctrl.allowsEditing = YES;
    }
    if(type == 201){
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
//        ctrl.cameraOverlayView.backgroundColor = WHITE_COLOR;
    }else{
        [self setNavigationBar_white];
        ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self viewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [[self viewController] presentViewController:ctrl animated:YES completion:^{
        if(type==201){
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }];
}

#pragma mark -- UIImagePickerControllerDelegate
//点击相册中的图片 货照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setNavigationBar_kdefaultColor];
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    if(image.size.width != image.size.height && self.type != UploadImageTypeViewType_UploadNoEditImage){
        image = [UIImage resizeImageWithRect:image];
    }else{
        image = info[@"UIImagePickerControllerOriginalImage"];
    }
    if(self.type == UploadImageTypeViewType_UploadHeaderImage){
        [self uploadHeadImage:image];
    }else if(self.type == UploadImageTypeViewType_UploadNormalImage || self.type == UploadImageTypeViewType_UploadNoEditImage){
        if(self.uploadImageViewImage){
            self.uploadImageViewImage(image);
        }
        [self removeView];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self setNavigationBar_kdefaultColor];
    [self removeView];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNavigationBar_kdefaultColor{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:WHITE_COLOR,NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setNavigationBar_white{
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1))];
    [[UINavigationBar appearance] setTintColor:HEX_COLOR(@"383838")];
    [[UINavigationBar appearance] setBarTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"383838"),NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
}

//上传头像
- (void)uploadHeadImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud =
    [MBProgressHUD showMessag:@"上传头像中..." toView:[self viewController].view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [[[UIViewController alloc] init] requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            [weakSelf saveHeadImage:urlStr hud: hud];
        }else{
            [hud hideAnimated:YES];
            weakSelf.hidden = NO;
            [MBProgressHUD showError:@"头像上传失败" toView:weakSelf];
            if(weakSelf.uploadHeaderImageViewResult){
                weakSelf.uploadHeaderImageViewResult(NO);
            }
            [weakSelf removeView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.hidden = NO;
        [MBProgressHUD showError:@"头像上传失败" toView:weakSelf];
        if(weakSelf.uploadHeaderImageViewResult){
            weakSelf.uploadHeaderImageViewResult(NO);
        }
        [weakSelf removeView];
    }];
}

//更改头像
- (void)saveHeadImage:(NSString *)urlStr hud:(MBProgressHUD*)hud{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:urlStr forKey:@"headimg"];
    [[[UIViewController alloc] init] requstType:RequestType_Post apiName:API_NAME_MEMBER_SAVE_IMG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *tmpModel = [DataModelInstance shareInstance].userModel;
            tmpModel.image = urlStr;
            [DataModelInstance shareInstance].userModel = tmpModel;
            if(weakSelf.uploadHeaderImageViewResult){
                weakSelf.uploadHeaderImageViewResult(YES);
            }
        }else{
            weakSelf.hidden = NO;
            [MBProgressHUD showError:@"头像上传失败" toView:weakSelf];
            if(weakSelf.uploadHeaderImageViewResult){
                weakSelf.uploadHeaderImageViewResult(NO);
            }
        }
        [weakSelf removeView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.hidden = NO;
        [MBProgressHUD showError:@"头像上传失败" toView:weakSelf];
        if(weakSelf.uploadHeaderImageViewResult){
            weakSelf.uploadHeaderImageViewResult(NO);
        }
        [weakSelf removeView];
    }];
}

@end
