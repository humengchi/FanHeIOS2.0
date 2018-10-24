//
//  JionQRcodeGroupViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/22.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "JionQRcodeGroupViewController.h"
#import "MessageSidViewController.h"
@interface JionQRcodeGroupViewController ()
@property (nonatomic ,strong)  EMGroup *group;
@property (nonatomic ,strong) ChartModel *model;
@end

@implementation JionQRcodeGroupViewController
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
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self createCustomNavigationBar:@"加入群聊"];
      [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
        self.group = aGroup;
      NSLog(@"%@  --  %@",self.groupID,self.group.owner);
//      26508734300162
         [self getGroupOwenNameAndHeader];
  }];

   
    // Do any additional setup after loading the view.
}
- (void)getGroupOwenNameAndHeader{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
   [requestDict setObject:self.group.owner forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_CHECKUSER_HEADERANDNAME paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];

            for(NSDictionary *dict in tmpArray){
               self.model = [[ChartModel alloc] initWithDict:dict];
                
            }
            [self cretaerGroupView];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

- (void)cretaerGroupView{
    CGFloat heigth = [NSHelper heightOfString:self.group.description font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth > 0) {
      heigth =   heigth + 28;
    }
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, 70, WIDTH, 72+ heigth) backColor:@"ffffff"];
    [self.view addSubview:backView];
    UIImageView *coverImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 44, 44)];
    coverImageView.layer.cornerRadius = 22;
    coverImageView.layer.masksToBounds = YES;
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:kImageWithName(@"头像")];
    [backView addSubview:coverImageView];
    UILabel *groupNameLabel = [UILabel createLabel:CGRectMake(70, 17, WIDTH - 70 - 17, 42) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    groupNameLabel.numberOfLines = 2;
    groupNameLabel.text = self.group.subject;
    [backView addSubview:groupNameLabel];
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 71.5, WIDTH, 0.5)];
    label3.backgroundColor = kCellLineColor;
    [backView addSubview:label3];
    
    UILabel *descriptionLabel = [UILabel createLabel:CGRectMake(70, 84, WIDTH - 32, heigth) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.text = self.group.description;
    [backView addSubview:descriptionLabel];

    UIView *footView = [NSHelper createrViewFrame:CGRectMake(0, 70 + 72+ heigth + 10, WIDTH, 122) backColor:@"ffffff"];
    [self.view addSubview:footView];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 16, 50, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.text = @"群主";
    [footView addSubview:titleLabel];
    UILabel *nameLabel = [UILabel createLabel:CGRectMake(70, 16, WIDTH - 70 - 16, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    nameLabel.text = self.model.realname;
    [footView addSubview:nameLabel];
    UILabel *countLabel = [UILabel createLabel:CGRectMake(16, 88, 50, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    countLabel.text = @"群成员";
    [footView addSubview:countLabel];
    
    UILabel *countLabelShow = [UILabel createLabel:CGRectMake(70, 88, WIDTH - 86, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    countLabelShow.text = [NSString stringWithFormat:@"%ld人",self.group.occupants.count];
    [footView addSubview:countLabelShow];
    
    
    UIButton *quitBtn =  [NSHelper createButton:CGRectMake(62, footView.frame.size.height + 70 + 72+ heigth + 10 + 32, WIDTH - 124, 40) title:@"进入群聊" unSelectImage:[UIImage imageNamed:@""] selectImage:nil target:self selector:@selector(joinGroupBtnAction:)];
    [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_rm_off_red"] forState:UIControlStateNormal];
    [footView addSubview:quitBtn];


}
- (void)joinGroupBtnAction:(UIButton *)btn{
    EMError *error = nil;
    [[EMClient sharedClient].groupManager addOccupants:@[@""] toGroup:self.groupID welcomeMessage:@"欢迎加入群聊" error:&error];
    if (!error) {
        MessageSidViewController *chatController = [[MessageSidViewController alloc] initWithConversationChatter:self.groupID conversationType:EMConversationTypeGroupChat];
        chatController.isMakeGroup = YES;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
