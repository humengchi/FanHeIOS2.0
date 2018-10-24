//
//  SubjectDetailViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SubjectDetailViewController.h"
#import "ActivityReportListCell.h"
#import "ActivityOverViewCell.h"
#import "ActivityVIewCell.h"
#import "SubjectView.h"

#import "InformationDetailController.h"
#import "ActivityDetailController.h"
@interface SubjectDetailViewController ()
@property (nonatomic ,strong)    UIView *headerView;
@property (nonatomic ,strong)  UILabel *countLabel;
@property (nonatomic ,strong)    UIView *sectionView;
@property (nonatomic ,strong)   NSMutableArray *activityArray;
@property (nonatomic ,strong)   NSMutableArray *activityReportArray;
@property (nonatomic ,strong)  ReportModel *reportModel;
@property (nonatomic ,assign) NSInteger currentPag;
@property (nonatomic,strong) MyActivityModel *activityModle;
@property (nonatomic ,strong) UIButton *unfoldBtn;
@property (nonatomic ,strong) UIView *backView;
@property (nonatomic ,strong) UIView *unfoldView;
@property (nonatomic ,strong) UILabel *showLabel;
@end

@implementation SubjectDetailViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UserModel *model = [DataModelInstance shareInstance].userModel;
    [[AppDelegate shareInstance] setZhugeTrack:@"活动详情" properties:@{@"useID":model.userId, @"position":[CommonMethod paramStringIsNull:model.position],@"address":[CommonMethod paramNumberIsNull:model.city],@"goodAt":[[CommonMethod paramArrayIsNull:model.goodjobs]componentsJoinedByString:@","],@"industry":model.industry}];
    self.activityArray = [NSMutableArray new];
    self.activityReportArray = [NSMutableArray new];
    self.Actiontype = ActionStat;
    self.currentPag = 1;
    [self createCustomNavigationBar:self.model.name];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    [self createrReportHeaderView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getSubjectActivityList:self.currentPag];
    
}
#pragma mark ------  获取活动列表
- (void)getSubjectActivityList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    self.tableView.tableFooterView = [UIView new];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld/%@", page,self.model.asid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_SUBJECTREPOIT_REPORTACTIVITY_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.currentPag == 1) {
                [weakSelf.tableView endRefresh];
                [weakSelf.tableView.mj_footer resetNoMoreData];
                [weakSelf.activityArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            for (NSDictionary *subDic in array) {
                
                weakSelf.activityModle = [[MyActivityModel alloc] initWithDict:subDic];
                [weakSelf.activityArray addObject:weakSelf.activityModle];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
}


#pragma mark ------  获取报道列表
- (void)getActivityReportList:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    self.tableView.tableFooterView = [UIView new];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld/%@", page,self.model.asid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_SUBJECTREPOIT_ACTIVITY_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.currentPag == 1) {
                [weakSelf.tableView endRefresh];
                [weakSelf.tableView.mj_footer resetNoMoreData];
                [weakSelf.activityReportArray removeAllObjects];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            for (NSDictionary *subDic in array) {
                
                weakSelf.reportModel = [[ReportModel alloc] initWithDict:subDic];
                [weakSelf.activityReportArray addObject:weakSelf.reportModel];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
    
}
#pragma mark ------  头视图
- (void)createrReportHeaderView{
    CGFloat heigthLabel = [self getSpaceLabelHeight:self.model.intro withFont:[UIFont systemFontOfSize:17.0] withWidth:WIDTH - 32];
    CGFloat heigth1 = heigthLabel;
    NSInteger  lineCount = 3;
    self.headerView = [[UIView alloc]init];
    CGFloat heigth = 0;
    if (heigth1 > 66) {
        heigth1 = 66 + 103 + 41;
        lineCount = 3;
        heigth1 += 10;
        heigth = heigth1;
        self.headerView.frame = CGRectMake(0, 0, WIDTH, heigth);
    }else{
        heigth1 += 103 + 26;
        heigth1 += 10;
        heigth = heigth1;
        self.headerView.frame = CGRectMake(0, 0, WIDTH, heigth);
    }
    
    if (heigthLabel > 66) {
        self.unfoldView = [[UIView alloc]initWithFrame:CGRectMake(0, heigth - 50,WIDTH, 40)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choseBtnAction)];
        [self.unfoldView addGestureRecognizer:tap];
        [self.headerView addSubview:self.unfoldView];
        self.unfoldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.unfoldBtn.frame = CGRectMake(WIDTH/2.0 - 7.5, heigth - 36, 15, 8.5);
        [self.unfoldBtn addTarget:self action:@selector(choseBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.unfoldBtn setImage:[UIImage imageNamed:@"btn_darrow_bg"] forState:UIControlStateNormal];
        [self.unfoldBtn setImage:[UIImage imageNamed:@"btn_tarrow_bg"] forState:UIControlStateSelected];
        self.unfoldBtn.selected = NO;
        [self.headerView addSubview:self.unfoldBtn];
    }
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
    UIImageView *tagImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2.0 - 32.5, 16, 75, 75)];
    [tagImageView sd_setImageWithURL:[NSURL URLWithString:self.model.ios_icon2x] placeholderImage:[UIImage imageNamed:@""]];
    tagImageView.contentMode = UIViewContentModeScaleAspectFill;
    //设置圆角
    tagImageView.layer.cornerRadius = tagImageView.frame.size.width / 2;
    //将多余的部分切掉
    tagImageView.layer.masksToBounds = YES;
    [self.headerView addSubview:tagImageView];
    CGFloat heigthLabel1 = [self getSpaceLabelHeight:self.model.intro withFont:[UIFont systemFontOfSize:17.0] withWidth:WIDTH - 32];
    if (heigth1 > 66) {
        heigthLabel1 = 66;
    }
    self.countLabel = [UILabel createrLabelframe:CGRectMake(16, 103, WIDTH - 32, heigthLabel1) backColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"41464E"] test:self.model.intro font:17.0 number:3 nstextLocat:NSTextAlignmentLeft];
    [self.headerView addSubview:self.countLabel];
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, heigth - 10, WIDTH, 10)];
    self.backView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self.headerView addSubview:self.backView];
}
- (NSAttributedString *)createrwithValue:(NSString*)str withFont:(UIFont*)font{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 7; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:str attributes:nil];
    return attributeStr;
}
//计算UILabel的高度(带有行间距的情况)
-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 7;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
                          };
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

