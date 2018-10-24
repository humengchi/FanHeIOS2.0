//
//  MyActivityController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyActivityController.h"
#import "MyActivityCell.h"
#import "DelectDataView.h"
#import "NONetWorkTableViewCell.h"
#import "ActivityViewController.h"
#import "MyPublishActivityCtr.h"
#import "ActivityDetailController.h"
#import "MyActivityOrderController.h"

@interface MyActivityController (){
    NSInteger _newMsgCount;
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger  currentPag;
@property (nonatomic,strong) DelectDataView *delectView;
@property (nonatomic,assign)  BOOL netWorkStat;
@end

@implementation MyActivityController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self getMessagesCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.netWorkStat = NO;
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"我的活动"];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPag = 1;
    [self getMyActivity:self.currentPag];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getMyActivity:self.currentPag];
    }];
}

#pragma mark ---------  创建FootView
- (void)cretaterTabViewFootView{
    CGFloat heigth = HEIGHT - 64 - 60;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, heigth)];
    self.tableView.tableFooterView = view;
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.coverImageView.hidden = YES;
    self.delectView.showTitleLabel.hidden = YES;
    
    UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(WIDTH/2.0 - 37.5, 90 , 75, 75) bgColor:[UIColor colorWithHexString:@"EFEFF4"]];
    imageView.image = [UIImage imageNamed:@"icon_event_b"];
    [self.delectView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(0, 200, WIDTH, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"你还没有报名任何活动";
    [self.delectView addSubview:titleLabel];
    
    UIButton *btn = [NSHelper createButton:CGRectMake(WIDTH/2.0 - 60, 240, 120, 30) title:@"查看更多活动" unSelectImage:nil selectImage:nil target:self selector: @selector(checkMoreActivity)];
    [btn setTitleColor:[UIColor colorWithHexString:@"818C9E"] forState:UIControlStateNormal];
    btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
    [self.delectView addSubview:btn];
    btn.layer.borderWidth = 0.5;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 2;
    btn.layer.borderColor = [[UIColor colorWithHexString:@"818C9E"] CGColor];
    
    [view addSubview:self.delectView];
}
- (void)checkMoreActivity{
    ActivityViewController *activity = [CommonMethod getVCFromNib:[ActivityViewController class]];
    activity.showBackBtn = YES;
    [self.navigationController pushViewController:activity animated:YES];
}

#pragma mark - 获取新消息数量
- (void)getMessagesCount{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_NEW_MSG_COUNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dict = [responseObject objectForKey:@"data"];
            //活动
            NSNumber *newapplycount = [dict objectForKey:@"newapplycount"];
            NSNumber *newaskcount = [dict objectForKey:@"newaskcount"];
            _newMsgCount = newapplycount.integerValue + newaskcount.integerValue;
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark ------  获取我报名的活动
- (void)getMyActivity:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",[DataModelInstance shareInstance].userModel.userId, page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_MYACTIVITY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        [self.delectView removeFromSuperview];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.currentPag == 1) {
                [self.dataArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                MyActivityModel *activityModle = [[MyActivityModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:activityModle];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            if (weakSelf.dataArray.count == 0) {
                [weakSelf cretaterTabViewFootView];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
    
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    if (self.dataArray.count == 0 && self.netWorkStat == NO) {
        return 0;
    }
    if (self.netWorkStat == YES) {
        return 1;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 53;
    }else{
        if (self.dataArray.count == 0 || self.netWorkStat == YES) {
            return HEIGHT-53- 64 - HEIGHT/3;
        }
        return 97;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }else{
        if (self.dataArray.count == 0 && self.netWorkStat == NO) {
            return 0;
        }
        if (self.netWorkStat == YES) {
            return 0;
        }
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat heigth = 10;
    if (section == 1) {
        heigth = 44;
    }
    NSArray *titleArray = @[@"",@"我报名的活动"];
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, heigth) backColor:@"EFEFF4"];
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(0, 13, WIDTH, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"818c9e")];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = titleArray[section];
    [view addSubview:titleLabel];
    if (section == 0) {
        titleLabel.hidden = YES;
    }
    return view;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) {
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UIImageView *imageView = [UIImageView drawImageViewLine:CGRectMake(16, 12, 30, 30) bgColor:[UIColor whiteColor]];
        imageView.image = [UIImage imageNamed:@"icon_event_fabu"];
        [cell.contentView addSubview:imageView];
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(53, 20, WIDTH - 100, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
        titleLabel.text = @"我发布的活动";
        [cell.contentView addSubview:titleLabel];
        if(indexPath.row == 1){
            imageView.image = [UIImage imageNamed:@"icon_myhd_order"];
            titleLabel.text = @"我的订单";
        }
        if(_newMsgCount==0||indexPath.row == 1){
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 19, 14, 15)];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            iconImageView.image = kImageWithName(@"icon_next_gray");
            [cell.contentView addSubview:iconImageView];
        }else{
            CGFloat width = [NSHelper widthOfString:[NSString stringWithFormat:@"%ld",_newMsgCount] font:FONT_SYSTEM_SIZE(14) height:18 defaultWidth:18];
            if (_newMsgCount > 9) {
                width = [NSHelper widthOfString:[NSString stringWithFormat:@"%ld",_newMsgCount] font:FONT_SYSTEM_SIZE(14) height:18 defaultWidth:18]+6;
            }
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(WIDTH-width-16, 18, width, 18) font:[UIFont systemFontOfSize:14] bkColor:HEX_COLOR(@"E24943") textColor:WHITE_COLOR];
            titleLabel.layer.cornerRadius = 9;
            titleLabel.layer.masksToBounds = YES;
            titleLabel.text = [NSString stringWithFormat:@"%ld",_newMsgCount];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:titleLabel];
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 52.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        return cell;
    }else{
        if(self.netWorkStat){
            static NSString *cellID = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }else{
            static NSString *cellID = @"MyActivityCell";
            MyActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([MyActivityCell class])];
            }
            MyActivityModel * activityModle = self.dataArray[indexPath.row];
            cell.selectionStyle = UITableViewCellAccessoryNone;
            [cell tranferMyActivityCellModel:activityModle];
            
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        if(indexPath.row == 0){
        MyPublishActivityCtr *activity = [[MyPublishActivityCtr alloc]init];
        [self.navigationController pushViewController:activity animated:YES];
        }else{
            MyActivityOrderController *vc = [CommonMethod getVCFromNib:[MyActivityOrderController class]];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if(self.dataArray.count){
            MyActivityModel *model = self.dataArray[indexPath.row];
            ActivityDetailController *vc = [CommonMethod getVCFromNib:[ActivityDetailController class]];
            vc.activityid = model.activityid;
            [self.navigationController pushViewController:vc animated:YES];
        }else if(self.netWorkStat==YES){
            [self getMyActivity:self.currentPag];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------- 去掉Section的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = 44;
    CGFloat sectionHeigth = 5;
    if ((scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) || (scrollView.contentOffset.y<=sectionHeigth&&scrollView.contentOffset.y>=0)) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
