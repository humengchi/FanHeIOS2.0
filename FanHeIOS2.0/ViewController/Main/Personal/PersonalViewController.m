//
//  PersonalViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "PersonalViewController.h"
#import "SettingViewController.h"
#import "MyConnectionsController.h"
#import "ShowPersonalQRCodeViewController.h"
#import "InformationViewController.h"
#import "EditPersonalInfoViewController.h"
#import "MyTopicController.h"

#import "ShareCollectZanViewController.h"
#import "MyActivityController.h"
#import "TaskListViewController.h"
#import "MyCoffeeBeansController.h"

@interface PersonalViewController ()<UITableViewDelegate, UITableViewDataSource,EMChatManagerDelegate>{
    NSInteger _newMsgNum;
    NSInteger _unReadCount;
    NSInteger _topicCount;
    NSInteger _activityCount;
    NSInteger _taskCount;
}
@property (weak, nonatomic) IBOutlet UIButton *headerImageView;
@property (weak, nonatomic) IBOutlet UITableView *theTableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *coffeeBeansLabel;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray arrayWithObjects:
                      @{@"image":@"btn_my_information", @"name":@"我的资料"},
                    @{@"image":@"btn_sideslip_friends", @"name":@"我的人脉"},
                          @{@"image":@"btn_my_topic", @"name":@"我的话题"},
                       @{@"image":@"icon_event", @"name":@"我的活动"},
                      @{@"image":@"btn_my_message", @"name":@"消息"},
                      @{@"image":@"icon_my_misson", @"name":@"我的任务"},
                      @{@"image":@"btn_sideslip_set", @"name":@"设置"}, nil];
    [CALayer updateControlLayer:self.headerImageView.layer radius:30 borderWidth:2 borderColor:HEX_COLOR(@"AFB6C1").CGColor];
    self.theTableView.delegate = self;
    self.theTableView.dataSource = self;
    self.theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self updateDisplay];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteUserNewMsg) name:DeleteUserNewMsg object:nil];
}

