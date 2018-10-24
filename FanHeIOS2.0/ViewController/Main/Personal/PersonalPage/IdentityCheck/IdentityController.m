//
//  IdentityController.m
//  JinMai
//
//  Created by renhao on 16/5/12.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "IdentityController.h"
#import "ReviewController.h"
#import "BaseTabbarViewController.h"
#import "PassReviewController.h"

@interface IdentityController ()
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *upPhoneView;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverHeaderImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIButton *showUpPhoneBtn;
@property (strong , nonatomic) UIButton *upPhoneBtn;
@property (nonatomic ,assign) CGFloat heigth;
@property (nonatomic ,assign) CGFloat weidth;
@property (nonatomic ,strong)UIImage *showImage;
@property (nonatomic,assign)CGFloat belielSize;
@property (nonatomic,strong)NSString *uid;
@property (nonatomic,strong)NSString *url;
@property (nonatomic ,assign) CGFloat theigth;
@property (nonatomic ,assign) CGFloat tweidth;

@property (nonatomic, assign) BOOL isPushVC;
@end

@implementation IdentityController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
    self.isPushVC = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if(self.isPushVC==NO&&[self.rootTmpViewController isKindOfClass:[BaseTabbarViewController class]]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (self.navigationController.childViewControllers.count == 1){
        return NO;
    }
    //向左滑动
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translatedPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        if(translatedPoint.x < 0 || translatedPoint.y){
            return NO;
        }
        if([gestureRecognizer locationInView:self.view].x>50){
            return NO;
        }
    }
    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    if([vc isKindOfClass:[ReviewController class]] || [vc isKindOfClass:[PassReviewController class]]){
        return NO;
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self initScrollView:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = HEX_COLOR(@"F6F6F6");
    self.scrollView.scrollEnabled = YES;
    self.mainView.frame = CGRectMake(0, 0, WIDTH, 162);
    
    [self.scrollView addSubview:self.mainView];
    
    [self createrViewUpPhoneView];
    
    self.nameLabel.text = [DataModelInstance shareInstance].userModel.realname;
    
    self.postLabel.text = [NSString stringWithFormat:@"%@%@",[DataModelInstance shareInstance].userModel.company, [DataModelInstance shareInstance].userModel.position];
    self.coverHeaderImageView.layer.masksToBounds=YES;
    self.coverHeaderImageView.layer.cornerRadius=15;
    [self.coverHeaderImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    [self createrIdTabBerView];
}

#pragma mark -------  创建导航
- (void)createrIdTabBerView{
    UIView *tabBarView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    tabBarView.backgroundColor = HEX_COLOR(@"4393E2");
    [self.view addSubview:tabBarView];
    UIButton *backBtn = [NSHelper createButton:CGRectMake(0,20 , 44, 44) title:nil unSelectImage:[UIImage imageNamed:@"btn_reture_white"] selectImage:nil target:self selector:@selector(backButtonClicked:)];
    
    [tabBarView addSubview:backBtn];
    UILabel *titleTabBaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 26, WIDTH, 30)];
    titleTabBaeLabel.text = @"身份认证";
    titleTabBaeLabel.textColor = [UIColor whiteColor];
    titleTabBaeLabel.textAlignment = NSTextAlignmentCenter;
    [tabBarView addSubview:titleTabBaeLabel];
}

