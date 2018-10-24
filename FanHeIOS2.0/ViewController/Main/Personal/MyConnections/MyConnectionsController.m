//
//  MyConnectionsController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyConnectionsController.h"
#import "FriendTableViewCell.h"
#import "ConnectionsCell.h"
#import "ChatViewController.h"

#import "NewFriendsController.h"
#import "AttentionViewController.h"
#import "PrivacySettingController.h"

@interface MyConnectionsController ()
@property (nonatomic ,strong)   UILabel *allFriendsLabel;
@property (nonatomic ,strong )  NSMutableArray *friendsArray;
@property (nonatomic ,strong )  NSMutableDictionary *msgNumDict;
@property (nonatomic   ,strong) NSMutableArray *searchArry;
@end

@implementation MyConnectionsController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessagesCount];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgNumDict = [NSMutableDictionary dictionary];
    [self createCustomNavigationBar:@"我的人脉"];
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    settingBtn.frame = CGRectMake(WIDTH-48, 20, 44, 44);
    [settingBtn setImage:kImageWithName(@"icon_setting") forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 6)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
    
    self.allFriendsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
    self.allFriendsLabel.backgroundColor = HEX_COLOR(@"EFEFF4");
    self.allFriendsLabel.textAlignment = NSTextAlignmentCenter;
    self.allFriendsLabel.font = [UIFont systemFontOfSize:14];
    self.allFriendsLabel.textColor = HEX_COLOR(@"41464E");
    self.tableView.tableFooterView = self.allFriendsLabel;
    //右检索背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
     //右检索字体颜色
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"41464E"];
    
    [self loadAllfriendsListArrayData];
 
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(referView) name:MyFriendsChange object:nil];
}

- (void)referView{
     [self loadAllfriendsListArrayData];
}

#pragma mark - 设置
- (void)settingButtonClicked:(id)sender{
    PrivacySettingController *vc = [[PrivacySettingController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 获取新消息数量
- (void)getMessagesCount{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_NEW_MSG_COUNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            weakSelf.msgNumDict = [responseObject objectForKey:@"data"];
            [weakSelf.tableView reloadData];
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        
    }];
}

#pragma mafrk ------ 好友
- (void)loadAllfriendsListArrayData{
    __weak typeof(self) weakSelf = self;
    if(self.friendsArray){
        [self.friendsArray removeAllObjects];
    }
    __weak NSMutableArray *array = [[DBInstance shareInstance] getAllChartsModel];
    if(array.count){
        self.allFriendsLabel.text = [NSString stringWithFormat:@"共有%ld名好友",(unsigned long)array.count];
        [self sort:array];
    }
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_ALLFRIENDS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [dataArray addObject:model];
            }
            if(dataArray.count){
                [[DBInstance shareInstance] saveChartModelArray:dataArray];
                 weakSelf.allFriendsLabel.text = [NSString stringWithFormat:@"共有%ld名好友",(unsigned long)tmpArray.count];
                [dataArray sortUsingComparator:^NSComparisonResult(ChartModel *obj1, ChartModel *obj2){
                    return obj1.userid.integerValue > obj2.userid.integerValue;
                }];
                [array sortUsingComparator:^NSComparisonResult(ChartModel *obj1, ChartModel *obj2){
                    return obj1.userid.integerValue > obj2.userid.integerValue;
                }];
                if(dataArray.count != array.count || dataArray.count == 0){
                    [weakSelf sort:dataArray];
                }else{
                    BOOL refresh = NO;
                    for(int i = 0; i < dataArray.count; i++){
                        ChartModel *model1 = dataArray[i];
                        ChartModel *model2 = dataArray[i];
                        if(model1.userid.integerValue != model2.userid.integerValue){
                            refresh = YES;
                            break;
                        }
                    }
                    if(refresh){
                        [weakSelf sort:dataArray];
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf sort:[[DBInstance shareInstance] getAllChartsModel]];
    }];
}

#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.friendsArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        NSDictionary *dict = self.friendsArray[section-1];
        NSArray *array = dict[dict.allKeys[0]];
        return [array count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 32;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 6)];
        headerView.backgroundColor = kTableViewBgColor;
       return headerView;
    }else{
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
        headerView.backgroundColor = kTableViewBgColor;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-16, 32)];
        label.textColor = HEX_COLOR(@"818C9E");
        label.font = FONT_SYSTEM_SIZE(14);
        [headerView addSubview:label];
        NSDictionary *dic = self.friendsArray[section - 1];
        label.text = dic.allKeys[0];
        
//        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
//        label2.backgroundColor = kCellLineColor;
//        [headerView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
        label3.backgroundColor = kCellLineColor;
        [headerView addSubview:label3];
        
        return headerView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *cellID = @"stactTableViewCell";
        ConnectionsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ConnectionsCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell updateDisplay:indexPath.row num:self.msgNumDict[@"attention"]];
        UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 53.5, WIDTH, 0.5) backColor:@"D9D9D9"];
        [cell.contentView addSubview:lineView];
        return cell;
    }else {
        static NSString *identify = @"FriendTableViewCell";
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"FriendTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *dict = self.friendsArray[indexPath.section-1];
        NSMutableArray *array = dict[dict.allKeys[0]];
        ChartModel *model = array[indexPath.row];
        [cell updateDisplay:model];
        UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 53.5, WIDTH, 0.5) backColor:@"D9D9D9"];
        [cell.contentView addSubview:lineView];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        AttentionViewController *attention = [[AttentionViewController alloc]init];
        if (indexPath.row == 0) {
            attention.typeIndex = 1;
        }else{
            attention.typeIndex = 2;
        }
        [self.navigationController pushViewController:attention animated:YES];
    }else{
        if(self.friendsArray.count){
            NSDictionary *dict = self.friendsArray[indexPath.section - 1];
            NSMutableArray *array = dict[dict.allKeys[0]];
            ChartModel *model = array[indexPath.row];
            NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
            home.userId = model.userid;
            [self.navigationController pushViewController:home animated:YES];
        }
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    self.searchArry = [NSMutableArray new];
    [self.searchArry addObject:@"♡"];
    NSArray *newArray = [NSArray new];
    for (NSInteger i = 0 ; i< self.friendsArray.count; i++) {
        NSDictionary *dic = self.friendsArray[i];
        [self.searchArry addObject:dic.allKeys[0]];
    }
    newArray = self.searchArry;
    return newArray;
}

//排序
- (void)sort:(NSMutableArray*)array{
    if(self.friendsArray == nil){
        self.friendsArray = [NSMutableArray array];
    }else{
        [self.friendsArray removeAllObjects];
    }
    if(array.count){
        char pre = 'A';
        for(int i = 0; i < 26; i++){
            [self filter:[NSString stringWithFormat:@"%C", (unichar)(pre+i)] array:array];
        }
        [self filter:@"#" array:array];
    }
    
    [self.tableView reloadData];

}

- (void)filter:(NSString*)str array:(NSMutableArray*)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([str isEqualToString:@"#"]){
        for(ChartModel *model in array){
            if([EaseChineseToPinyin sortSectionTitle:[EaseChineseToPinyin pinyinFromChineseString:model.realname]] == '#'){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }else{
        for(ChartModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.realname] uppercaseString] hasPrefix:str]){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }
    if(tempArray.count){
        [self.friendsArray addObject:@{str:tempArray}];
    }
}

@end
