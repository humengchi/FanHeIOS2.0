//
//  InterviewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/14.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "InterviewController.h"
#import "InterviewCell.h"
#import "FianaceCell.h"
#import "GuestsAppayController.h"
#import "InformationDetailController.h"
#import "NONetWorkTableViewCell.h"
#import "HomeTableViewCell.h"

@interface InterviewController ()
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,strong)  TalkFianaceModel *financeModel;
@property (nonatomic,strong)  NSMutableArray *interviewArray;
@property (nonatomic,strong)  NSMutableArray *moodsArray;

@property (strong, nonatomic) IBOutlet UIView *colctView;
@property (nonatomic,assign)  NSInteger currentPag;
@property (nonatomic,assign) BOOL isPresentVC;
@end

@implementation InterviewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isPresentVC = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault &&     self.isPresentVC == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.netWorkStat = NO;
    self.interviewArray = [NSMutableArray new];
    self.moodsArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"大家聊金融"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self createrTalkFianaceTabHeaderView];
    self.currentPag = 1;
    [self getMoodsSubjectTalkFianace];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getSubjectTalkFianace:self.currentPag];
    });
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getSubjectTalkFianace:self.currentPag];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isrferGetData) name:InformationRefar object:nil];
   
}
- (void)isrferGetData{
     self.currentPag = 1;
      [self getSubjectTalkFianace:self.currentPag];
}

#pragma mark ------  获取人气嘉宾
- (void)getMoodsSubjectTalkFianace{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_MOODSFINANACE_HONORED paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.financeModel = [[TalkFianaceModel alloc] initWithDict:dict];
                [self.moodsArray addObject:weakSelf.financeModel];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
    }];
    
}

