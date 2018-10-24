//
//  MyTopicController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyTopicController.h"
#import "NONetWorkTableViewCell.h"
#import "ToicpTopCell.h"
#import "MyTopCell.h"
#import "NotificationController.h"
#import "MyViewpointController.h"
#import "MyStartController.h"
#import "MyTopicModel.h"
#import "ToicpCharacterCell.h"
#import "TopicViewController.h"

@interface MyTopicController (){
    NSInteger _notecount;
}
@property (nonatomic, strong) NSMutableArray *topArray;
@property (nonatomic, assign) NSInteger currentPag;


@end

@implementation MyTopicController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMessagesCount];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"我的话题"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     self.tableView.backgroundColor = [UIColor whiteColor];
    self.currentPag = 1;
    [self getMyAttionTopic:self.currentPag];
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getMyAttionTopic:self.currentPag];
    }];
}

#pragma mark ------  获取我关注列表数据
- (void)getMyAttionTopic:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(self.topArray.count==0){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",[DataModelInstance shareInstance].userModel.userId, (long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_MYTOPIC_MYATTIONTOPIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count==0){
                [weakSelf.tableView endRefreshNoData];
            }else{
                [weakSelf.tableView endRefresh];
            }
            for (NSDictionary *dict in array) {
                MyTopicModel *model = [[MyTopicModel alloc] initWithDict:dict];
                [weakSelf.topArray addObject:model];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    return self.topArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 53;
    }else{
        MyTopicModel *model = self.topArray[indexPath.row];
        if (model.srcnt.integerValue > 0) {
            return  91;
        }else{
            return [ToicpCharacterCell backToicpCharacterCell:model];
        }
        
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 5;
    }
    if (self.topArray.count > 0) {
        return 46;
    }else{
        return 0;
    }
    return 46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSArray *titleArray = @[@"",@"我关注的话题"];
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 46) backColor:@"EFEFF4"];
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(0, 13, WIDTH, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = titleArray[section];
    [view addSubview:titleLabel];
    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    backLabel.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [view addSubview:backLabel];
    if (section == 0) {
        titleLabel.hidden = YES;
    }
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        static NSString *cellID = @"ToicpTopCell";
        ToicpTopCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ToicpTopCell class])];
        }
        cell.selectionStyle = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            if (_notecount > 0) {
                cell.acountLabel.text = [NSString stringWithFormat:@"%ld",(long)_notecount];
                cell.leftImageView.hidden = YES;
            }else{
                cell.acountLabel.hidden = YES;
                cell.leftImageView.hidden = NO;
            }
        }else{
            cell.acountLabel.hidden = YES;
        }
         cell.backgroundColor = [UIColor whiteColor];
        [cell createrToicpTopCell:indexPath.row];
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        MyTopicModel *model = self.topArray[indexPath.row];
        if (model.srcnt.integerValue == 0) {
            static NSString *cellID = @"ToicpCharacterCell";
            ToicpCharacterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([ToicpCharacterCell class])];
            }
            cell.selectionStyle = UITableViewCellAccessoryNone;
            [cell tranferToicpCharacterCellMyTopicModel:model];
             cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }else{
            static NSString *cellID = @"MyTopCell";
            MyTopCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([MyTopCell class])];
            }
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellAccessoryNone;
            [cell tranferMyTopicModel:model];
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NotificationController *notCtr = [[NotificationController alloc]init];
            notCtr.newMsgCount = _notecount;
            [self.navigationController pushViewController:notCtr animated:YES];
            _notecount = 0;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
        }else if (indexPath.row == 1){
            MyViewpointController *pointCtr = [[MyViewpointController alloc]init];
            [self.navigationController pushViewController:pointCtr animated:YES];
        }else{
            MyStartController *startCtr = [[MyStartController alloc]init];
            [self.navigationController pushViewController:startCtr animated:YES];
        }
    }else{
        MyTopicModel *model = self.topArray[indexPath.row];
        TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
        vc.subjectId = model.subjectid;
        [self.navigationController pushViewController:vc animated:YES];
        if(model.srcnt.integerValue){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                model.srcnt = @(0);
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"取消关注";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"取消中..." toView:self.view];
    MyTopicModel *model = self.topArray[indexPath.row];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:model.subjectid forKey:@"subjectid"];
    [self requstType:RequestType_Post apiName:API_NAME_MYTOPIC_CANCLETOPIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"取消成功" toView:weakSelf.view];
            [weakSelf.topArray removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取新消息数量
- (void)getMessagesCount{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_NEW_MSG_COUNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dict = [responseObject objectForKey:@"data"];
            NSNumber *notecount = [dict objectForKey:@"notecount"];
            _notecount = notecount.integerValue;
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [self.tableView reloadData];
    }];
}


@end
