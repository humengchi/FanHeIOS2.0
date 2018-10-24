//
//  TopicIdentifyViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TopicIdentifyViewController.h"
#import "EditPersonalInfoViewController.h"
#import "IdentityController.h"

@interface TopicIdentifyViewController ()

@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *showHudLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UIButton *userNameBtn;
@property (nonatomic, weak) IBOutlet UIButton *companyBtn;
@property (nonatomic, weak) IBOutlet UIButton *positionBtn;
@property (nonatomic, weak) IBOutlet UIButton *headerImageBtn;
@property (nonatomic, weak) IBOutlet UIButton *rzBtn;

@property (nonatomic, weak) IBOutlet UILabel *finishInfoLabel;

@end

@implementation TopicIdentifyViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
    [self updateUserInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    [CALayer updateControlLayer:self.rzBtn.layer radius:5 borderWidth:0 borderColor:nil];
    switch (self.publishType) {
        case PublishType_Topic:
            self.subTitleLabel.text = @"发起话题前请先完善";
            [self createCustomNavigationBar:@"创建话题"];
            break;
        case PublishType_Viewpoint:
            self.subTitleLabel.text = @"发起观点前请先完善";
            [self createCustomNavigationBar:@"发表观点"];
            break;
        case PublishType_Activity:
            self.subTitleLabel.text = @"发布活动前请先完善";
            [self createCustomNavigationBar:@"发布活动"];
            break;
        case JoinType_Action:
            self.subTitleLabel.text = @"报名前请先完善请先完善";
            [self createCustomNavigationBar:@"报名活动"];
            break;
        case PublishType_Review:
            self.subTitleLabel.text = @"发起评论前请先完善";
            [self createCustomNavigationBar:@"发表评论"];
            break;
        case PublishType_Dynamic:
            self.subTitleLabel.text = @"发布动态前请先完善";
            [self createCustomNavigationBar:@"发布动态"];
            break;
            
        default:
            break;
    }
}

- (void)updateUserInfo{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    self.userNameBtn.selected = model.realname.length>0;
    self.companyBtn.selected = model.company.length>0;
    self.positionBtn.selected = model.position.length>0;
    self.headerImageBtn.selected = model.image.length>0;
    self.finishInfoLabel.hidden = YES;
    if(![CommonMethod getUserCanPublishTopicOrReview]){
        [self setshowHudLabelText:NSMakeRange(0, 4)];
        [self.rzBtn setTitle:@"立即完善" forState:UIControlStateNormal];
        [self.rzBtn setBackgroundColor:HEX_COLOR(@"e24943")];
        self.rzBtn.userInteractionEnabled = YES;
        self.iconImageView.image = kImageWithName(@"icon_authentication_identity");
        self.finishInfoLabel.hidden = NO;
    }else if(model.hasValidUser.integerValue==2){
        [self setshowHudLabelText:NSMakeRange(7, 4)];
        [self.rzBtn setTitle:@"审核中" forState:UIControlStateNormal];
        [self.rzBtn setBackgroundColor:HEX_COLOR(@"f76b1c")];
        self.rzBtn.userInteractionEnabled = NO;
        self.iconImageView.image = kImageWithName(@"icon_authentication");
    }else{
        [self setshowHudLabelText:NSMakeRange(7, 4)];
        [self.rzBtn setTitle:@"立即认证" forState:UIControlStateNormal];
        [self.rzBtn setBackgroundColor:HEX_COLOR(@"1abc9c")];
        self.rzBtn.userInteractionEnabled = YES;
        self.iconImageView.image = kImageWithName(@"icon_authentication");
    }
}

- (void)setshowHudLabelText:(NSRange)range{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"个人资料 和 身份认证"];
    [attr setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEX_COLOR(@"e24943"),NSForegroundColorAttributeName, nil] range:range];
    self.showHudLabel.attributedText = attr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--完善资料
- (IBAction)editInfoAction:(UIButton *)sender {
    if([CommonMethod getUserCanPublishTopicOrReview]){
        IdentityController *vc = [CommonMethod getVCFromNib:[IdentityController class]];
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        __weak typeof(self) weakSelf = self;
        EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
        vc.savePersonalInfoSuccess = ^(){
            [weakSelf updateUserInfo];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