- (void)deleteUserNewMsg{
    _newMsgNum = 0;
    _unReadCount = 0;
    _topicCount = 0;
    _activityCount = 0;
    [self.theTableView reloadData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDisplay{
    [self.headerImageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] forState:UIControlStateNormal placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    
    self.nameLabel.text = [DataModelInstance shareInstance].userModel.realname;
    self.nameLabel.userInteractionEnabled = YES;
    [self getMessagesCount];
    [self getUnReadNewMsgNumber];
    self.vipImageView.hidden = [DataModelInstance shareInstance].userModel.usertype.integerValue!=9;
    [self getCoffeeBeans];
}

#pragma mark -UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSDictionary *dict = self.dataArray[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 15, 18, 18)];
    imageView.image = kImageWithName(dict[@"image"]);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(55, 0, 70, 48) backColor:[UIColor clearColor] textColor:WHITE_COLOR test:dict[@"name"] font:14 number:1 nstextLocat:NSTextAlignmentLeft];
    [cell.contentView addSubview:titleLabel];
    
    if(indexPath.row == 0){
        UILabel *paramLabel = [UILabel createrLabelframe:CGRectMake(123, 0, 50, 48) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"D0D0D0") test:[NSString stringWithFormat:@"%ld%%",(long)[CommonMethod getUserInfoCompletionRate]] font:12 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:paramLabel];
    }else if (indexPath.row == 2||indexPath.row == 3){
        UILabel *unReadNotLabel = [UILabel createLabel:CGRectMake(124, 20, 8, 8) font:[UIFont systemFontOfSize:2] bkColor:[UIColor colorWithHexString:@"E24943"] textColor:[UIColor whiteColor]];
        NSInteger count;
        if(indexPath.row==2){
            count = _topicCount;
        }else{// if(indexPath.row==3)
            count = _activityCount;
        }
        if (count) {
            unReadNotLabel.hidden = NO;
        }else{
            unReadNotLabel.hidden = YES;
        }
        unReadNotLabel.layer.cornerRadius = 4.0;
        unReadNotLabel.layer.masksToBounds = YES;
        [cell.contentView addSubview:unReadNotLabel];
    }else if(indexPath.row==1||indexPath.row==4||indexPath.row==5){
        NSInteger count;
        if(indexPath.row==1){
            count = _newMsgNum;
        }else if(indexPath.row==4){
            count = _unReadCount;
        }else{
            count = _taskCount;
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.theTableView.frame.size.width-87, 17, 62, 14)];
            iconImageView.image = kImageWithName(@"btn_my_ykfd");
            [cell.contentView addSubview:iconImageView];
        }
        if(count){
            NSString *numStr;
            if(count>99){
                numStr = @"99";
            }else{
                numStr = [NSString stringWithFormat:@"%ld", (long)count];
            }
            CGFloat strWidth = [NSHelper widthOfString:numStr font:FONT_SYSTEM_SIZE(14) height:18 defaultWidth:8]+10;
            UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(indexPath.row==4?95:123, 15, strWidth, 18) backColor:HEX_COLOR(@"E24943") textColor:HEX_COLOR(@"F8F8F8") test:numStr font:14 number:1 nstextLocat:NSTextAlignmentCenter];
            [cell.contentView addSubview:numLabel];
            [CALayer updateControlLayer:numLabel.layer radius:9 borderWidth:0 borderColor:nil];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.sideMenuViewController hideMenuViewController];
        EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
        vc.savePersonalInfoSuccess = ^{
            [self updateDisplay];
        };
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 1) {
        [self.sideMenuViewController hideMenuViewController];
        MyConnectionsController *vc = [[MyConnectionsController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 2) {
        [self.sideMenuViewController hideMenuViewController];
        MyTopicController *vc = [[MyTopicController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 3) {
        [self.sideMenuViewController hideMenuViewController];
        MyActivityController *vc = [[MyActivityController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 4) {
        [self.sideMenuViewController hideMenuViewController];
        InformationViewController *vc = [[InformationViewController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 5) {
        [self.sideMenuViewController hideMenuViewController];
        TaskListViewController *vc = [[TaskListViewController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }else if (indexPath.row == 6) {
        [self.sideMenuViewController hideMenuViewController];
        SettingViewController *vc = [[SettingViewController alloc]init];
        [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
    }
}

#pragma mark - 获取新好友请求和关注消息数量
- (void)getMessagesCount{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_NEW_MSG_COUNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dict = [responseObject objectForKey:@"data"];
            NSNumber *attention = [dict objectForKey:@"attention"];
            NSNumber *notecount = [dict objectForKey:@"notecount"];
            NSNumber *vpcount = [dict objectForKey:@"vpcount"];
            NSNumber *newapplycount = [dict objectForKey:@"newapplycount"];
            NSNumber *newaskcount = [dict objectForKey:@"newaskcount"];
            NSNumber *taskcount = [dict objectForKey:@"taskcount"];
            _newMsgNum = attention.integerValue;
            _topicCount = notecount.integerValue+vpcount.integerValue;
            _activityCount = newaskcount.integerValue+newapplycount.integerValue;
            _taskCount = taskcount.integerValue;
        }else{
            _newMsgNum = 0;
        }
        [weakSelf.theTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _newMsgNum = 0;
        [weakSelf.theTableView reloadData];
    }];
}

#pragma mark - 我的咖啡豆数量
- (void)getCoffeeBeans{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_MYCOFFEEBEANS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSNumber *coffeeBeans = @(0);
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            coffeeBeans = [CommonMethod paramNumberIsNull:responseObject[@"data"][@"cb"]];
            [DataModelInstance shareInstance].coffeeBeans = coffeeBeans;
        }
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", coffeeBeans]];
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = kImageWithName(@"icon_kfd_bg");
        attchImage.bounds = CGRectMake(4, -1, 13, 15);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr appendAttributedString:stringImage];
        weakSelf.coffeeBeansLabel.attributedText = attriStr;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:@"0"];
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = kImageWithName(@"icon_kfd_bg");
        attchImage.bounds = CGRectMake(4, 0, 13, 15);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr appendAttributedString:stringImage];
        weakSelf.coffeeBeansLabel.attributedText = attriStr;
    }];
}

#pragma mark - 未读消息数量
- (void)getUnReadNewMsgNumber{
    _unReadCount = 0;
    for (EMConversation *conversation in [[EMClient sharedClient].chatManager getAllConversations]){
        _unReadCount += conversation.unreadMessagesCount;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = _unReadCount;
}

#pragma mark - 跳转按钮
- (IBAction)gotoWallCoffeeButtonClicked:(UIButton *)sender {
    [self.sideMenuViewController hideMenuViewController];
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:[CommonMethod getVCFromNib:[ShareCollectZanViewController class]]];
}

- (IBAction)showScaningCtr:(UITapGestureRecognizer *)sender {
    [self.sideMenuViewController hideMenuViewController];
    ShowPersonalQRCodeViewController *vc = [CommonMethod getVCFromNib:[ShowPersonalQRCodeViewController class]];
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

- (IBAction)gotoPersonalCodeButtonClicked:(id)sender{
    [self.sideMenuViewController hideMenuViewController];
    ShowPersonalQRCodeViewController *vc = [CommonMethod getVCFromNib:[ShowPersonalQRCodeViewController class]];
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

- (IBAction)gotoMyHomePageCtr:(UITapGestureRecognizer *)sender {
    [self.sideMenuViewController hideMenuViewController];
    NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
    vc.userId = [DataModelInstance shareInstance].userModel.userId;
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

- (IBAction)gotoMyHomeButtonClicked:(UIButton *)sender {
    [self.sideMenuViewController hideMenuViewController];
    NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
    vc.userId = [DataModelInstance shareInstance].userModel.userId;
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

- (IBAction)gotoTaskListButtonClicked:(UIButton *)sender {
    [self.sideMenuViewController hideMenuViewController];
    TaskListViewController *vc = [[TaskListViewController alloc]init];
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

- (IBAction)gotoCoffeeBeansButtonClicked:(UIButton *)sender {
    [self.sideMenuViewController hideMenuViewController];
    MyCoffeeBeansController *vc = [[MyCoffeeBeansController alloc] init];
    [[AppDelegate shareInstance] gotoOtherViewControllerFromPersonal:vc];
}

#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages{
    [self updateDisplay];
}

#pragma mark -------  透传广告消息
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for(EMMessage *message in aCmdMessages){
        if ([message.from isEqualToString:@"jm_assistant"]){
            NSDictionary *dict = message.ext;
            NSNumber *type = dict[@"type"];
            if(type.integerValue == 2){
                [self getMessagesCount];
            }
        }
    }
}
@end
