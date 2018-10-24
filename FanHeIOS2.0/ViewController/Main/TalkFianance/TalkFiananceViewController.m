//
//  TalkFiananceViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TalkFiananceViewController.h"
#import "TopicViewController.h"
#import "InterviewController.h"
#import "FianaceCell.h"
#import "PushTopicCell.h"
#import "ConventionTopicCell.h"
#import "TalkFinanceCell.h"
#import "CreateTopicViewController.h"
#import "NONetWorkTableViewCell.h"
#import "InformationDetailController.h"
#import "TopicIdentifyViewController.h"
#import "NotificationController.h"

#import "SearchAvtivityAndFianaceController.h"


@interface TalkFiananceViewController ()<FianaceCellDelegate>{
    NSInteger _newMsgCount;
}
@property (nonatomic,strong) UIButton *showBtnNotWork;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,strong)  FinanaceModel *finanaceModel;
@property (nonatomic,strong)  PushTicpsmodle *tipecModel;
@property (nonatomic,strong)  NSMutableArray *fianaceArray;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *acountLabel;
@property (weak, nonatomic) IBOutlet UIView *coruidView;
@property (nonatomic,assign) NSInteger currentPag;

@end

@implementation TalkFiananceViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.fianaceArray == nil) {
        self.fianaceArray = [NSMutableArray new];
        self.currentPag = 1;
        [self getTalkFinanceData:self.currentPag];
        
    }
    if (self.netWorkStat == NO) {
        [self.tableView tableViewAddUpLoadRefreshing:^{
            self.currentPag ++;
            [self getTalkFinanceData:self.currentPag];
        }];
        [self.tableView tableViewAddDownLoadRefreshing:^{
            self.currentPag = 1;
            
            [self getTalkFinanceData:self.currentPag];
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChange:) name:kReachabilityChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isrferGetData) name:InformationRefar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishTopicSaveSuccess) name:@"publishOrEditTopicSaveSuccess" object:nil];

    __weak typeof(self) weakSelf = self;
    self.tfNoteRequestBlock = ^(NSNumber *number){
        [weakSelf showNoReadInformation:number];
        _newMsgCount = number.integerValue;
    };
    [[AppDelegate shareInstance] setZhugeTrack:@"进入话题" properties:@{}];
}

- (void)isrferGetData{
    self.currentPag = 1;
    [self getTalkFinanceData:self.currentPag];
}

- (void)showNoReadInformation:(NSNumber *)number{
    NSInteger notecount = number.integerValue;
    if (notecount > 0) {
        [self showTabViewHeaderView:number];
    }else{
         [self showTabViewHeaderView:0];
    }
}

- (void)showTabViewHeaderView:(NSNumber *)number{
    NSInteger notecount = number.integerValue;
    
    [self initTableHeaderView:notecount];
}

