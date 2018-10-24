//
//  MyPublishActivityCtr.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyPublishActivityCtr.h"
#import "NONetWorkTableViewCell.h"
#import "PublishCell.h"
#import "DelectDataView.h"
#import "CreateActivityViewController.h"
#import "TopicIdentifyViewController.h"
#import "ActivityManagerViewController.h"

@interface MyPublishActivityCtr (){
    NSInteger _currentpage;
}

@property (nonatomic,strong) DelectDataView *delectView;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MyPublishActivityCtr

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _currentpage = 1;
    [self getMyActivityListData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _currentpage = 1;
    [self createCustomNavigationBar:@"我发布的活动"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getMyActivityListData];
    }];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark ------  获取我的活动列表数据
- (void)getMyActivityListData{
    self.netWorkStat = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(self.dataArray==nil){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",[DataModelInstance shareInstance].userModel.userId,_currentpage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_MY_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if(_currentpage==1){
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for(NSDictionary *dict in array){
                MyActivityModel *model = [[MyActivityModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            _currentpage++;
        }else{
            [weakSelf.tableView endRefresh];
        }
        if(weakSelf.dataArray.count==0){
            [weakSelf cretaterTabViewFootView];
        }else{
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView endRefresh];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark ---------  创建FootView
- (void)cretaterTabViewFootView{
    CGFloat heigth = HEIGHT - 64 - 60;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH,heigth )];
    self.tableView.tableFooterView = view;
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.coverImageView.hidden = YES;
    self.delectView.showTitleLabel.hidden = YES;
    
    UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(WIDTH/2.0 - 37.5, 90 , 75, 75) bgColor:[UIColor colorWithHexString:@"EFEFF4"]];
    imageView.image = [UIImage imageNamed:@"icon_no_release_b"];
    [self.delectView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(0, 200, WIDTH, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"你还没有发布的活动";
    [self.delectView addSubview:titleLabel];
    
    UIButton *btn = [NSHelper createButton:CGRectMake(WIDTH/2.0 - 60, 240, 120, 30) title:@"发布活动" unSelectImage:nil selectImage:nil target:self selector: @selector(publishActivity)];
    btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
    [btn setTitleColor:[UIColor colorWithHexString:@"818C9E"] forState:UIControlStateNormal];
    [self.delectView addSubview:btn];
    btn.layer.borderWidth = 0.5;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 4;
    btn.layer.borderColor = [[UIColor colorWithHexString:@"818C9E"] CGColor];
    
    [view addSubview:self.delectView];
}

- (void)publishActivity{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        CreateActivityViewController *vc = [CommonMethod getVCFromNib:[CreateActivityViewController class]];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Activity;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 100;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *cellID = @"PublishCell";
        PublishCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([PublishCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        MyActivityModel *model = self.dataArray[indexPath.row];
        [cell tranferMyActivityCellModel:model];
        return cell;
    }else{
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArray.count){
        ActivityManagerViewController *vc = [[ActivityManagerViewController alloc] init];
        MyActivityModel *model = self.dataArray[indexPath.row];
        vc.activityid = model.activityid;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self getMyActivityListData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
