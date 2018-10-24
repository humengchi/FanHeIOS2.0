
//
//  DynamicNotificationCtr.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicNotificationCtr.h"
#import "DynamicNotificationCell.h"
#import "NONetWorkTableViewCell.h"
#import "VariousDetailController.h"
#import "DelectDataView.h"
@interface DynamicNotificationCtr ()
@property (nonatomic ,strong)NSMutableArray *dataArray;
@property (nonatomic ,assign) BOOL netWorkStat;
@property (nonatomic ,assign) NSInteger currage;
@property (nonatomic ,strong) DelectDataView *delectView;
@end

@implementation DynamicNotificationCtr
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
    self.netWorkStat = NO;
    self.currage = 1;
    self.dataArray = [NSMutableArray new];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getDynicmaNoteionList:self.currage];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currage ++;
        [self getDynicmaNoteionList:self.currage];
    }];
    // Do any additional setup after loading the view from its nib.
}

#pragma MARK -------动态通知
- (void)getDynicmaNoteionList:(NSInteger)currage{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    if (self.notecount.integerValue > 0) {
        [requestDict setObject:self.notecount forKey:@"notecount"];
    }
    if (self.dataArray.count > 0) {
        DynamicDetailModel *model = self.dataArray.lastObject;
        [requestDict setObject:model.lasttime forKey:@"lasttime"];
    }
    
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_NOTELIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dic in array) {
                DynamicDetailModel *model = [[DynamicDetailModel alloc]init];
                [model setValuesForKeysWithDictionary:dic];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
            if (weakSelf.dataArray.count == 0) {
                [weakSelf notStartPiontNewDetail];
            }
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
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

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearButtonClicked:(id)sender{
    // @"删除";
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否要清空通知" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
    } confirm:^{
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"清空中..." toView:self.view];
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        [self requstType:RequestType_Delete apiName:API_NAME_DELETE_DYNAMIC_CLEARNOTE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [weakSelf.tableView endRefresh];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.tableView reloadData];
                [self notStartPiontNewDetail];
            }else{
                [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }];
        
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        return 1;
    }else if(_currage==1){
        self.tableView.mj_footer.hidden = YES;
        if(self.dataArray.count){
            return self.dataArray.count+1;
        }else{
            return 0;
        }
    }else{
        self.tableView.mj_footer.hidden = NO;
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }
    if(_currage==1 && indexPath.row == self.dataArray.count){
        return 55;
    }else{
        return 92;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        if(self.currage == 1 && self.dataArray && indexPath.row == self.dataArray.count){
            static NSString *cellID = @"UITableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 5) backColor:@"EFEFF4"];
            [cell.contentView addSubview:backView];
            cell.textLabel.text = @"查看历史数据";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = KTextColor;
            return cell;
        }else{
            DynamicDetailModel *model = self.dataArray[indexPath.row];
            static NSString *cellID = @"DynamicNotificationCell";
            DynamicNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([DynamicNotificationCell class])];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor whiteColor];
            
            [cell tranferDynamicNotificationCellModel:model];
            return cell;
            
        }
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_currage==1  && indexPath.row == self.dataArray.count){
        _currage ++;
        [self getDynicmaNoteionList:1];
        return;
    }
    
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        [self getDynicmaNoteionList:1];
    }else{
        DynamicDetailModel *model = self.dataArray[indexPath.row];
        
        VariousDetailController *varDynamic = [[VariousDetailController alloc]init];
        
        varDynamic.dynamicid = model.dynamic_id;
        [self.navigationController pushViewController:varDynamic animated:YES];
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
