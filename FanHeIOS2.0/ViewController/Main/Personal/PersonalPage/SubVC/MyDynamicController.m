//
//  MyDynamicController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/6.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyDynamicController.h"
#import "NONetWorkTableViewCell.h"
#import "DynamicHeaderCell.h"
@interface MyDynamicController ()
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) DynamicModel *dyMOdel;
@property (nonatomic ,assign)  BOOL netWorkStat;
@end

@implementation MyDynamicController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"我的动态"];
    [self createCustomNavigationBar:@"动态详情"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64 - 55)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view from its nib.
}
- (void)getMyDynamicData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",@"1133",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMICDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict  = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            
            self.dyMOdel = [[DynamicModel alloc]initWithDict:dict];
            
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = YES;
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }
    if (section == 0) {
        if (self.dyMOdel.userModel.user_realname.length > 0) {
            return 1;
            
        }
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else {
        
        return   self.dyMOdel.contentHeight +  self.dyMOdel.shareViewHeight + 72 + 15;
        //        return self.dyMOdel.cellHeight  ;
    }
  
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else {
        static NSString *cellID = @"DynamicCell";
        DynamicHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        cell = [[DynamicHeaderCell alloc] initWithDataDict:self.dyMOdel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
        
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
