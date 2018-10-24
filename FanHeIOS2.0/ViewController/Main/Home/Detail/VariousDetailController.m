//
//  VariousDetailController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/27.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "VariousDetailController.h"
#import "NONetWorkTableViewCell.h"
#import "PraiseListViewController.h"
#import "DynamicDetailCell.h"
#import "ReportViewController.h"
#import "DymanicRateController.h"
#import "ContentView.h"
#import "DynamicHeaderCell.h"
#import "PriseListSectionVIew.h"
#import "DynamicShareView.h"
#import "ChoiceFriendViewController.h"
#import "DelectDataView.h"
#import "TransmitDynamicController.h"

@interface VariousDetailController ()<DynamicDetailCellDelegate,DymanicRateControllerDelegate>
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic ,assign)  BOOL netWorkStat;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) FinanaceDetailModel *datailModel;
@property (nonatomic ,strong)DelectDataView *delectView;

@property (weak, nonatomic) IBOutlet UIView *shareDynamicView;
@property (weak, nonatomic) IBOutlet UIButton *sideLikeBtn;
@property (nonatomic, strong) UIMenuController *menuCtr;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (nonatomic ,assign) NSInteger cuurrPage;
@property (nonatomic ,assign) NSInteger indexRow;
@property (nonatomic ,assign) BOOL isBack;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic ,strong) DynamicModel *dyModel;
@property (nonatomic ,assign) BOOL isDelect;
@property (nonatomic ,assign) NSInteger type;//1,关注动态2.动态点赞，3评论动态点赞
//
@property (nonatomic ,assign) BOOL isCopy;
@property (nonatomic ,assign) BOOL isAttion;
@property (nonatomic ,assign) NSInteger idexDelect;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@end

@implementation VariousDetailController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isBack != YES) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoAttionHisActive) name:ATTIONHISACTIVEORTALK object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delectDynamic) name:DELECTACTIVITYACTION object:nil];
    
    // 注册监听 菜单即将显示 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIMenuControllerWillHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"reloadTableView" object:nil];
}

- (void)reloadTableView{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isDelect = NO;
    self.isAttion = NO;
    self.isCopy = NO;
    self.type = 0;
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.sideLikeBtn.layer.masksToBounds = YES;
    self.sideLikeBtn.layer.cornerRadius = 15;
    [self.sideLikeBtn.layer setBorderWidth:0.5]; //边框宽度
    self.sideLikeBtn.layer.borderColor=[UIColor colorWithHexString:@"D9D9D9"].CGColor;
    
    self.isBack = NO;
    self.cuurrPage = 1;
    self.netWorkStat = NO;
    self.imageArray = [NSMutableArray new];
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"动态详情"];
    
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64 - 55)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"FBFBFC"];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.cuurrPage = 1;
        [self getDynamicDetailData];
        [self getDynicmaRateList:self.cuurrPage];
    }];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.cuurrPage ++;
        [self getDynicmaRateList:self.cuurrPage];
    }];
    
    [self getDynamicDetailData];
    [self getDynicmaRateList:self.cuurrPage];
}

- (void)show{
    //一个section刷新
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)delectDynamic{
    if ([DataModelInstance shareInstance].userModel.userId.integerValue == self.dyModel.userModel.user_id.integerValue) {
        // @"删除";
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否要删除该条动态？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        } confirm:^{
            self.isDelect = YES;
            [self delectRateIndex:self.datailModel index:0 dyModel:self.dyModel];
        }];
    }else{
        //@"举报";
        self.isBack = YES;
        ReportViewController *report = [[ReportViewController alloc]init];
        report.reportType = ReportType_Dynamic;
        report.reportId = self.dynamicid;
        [self.navigationController pushViewController:report animated:YES];
    }
}

#pragma mark ------- 关注他
- (void)gotoAttionHisActive{
    if (self.dyModel.userModel.isattention.integerValue == 1) {
        [self.view showToastMessage:@"你已经关注过啦"];
    }else{
        
        self.type = 1;
        [self likePraiseAllRateDynamicModel:self.dyModel FinanaceDetailModel:self.datailModel isFrist:YES inde:0];
    }
}

