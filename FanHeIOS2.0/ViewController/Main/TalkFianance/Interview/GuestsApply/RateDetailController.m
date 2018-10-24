//
//  RateDetailController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RateDetailController.h"
#import "HotRateViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "PraiseListViewController.h"
#import "WriteRateController.h"
#import "DelectDataView.h"
#import "ReportViewController.h"

@interface RateDetailController ()<HotRateViewCellDelegate,WriteRateControllerDelegate>
@property (nonatomic ,assign)  BOOL netWorkStat;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) FinanaceDetailModel *datailModel;
@property (nonatomic ,strong) FinanaceDetailModel *headerDatailModel;
@property (nonatomic, strong) UIMenuController *menuCtr;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (nonatomic ,assign)  NSInteger indepathRow;
@property (nonatomic,assign)  BOOL startType;
@property (weak, nonatomic) IBOutlet UIButton *rateBtn;
@property (weak, nonatomic) IBOutlet UILabel *rateAcountLabel;
@property (nonatomic,strong) NSMutableArray *imageArray;
@end

@implementation RateDetailController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.netWorkStat = NO;
    self.indepathRow = -1;
    self.rateBtn.layer.masksToBounds = YES;
    self.rateBtn.layer.cornerRadius = 15;
    [self.rateBtn.layer setBorderWidth:0.5]; //边框宽度
    self.rateBtn.layer.borderColor=[UIColor colorWithHexString:@"D9D9D9"].CGColor;
    self.imageArray = [NSMutableArray new];
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"评论详情"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64 - 55)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"FBFBFC"];
    [self getSecoundNewRateData];
    
}

