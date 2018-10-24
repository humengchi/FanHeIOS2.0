//
//  PassReviewController.m
//  JinMai
//
//  Created by renhao on 16/5/13.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "PassReviewController.h"
#import "IdentityController.h"
#import "BaseTabbarViewController.h"

@interface PassReviewController ()<IdentityControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *hederView;
@property (strong, nonatomic) IBOutlet UIView *reviewView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;

@end

@implementation PassReviewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if([self.rootTmpViewController isKindOfClass:[BaseTabbarViewController class]]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createrView:nil];
   
}

- (void)referImageView:(UIImage *)image{
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    _urlImage = nil;
    [self createrView:image];
    
}

- (void)createrView:(UIImage *)image{
    [self initScrollView:CGRectMake(0, 0, WIDTH, HEIGHT)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.scrollView.scrollEnabled = YES;
    [self.scrollView addSubview:self.hederView];
    self.hederView.frame = CGRectMake(0, 0, WIDTH, 207);
    self.nameLabel.text = [DataModelInstance shareInstance].userModel.realname;
    self.postLabel.text = [NSString stringWithFormat:@"%@%@",[DataModelInstance shareInstance].userModel.company, [DataModelInstance shareInstance].userModel.position];
    self.coverImageView.backgroundColor = [UIColor redColor];
    self.coverImageView.layer.masksToBounds=YES;
    self.coverImageView.layer.cornerRadius=15;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];

    if(_urlImage.length != 0){
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_urlImage]];
        self.showImage  = [UIImage imageWithData:imageData];
        self.width = WIDTH -50;
        self.heigth = WIDTH -50;
        
        if (self.reviewView.frame.size.width < self.width) {
            self.rate = ((self.width - (self.reviewView.frame.size.width))/self.width);
        }else{
            self.rate = (( (self.reviewView.frame.size.width)-self.width)/(self.reviewView.frame.size.width));
        }
        self.heigth =self.heigth - self.rate*self.heigth;
    }else{
        self.showImage  = image;
        self.width = WIDTH -50;
        self.heigth = WIDTH -50;
        
        if (self.reviewView.frame.size.width < self.width) {
            self.rate = ((self.width - (self.reviewView.frame.size.width))/self.width);
        }else{
            self.rate = (( (self.reviewView.frame.size.width)-self.width)/(self.reviewView.frame.size.width));
        }
        self.heigth =self.heigth - self.rate*self.heigth;
    }
    
    self.reviewView.frame = CGRectMake(0, 213, WIDTH, 120+self.heigth);
    
    UIImageView *edginImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 77, self.width, self.heigth+2)];
//    edginImageView.image = [UIImage imageNamed:@"bg_rz_box"];
    [self.reviewView addSubview:edginImageView];
    
    UIImageView *showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(1,1,self.width - 2,self.heigth)];
    showImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    showImageView.layer.cornerRadius = 8.0; //设置图片圆角的尺度
    showImageView.image = self.showImage;
    [edginImageView addSubview:showImageView];
    
    
    UIImageView *tagImageView = [UIImageView drawImageViewLine:CGRectMake(edginImageView.frame.size.width - 104, 15, 104, 23) bgColor:[UIColor clearColor]];
    tagImageView.image = [UIImage imageNamed:@"icon_card_authorized"];
    [showImageView addSubview:tagImageView];
    
    UILabel *tagLabel = [UILabel createLabel:CGRectMake(0, 4, 104, 15) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"FFFFFF"]];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.text = @"认证成功";
    [tagImageView addSubview:tagLabel];
    
    [self.scrollView addSubview:self.reviewView];
    
    self.scrollView.contentSize = CGSizeMake(WIDTH, 152+self.reviewView.frame.size.height+self.reviewView.frame.origin.y);
    
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"如信息有误，请重新提交材料 >>"];
    
    UILabel *sideLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.reviewView.frame.size.height+self.reviewView.frame.origin.y+18, WIDTH, 20)];
    sideLabel.textAlignment = NSTextAlignmentCenter;
    sideLabel.textColor = HEX_COLOR(@"818C9E");
    sideLabel.attributedText = str;
    sideLabel.font = [UIFont systemFontOfSize:13];
    [self.scrollView addSubview:sideLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reverUpPhone)];
    sideLabel.userInteractionEnabled = YES;
    [sideLabel addGestureRecognizer:tap];
    [self createrReTabBerView];
}
#pragma mark -------  创建导航
- (void)createrReTabBerView{
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

- (void)reverUpPhone{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"重新提交后您的身份将重新认证" cancelButtonTitle:@"取消" otherButtonTitle:@"确认" cancle:^{
    } confirm:^{
        NSString *uid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
        
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        
        [requestDict setObject:uid forKey:@"userid"];
        
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
        
        [self requstType:RequestType_Post apiName:API_NAME_MEMBER_POST_CHANGE_MYPHONTEHEADE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            NSString *str = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
            if([str isEqualToString:@"1"]){
                IdentityController  *vc = [[IdentityController alloc]init];
                vc.idDelegate = self;
                vc.rootTmpViewController = self.rootTmpViewController;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [MBProgressHUD showError:@"网络出错" toView:self.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
        }];
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