//动态详情
- (void)getDynamicDetailData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.dynamicid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMICDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = NO;
        NSNumber *index = responseObject[@"status"];
        if (index.integerValue == 0) {
            [weakSelf createrDeleteVIew];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict  = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSMutableDictionary *newdic = [NSMutableDictionary dictionaryWithDictionary:dict];
            [newdic setValue:@"1" forKey:@"isDynamicDetail"];
            NSDictionary *subDic = newdic;
            
            weakSelf.dyModel = [[DynamicModel alloc]initWithDict:subDic];
            if (weakSelf.dyModel.ispraise.integerValue == 1) {
                weakSelf.likeBtn.selected = YES;
            }
            [weakSelf.tableView reloadData];
            weakSelf.shareBtn.enabled = weakSelf.dyModel.parent_status.integerValue<4;
            if (weakSelf.dyModel.parent_status.integerValue>= 4) {
                weakSelf.shareBtn.selected = YES;
            }else{
                weakSelf.shareBtn.selected = NO;
            }
            UserModel *model = [DataModelInstance shareInstance].userModel;
            [[AppDelegate shareInstance] setZhugeTrack:@"浏览动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:weakSelf.dyModel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:weakSelf.dyModel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:weakSelf.dyModel.exttype]}];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = YES;
    }];
}

#pragma mark ----- 数据被删除
- (void)createrDeleteVIew{
    [self.scrollView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    self.delectView.showTitleLabel.text = @"该动态已删除";
    [self.view addSubview:self.delectView];
}

#pragma MARK -------动态评论
- (void)getDynicmaRateList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",self.dynamicid,[DataModelInstance shareInstance].userModel.userId,(long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMICDETAILRATELIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.cuurrPage == 1) {
                [weakSelf.dataArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDict in array) {
                weakSelf.datailModel = [[FinanaceDetailModel alloc] initWithDict:subDict];
                [weakSelf.dataArray addObject:weakSelf.datailModel];
            }
            if(array.count!=20){
                [weakSelf.tableView endRefreshNoData];
            }else{
                [weakSelf.tableView endRefresh];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }else if(self.dyModel){
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }
    if(section == 0) {
        if (self.dyModel.userModel.user_realname.length>0) {
            return 1;
        }else{
            return 0;
        }
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0 ){
        if(self.dyModel.type.integerValue==17 ||(self.dyModel.type.integerValue==13&&self.dyModel.exttype.integerValue==17)){
            return self.dyModel.cellHeight;
        }else{
            return self.dyModel.cellHeight - 60;
        }
    }else{
        self.datailModel = self.dataArray[indexPath.row];
        return [DynamicDetailCell backHotRateViewCell:self.datailModel] - 16;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.000001;
    }else{
        if(self.dyModel.userModel.user_realname.length > 0) {
            if (self.dyModel.praiselist.count > 0) {
                return 146;
            }else{
                return 80;
            }
        }
    }
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    CGFloat viewHeight = 0;
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 36+viewHeight) backColor:@"FBFBFC"];
    
    PriseListSectionVIew *headerView = [CommonMethod getViewFromNib:@"PriseListSectionVIew"];
    if (self.dyModel.praiselist.count > 0) {
        headerView.frame = CGRectMake(0, 0, WIDTH, 106);
        viewHeight = 106;
    }else{
        headerView.frame = CGRectMake(0, 0, WIDTH, 40);
        viewHeight = 40;
    }
    
    [headerView updateDisplay:self.dyModel];
    [view addSubview:headerView];
    
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(16, viewHeight+16, WIDTH, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FBFBFC"] textColor:[UIColor colorWithHexString:@"41464E"]];
    if (self.dataArray.count == 0) {
        titleLabel.hidden = YES;
    }
    titleLabel.text =@"全部评论";
    [view addSubview:titleLabel];
    view.backgroundColor = [UIColor colorWithHexString:@"FBFBFC"];
    viewHeight = viewHeight + 40;
    view.frame = CGRectMake(0, 0, WIDTH, viewHeight);
    return view;
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
    }else if (indexPath.section == 0){
        static NSString *cellID = @"DynamicCell";
        DynamicHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        cell = [[DynamicHeaderCell alloc] initWithDataDict:self.dyModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }else{
        static NSString *identify = @"HotRateViewCelld";
        self.datailModel = self.dataArray[indexPath.row];
        DynamicDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        NSString *str = self.datailModel.replyto[@"realname"];
        if (str.length > 0) {
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"DynamicDetailBackCell"];
            }
        }else{
            if(!cell){
                cell = [CommonMethod getViewFromNib:NSStringFromClass([DynamicDetailCell class])];
            }
        }
        cell.dynamicDetailCellDelegate = self;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.indePathRow = indexPath.row;
        [cell tranferFianaceDetailModel:self.datailModel];
        cell.backgroundColor = [UIColor colorWithHexString:@"FBFBFC"];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        [self getDynamicDetailData];
        self.cuurrPage = 1;
        [self getDynicmaRateList:self.cuurrPage];
    }
}
- (IBAction)likeTapAction:(UITapGestureRecognizer *)sender {
    
    if (self.dyModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }else{
        self.type = 2;
        [self likePraiseAllRateDynamicModel:self.dyModel FinanaceDetailModel:self.datailModel isFrist:NO inde:0];
    }
    
}

