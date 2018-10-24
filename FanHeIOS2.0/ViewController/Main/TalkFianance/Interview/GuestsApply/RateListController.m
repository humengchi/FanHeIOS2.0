//
//  RateListController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//
#import "RateDetailController.h"
#import "RateListController.h"
#import "HotRateViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "WriteRateController.h"
#import "ReportViewController.h"
#import "ShareNormalView.h"
#import "DelectDataView.h"

@interface RateListController ()<HotRateViewCellDelegate,WriteRateControllerDelegate>
@property   (nonatomic ,strong) DelectDataView *delectView;
@property (nonatomic ,strong) NSMutableArray *hotArray;
@property (nonatomic ,strong) NSMutableArray *rateArray;
@property (nonatomic ,assign) BOOL netWorkStat;
@property (nonatomic ,strong) FinanaceDetailModel *cotentModel;
@property (nonatomic,assign)  NSInteger currentPag;
@property (nonatomic, strong) UIMenuController *menuCtr;
@property (nonatomic,assign)  BOOL startType;
@property (weak, nonatomic) IBOutlet UIButton *rateBtn;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (nonatomic,assign)  NSInteger indepathRow;

@end

@implementation RateListController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hotArray = [NSMutableArray new];
    self.rateArray = [NSMutableArray new];
    self.netWorkStat = NO;
    self.rateBtn.layer.masksToBounds = YES;
    self.rateBtn.layer.cornerRadius = 15;
    [self.rateBtn.layer setBorderWidth:0.5]; //边框宽度
    self.rateBtn.layer.borderColor=[UIColor colorWithHexString:@"D9D9D9"].CGColor;
    self.backLabel.userInteractionEnabled = YES;
    [self createCustomNavigationBar:@"评论"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64 - 55)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view.
    self.currentPag = 1;
    [self getHotRateCountData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getFristNewRateData:self.currentPag];
    });
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getFristNewRateData:self.currentPag];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetAllRata) name:ratePostName object:nil];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reGetAllRata{
    self.currentPag = 1;
    [self getHotRateCountData];
      [self getFristNewRateData:self.currentPag];
}
#pragma mark --------  热门评论数据
- (void)getHotRateCountData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.postID, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_FRISTHOTRATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [self.hotArray removeAllObjects];
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *dict in array) {
                weakSelf.cotentModel = [[FinanaceDetailModel alloc] initWithDict:dict];
                weakSelf.cotentModel.hotRateStart = YES;
                [self.hotArray addObject:weakSelf.cotentModel];
            }
        };
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
    
    
}
#pragma mark --------  最新评论数据
- (void)getFristNewRateData:(NSInteger)page{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld", self.postID,[DataModelInstance shareInstance].userModel.userId,(long)page] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_FRISTNEWRATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            if (page == 1) {
                [self.rateArray removeAllObjects];
            }
            for (NSDictionary *dict in array) {
                weakSelf.cotentModel = [[FinanaceDetailModel alloc] initWithDict:dict];
                weakSelf.cotentModel.hotRateStart = NO;
                [self.rateArray addObject:weakSelf.cotentModel];
            }
            
            if (self.rateArray.count > 0 || self.hotArray.count > 0) {
                if (self.delectView) {
                    [self.delectView removeFromSuperview];
                    [self.view addSubview:self.tableView];
                }
                [weakSelf.tableView reloadData];
            }
            if (self.rateArray.count == 0 && self.hotArray.count == 0) {
                [self notStartPiontNewDetailEveryRate];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView endRefresh];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
    }];
}
#pragma mark ---你还没有发布任何观点&评论
- (void)notStartPiontNewDetailEveryRate{
    [self.tableView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT - 64 - 49);
    
    self.delectView.coverImageView.image = kImageWithName(@"icon_mytopic_nocomment");
    self.delectView.showTitleLabel.text = @"暂无任何评论";
    [self.view addSubview:self.delectView];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        return 1;
    }else if (section == 0) {
        
        return self.hotArray.count;
    }
    return self.rateArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        return self.tableView.frame.size.height;
    }else if (indexPath.section == 0) {
        FinanaceDetailModel *model = self.hotArray[indexPath.row];
        return [HotRateViewCell backHotRateViewCell:model];
    }else{
        FinanaceDetailModel *model = self.rateArray[indexPath.row];
        return [HotRateViewCell backHotRateViewCell:model];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        return 1;
    }
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        return 0;
    }
    if (self.hotArray.count <= 0) {
        if (section == 0) {
            return 0;
        }
    }
    if (self.rateArray.count <= 0) {
        if (section == 1) {
            return 0;
        }
    }
    return 46;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 46) backColor:@"FFFFFF"];
    UILabel *label = [UILabel createLabel:CGRectMake(0, 0, WIDTH, 6) font:[UIFont systemFontOfSize:0] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor whiteColor]];
    [view addSubview:label];
    NSArray *titleArray = @[@"热门评论",@"最新评论"];
    UILabel *titleLabel = [UILabel  createLabel:CGRectMake(16, 22, WIDTH, 20) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    titleLabel.text = titleArray[section];
    [view addSubview:titleLabel];
    return view;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else if(indexPath.section == 0) {
        static NSString *identify = @"HotRateViewCell";
        HotRateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([HotRateViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.indePathRow = indexPath.row;
        [cell tranferFianaceDetailModel:self.hotArray[indexPath.row]];
        cell.hotRateViewCellDelegate = self;
        return cell;
    }else{
        static NSString *identify = @"HotRateViewCell";
        HotRateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([HotRateViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.indePathRow = indexPath.row;
        [cell tranferFianaceDetailModel:self.rateArray[indexPath.row]];
        cell.hotRateViewCellDelegate = self;
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES && self.hotArray.count == 0 && self.rateArray.count == 0){
        self.currentPag = 1;
        [self getHotRateCountData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getFristNewRateData:self.currentPag];
        });
    }else {
        if (indexPath.section == 0) {
            self.cotentModel = self.hotArray[indexPath.row];
        }else{
            self.cotentModel = self.rateArray[indexPath.row];
        }
        //评论详情
        RateDetailController *rateDetail = [[RateDetailController alloc]init];
        rateDetail.reviewid = self.cotentModel.reviewid;
        rateDetail.shareCount = self.shareCount;
        rateDetail.shareUrl = self.shareUrl;
        rateDetail.shareImage = self.shareImage;
        rateDetail.shareTitle = self.shareTitle;
        [self.navigationController pushViewController:rateDetail animated:YES];
    }
}
#pragma mark ------ HotRateViewCellDelegate;
- (void)attentionTapAction{

}

#pragma mark ------  点赞
- (void)likePraiseBtnAction:(NSInteger)index hotRate:(BOOL)start{
    //诸葛监控
    
    [[AppDelegate shareInstance] setZhugeTrack:@"点赞资讯评论" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.activityTitle],@"tag":[CommonMethod paramStringIsNull:self.tag]}];
    if (start == YES) {
        self.cotentModel = self.hotArray[index];
    }else{
        self.cotentModel = self.rateArray[index];
    }
    
    if (self.cotentModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.cotentModel.reviewid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_GETRATELIKE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
             [[NSNotificationCenter defaultCenter] postNotificationName:InformationRefar object:nil];
            [MBProgressHUD showSuccess:@"点赞成功" toView:self.view];
            self.cotentModel.ispraise = @1;
            self.cotentModel.praisecount = @(self.cotentModel.praisecount.integerValue + 1);
            //一个cell刷新
            NSIndexPath *indexPath;
            if (start == YES) {
                indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            }else{
                indexPath=[NSIndexPath indexPathForRow:index inSection:1];
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
#pragma mark ------  回复或删除
- (void)delectOrRateTapAction:(NSInteger)index hotRate:(BOOL)start{
    self.indepathRow = index;
    self.startType = start;
    if (start == YES) {
        self.cotentModel = self.hotArray[index];
    }else{
        self.cotentModel = self.rateArray[index];
    }
    if (self.cotentModel.reviewcount.integerValue > 0){
        //诸葛监控
        
      [[AppDelegate shareInstance] setZhugeTrack:@"点赞资讯评论" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.activityTitle],@"tag":[CommonMethod paramStringIsNull:self.tag]}];
        //评论详情
        RateDetailController *rateDetail = [[RateDetailController alloc]init];
        rateDetail.reviewid = self.cotentModel.reviewid;
        [self.navigationController pushViewController:rateDetail animated:YES];
    }else{
        if ([DataModelInstance shareInstance].userModel.userId.integerValue == self.cotentModel.userid.integerValue) {
            // @"删除";
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否要删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                
            } confirm:^{
                [self index:index hotRate:start];
            }];
        }else{
            //诸葛监控
            
          [[AppDelegate shareInstance] setZhugeTrack:@"点赞资讯评论" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.activityTitle],@"tag":[CommonMethod paramStringIsNull:self.tag]}];
            //@"回复";
            WriteRateController *writeCtr = [[WriteRateController alloc]init];
            writeCtr.postID = self.cotentModel.reviewid;
            writeCtr.writeRateControllerDelegate = self;
            writeCtr.nameStr = self.cotentModel.realname;
            writeCtr.backRate = YES;
            [self presentViewController:writeCtr animated:YES completion:nil];
        }
    }
}
-(void)senderRateSuccendBack:(BOOL)isRefer{
    if (isRefer) {
        self.currentPag = 1;
        [self getFristNewRateData:self.currentPag];
    }else{
        self.cotentModel.reviewcount = @(self.cotentModel.reviewcount.integerValue + 1);
        //一个cell刷新
        NSIndexPath *indexPath;
        if (self.startType == YES) {
            indexPath=[NSIndexPath indexPathForRow:self.indepathRow inSection:0];
        }else{
            indexPath=[NSIndexPath indexPathForRow:self.indepathRow inSection:1];
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
     [[NSNotificationCenter defaultCenter] postNotificationName:InformationRefar object:nil];
    
}
#pragma mark ------  投诉
- (void)longPreaaTapAction:(NSInteger)index hotRate:(BOOL)start{
    CGFloat section = 0;
    if (start == YES) {
        section = 0;
        self.cotentModel = self.hotArray[index];
    }else{
        section = 1;
        self.cotentModel = self.rateArray[index];
    }
    self.startType = start;
    self.indepathRow = index;
    [self showCopyOrDelect:self.cotentModel index:index section:section];
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
        
        self.cotentModel = self.hotArray[self.indepathRow];
    }else{
        
        self.cotentModel = self.rateArray[self.indepathRow];
    }
    ReportViewController *report = [[ReportViewController alloc]init];
    report.reportType = ReportType_Review;
    report.reportId = self.cotentModel.reviewid;
    [self.navigationController pushViewController:report animated:YES];
}
- (void)copyRateMenuAction{
    if (self.startType == YES) {
        self.cotentModel = self.hotArray[self.indepathRow];
    }else{
        self.cotentModel = self.rateArray[self.indepathRow];
    }
    [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.cotentModel.content];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ------ 删除评论
- (void)index:(NSInteger)index hotRate:(BOOL)start{
    __weak typeof(self) weakSelf = self;
    if (start == YES) {
        weakSelf.cotentModel = self.hotArray[index];
    }else{
        weakSelf.cotentModel = self.rateArray[index];
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",weakSelf.cotentModel.reviewid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    
    [weakSelf requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_GETDELECTRATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:self.view];
            if (start == YES) {
                [weakSelf.hotArray removeObjectAtIndex:index];
            }else{
                [weakSelf.rateArray removeObjectAtIndex:index];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:InformationRefar object:nil];
            if (self.hotArray.count == 0 && self.rateArray.count == 0) {
                self.currentPag = 1;
                [self getHotRateCountData];
                [self getFristNewRateData:self.currentPag];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
- (IBAction)shareBanAction:(UIButton *)sender {
    ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
    shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [shareView setCopylink];
    @weakify(self);
    shareView.shareIndex = ^(NSInteger index){
        @strongify(self);
        if(index==2){
            UIPasteboard *paste = [UIPasteboard generalPasteboard];
            [paste setString:self.shareUrl];
            [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
        }else{
            [self firendClickWX:index];
        }
    };
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showShareNormalView];
}
#pragma mark ----------分享 ---
- (void)firendClickWX:(NSInteger)index{
    
    NSString *html = self.shareCount;
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    
    NSString *title = self.shareTitle;
    NSString *imageUrl = self.shareImage;
    id imageSource;
    if(imageUrl && imageUrl.length){
        imageSource = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = self.shareUrl;
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}
- (IBAction)backInformationAction:(id)sender {
   
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rateBtnAction:(UIButton *)sender {
    //诸葛监控
   [[AppDelegate shareInstance] setZhugeTrack:@"点赞资讯评论" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.activityTitle],@"tag":[CommonMethod paramStringIsNull:self.tag]}];
    WriteRateController *writeCtr = [[WriteRateController alloc]init];
    writeCtr.postID = self.postID;
    writeCtr.referType = YES;
    writeCtr.writeRateControllerDelegate = self;
    [self presentViewController:writeCtr animated:YES completion:nil];
}
- (IBAction)backInformation:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark ------- 去掉Section的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = 46;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
@end