#pragma mark --------  最新评论数据
- (void)getSecoundNewRateData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.reviewid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_SECOUNDNEWRATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [self.imageArray removeAllObjects];
            [self.dataArray removeAllObjects];
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSString *delectStr = [CommonMethod paramStringIsNull:[responseObject objectForKey:@"msg"]];
            NSArray *array = [CommonMethod paramArrayIsNull:[dict objectForKey:@"reviewlist"]];
            weakSelf.headerDatailModel = [[FinanaceDetailModel alloc] initWithDict:dict[@"reviewdetail"]];
            self.headerDatailModel.hotRateStart = YES;
            NSArray *imageArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"praiselist"][@"list"]];
            for (NSDictionary *imageDict in imageArray) {
                UserModel *model = [[UserModel alloc] initWithDict:imageDict];
                [self.imageArray addObject:model];
            }
            
            for (NSDictionary *subDict in array) {
                weakSelf.datailModel = [[FinanaceDetailModel alloc] initWithDict:subDict];
                [self.dataArray addObject:weakSelf.datailModel];
            }
            if ([delectStr isEqualToString:@"已删除"]) {
                [self delectNewDetail];
            }else{
                [weakSelf.tableView reloadData];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark ----- 数据被删除
- (void)delectNewDetail{
    [self.tableView removeFromSuperview];
    DelectDataView *delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    delectView.showTitleLabel.text = @"该评论已被删除";
    delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    [self.view addSubview:delectView];
}
#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 1;
    }else if (section == 0){
        return 1;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0){
        return [HotRateViewCell backHotRateViewCell:self.headerDatailModel]-8;
    }else{
        self.datailModel = self.dataArray[indexPath.row];
        return [HotRateViewCell backHotRateViewCell:self.datailModel];
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.dataArray.count == 0){
        return 0;
    }
    if (section == 0) {
        return 0;
    }else if (self.imageArray.count == 0 && self.dataArray.count == 0) {
        return 0;
    }else if (self.imageArray.count > 0 && self.dataArray.count == 0) {
        return 66;
    }else if (self.imageArray.count == 0 && self.dataArray.count > 0) {
        return 36;
    }else{
        return 102;
        
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat  viewHeight = 0;
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 36+viewHeight) backColor:@"FBFBFC"];
    
    if (self.imageArray.count > 0) {
        viewHeight = 66;
        
        UIView *friendsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
        [CommonMethod viewAddGuestureRecognizer:friendsView tapsNumber:1 withTarget:self withSEL:@selector(gotoZanList)];
        friendsView.backgroundColor = WHITE_COLOR;
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 25, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [friendsView addSubview:nextImageView];
        CGFloat strWidth = [NSHelper widthOfString:[NSString stringWithFormat:@"%ld个人赞过", self.imageArray.count] font:FONT_SYSTEM_SIZE(14) height:50];
        UILabel *friNumLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-33-strWidth, 0, strWidth, 66) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:[NSString stringWithFormat:@"%ld个人赞过",self.imageArray.count] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [friendsView addSubview:friNumLabel];
        for (int i=0; i < self.imageArray.count; i++) {
            if(WIDTH-33-strWidth<16+27*i+18){
                break;
            }
            UserModel *model = self.imageArray[i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, 16, 34, 34)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            [friendsView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
        [view addSubview:friendsView];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight - 0.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [view addSubview:lineLabel];
        
    }
    
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(16, viewHeight+16, WIDTH, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"FBFBFC"] textColor:[UIColor colorWithHexString:@"41464E"]];
    if (self.dataArray.count == 0) {
        titleLabel.hidden = YES;
    }
    titleLabel.text =@"全部评论";
    [view addSubview:titleLabel];
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
    }else if(indexPath.section == 0){
        static NSString *identify = @"HotRateViewCell";
        HotRateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([HotRateViewCell class])];
        }
        if(self.headerDatailModel.ispraise.integerValue == 1) {
            self.likeBtn.selected = YES;
            self.rateAcountLabel.textColor = [UIColor colorWithHexString:@"E24943"];
        }
        if (self.headerDatailModel.praisecount.integerValue > 10000) {
            self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld万",self.headerDatailModel.praisecount.integerValue/10000];
        }else{
            self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld",(long)self.headerDatailModel.praisecount.integerValue];
        }
        cell.headerAttentBtn.selected = self.headerDatailModel.isattention.integerValue;
        if([DataModelInstance shareInstance].userModel.userId.integerValue != self.headerDatailModel.userid.integerValue){
            cell.headerAttentBtn.hidden = NO;
        }
        cell.likeRateBtn.hidden = YES;
        cell.rateCountLabel.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.indePathRow = indexPath.row;
        [cell tranferFianaceDetailModel:self.headerDatailModel];
        cell.hotRateViewCellDelegate = self;
        return cell;
    }else{
        static NSString *identify = @"HotRateViewCelld";
        self.datailModel = self.dataArray[indexPath.row];
        HotRateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (self.datailModel.realname.length > 0) {
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"HotRateViewListCell"];
            }
        }else{
            if(!cell){
                cell = [CommonMethod getViewFromNib:NSStringFromClass([HotRateViewCell class])];
            }
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.indePathRow = indexPath.row;
        [cell tranferFianaceDetailModel:self.datailModel];
        cell.hotRateViewCellDelegate = self;
        cell.backgroundColor = [UIColor colorWithHexString:@"FBFBFC"];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.dataArray.count == 0 ){
        [self getSecoundNewRateData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---- goto点赞列表
- (void)gotoZanList{
    PraiseListViewController *ratePraise = [[PraiseListViewController alloc]init];
    ratePraise.reviewid = self.reviewid;
    ratePraise.listType = YES;
    [self.navigationController pushViewController:ratePraise animated:YES];
}

#pragma mark ------ HotRateViewCellDelegate;
- (void)attentionTapAction{
    //诸葛监控

    [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":self.headerDatailModel.userid, @"company":[CommonMethod paramStringIsNull:self.headerDatailModel.company],@"position":[CommonMethod paramStringIsNull:self.headerDatailModel.position]}];


    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.headerDatailModel.userid forKey:@"otherid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_ADDATION paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
            weakSelf.headerDatailModel.isattention = @(1);
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
#pragma mark ------  点赞
- (void)likePraiseBtnAction:(NSInteger)index hotRate:(BOOL)start{
    NSInteger sction;
    if (start == YES) {
        sction = 0;
        self.datailModel = self.headerDatailModel;
    }else{
        sction = 1;
        self.datailModel = self.dataArray[index];
    }
    if (self.datailModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.datailModel.reviewid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_GETRATELIKE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"点赞成功" toView:self.view];
            if (start == YES) {
                self.headerDatailModel.ispraise = @1;
                self.headerDatailModel.praisecount = @(self.datailModel.praisecount.integerValue + 1);;
                self.likeBtn.selected = YES;
                [self getSecoundNewRateData];
                
                if (self.headerDatailModel.praisecount.integerValue > 10000) {
                    self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld万",self.headerDatailModel.praisecount.integerValue/10000];
                }else{
                    self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld",self.headerDatailModel.praisecount.integerValue];
                }
            }else{
                self.datailModel.ispraise = @1;
                self.datailModel.praisecount = @(self.datailModel.praisecount.integerValue + 1);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ratePostName object:nil];
            //一个cell刷新
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:sction];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
#pragma mark ------  回复或删除
- (void)delectOrRateTapAction:(NSInteger)index hotRate:(BOOL)start{
    if (start == YES) {
        self.datailModel = self.headerDatailModel;
    }else{
        self.datailModel = self.dataArray[index];
    }
    if ([DataModelInstance shareInstance].userModel.userId.integerValue == self.datailModel.userid.integerValue) {
        // @"删除";
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否要删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        } confirm:^{
            [self index:index hotRate:start];
        }];
    }else{
        //@"回复";
        WriteRateController *writeCtr = [[WriteRateController alloc]init];
        writeCtr.postID = self.datailModel.reviewid;
        writeCtr.writeRateControllerDelegate = self;
        writeCtr.nameStr = self.datailModel.realname;
        writeCtr.backRate = YES;
        [self presentViewController:writeCtr animated:YES completion:nil];
    }
}
-(void)senderRateSuccendBack:(BOOL)isRefer{
    [self getSecoundNewRateData];
}
#pragma mark ------  投诉
- (void)longPreaaTapAction:(NSInteger)index hotRate:(BOOL)start{
    CGFloat section = 0;
    if (start == YES) {
        section = 0;
        self.datailModel = self.headerDatailModel;
    }else{
        section = 1;
        self.datailModel = self.dataArray[index];
    }
    self.startType = start;
    self.indepathRow = index;
    [self showCopyOrDelect:self.datailModel index:index section:section];
}
- (void)showCopyOrDelect:(FinanaceDetailModel *)model index:(NSInteger)index section:(NSInteger)section{
    if(self.menuCtr==nil){
        self.menuCtr = [UIMenuController sharedMenuController];
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyRateMenuAction)];
        UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(reportRateMenuAction)];
        if(model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
            [self.menuCtr setMenuItems:[NSArray arrayWithObjects:copy,nil]];
        }else{
            [self.menuCtr setMenuItems:[NSArray arrayWithObjects:copy, report, nil]];
        }
    }
    HotRateViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
    
    [self.menuCtr setTargetRect:cell.contentLabel.frame inView:cell.contentLabel.superview];
    [self.menuCtr setMenuVisible:YES animated:YES];
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action ==@selector(copyRateMenuAction) || action ==@selector(reportRateMenuAction)){
        return YES;
    }
    return NO;//隐藏系统默认的菜单项
}
- (void)reportRateMenuAction{
    if (self.startType == YES) {
        self.datailModel = self.headerDatailModel;
    }else{
        self.datailModel = self.dataArray[self.indepathRow];
    }
    ReportViewController *report = [[ReportViewController alloc]init];
    report.reportType = ReportType_Review;
    report.reportId = self.datailModel.reviewid;
    [self.navigationController pushViewController:report animated:YES];
}
- (void)copyRateMenuAction{
    
    self.datailModel = self.dataArray[self.indepathRow];
    [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.datailModel.content];
}
#pragma mark ------ 删除评论
- (void)index:(NSInteger)index hotRate:(BOOL)start{
    __weak typeof(self) weakSelf = self;
    if (start != YES ) {
        self.datailModel = self.dataArray[index];
    }else{
        self.datailModel = self.headerDatailModel;
    }
    
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",weakSelf.datailModel.reviewid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [weakSelf requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_GETDELECTRATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:self.view];
            if (start != YES ){
                [weakSelf.dataArray removeObjectAtIndex:index];
                [weakSelf.tableView reloadData];
            }else{
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ratePostName object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (IBAction)writeRateBtnAction:(UIButton *)sender {
    WriteRateController *writeCtr = [[WriteRateController alloc]init];
    writeCtr.postID = self.reviewid;
    writeCtr.referType = YES;
    writeCtr.backRate = YES;
    writeCtr.nameStr = self.headerDatailModel.realname;
    writeCtr.writeRateControllerDelegate = self;
    [self presentViewController:writeCtr animated:YES completion:nil];
}

- (IBAction)likeRateAction:(UIButton *)sender {
    if (self.headerDatailModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.reviewid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_GETRATELIKE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"点赞成功" toView:self.view];
            self.headerDatailModel.ispraise = @1;
            self.headerDatailModel.praisecount = @(self.datailModel.praisecount.integerValue + 1);
            self.likeBtn.selected = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:ratePostName object:nil];
            if (self.headerDatailModel.praisecount.integerValue > 10000) {
                self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld万",self.headerDatailModel.praisecount.integerValue/10000];
            }else{
                self.rateAcountLabel.text = [NSString stringWithFormat:@"%ld",(long)self.headerDatailModel.praisecount.integerValue];
            }
            
            //一个cell刷新
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

#pragma mark ------- 去掉Section的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = 36;
    if (self.imageArray.count > 0) {
        sectionHeaderHeight = 102;
    }
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


@end
