//
//  NotificationController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NotificationController.h"
#import "DelectDataView.h"
#import "NONetWorkTableViewCell.h"
#import "NotificationCell.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"
#import "ViewpointDetailViewController.h"
#import "RateDetailController.h"
#import "NotificationReviewCell.h"

@interface NotificationController ()<NotificationCellDelegate>{
    NSInteger _currentPage;
}
@property   (nonatomic ,assign) BOOL netWorkStat;
@property   (nonatomic ,strong) DelectDataView *delectView;
@property   (nonatomic ,strong) NSMutableArray *notiforArray;

@end

@implementation NotificationController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"话题通知"];
    self.notiforArray = [NSMutableArray new];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _currentPage = 0;
    [self getNotiformationListData];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getNotiformationListData];
    }];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [editBtn setTitle:@"清空" forState:UIControlStateNormal];
    [editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
    editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [editBtn addTarget:self action:@selector(removeAllNot) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
}

- (void)removeAllNot{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否删除所有我的通知" cancelButtonTitle:@"确定" otherButtonTitle:@"取消" cancle:^{
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"清空中..." toView:self.view];
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        [self requstType:RequestType_Delete apiName:API_NAME_CLEARALL_NOTCENTABOUTTOPIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [MBProgressHUD showSuccess:@"网络请求失败，请检查网络" toView:weakSelf.view];
                [weakSelf notStartPiontNewDetail];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
            [weakSelf.tableView reloadData];
        }];
    } confirm:^{
       
    }];
}

#pragma mark ------  获取通知列表数据
- (void)getNotiformationListData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    if(self.notiforArray.count){
        MyTopicModel *model = self.notiforArray.lastObject;
        [requestDict setObject:[CommonMethod paramNumberIsNull:model.lasttime] forKey:@"lasttime"];
    }
    [requestDict setObject:[CommonMethod paramNumberIsNull:@(self.newMsgCount)] forKey:@"notecount"];
    [self requstType:RequestType_Post apiName:API_NAME_MYTOPIC_NOTCENTABOUTTOPIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                MyTopicModel *myModel = [[MyTopicModel alloc] initWithDict:dict];
                NotSecoundModel *model = [[NotSecoundModel alloc] initWithDict:dict[@"parentinfo"]];
                myModel.model = model;
                [weakSelf.notiforArray addObject:myModel];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            _currentPage++;
        }else{
            [weakSelf.tableView endRefresh];
        }
        if(weakSelf.notiforArray.count == 0) {
            [weakSelf notStartPiontNewDetail];
        }else{
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
    
}
#pragma mark ---你还没有发布任何观点&评论
- (void)notStartPiontNewDetail{
    [self.tableView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    
    self.delectView.coverImageView.image = kImageWithName(@"icon_mytopic_nocomment");
    self.delectView.showTitleLabel.text = @"你还没有任何通知";
    [self.view addSubview:self.delectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }
    if(_currentPage==1 && self.newMsgCount){
        self.tableView.mj_footer.hidden = YES;
        return self.notiforArray.count+1;
    }else{
        self.tableView.mj_footer.hidden = NO;
        return self.notiforArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }
    if(_currentPage==1 && self.newMsgCount && indexPath.row == self.notiforArray.count){
        return 50;
    }else{
        MyTopicModel *model = self.notiforArray[indexPath.row];
        return model.cellHeight;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        if(_currentPage==1 && self.newMsgCount && indexPath.row == self.notiforArray.count){
            static NSString *cellID = @"UITableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = @"查看历史数据";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = KTextColor;
            return cell;
        }else{
            MyTopicModel *model = self.notiforArray[indexPath.row];
            if(model.status.integerValue == 2 && (model.type.integerValue == 8||model.type.integerValue == 3)){
                static NSString *cellID = @"NotificationReviewCell";
                NotificationReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell) {
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([NotificationReviewCell class])];
                }
                [cell createrNotificationCellNotificationCell:model];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                static NSString *cellID = @"NotificationCell";
                NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell) {
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([NotificationCell class])];
                }
                cell.notificationCellDelegate = self;
                [cell createrNotificationCellNotificationCell:model];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
    }
}
- (void)textViewTouchPointProcessing:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.tableView];
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_currentPage==1 && self.newMsgCount && indexPath.row == self.notiforArray.count){
        [self getNotiformationListData];
        return;
    }
    MyTopicModel *model = self.notiforArray[indexPath.row];
    
    if (model.type.integerValue == 2 && model.status.integerValue == 1){
        //资讯详情
        InformationDetailController  *intDetailCtr = [[InformationDetailController alloc]init];
        intDetailCtr.postID = model.post_id;
        intDetailCtr.startType = YES;
        [self.navigationController pushViewController:intDetailCtr animated:YES];
        
    }else  if (model.type.integerValue == 3 && model.status.integerValue == 1){
        //资讯一级评论
        
        RateDetailController *vc = [CommonMethod getVCFromNib:[RateDetailController class]];
        vc.reviewid = model.review_id;//@(628);//53
        [self.navigationController pushViewController:vc animated:YES];
        
    }else  if (model.type.integerValue == 4 && model.status.integerValue == 1){
        //话题详情
        TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
        vc.subjectId = model.subject_id;//@(628);//53
        [self.navigationController pushViewController:vc animated:YES];
        
    }else  if ((model.type.integerValue == 8 && model.status.integerValue == 1)|| (model.type.integerValue == 8 && model.status.integerValue == 3)){
        //观点详情
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
    
        vc.viewpointId = model.subject_review_id;//@(628);//53
        TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
        topicDetailModel.subjectid = model.subject_review_id;
        topicDetailModel.title = model.title;
        vc.topicDetailModel = topicDetailModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
