//
//  WorkHistoryController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "WorkHistoryController.h"
#import "UrlShowView.h"
#import "NONetWorkTableViewCell.h"
#import "WorkHistoryDetailCell.h"
#import "UrlDetailController.h"
#import "EditPersonalInfoViewController.h"
#import "WorkHistoryEditorViewController.h"
#import "CompanyViewController.h"

@interface WorkHistoryController ()<MWPhotoBrowserDelegate,UrlShowViewDelegate,WorkHistoryEditorViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic ,strong) UrlShowView *urlView;
@property (nonatomic ,strong)  UILabel *authenticationLabel;
@property (nonatomic ,strong)  UILabel *prefentLabel;

@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger currentpage;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,assign) BOOL isFrist;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@end

@implementation WorkHistoryController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    _currentpage = 1;
    _netWorkStat = NO;
    
    [self initTableView:CGRectMake(0,64, WIDTH,HEIGHT-64 - 55)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getMyWorkHistoryMapListData];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        _currentpage ++;
        [self getMyWorkHistoryMapListData];
    }];
    [self createrTabHeaderView];
    
    self.addBtn.hidden = self.isMyPage==NO;
}

#pragma mark --- method
- (IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButtonClicked:(UIButton*)sender{
    WorkHistoryEditorViewController *workHistory = [[WorkHistoryEditorViewController alloc]init];
    if(sender.tag == 2){
        workHistory.workModel = self.workModel;
    }
    workHistory.index = sender.tag;
    workHistory.workDelegate = self;
    [self.navigationController pushViewController:workHistory animated:YES];
}

- (IBAction)gotoCompanyDetail:(id)sender{
    CompanyViewController *vc = [[CompanyViewController alloc] init];
    vc.companyId = self.workModel.companyid;
    vc.company = self.workModel.company;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - WorkHistoryEditorViewControllerDelegate
- (void)changeWorkHistory:(workHistryModel *)model delect:(BOOL)isdelect{
    self.workModel = model;
    [self createrTabHeaderView];
    if(self.workHistoryDetailChange){
        self.workHistoryDetailChange(YES, self.workModel);
    }
}

- (void)deleteButtonClicked:(UIButton*)sender{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否要删除该经历？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [self deleteWorkHistory];
    }];
}

