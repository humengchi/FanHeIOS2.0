//
//  NewFriendsController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NewFriendsController.h"
#import "PhoneFriendsController.h"
#import "NewFriendsCell.h"
#import "SendFriendsDetailsController.h"
#import "VisitPhoneBookView.h"

@interface NewFriendsController ()<NewFriendsCellDelegate>
@property (nonatomic ,strong)NSMutableArray *cardListArray;
@end

@implementation NewFriendsController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardListArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"新的好友"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getGoodFriendsList];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.view addSubview:lineLabel];
}

#pragma mark --- 网络请求数据
- (void)getGoodFriendsList{
    if(self.cardListArray==nil){
        self.cardListArray = [NSMutableArray new];
    }else{
        [self.cardListArray removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_ASKFRIENDSLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                ChartModel *coffModel = [[ChartModel alloc] initWithDict:subDic];
                [self.cardListArray addObject:coffModel];
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }else{
        return self.cardListArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 105;
    }else{
        return 74;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(0, 67, WIDTH, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"999999") test:@"添加手机联系人" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:titleLabel];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-45)/2, 16, 45, 45)];
        iconImageView.image = [UIImage imageNamed:@"icon_rm_txl"];
        [cell.contentView addSubview:iconImageView];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, WIDTH, 10)];
        lineLabel.backgroundColor = kTableViewBgColor;
        [cell.contentView addSubview:lineLabel];
        
        return cell;
    }else{
        static NSString *string = @"phone";
        NewFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
        if (!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NewFriendsCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.index = indexPath.row;
        ChartModel *coffModel = self.cardListArray[indexPath.row];
        [cell sendGoodFriends:coffModel];
        cell.friendsDelegate = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
            VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            view.visitPhoneBookViewResult = ^(BOOL result){
                if(result){
                    PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            };
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }else{
            PhoneFriendsController *vc = [[PhoneFriendsController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        ChartModel *coffModel = self.cardListArray[indexPath.row];
        if (coffModel.status.integerValue == 0) {
            SendFriendsDetailsController *send = [CommonMethod getVCFromNib:[SendFriendsDetailsController class]];
            send.addFriendsSuccess = ^(BOOL success){
                [self getGoodFriendsList];
                //更新本地好友请求
                [[AppDelegate shareInstance] updateFriendsListArrayData:nil];
            };
            send.otherID = coffModel.userid;
            [self.navigationController pushViewController:send  animated:YES];
        }else{
            NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
            home.userId = coffModel.userid;
            [self.navigationController pushViewController:home animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

//*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self delectFriendsAttion:indexPath.row];
}

#pragma mark - --- AttentionCellDelegate
- (void)sendAddFriends:(NSInteger)index{
    ChartModel *chartModel = self.cardListArray[index];
    if (chartModel.status.integerValue == 0) {
        [self addFriendsAttion:index];
    }else{
        NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
        home.userId = chartModel.userid;
        [self.navigationController pushViewController:home animated:YES];
    }
}

#pragma mark --------- 添加好友
- (void)addFriendsAttion:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    __block ChartModel *chartModel = self.cardListArray[index];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"添加中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"%@",chartModel.reqid] forKey:@"id"];
    [requestDict setObject:@"2" forKey:@"isaccept"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_AGREEADDFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            chartModel.status = @(2);
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            [[NSNotificationCenter defaultCenter]postNotificationName:MyFriendsChange object:nil];
            [MBProgressHUD showSuccess:@"添加好友成功" toView:weakSelf.view];
            //更新本地好友请求
            [[AppDelegate shareInstance] updateFriendsListArrayData:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
#pragma mark --------- 删除好友
- (void)delectFriendsAttion:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    __block ChartModel *chartModel = self.cardListArray[index];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",chartModel.userid] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_USER_GET_DELECTFRIENDSASK paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.cardListArray removeObject:chartModel];
            [weakSelf.tableView reloadData];
            [MBProgressHUD showSuccess:@"删除成功" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

@end
