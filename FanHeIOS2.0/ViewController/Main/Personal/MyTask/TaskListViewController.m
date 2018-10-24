//
//  TaskListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TaskListViewController.h"
#import "NONetWorkTableViewCell.h"
#import "TaskCell.h"
#import "MyCoffeeBeansController.h"

@interface TaskListViewController (){
    BOOL _noNetWork;
}

@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSNumber *sign;//是否签到
@property (nonatomic, strong) NSNumber *coffeeBeans;//咖啡豆数量

@end

@implementation TaskListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self loadTaskListHttpData];
    //完成开启通知任务调接口
    [self finishOpenNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sign = @(1);
    self.coffeeBeans = @(0);
    self.taskArray = [NSMutableArray array];
    [self createCustomNavigationBar];

    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.separatorColor = kCellLineColor;
    [self initTableHeaderView];
}

- (void)createCustomNavigationBar{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    barView.backgroundColor = HEX_COLOR(@"e24943");
    [self.view addSubview:barView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:kImageWithName(@"btn_reture_white") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(customNavBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backBtn];
}

- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -初始化列表头
- (void)initTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 170)];
    headerView.backgroundColor = HEX_COLOR(@"e24943");
    
    UILabel *titleLabel1 = [UILabel createrLabelframe:CGRectMake(0, 6, WIDTH, 18) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"每日任务赢取咖啡豆" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel1];
    UILabel *titleLabel2 = [UILabel createrLabelframe:CGRectMake(0, 32, WIDTH, 18) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"赢取更多特权" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [headerView addSubview:titleLabel2];
    
    UIButton *signinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signinBtn.frame = CGRectMake((WIDTH-150)/2, 62, 150, 40);
    signinBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    if(self.sign.integerValue==0){
        [signinBtn setBackgroundImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, 150, 40)) forState:UIControlStateNormal];
        NSMutableAttributedString *btnAttriStr = [[NSMutableAttributedString alloc] initWithString:@"今日签到 1"];
        [btnAttriStr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"e24943")} range:NSMakeRange(0, 6)];
        NSTextAttachment *btnAttchImage = [[NSTextAttachment alloc] init];
        btnAttchImage.image = kImageWithName(@"icon_kfd_red");
        btnAttchImage.bounds = CGRectMake(2, -2, 13, 15);
        NSAttributedString *btnStringImage = [NSAttributedString attributedStringWithAttachment:btnAttchImage];
        [btnAttriStr appendAttributedString:btnStringImage];
        [signinBtn setAttributedTitle:btnAttriStr forState:UIControlStateNormal];
        [signinBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
        [signinBtn addTarget:self action:@selector(signInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [signinBtn setBackgroundImage:kImageWithColor(HEX_COLOR(@"e6e8eb"), CGRectMake(0, 0, 150, 40)) forState:UIControlStateNormal];
        [signinBtn setTitle:@"已签到" forState:UIControlStateNormal];
        [signinBtn setTitleColor:HEX_COLOR(@"afb6c1") forState:UIControlStateNormal];
        signinBtn.userInteractionEnabled = NO;
    }
    [CALayer updateControlLayer:signinBtn.layer radius:5 borderWidth:0 borderColor:nil];
    [headerView addSubview:signinBtn];
    
    UILabel *countLabel = [UILabel createrLabelframe:CGRectMake(0, 122, WIDTH, 38) backColor:HEX_COLOR(@"e57a77") textColor:WHITE_COLOR test:@"" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    [CommonMethod viewAddGuestureRecognizer:countLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoMyCoffeeBeansVC)];
    [headerView addSubview:countLabel];
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前咖啡豆：%@", self.coffeeBeans]];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = kImageWithName(@"icon_kfd_white");
    attchImage.bounds = CGRectMake(4, -1, 10, 11);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr appendAttributedString:stringImage];
    countLabel.attributedText = attriStr;
    
    UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 133, 9, 15)];
    nextImageView.image = [kImageWithName(@"icon_next_gray") imageWithColor:WHITE_COLOR];
    [headerView addSubview:nextImageView];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, WIDTH, 10)];
    lineLabel.backgroundColor = kTableViewBgColor;
    [headerView addSubview:lineLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)gotoMyCoffeeBeansVC{
    MyCoffeeBeansController *vc = [[MyCoffeeBeansController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -完成开启通知任务调接口
- (void)finishOpenNotification{
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    BOOL isOpenNoti = (type!=UIUserNotificationTypeNone);
    if(isOpenNoti){
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:@(13) forKey:@"taskid"];
        [self requstType:RequestType_Post apiName:API_NAME_POST_TASK_COMPLETETASK paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        }];
    }
}

#pragma mark --- 任务列表
- (void)loadTaskListHttpData{
    _noNetWork = NO;
    [self.taskArray removeAllObjects];
    __weak MBProgressHUD *hud;// = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_TASK_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            weakSelf.sign = [CommonMethod paramNumberIsNull:dict[@"sign"]];
            weakSelf.coffeeBeans = [CommonMethod paramNumberIsNull:dict[@"cb"]];
            [DataModelInstance shareInstance].coffeeBeans = weakSelf.coffeeBeans;
            NSArray *dailyArray = [CommonMethod paramArrayIsNull:dict[@"daily"]];
            NSMutableArray *dailyMutableArray = [NSMutableArray array];
            for(NSDictionary *taskDict in dailyArray){
                TaskModel *model = [[TaskModel alloc] initWithDict:taskDict];
                [dailyMutableArray addObject:model];
            }
            if(dailyMutableArray.count){
                [weakSelf.taskArray addObject:dailyMutableArray];
            }
            NSArray *baseArray = [CommonMethod paramArrayIsNull:dict[@"base"]];
            NSMutableArray *baseMutableArray = [NSMutableArray array];
            for(NSDictionary *taskDict in baseArray){
                TaskModel *model = [[TaskModel alloc] initWithDict:taskDict];
                [baseMutableArray addObject:model];
            }
            if(baseMutableArray.count){
                [weakSelf.taskArray addObject:baseMutableArray];
            }
            [weakSelf initTableHeaderView];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark --- 签到
- (void)signInButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"签到中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_TASK_SIGNIN paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"签到成功" toView:weakSelf.view];
            weakSelf.sign = @(1);
            weakSelf.coffeeBeans = @(weakSelf.coffeeBeans.integerValue+1);
            [DataModelInstance shareInstance].coffeeBeans = weakSelf.coffeeBeans;
            [weakSelf initTableHeaderView];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.taskArray.count){
        return self.taskArray.count;
    }else if(_noNetWork){
        return 1;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.taskArray.count){
        NSMutableArray *array = self.taskArray[section];
        return array.count;
    }else if(_noNetWork){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.taskArray.count){
        return 76;
    }else{
        return HEIGHT-64;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 46)];
    headerView.backgroundColor = WHITE_COLOR;
    UILabel *label = [UILabel createLabel:CGRectMake(16, 0, WIDTH-32, 46) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
    if(section==0){
        label.text = @"日常任务";
    }else{
       label.text = @"新手任务";
    }
    [headerView addSubview:label];
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.taskArray.count){
        static NSString *identify = @"TaskCell";
        TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TaskCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSMutableArray *array = self.taskArray[indexPath.section];
        [cell updateDisplay:array[indexPath.row]];
        cell.tag = indexPath.section*1000+indexPath.row;
        __weak typeof(self) weakSelf = self;
        cell.taskButtonClicked = ^(TaskCell *tmpCell) {
            NSInteger section = tmpCell.tag/1000;
            NSInteger row = tmpCell.tag%1000;
            TaskModel *model = weakSelf.taskArray[section][row];
            model.status = @(3);
            weakSelf.coffeeBeans = @(weakSelf.coffeeBeans.integerValue+model.award_cb.integerValue);
            [DataModelInstance shareInstance].coffeeBeans = weakSelf.coffeeBeans;
            [weakSelf initTableHeaderView];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
        };
        return cell;
    }else{
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork&&self.taskArray.count==0){
        [self loadTaskListHttpData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

@end