- (void)initTableHeaderView:(NSInteger)index{
    CGFloat heigth = 45;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, heigth)];
    headerView.backgroundColor = HEX_COLOR(@"E6E8EB");
    CGFloat heigth1 = 0;
    if (index > 0) {
        heigth = 95;
        heigth1 = 55;
        headerView.frame = CGRectMake(0, 0, WIDTH, heigth);
        self.headerView.frame = CGRectMake(0, 0, WIDTH, 55);
        self.coruidView.layer.cornerRadius = 4;
        self.coruidView.layer.masksToBounds = YES;
        self.acountLabel.text = [NSString stringWithFormat:@"%ld 条新通知",(long)index];
        [headerView addSubview:self.headerView];
    }
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, heigth1, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:HEX_COLOR(@"E6E8EB")];
    [self.searchBar setBackgroundImage:kImageWithColor(HEX_COLOR(@"E6E8EB"), self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    self.searchBar.userInteractionEnabled = NO;
    
    [headerView addSubview:self.searchBar];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = self.searchBar.frame;
    [searchBtn addTarget:self action:@selector(gotoSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchBtn];
    self.tableView.tableHeaderView  = headerView;
}

#pragma mark ------- 去搜索
- (void)gotoSearchButtonClicked:(UIButton*)sender{
    SearchAvtivityAndFianaceController *vc = [CommonMethod getVCFromNib:[SearchAvtivityAndFianaceController class]];
    vc.type = SearchResult_Topic;
    vc.isHideNavBack = YES;
    vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
    vc.view.alpha = 0.8;
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 1;
        vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)publishTopicSaveSuccess{
    
}

- (void)getTalkFinanceData:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(self.fianaceArray.count==0){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld", (long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_FRIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.currentPag == 1) {
                [weakSelf.fianaceArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.finanaceModel = [[FinanaceModel alloc] initWithDict:dict];
                [weakSelf.fianaceArray addObject:weakSelf.finanaceModel];
            }
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.topicData = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            [DataModelInstance shareInstance].userModel = model;
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark - 网络变化
- (void)netWorkChange:(NSNotification *)netWorkChange{
    Reachability *reach = [netWorkChange object];
    [self showNetWorkStatue:reach.currentReachabilityStatus!=NotReachable];
}

- (void)showNetWorkStatue:(BOOL)hasNet{
    if (!hasNet) {
        if (self.showBtnNotWork==nil) {
            self.showBtnNotWork = [UIButton buttonWithType:UIButtonTypeCustom];
            self.showBtnNotWork.frame = CGRectMake(0, 0, WIDTH, 36);
            [self.tableView addSubview:self.showBtnNotWork];
            [self.showBtnNotWork setTitle:@"没有网络连接，请检查网络设置" forState:UIControlStateNormal];
            [self.showBtnNotWork setTitleColor:[UIColor colorWithHexString:@"8B4542"] forState:UIControlStateNormal];
            self.showBtnNotWork.titleLabel.font = [UIFont systemFontOfSize:14];
            self.showBtnNotWork.backgroundColor = [UIColor colorWithHexString:@"FFE1E1"];
        }
    }else{
        if(self.fianaceArray.count==0){
            [self getTalkFinanceData:1];
        }
        if(self.showBtnNotWork){
            [self.showBtnNotWork removeFromSuperview];
            self.showBtnNotWork = nil;
        }
    }
}
#pragma mark ----- 初始化
- (void)updateVCDisplay{
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self intNavBarButtonItem:YES frame:CGRectMake(0, 0, 20, 20) imageName:@"posticon_topic_post" buttonName:@""];
    self.netWorkStat = NO;
    self.fianaceArray = [NSMutableArray new];
    UserModel *userModel = [DataModelInstance shareInstance].userModel;
    if(userModel.topicData.count){
        for (NSDictionary *dict in [CommonMethod paramArrayIsNull:userModel.topicData]) {
            self.finanaceModel = [[FinanaceModel alloc] initWithDict:dict];
            [self.fianaceArray addObject:self.finanaceModel];
        }
    }

    self.currentPag = 1;
    [self getTalkFinanceData:self.currentPag];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getTalkFinanceData:self.currentPag];
    }];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        [self getTalkFinanceData:self.currentPag];
    }];
    [self initTableHeaderView:0];
}
#pragma mark - 创建话题
- (void)rightButtonClicked:(id)sender{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        CreateTopicViewController *vc = [[CreateTopicViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Topic;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES  && self.fianaceArray.count == 0){
        return 1;
    }
//    if (section == 0) {
//        return 1;
//    }
    return self.fianaceArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat heigth = 167.0/343.0*(WIDTH - 32);
    if(self.netWorkStat == YES  && self.fianaceArray.count == 0){
        return self.tableView.frame.size.height;
    }
//    if (indexPath.section == 0) {
//        return (heigth+52+16);
//    }else{
        FinanaceModel *model = self.fianaceArray[indexPath.row];
        if (model.type.integerValue == 1) {
            if (model.photo.length > 0){
                return heigth + 16+5 + 40;
            }else{
                return model.cellHeight;//[ConventionTopicCell tableFrameBackCellHeigthContactsModel:self.finanaceModel];
            }
        }else{
            return [TalkFinanceCell tableFrameTalkFinanceCellHeigthContactsModel:model];
        }
//    }
//    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!(self.netWorkStat == YES && self.fianaceArray.count == 0)){
        self.finanaceModel = self.fianaceArray[indexPath.row];
        if (self.finanaceModel.type.integerValue == 1) {
            if (self.finanaceModel.photo.length > 0){
                [(PushTopicCell*)cell tranferPushTopicModel:self.finanaceModel];
            }else{
                [(ConventionTopicCell *)cell createrConventionTip:self.finanaceModel];
            }
        }else{
            [(TalkFinanceCell *)cell tranferFianaceModel:self.finanaceModel];
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.netWorkStat == YES && self.fianaceArray.count == 0) {
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
       
        return cell;
//    }else if (indexPath.section == 0) {
//        static NSString *identify = @"FianaceCell";
//        FianaceCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
//        if(!cell){
//            cell = [CommonMethod getViewFromNib:NSStringFromClass([FianaceCell class])];
//        }
//        cell.selectionStyle = UITableViewCellAccessoryNone;
//        cell.fianaceCellDelegate = self;
//        [cell tranferFianaceCell];
//        return cell;
    }else{
        self.finanaceModel = self.fianaceArray[indexPath.row];
        if (self.finanaceModel.type.integerValue == 1) {
            if (self.finanaceModel.photo.length > 0){
                static NSString *identify = @"PushTopicCell";
                PushTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell){
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([PushTopicCell class])];
                    cell.selectionStyle = UITableViewCellAccessoryNone;
                }
                return cell;
            }else {
                static NSString *identify;
                if (self.finanaceModel.model.content.length > 0) {
                    identify = @"ConventionOtherTopicCell";
                }else{
                    identify = @"ConventionTopicCell";
                }
                ConventionTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell){
                    cell = [CommonMethod getViewFromNib:identify];
                }
                cell.selectionStyle = UITableViewCellAccessoryNone;
                return cell;
            }
        }else{
            static NSString *identify = @"TalkFinanceCell";
            TalkFinanceCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:NSStringFromClass([TalkFinanceCell class])];
            }
            cell.selectionStyle = UITableViewCellAccessoryNone;
            return cell;
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.netWorkStat == YES && self.fianaceArray.count == 0) {
        self.currentPag = 1;
        [self getTalkFinanceData:self.currentPag];
    }
//        else if (indexPath.section == 0) {
//        InterviewController *intViwCtr = [[InterviewController alloc]init];
//        [self.navigationController pushViewController:intViwCtr animated:YES];
//    }else if (indexPath.section == 1)
    else{
        self.finanaceModel = self.fianaceArray[indexPath.row];
        if(self.finanaceModel.type.integerValue == 2){
            InformationDetailController  *intDetailCtr = [[InformationDetailController alloc]init];
            intDetailCtr.postID = self.finanaceModel.gid;
            [self.navigationController pushViewController:intDetailCtr animated:YES];
        }else if (self.finanaceModel.type.integerValue == 1){
            TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
            vc.subjectId = self.finanaceModel.gid;//@(628);//53
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}
#pragma mark ------FianaceCellDelegate专访
- (void)gotoIntviewProgramme{
    
}

- (IBAction)notCentionTapAction:(UITapGestureRecognizer *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showNoReadInformation:@(0)];
        [self getMessagesCount];
    });
    NotificationController *notifiCtr = [[NotificationController alloc]init];
    notifiCtr.newMsgCount = _newMsgCount;
    [self.navigationController pushViewController:notifiCtr animated:YES];
    _newMsgCount = 0;
}
@end
