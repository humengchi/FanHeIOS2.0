

//
//  SendFriendsDetailsController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SendFriendsDetailsController.h"
#import "WJTimeCircle.h"

#define TOTAL_TIME 60

@interface SendFriendsDetailsController ()
@property (weak, nonatomic) IBOutlet UIView *caryBgView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *goodAtLabel;

@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *sideIamgeView;
@property (weak, nonatomic) IBOutlet UILabel *mystateLabel;
@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UIButton *notAccesptBtn;
@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;

@property (nonatomic,strong)ContactsModel * contactsModel;
@end

@implementation SendFriendsDetailsController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.bgView.frame = CGRectMake(0, 0, WIDTH, 468);
    [self.scrollView addSubview:self.bgView];
    [self.scrollView setContentSize:CGSizeMake(WIDTH, HEIGHT)];
    [self createCustomNavigationBar:@"好友申请详情"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self getSendDetailGoodFriendsList];
    
    [CALayer updateControlLayer:self.notAccesptBtn.layer radius:4 borderWidth:.5 borderColor:kCellLineColor.CGColor];
    self.caryBgView.layer.masksToBounds = YES; //没这句话它圆不起来
    self.caryBgView.userInteractionEnabled = YES;
    self.caryBgView.layer.cornerRadius = 10; //设置图片圆角的尺度
    self.caryBgView.layer.borderColor = WHITE_COLOR.CGColor;
    self.caryBgView.layer.borderWidth = 0.5;
    self.headerImageVIew.userInteractionEnabled = YES;
    self.headerImageVIew.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageVIew.layer.cornerRadius = 47; //设置图片圆角的尺度
}

#pragma mark --- 网络请求数据
- (void)getSendDetailGoodFriendsList{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.otherID] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_FR_REQUEST_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *subDic = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            self.contactsModel = [[ContactsModel alloc] initWithDict:subDic];
            [self createrViewModel:self.contactsModel];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)createrViewModel:(ContactsModel *)model{
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    [self.headerImageVIew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ | %@ | %@ ",model.realname,model.city,model.workyearstr];
    self.companyLabel.text = model.company;
    self.positionLabel.text = model.position;
    self.goodAtLabel.text = [NSString stringWithFormat:@"#%@#",[model.goodjob componentsJoinedByString:@"# #"]];
   
    self.mystateLabel.text = model.mystate.length?model.mystate:@"Ta很懒,什么都没有写";
    CGFloat mystateHeight = [NSHelper heightOfString:self.mystateLabel.text font:FONT_SYSTEM_SIZE(12) width:WIDTH-100 defaultHeight:12];
    if(mystateHeight>30){
        mystateHeight = 30;
    }
    //删除个人动态
    mystateHeight = -15;
    if(model.count.integerValue != 0 && model.userArray.count > 0){
        CGFloat start_x = 0;
        for(int i=0; i<model.userArray.count; i++){
            NSString *imageStr = model.userArray[i];
            start_x = 16*i;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x, 18, 20, 20)];
            [CALayer updateControlLayer:imageView.layer radius:10 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
            if(i == 4 && model.count.integerValue != 5){
                imageView.image = kImageWithName(@"icon_index_rmgd");
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:KHeadImageDefault];
            }
            [self.friendsView addSubview:imageView];
            if(i==4){
                break;
            }
        }
        UILabel *label = [UILabel createLabel:CGRectMake(start_x+26, 18, 100, 20) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        label.text = [NSString stringWithFormat:@"%@个共同好友",model.count];
        [self.friendsView addSubview:label];
        mystateHeight += 57;
    }
    
    CGFloat sizeHeigth = [NSHelper heightOfString:model.reason font:[UIFont systemFontOfSize:14] width:self.caryBgView.frame.size.width - 50];
    CGRect frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    CGFloat heigth = 279+mystateHeight;
    
    UIView *textBgView = [NSHelper createrViewFrame:CGRectMake(0, heigth-2, WIDTH-50, 45+sizeHeigth+2) backColor:@"ffffff"];
    [self.caryBgView addSubview:textBgView];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    lineView.backgroundColor = HEX_COLOR(@"F7F7FA");
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.3)];
    lineLabel1.backgroundColor = kCellLineColor;
    [lineView addSubview:lineLabel1];
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 4.7, WIDTH, 0.3)];
    lineLabel2.backgroundColor = kCellLineColor;
    [lineView addSubview:lineLabel2];
    [textBgView addSubview:lineView];
    
    UserModel *usermodel = [DataModelInstance shareInstance].userModel;
    CGFloat start_Y = 21;
    if(usermodel.hasaskcheck.integerValue==1){
        UIImageView *questImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 21, 36, 36)];
        questImage.image = kImageWithName(@"icon_questions");
        [textBgView addSubview:questImage];
        NSString *str = usermodel.askcheck.length?usermodel.askcheck:usermodel.asksubject;
        UILabel *questlabel = [UILabel createrLabelframe:CGRectMake(55, 21, WIDTH-120, 36) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:str font:14 number:2 nstextLocat:NSTextAlignmentLeft];
        [textBgView addSubview:questlabel];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 67, WIDTH-82, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [textBgView addSubview:lineLabel];
        start_Y += 60;
        textBgView.frame = CGRectMake(0, heigth-2, WIDTH-50, 45+sizeHeigth+2+60);
        heigth += 60;
    }
    
    UIImageView *quotImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, start_Y, 11, 10)];
    quotImage.image = kImageWithName(@"icon_zy_yh");
    [textBgView addSubview:quotImage];
    
    UILabel *textLabel = [UILabel createLabel:CGRectMake(34, start_Y,textBgView.frame.size.width - 50, sizeHeigth) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    textLabel.text = model.reason;
    textLabel.numberOfLines = 0;
    [textBgView addSubview:textLabel];
    
    frame.size.height = heigth + sizeHeigth + 45 +36*4;
    frame.size.width = WIDTH;
    self.bgView.frame = frame;
    [self.scrollView addSubview:self.bgView];
    [self.scrollView setContentSize:CGSizeMake(WIDTH, frame.size.height)];
}

#pragma maek --------  忽略-- 添加好友
- (IBAction)silpBtnAction:(UIButton *)btn{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发送中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"%@",self.contactsModel.cardrequestid] forKey:@"id"];
    if (btn.tag == 201) {
        [requestDict setObject:@"1" forKey:@"isaccept"];
    }
    if (btn.tag == 202) {
        [requestDict setObject:@"2" forKey:@"isaccept"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_AGREEADDFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (btn.tag == 1) {
                [MBProgressHUD showSuccess:@"已忽略" toView:self.view];
            }
            if (btn.tag == 2) {
                [MBProgressHUD showSuccess:@"添加好友成功" toView:self.view];
            }
            if(weakSelf.addFriendsSuccess){
                weakSelf.addFriendsSuccess(YES);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)tapHisMessageAction:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
    home.userId = self.otherID;
    [self.navigationController pushViewController:home animated:YES];
}

- (IBAction)gotoTaPageCtr:(id)sender {
    NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
    home.userId = self.otherID;
    [self.navigationController pushViewController:home animated:YES];
}

- (void)setLabelTextAttri:(UILabel*)label text:(NSString*)text{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:text];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, text.length-2)];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(text.length-2, 2)];
    [label setAttributedText:AttributedStr];
}

- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