#pragma mark ----- 点赞
- (void)likePraiseBtnAction:(NSInteger)index{
    self.datailModel = self.dataArray[index];
    if (self.datailModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }else{
        self.type = 3;
        [self likePraiseAllRateDynamicModel:self.dyModel FinanaceDetailModel:self.datailModel isFrist:NO inde:index];
    }
}
- (void)likePraiseAllRateDynamicModel:(DynamicModel *)mode FinanaceDetailModel:(FinanaceDetailModel *)financeModel isFrist:(BOOL)isFrist inde:(NSInteger)inde{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *apiStr;
    if (self.type == 1) {
        
        //诸葛监控
        
        [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":self.dyModel.userModel.user_id, @"company":[CommonMethod paramStringIsNull:self.dyModel.userModel.user_company],@"position":[CommonMethod paramStringIsNull:self.dyModel.userModel.user_position]}];
        
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:self.dyModel.userModel.user_id forKey:@"otherid"];
        apiStr = API_NAME_USER_GET_ADDATION;
        
    }else if (self.type == 2){
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:self.dynamicid forKey:@"dynamicid"];
        apiStr = API_NAME_POST_DYNAMICDETAILRATELIT_PARSEDNAMIC;
    }else{
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:financeModel.reviewid forKey:@"reviewid"];
        apiStr = API_NAME_POST_DYNAMICDETAILRATELIT_PARSEVIEW;
    }
    [self requstType:RequestType_Post apiName:apiStr paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.type == 1) {
                [MBProgressHUD showSuccess:@"关注成功" toView:self.view];
                if(self.attentUser){
                    self.attentUser(YES);
                }
            }
            if (self.type == 2) {
                [MBProgressHUD showSuccess:@"点赞成功" toView:self.view];
                UserModel *model = [DataModelInstance shareInstance].userModel;
                [[AppDelegate shareInstance] setZhugeTrack:@"点赞动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:weakSelf.dyModel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:weakSelf.dyModel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:weakSelf.dyModel.exttype]}];
            }
            if (self.type == 1 || self.type == 2) {
                [self getDynamicDetailData];
            }else{
                [MBProgressHUD showSuccess:@"点赞成功" toView:self.view];
                self.datailModel.ispraise = @1;
                self.datailModel.praisecount = @(self.datailModel.praisecount.integerValue + 1);
                //一个cell刷新
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:inde inSection:1];            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
#pragma mark ----- 删除或者评论
- (void)delectOrRateTapAction:(NSInteger )index{
    self.datailModel = self.dataArray[index];
    if ([DataModelInstance shareInstance].userModel.userId.integerValue == self.datailModel.userid.integerValue) {
        // @"删除";
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否要删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        } confirm:^{
            [self delectRateIndex:self.datailModel index:index dyModel:self.dyModel];
        }];
    }else{
        //@"回复";
        self.isBack = YES;
        DymanicRateController *writeCtr = [[DymanicRateController alloc]init];
        writeCtr.dynamicID = self.datailModel.reviewid;
        writeCtr.dymanicRateControllerDelegate = self;
        writeCtr.dynamicModel = self.dyModel;
        writeCtr.nameStr = self.datailModel.realname;
        [self presentViewController:writeCtr animated:YES completion:nil];
    }
}
- (void)succendRateDynamic{
    self.cuurrPage = 1;
    [self getDynicmaRateList:self.cuurrPage];
}
#pragma mark ----- 删除评论
- (void)delectRateIndex:(FinanaceDetailModel *)model index:(NSInteger)index dyModel:(DynamicModel *)dyModel{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *API;
    if (self.isDelect) {
        [requestDict setObject:[NSString stringWithFormat:@"/%@",self.dynamicid] forKey:@"param"];
        API = API_NAME_DELETE_DYNAMICDETAILRATELIT_DELECTDYNAMIC;
    }else{
        [requestDict setObject:[NSString stringWithFormat:@"/%@",model.reviewid] forKey:@"param"];
        API = API_NAME_DELETE_DYNAMICDETAILRATELIT_DELECTRATE;
    }
    [weakSelf requstType:RequestType_Delete apiName:API paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:self.view];
            if (weakSelf.isDelect) {
                if(weakSelf.deleteDynamicDetail){
                    weakSelf.deleteDynamicDetail(weakSelf.dynamicid);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [weakSelf.dataArray removeObjectAtIndex:index];
                [weakSelf.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        NSLog(@"%@",error);
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
#pragma mark ------ 长按删除
- (void)longPreaaTapAction:(NSInteger )index{
    self.indexRow = index;
    FinanaceDetailModel *model = self.dataArray[index];
    if(self.menuCtr==nil){
        self.menuCtr = [UIMenuController sharedMenuController];
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyRateMenuAction)];
        //        UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(reportRateMenuAction)];
        if(model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
            [self.menuCtr setMenuItems:[NSArray arrayWithObjects:copy,nil]];
        }else{
            [self.menuCtr setMenuItems:[NSArray arrayWithObjects:copy, nil]];
        }
    }
    DynamicDetailCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    self.isCopy = YES;
    
    [self.menuCtr setTargetRect:cell.countLabel.frame inView:cell.countLabel.superview];
    [self.menuCtr setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder{
    self.isCopy = NO;
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action ==@selector(copyRateMenuAction) || action ==@selector(reportRateMenuAction)){
        return YES;
    }
    self.isCopy = NO;
    
    return NO;//隐藏系统默认的菜单项
}
#pragma mark---- 举报
- (void)reportRateMenuAction{
    self.datailModel = self.dataArray[self.indexRow];
    ReportViewController *report = [[ReportViewController alloc]init];
    report.reportType = ReportType_Review;
    report.reportId = self.datailModel.reviewid;
    [self.navigationController pushViewController:report animated:YES];
}
#pragma mark ----- 复制
- (void)copyRateMenuAction{
    self.isCopy = NO;
    self.datailModel = self.dataArray[self.indexRow];
    [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.datailModel.content];
    [self.tableView reloadData];
}

- (IBAction)reteFristBtnAction:(UIButton *)sender {
    self.isBack = YES;
    DymanicRateController *writeCtr = [[DymanicRateController alloc]init];
    writeCtr.dynamicID = self.dynamicid;
    writeCtr.dymanicRateControllerDelegate = self;
    writeCtr.nameStr = self.datailModel.realname;
    writeCtr.fristRate = YES;
    writeCtr.dynamicModel = self.dyModel;
    [self presentViewController:writeCtr animated:YES completion:nil];
}

- (IBAction)shareBTnAction:(UIButton *)sender {
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
        [shareSlef firendClick:index];
    }];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *html;
    if (self.dyModel.type.integerValue == 13) {
        if (self.dyModel.exttype.integerValue == 3 ||self.dyModel.exttype.integerValue == 8) {
            html = self.dyModel.parent_subject_title;
        }
        if (self.dyModel.exttype.integerValue == 4 ||self.dyModel.exttype.integerValue == 9) {
            html = self.dyModel.parent_post_title;
        }
        if (self.dyModel.exttype.integerValue == 5 ||self.dyModel.exttype.integerValue == 10) {
            html = self.dyModel.parent_activity_title;
        }
        
        if (self.dyModel.exttype.integerValue == 7 ||self.dyModel.exttype.integerValue == 12 || self.dyModel.exttype.integerValue == 6 ||self.dyModel.exttype.integerValue == 11) {
            html =  self.dyModel.parent_review_content;
        }
        if (self.dyModel.exttype.integerValue == 1) {
            //村文本
            html = self.dyModel.parent_content;
        }
        if (self.dyModel.exttype.integerValue == 2) {
            //村文本
            if (self.dyModel.parent_content.length > 0) {
                html = self.dyModel.parent_content;
                
            }else{
                NSArray *imageArray = [self.dyModel.parent_image componentsSeparatedByString:@","];
                html = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
            }
        }
    }else{
        if (self.dyModel.type.integerValue == 3 || self.dyModel.type.integerValue == 8) {
            html = self.dyModel.subject_title;
        }
        
        if (self.dyModel.type.integerValue == 4 ||self.dyModel.type.integerValue == 9) {
            html = self.dyModel.post_title;
        }
        if (self.dyModel.type.integerValue == 5 ||self.dyModel.type.integerValue == 10) {
            html =  self.dyModel.activity_title;
            
        }
        if (self.dyModel.type.integerValue == 7 ||self.dyModel.type.integerValue == 12 || self.dyModel.type.integerValue == 6 ||self.dyModel.type.integerValue == 11) {
            html =  self.dyModel.review_content;
        }
        if (self.dyModel.type.integerValue == 1) {
            //村文本
            html = self.dyModel.content;
        }
        if (self.dyModel.type.integerValue == 2) {
            //村文本
            if (self.dyModel.content.length > 0) {
                html = self.dyModel.content;
                
            }else{
                NSArray *imageArray = [self.dyModel.image componentsSeparatedByString:@","];
                html = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
            }
        }
    }
    
    
    NSString *title = [NSString stringWithFormat:@"%@的金脉动态", self.dyModel.parent_user_realname];
    html = [html filterHTML];
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *imageUrl = self.dyModel.parent_user_image;
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.dynamicid];
    UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
        
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    if(self.dyModel.type.integerValue == 17){
        title = self.dyModel.title;
        content = self.dyModel.content;
        contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.dyModel.dynamic_id];
    }else if(self.dyModel.type.integerValue == 13 && self.dyModel.exttype.integerValue == 17){
        title = self.dyModel.parent_title;
        contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.dyModel.parent];
        content = title;//self.model.parent_content;
    }
    switch (index){
        case 0:{
            self.isBack = YES;
            TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
            jinmai.model = self.dyModel;
            [self presentViewController:jinmai animated:YES completion:nil];
            break;
        }
        case 1:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 2:{
            title = content;
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 3:{
            self.isBack = YES;
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.dymodel = self.dyModel;
            [self.navigationController pushViewController:choseCtr animated:YES];
            return;
        }
        case 4:{
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
            UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
            [generalPasteBoard setString:contentUrl];
            return;
        }
    }
}

- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    [[AppDelegate shareInstance] setZhugeTrack:@"分享动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:self.dyModel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:self.dyModel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:self.dyModel.exttype]}];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 1) {
        shareType = UMSocialPlatformType_WechatSession;
    }else {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:count thumImage:imageSource];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
}

- (IBAction)likeFristBtn:(UIButton *)sender {
    if (self.dyModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点赞啦"];
        return;
    }else{
        self.type = 2;
        [self likePraiseAllRateDynamicModel:self.dyModel FinanaceDetailModel:self.datailModel isFrist:YES inde:0];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    CGFloat sectionHeaderHeight = 0;
    //    if (self.dyModel.praiselist.count > 0) {
    //        sectionHeaderHeight =  146;
    //    }else{
    //        sectionHeaderHeight =  80;
    //    }
    //
    //    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
    //        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    //    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
    //        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    //    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