- (void)choseBtnAction{
    self.unfoldBtn.selected = !self.unfoldBtn.selected;
    CGFloat heigth1 = [NSHelper heightOfString:self.model.intro font:[UIFont systemFontOfSize:17.0] width:WIDTH - 32];
    CGFloat heigth = heigth1;
    CGFloat lineHeight = [UIFont systemFontOfSize:17.0].lineHeight;
    if (self.unfoldBtn.selected) {
        self.countLabel.numberOfLines = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.countLabel.frame = CGRectMake(16, 103, WIDTH - 32, heigth);
            self.headerView.frame = CGRectMake(0, 0, WIDTH, heigth + 154);
            self.unfoldView.frame = CGRectMake(0, self.headerView.frame.size.height - 50,WIDTH, 40);
            self.unfoldBtn.frame = CGRectMake(WIDTH/2.0 - 7.5, self.headerView.frame.size.height - 36, 15, 8.5);
            self.backView.frame = CGRectMake(0, self.headerView.frame.size.height - 10, WIDTH, 10);
            self.tableView.tableHeaderView = self.headerView;
        } completion:^(BOOL finished) {
        }];
    }else{
        heigth = 3*lineHeight + 154;
        self.countLabel.numberOfLines = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.countLabel.frame = CGRectMake(16, 103, WIDTH - 32, heigth - 154);
            self.headerView.frame = CGRectMake(0, 0, WIDTH, heigth );
            self.unfoldView.frame = CGRectMake(0, self.headerView.frame.size.height - 50,WIDTH, 40);
            self.unfoldBtn.frame = CGRectMake(WIDTH/2.0 - 7.5, self.headerView.frame.size.height - 36, 15, 8.5);
            self.backView.frame = CGRectMake(0, self.headerView.frame.size.height - 10, WIDTH, 10);
            self.tableView.tableHeaderView = self.headerView;
        } completion:^(BOOL finished) {
            self.countLabel.numberOfLines = 3;
        }];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ( self.Actiontype == ActionStat)
    {
        if(self.activityArray.count>0){
            return  self.activityArray.count;
        }else{
            return 1;
        }
    }
    if (self.Actiontype == ActionReportStant)
    {
        if(self.activityReportArray.count>0){
            return  self.activityReportArray.count;
        }else{
            return 1;
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ( self.Actiontype == ActionStat)
    {
        if(self.activityArray.count>0){
            self.activityModle = self.activityArray[indexPath.row];
            if ([self.activityModle.price isEqualToString:@"已结束"]) {
                return 116;
            }
            return self.activityModle.cellHeight;
        }else{
            return HEIGHT-44-64;
        }
    }else {
        if(self.activityReportArray.count>0){
            return 106;
        }else{
            return HEIGHT-44-64;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 43;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    self.sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 43)];
    self.sectionView.backgroundColor = [UIColor whiteColor];
    NSArray *titleArray = @[@"活动预告",@"活动报道"];
    for (NSInteger i = 0; i < titleArray.count; i++) {
        CGFloat x = 0+ i*(WIDTH/2.0);
        UIButton *btn = [NSHelper createButton:CGRectMake(x, 0,WIDTH/2.0 , 43) title:titleArray[i] unSelectImage:nil selectImage:nil target:self selector:@selector(selectBtnAction:)];
        //        [btn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithHexString:@"41464E"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        btn.tag = i;
        self.showLabel = [[UILabel alloc]initWithFrame:CGRectMake(x+(btn.frame.size.width/2.0- 32.5) , 41, 65, 2)];
        self.showLabel.tag = i;
        self.showLabel.backgroundColor = [UIColor colorWithHexString:@"E24943"];
        [self.sectionView addSubview:self.showLabel];
        self.showLabel.hidden = YES;
        if ( self.Actiontype == ActionStat)
        {
            if (i == 0) {
                btn.selected = YES;
                self.showLabel.hidden = NO;
            }
        }
        if (self.Actiontype == ActionReportStant)
        {
            if (i == 1) {
                btn.selected = YES;
                self.showLabel.hidden = NO;
                
            }
        }
        [self.sectionView addSubview:btn];
    }
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,42.5, WIDTH,0.5)];
    view.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [self.sectionView addSubview:view];
    return self.sectionView;
    
}
- (void)selectBtnAction:(UIButton *)btn{
    
    for (UIView *sub in self.sectionView.subviews)
    {
        if ([sub isKindOfClass:[UIButton class]])
        {
            UIButton *lbtn = (UIButton *)sub;
            
            lbtn.selected = NO;
        }
    }
    btn.selected = YES;
    for (UIView *view in self.sectionView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if (label.tag == btn.tag) {
                label.hidden = NO;
            }else{
                label.hidden = YES;
            }
        }
        
    }
    if (btn.tag == 0)
    { self.Actiontype = ActionStat;
        [self getSubjectActivityList:self.currentPag];
        
    }
    if (btn.tag == 1)
    { self.Actiontype = ActionReportStant;
        [self getActivityReportList:self.currentPag];
        
    }
    [self.tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( self.Actiontype == ActionStat && self.activityArray.count>0){
        UITableViewCell *cell = [self ActionConsumedCellFortableView:self.tableView atIndexPath:indexPath];
        return cell;
    }else if (self.Actiontype == ActionReportStant && self.activityReportArray.count>0){
        UITableViewCell *cell = [self ActionReportRateCellFortableView:self.tableView atIndexPath:indexPath];
        return cell;
    }else{
        static NSString *cellID = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:[self createrTabViewFootView]];
        return cell;
    }
    return nil;
}
#pragma mark------活动预告
- (UITableViewCell *)ActionConsumedCellFortableView:(UITableView *)tableView atIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellID = @"ActivityVIewCell";
    self.activityModle = self.activityArray[indexPath.row];
    if ([self.activityModle.price isEqualToString:@"已结束"]) {
        ActivityOverViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityOverViewCell class])];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell tranferActivityVIewCellModel:self.activityModle];
        return cell;
    }else{
        ActivityVIewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityVIewCell class])];
        }
        cell.index = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell tranferActivityVIewCellModel:self.activityModle];
        return cell;
    }
    
}
#pragma mark------活动报道
- (UITableViewCell *)ActionReportRateCellFortableView:(UITableView *)tableView atIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellID = @"ActivityReportListCell";
    ActivityReportListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityReportListCell class])];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.reportModel = self.activityReportArray[indexPath.row];
    [cell tranferActivityReportModel:self.reportModel];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( self.Actiontype == ActionStat && self.activityArray.count>0)
    {
        ActivityDetailController *activityDetail = [[ActivityDetailController alloc]init];
        self.activityModle = self.activityArray[indexPath.row];
        activityDetail.activityid = self.activityModle.activityid;
        
        [self.navigationController pushViewController:activityDetail animated:YES];
    }else if (self.Actiontype == ActionReportStant && self.activityReportArray.count>0)
    {
        self.reportModel = self.activityReportArray[indexPath.row];
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.startType = YES;
        vc.postID = self.reportModel.pid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (SubjectView*)createrTabViewFootView{
    SubjectView *subjectView = [CommonMethod getViewFromNib:NSStringFromClass([SubjectView class])];
    subjectView.frame = CGRectMake(0, 0, WIDTH, HEIGHT - 44 - 64);
    subjectView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    if ( self.Actiontype == ActionStat)
    {
        subjectView.titleLabel.text = @"暂无任何活动预告";
        subjectView.coverImageView.image = [UIImage imageNamed:@"icon_zt_nonhd"];
    }
    if (self.Actiontype == ActionReportStant)
    {
        subjectView.titleLabel.text = @"暂无任何活动报道";
        subjectView.coverImageView.image = [UIImage imageNamed:@"icon_zt_nonnews"];
    }
    return subjectView;
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