- (void)deleteWorkHistory{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.workModel.careerid] forKey:@"param"];
    
    [self requstType:RequestType_Delete apiName:API_NAME_USER_DELECT_MYCAREER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功！" toView:weakSelf.view];
            if(weakSelf.workHistoryDetailChange){
                weakSelf.workHistoryDetailChange(NO, weakSelf.workModel);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
#pragma mark ------- 链接页面web
- (void)gotoMakeUrl:(NSInteger)index{
    NSDictionary *dic = self.workModel.url[index];
    UrlDetailController *url = [[UrlDetailController alloc]init];
    url.title = dic[@"title"];
    url.url = dic[@"url"];
    [self.navigationController pushViewController:url animated:YES];
    
}
- (void)createrTabHeaderView{
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:self.workModel.logo] placeholderImage:kImageWithName(@"icon_work_company")];
    self.positionLabel.text = self.workModel.position;
    self.companyLabel.text = self.workModel.company;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@",self.workModel.begintime,self.workModel.endtime];
    [self.sideLabel setParagraphText:self.workModel.jobintro lineSpace:7];
    
    CGFloat height = [NSHelper heightOfString:self.workModel.jobintro font:[UIFont systemFontOfSize:14] width:WIDTH - 32];
    height += (height/FONT_SYSTEM_SIZE(14).lineHeight)*7;
    
    CGFloat start_Y = 0;
    
    UIView *headerSubView = [self.headerView viewWithTag:400];
    if(headerSubView){
        [headerSubView removeFromSuperview];
        headerSubView = nil;
    }
    headerSubView = [[UIView alloc] initWithFrame:CGRectMake(0, 93+height+5, WIDTH, 300)];
    headerSubView.tag = 400;
    if (self.workModel.image.count > 0) {
        CGFloat wideth = (WIDTH - 44)/3.0;
        CGFloat imageHeigth = wideth *61/110.0;
        for (NSInteger i = 0; i < self.workModel.image.count; i++) {
            CGFloat x = 16+(wideth+6)*i;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, start_Y, wideth, imageHeigth)];
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.workModel.image[i] ]placeholderImage:KWidthImageDefault];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [headerSubView addSubview:imageView];
            imageView.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBugImage:)];
            [imageView addGestureRecognizer:tap];
        }
        start_Y += imageHeigth + 12;
    }
    
    if (self.workModel.url.count > 0) {
        start_Y = start_Y - 12;
        self.urlView = [[UrlShowView alloc]initWithFrame:CGRectMake(0, start_Y, WIDTH, 52*self.workModel.url.count)];
        [self.urlView createrUrlView:self.workModel.url];
        self.urlView.urlShowViewDelegate = self;
        [headerSubView addSubview:self.urlView];
        start_Y = start_Y + 52*self.workModel.url.count + 16;
    }
    if(self.workModel.attestationtotal.integerValue > 0) {
        UIView *titleView = [NSHelper createrViewFrame:CGRectMake(0, start_Y, WIDTH, 46) backColor:@"EFEFF4"];
        self.authenticationLabel = [UILabel createLabel:CGRectMake(16, 16, WIDTH - 100, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        if (self.workModel.attestationtotal.integerValue >  0) {
            if (self.isMyPage) {
                self.authenticationLabel.text = [NSString stringWithFormat:@"%@个用户为我认证",self.workModel.attestationtotal];
            }else{
                self.authenticationLabel.text = [NSString stringWithFormat:@"%@个用户为Ta认证",self.workModel.attestationtotal];
            }
        }else{
            self.authenticationLabel.text = @"";
        }
        [titleView addSubview:self.authenticationLabel];
        self.prefentLabel = [UILabel createLabel:CGRectMake(WIDTH - 100, 16, 100, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        [titleView addSubview:self.prefentLabel];
        [headerSubView addSubview:titleView];
        start_Y += 46;
    }else{
        self.authenticationLabel.text = @"";
    }
    headerSubView.frame = CGRectMake(0, 93+height+5, WIDTH, start_Y);
    [self.headerView addSubview:headerSubView];
    self.headerView.frame = CGRectMake(0, 0, WIDTH, 93+height+5 + start_Y);
    self.tableView.tableHeaderView = self.headerView;
    
    //底部按钮
    UIView *footView = [self.view viewWithTag:300];
    if(footView){
        [footView removeFromSuperview];
        footView = nil;
    }
    if (self.isfriend.integerValue == 1) {
        footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"F7F7F7"];
        footView.tag = 300;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(37, 7, WIDTH - 74, 40);
        if (self.workModel.isattestation.integerValue == 0) {
            button.backgroundColor = [UIColor colorWithHexString:@"1ABC9C"];
            [button setTitle:@"为Ta认证" forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor colorWithHexString:@"E24943"];
            [button setTitle:@"撤销认证" forState:UIControlStateNormal];
        }
        //设置button正常状态下的图片
        [button setImage:[UIImage imageNamed:@"icon_auth_s"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 35);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.layer.cornerRadius = 5.0;//2.0是圆角的弧度，根据需求自己更改
        [button addTarget:self action:@selector(attionHisWorkVerty) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:button];
        [self.view addSubview:footView];
    }else if (self.isMyPage) {
        footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"F7F7F7"];
        footView.tag = 300;
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(25, 7, (WIDTH-60)/2, 40);
        deleteBtn.backgroundColor = WHITE_COLOR;
        [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [CALayer updateControlLayer:deleteBtn.layer radius:5.0 borderWidth:0.5 borderColor:HEX_COLOR(@"E24943").CGColor];
        [deleteBtn addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:deleteBtn];
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(25+(WIDTH-60)/2+10, 7, (WIDTH-60)/2, 40);
        editBtn.backgroundColor = HEX_COLOR(@"E24943");
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        editBtn.layer.cornerRadius = 5.0;
        editBtn.tag = 2;
        [editBtn addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:editBtn];
        [self.view addSubview:footView];
    }else{
        self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
    }
}
#pragma mark ------为Ta认证
- (void)attionHisWorkVerty{
    if ([DataModelInstance shareInstance].userModel.realname.length == 0 && [DataModelInstance shareInstance].userModel.company.length == 0 && [DataModelInstance shareInstance].userModel.position.length == 0 && [DataModelInstance shareInstance].userModel.image.length == 0 && [DataModelInstance shareInstance].userModel.career.count == 0) {
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_WorkHistory];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }else{
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.workModel.careerid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        NSString *strType;
        if (self.workModel.isattestation.integerValue == 0) {
            strType = API_NAME_GET_WORKHISTORY_PROVE;
        }else{
            strType = API_NAME_GET_WORKHISTORY_CANCEL;
        }
        [self requstType:RequestType_Get apiName:strType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                if (self.workModel.isattestation.integerValue == 0) {
                    self.workModel.isattestation = @1;
                    self.workModel.attestationtotal = @(self.workModel.attestationtotal.integerValue +1);
                    [self showHint:@"认证成功"];
                }else{
                    self.workModel.isattestation = @0;
                    self.workModel.attestationtotal = @(self.workModel.attestationtotal.integerValue -1);
                    [self showHint:@"撤销成功"];
                }
                self.isFrist = YES;
                self.currentpage = 1;
                [self getMyWorkHistoryMapListData];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }];
    }
}
#pragma mark ----- 图片放大
- (void)tapBugImage:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    self.imageArray = [NSMutableArray new];
    for (NSInteger i =0; i < self.workModel.image.count; i++){
        MWPhoto *po = [MWPhoto photoWithURL:[NSURL URLWithString:self.workModel.image[i]]];
        [self.imageArray addObject:po];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    //        _photoBrowser.wantsFullScreenLayout = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
    
    
}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imageArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.imageArray.count)
        return [self.imageArray objectAtIndex:index];
    return nil;
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------  工作经历的认证列表
- (void)getMyWorkHistoryMapListData{
    self.netWorkStat = NO;
    __weak typeof(self) weakSelf = self;
    NSString *str = @"加载中...";
    if (self.isFrist && self.currentpage == 1) {
        str = @"";
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag: str toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.workModel.careerid,(long)_currentpage] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_GET_WORKHISTORYLIST_MAP paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if(_currentpage==1){
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary  *listDict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSString *str = @"%是前同事";
            NSNumber *nubIndex = listDict[@"percent"];
            if (nubIndex.integerValue > 0) {
                self.prefentLabel.text = [NSString stringWithFormat:@"%@%@",nubIndex,str];
            }
            NSArray *array = [CommonMethod paramArrayIsNull:[listDict objectForKey:@"list"]];
            if(weakSelf.workHistoryDetailChange){
                if(_currentpage==1){
                    weakSelf.workModel.attestationlist = array;
                }else{
                    NSMutableArray *tmp = [NSMutableArray arrayWithArray:weakSelf.workModel.attestationlist];
                    [tmp addObjectsFromArray:array];
                    weakSelf.workModel.attestationlist = tmp;
                }
                weakSelf.workHistoryDetailChange(YES, weakSelf.workModel);
            }
            for(NSDictionary *dict in array){
                UserModel *model = [[UserModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
        }else{
            [weakSelf.tableView endRefresh];
        }
        [weakSelf createrTabHeaderView];
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark------- tabVIewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.netWorkStat && self.dataArray.count == 0){
        return 1;
    }
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat && self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }
    return 74;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.netWorkStat && self.dataArray.count == 0) {
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        static NSString *cellID = @"NONetWorkTableViewCell";
        WorkHistoryDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([WorkHistoryDetailCell class])];
        }
        UserModel *model = self.dataArray[indexPath.row];
        [cell tranfrtWorkHistoryDetailCellModel:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UserModel *model = self.dataArray[indexPath.row];
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = model.userId;
    [self.navigationController pushViewController:myHome animated:YES];
}

@end