//返回
- (void)backButtonClicked:(id)sender {
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.rootTmpViewController){
        [self.navigationController popToViewController:self.rootTmpViewController animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)createrViewUpPhoneView{
    [self.upPhoneBtn removeFromSuperview];
    UIImageView *imageviewRe = [self.upPhoneView viewWithTag:100100];
    [imageviewRe removeFromSuperview];
    
    self.upPhoneView.frame = CGRectMake(0, 213, WIDTH , (WIDTH-50)*190/325+130);
    [self.scrollView addSubview:self.upPhoneView];
    self.showUpPhoneBtn.adjustsImageWhenHighlighted = NO;
    [self.showUpPhoneBtn addTarget:self action:@selector(upPhoneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    self.upPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.heigth != 0){
        self.showUpPhoneBtn.hidden = YES;
        CGFloat imageHeigth;
        CGFloat imageWidth;
        if (self.belielSize > 0){
            imageHeigth =self.heigth - self.belielSize*self.heigth;
            imageWidth = self.upPhoneView.frame.size.width-32;
            
        }else{
            imageHeigth = self.heigth;
            imageWidth = self.weidth;
        }
        
        self.theigth = WIDTH - 50;
        self.tweidth = WIDTH - 50;
        UIImageView *edginImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 76, imageWidth+2, imageHeigth+2)];
        edginImageView.tag = 100100;
        [self.upPhoneView addSubview:edginImageView];
        
        UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(1,1,self.theigth,self.theigth)];
        showImageView.layer.masksToBounds = YES; //没这句话它圆不起来
        showImageView.layer.cornerRadius = 8.0; //设置图片圆角的尺度
        showImageView.image = self.showImage;
        [edginImageView addSubview:showImageView];
        
        UILabel *showLabel = [UILabel createrLabelframe:CGRectMake(self.theigth-140, self.theigth-35, 130, 25) backColor:[HEX_COLOR(@"040000") colorWithAlphaComponent:0.6] textColor:WHITE_COLOR test:@"点击图片重新上传" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
        showLabel.layer.cornerRadius = 5;
        showLabel.layer.masksToBounds = YES;
        [edginImageView addSubview:showLabel];
        
        self.upPhoneView.frame = CGRectMake(0, 213, WIDTH , 304 -190 + self.theigth);
        self.upPhoneBtn.enabled = YES;
        self.upPhoneBtn.backgroundColor = kDefaultColor;
        edginImageView.userInteractionEnabled = YES;
        showImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(upPhoneBtnAction)];
        [showImageView addGestureRecognizer:g];
    }else{
        self.showUpPhoneBtn.hidden = NO;
        self.upPhoneBtn.enabled = NO;
        self.upPhoneBtn.backgroundColor = HEX_COLOR(@"D7D7D7");
    }
    
    self.upPhoneBtn.frame = CGRectMake(25, self.upPhoneView.frame.size.height + self.upPhoneView.frame.origin.y + 30, WIDTH - 50, 50);
    
    [self.upPhoneBtn addTarget:self action:@selector(postPhoneIfmartion:) forControlEvents:UIControlEventTouchUpInside];
    [self.upPhoneBtn setTitle:@"提交认证" forState:UIControlStateNormal];
    [self.upPhoneBtn.layer setMasksToBounds:YES];
    [self.upPhoneBtn.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
    
    [self.scrollView addSubview:self.upPhoneBtn];
    self.scrollView.contentSize = CGSizeMake(WIDTH, self.upPhoneBtn.frame.origin.y + self.upPhoneBtn.frame.size.height + 10);
}

- (void)upPhoneBtnAction{
    self.isPushVC = YES;
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    view.isIndentify = YES;
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    view.uploadImageViewImage = ^(UIImage *image){
        weakSelf.showImage = image;
        [weakSelf upPhoneImage];
    };
    view.cancleLoadImageViewType = ^(){
        weakSelf.isPushVC = NO;
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

- (void)upPhoneImage{
    //图片的的大小
    self.heigth = self.showImage.size.height;
    self.weidth = self.showImage.size.width;
   
    if (self.upPhoneView.frame.size.width-32 < self.weidth) {
        self.belielSize = (self.weidth - self.upPhoneView.frame.size.width-32)/self.weidth;
    }else{
        self.belielSize = (( (self.upPhoneView.frame.size.width-32)-self.weidth)/(self.upPhoneView.frame.size.width-32));
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    UIImage *newImage = self.showImage;//[self.showImage scaleToSize:WIDTH-50];
    NSData *imageData =  UIImageJPEGRepresentation(newImage, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        NSString *str = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if([str isEqualToString:@"1"]){
            self.url = [responseObject objectForKey:@"msg"];
            [self createrViewUpPhoneView];
        }else{
            [MBProgressHUD showError:@"图片上传失败" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:self.view];
    }];
}

- (void)postPhoneIfmartion:(UIButton *)btn{
    self.uid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.uid forKey:@"userid"];
    [requestDict setObject:self.url forKey:@"authenti_image"];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    
    [self requstType:RequestType_Post apiName:API_NAME_MEMBER_POST_SUBMIT_MYCARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        NSString *str = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if([str isEqualToString:@"1"]){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.authenti_image = self.url;
            model.hasValidUser = @(2);
            [DataModelInstance shareInstance].userModel = model;
            if ([self.idDelegate respondsToSelector:@selector(referImageView:)]) {
                [self.idDelegate referImageView:self.showImage];
            }
            ReviewController *review = [[ReviewController alloc]init];
            review.urlImage = self.url;
            review.rootTmpViewController = self.rootTmpViewController;
            [self.navigationController pushViewController:review animated:YES];
        }else{
            [MBProgressHUD showError:@"提交失败,请重新提交" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
         [MBProgressHUD showError:@"提交失败,请重新提交" toView:self.view];
    }];
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        scrollView.scrollEnabled = NO;
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        scrollView.scrollEnabled = YES;
    }else{
        scrollView.scrollEnabled = YES;
    }
}


@end