#pragma mark ------  获取专访列表数据
- (void)getSubjectTalkFianace:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld", (long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_INTERVIEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.financeModel = [[TalkFianaceModel alloc] initWithDict:dict];
                [self.interviewArray addObject:weakSelf.financeModel];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
    
}
- (void)createrTalkFianaceTabHeaderView{
    UIImageView *headerImageView = [UIImageView drawImageViewLine:CGRectMake(0, 0, WIDTH, WIDTH *465/1080) bgColor:[UIColor whiteColor]];
    headerImageView.image = kImageWithName(@"Back");
    headerImageView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = headerImageView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(applyJoinAction)];
    [headerImageView addGestureRecognizer:tap];
}
#pragma mark ------报名参加
- (void)applyJoinAction{
    self.isPresentVC = YES;
    GuestsAppayController *guestsCtr = [[GuestsAppayController alloc]init];
    [self.navigationController pushViewController:guestsCtr animated:YES];
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 1;
    }else if (section == 0) {
        return 1;
    }
    return self.interviewArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0) {
        return 244;
    }
    self.financeModel = self.interviewArray[indexPath.row];
    return [InterviewCell tableFrameInterviewCellHeigthContactsModel:self.financeModel]  - 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.netWorkStat == YES){
        return 1;
    }
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.netWorkStat == YES){
        return 0;
    }
    return 35;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    NSArray *titleArray = @[@"人气嘉宾",@"精彩访谈"];
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 35) backColor:@"FFFFFF"];
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(0, 21, WIDTH, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = titleArray[section];
    [view addSubview:titleLabel];
    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    backLabel.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [view addSubview:backLabel];
    return view;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else if(indexPath.section == 0) {
        static NSString *str = @"";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:str];
        }
        for (UIView *vew in cell.contentView.subviews) {
            [vew removeFromSuperview];
        }
        UIScrollView *scrrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 244)];
        for (NSInteger i = 0; i < self
             .moodsArray.count; i++) {
            self.financeModel = self.moodsArray[i];
            UIView *view = [self createrSlidView:self.financeModel xwideth:i];
            [scrrolView addSubview:view];
            view.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hisMainPage:)];
            view.userInteractionEnabled = YES;
            [view addGestureRecognizer:tap];
        }
        CGFloat wideth = self.moodsArray.count * (16+128)+16;
        scrrolView.showsHorizontalScrollIndicator = NO;
        scrrolView.contentSize = CGSizeMake(wideth, 128);
        [cell.contentView addSubview:scrrolView];
        return cell;
        
    }else{
        static NSString *identify = @"TalkFinanceCell";
        InterviewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([InterviewCell class])];
        }
        self.financeModel = self.interviewArray[indexPath.row];
        [cell tranferInterviewCellFianaceModel:self.financeModel];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        self.isPresentVC = YES;
        InformationDetailController *intViwCtr = [[InformationDetailController alloc]init];
        self.financeModel = self.interviewArray[indexPath.row];
        intViwCtr.postID = self.financeModel.postid;
        [self.navigationController pushViewController:intViwCtr animated:YES];
    }
}
#pragma mark ------ 她的主页
- (void)hisMainPage:(UITapGestureRecognizer *)g{
    self.isPresentVC = YES;
    NSInteger index = g.view.tag;
    self.financeModel = self.moodsArray[index];
    NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
    home.userId = self.financeModel.userid;
    [self.navigationController pushViewController:home animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ------ 创建滚动View
- (UIView *)createrSlidView:(TalkFianaceModel *)model xwideth:(CGFloat)xWideth{
    NSLog(@"%@",model.company);
    CGFloat x = 16;
    CGFloat y = 16;
    UIView *homeView = [NSHelper createrViewFrame:CGRectMake(x + (128+16)*xWideth, y,128, 211) backColor:@"FAFAFB"];
    UIImageView *coverImageView = [UIImageView drawImageViewLine:CGRectMake(0, 0, 128, 128) bgColor:[UIColor clearColor]];
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    [homeView addSubview:coverImageView];
    UIImageView *memberImageView = [UIImageView drawImageViewLine:CGRectMake(0, 0, 40, 40) bgColor:[UIColor clearColor]];
    memberImageView.image = kImageWithName(@"icon_rz_yrz");
    [homeView addSubview:memberImageView];
    if (model.realname.length > 5) {
        model.realname = [model.realname substringToIndex:5];
    }
    CGFloat wideth = [NSHelper widthOfString:model.realname font:[UIFont systemFontOfSize:14] height:14];
    CGFloat heigth = coverImageView.frame.origin.y+coverImageView.frame.size.height;
    UILabel *nameLabel = [UILabel createLabel:CGRectMake(8, heigth+ 15, wideth, 16) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    nameLabel.text = model.realname;
    [homeView addSubview:nameLabel];
    UIImageView *vityImageView = [UIImageView drawImageViewLine:CGRectMake(wideth + 12, heigth + 13, 16, 16) bgColor:[UIColor colorWithHexString:@"FAFAFB"]];
    vityImageView.image = kImageWithName(@"btn_zy_v");
    [homeView addSubview:vityImageView];
    heigth = heigth + 15+14+7;
    UILabel *companyLabel = [UILabel createLabel:CGRectMake(8, heigth, 128 - 8-6, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"41464E"]];
    companyLabel.text = model.company;
    [homeView addSubview:companyLabel];
    heigth = heigth + 14 + 6;
    UILabel *positionLabel = [UILabel createLabel:CGRectMake(8, heigth, 128 - 8-6, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"41464E "]];
    positionLabel.text = model.position;
    [homeView addSubview:positionLabel];
    homeView.layer.borderWidth = 0.5;
    homeView.layer.borderColor = [[UIColor colorWithHexString:@"D9D9D9"] CGColor];
    if (model.usertype.integerValue != 9) {
        vityImageView.hidden = YES;
    }
    if (model.hasValidUser.integerValue != 1) {
        memberImageView.hidden = YES;
    }
    return homeView;
}
#pragma mark ------- 去掉Section的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = 35;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


@end
