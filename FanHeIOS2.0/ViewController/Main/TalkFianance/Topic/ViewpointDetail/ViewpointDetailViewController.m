//
//  ViewpointDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ViewpointDetailViewController.h"
#import "ViewpointDetailTableViewCell.h"
#import "PraiseListViewController.h"
#import "RichTextViewController.h"
#import "ShareNormalView.h"
#import "NONetWorkTableViewCell.h"
#import "TopicHasDeletedCell.h"
#import "TopicViewController.h"
#import "ZSSRichTextEditor.h"
#import "TopicIdentifyViewController.h"
#import "ReportViewController.h"
#import "DynamicShareView.h"
#import "TransmitDynamicController.h"
#import "ChoiceFriendViewController.h"

@interface ViewpointDetailViewController ()<UIWebViewDelegate, MWPhotoBrowserDelegate>{
    BOOL _isShowMenuView;
    NSInteger _currentPage;
    BOOL _noNetWork;
    CGFloat _webHeight;
}

@property (strong, nonatomic) IBOutlet UIView *headerTableView;
@property (nonatomic, strong) ViewpointDetailModel *detailModel;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) IBOutlet UIView *toolView;

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *noNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *zfImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *reviewBtn;
@property (weak, nonatomic) IBOutlet UIButton *toolPraiseBtn;
@property (weak, nonatomic) IBOutlet UIButton *headerAttentBtn;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

@property (nonatomic, strong) UIWebView *contentWebView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;
@property (nonatomic, strong) NSArray  *htmlArray;
@property (nonatomic ,assign) BOOL isPush;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ViewpointDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isPush == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    self.isPush = NO;
    [self loadViewpointDetailHttpData];
    self.titleLabel = [self createCustomNavigationBar:@""];
    [CALayer updateControlLayer:self.reviewBtn.layer radius:15 borderWidth:0.5 borderColor:kCellLineColor.CGColor];

}

- (void)createTableView{
    if(self.tableView==nil){
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-55)];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView tableViewAddUpLoadRefreshing:^{
            [self loadReviewListHttpData];
        }];
    }
    if(self.detailModel){
        self.titleLabel.text = self.detailModel.subjecttitle;
        [self createContentWebView];
        self.toolView.hidden = NO;
    }else{
        [self.tableView reloadData];
        self.toolView.hidden = YES;
    }
    if(self.detailModel.mergeto.integerValue){
        self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        self.toolView.hidden = YES;
    }
}

#pragma mark - webview
- (void)createContentWebView{
    self.contentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(69, 65, WIDTH-85, 10)];
    self.contentWebView.delegate = self;
    NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style> body { margin:0; padding:0rem; border:0; font-size:100%; font-family:\"Helvetica Neue\",Helvetica,\"Hiragino Sans GB\",\"Microsoft YaHei\",Arial,sans-serif; vertical-align:baseline; word-break : normal; } p, div{ margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; word-break : normal; text-align:justify; text-justify:inter-word; } h1,h2,h3,h4,h5,h6 { margin: 0; font-size: 0.875rem; line-height: 1.5; color: #41464E; font-weight:bold; word-break : normal; text-align:justify; text-justify:inter-word; } img{ max-width: 100%; height: auto; object-fit:scale-down;  margin: 0.625rem 0rem 0;} a { font-size: 0.875rem; line-height: 1.5; color: #4393E2; padding:0 0.3125rem; text-decoration: none; -webkit-tap-highlight-color:rgba(0,0,0,0);  }width:100% !important;}</style></head><script type=\"text/JavaScript\"> window.onload=function(){ document.documentElement.style.webkitTouchCallout='none'; }; </script>"];
    [self.contentWebView loadHTMLString:[NSString stringWithFormat:@"%@<p>%@</p>", style, self.detailModel.content] baseURL:[NSBundle mainBundle].resourceURL];
      self.htmlArray = [[NSArray alloc]init];
     self.htmlArray = [self getImageurlFromHtml:[NSString stringWithFormat:@"%@<p>%@</p>", style, self.detailModel.content]];
    self.contentWebView.scrollView.scrollEnabled = NO;
    self.contentWebView.scalesPageToFit = NO;
}

#pragma mark - 表头
- (void)createTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT)];
    headerView.backgroundColor = WHITE_COLOR;
    
    CGFloat viewHeight = 0;
    if(self.detailModel.mergeto.integerValue){
        UIView *mergeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 59)];
        mergeView.backgroundColor = HEX_COLOR(@"ffe1e1");
        [headerView addSubview:mergeView];
        UILabel *label1 = [UILabel createLabel:CGRectMake(16, 12, 200, 16) font:FONT_SYSTEM_SIZE(14) bkColor:HEX_COLOR(@"ffe1e1") textColor:HEX_COLOR(@"8b4542")];
        label1.text = @"原话题已被合并至：";
        [mergeView addSubview:label1];
        
        UILabel *label2 = [UILabel createLabel:CGRectMake(16, 33, WIDTH-104, 16) font:FONT_SYSTEM_SIZE(14) bkColor:HEX_COLOR(@"ffe1e1") textColor:HEX_COLOR(@"8b4542")];
        label2.text = [NSString stringWithFormat:@"%@", self.detailModel.mergetitle];
        [mergeView addSubview:label2];
        
        UIButton *lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lookBtn.frame = CGRectMake(WIDTH-80, 15, 64, 28);
        lookBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        [lookBtn setTitle:@"去讨论" forState:UIControlStateNormal];
        [lookBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [lookBtn setBackgroundColor:HEX_COLOR(@"e24943")];
        [CALayer updateControlLayer:lookBtn.layer radius:4 borderWidth:0 borderColor:nil];
        [lookBtn addTarget:self action:@selector(lookButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:lookBtn];
        viewHeight += 59;
    }
    if([DataModelInstance shareInstance].userModel.userId.integerValue == self.detailModel.userModel.userId.integerValue){
        self.headerAttentBtn.hidden = YES;
    }
    
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
    self.vipImageView.hidden = self.detailModel.userModel.usertype.integerValue != 9;
    if(self.detailModel.ishidden.integerValue == 1){
        self.headerImageView.image = KHeadImageDefaultName(@"匿名");
        self.noNameLabel.hidden = NO;
        self.vipImageView.hidden = YES;
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:self.detailModel.userModel.image] placeholderImage:KHeadImageDefaultName(self.detailModel.userModel.realname)];
        self.noNameLabel.hidden = YES;
        self.realNameLabel.text = self.detailModel.userModel.realname;
        self.companyLabel.text = [NSString stringWithFormat:@"%@%@",self.detailModel.userModel.company, self.detailModel.userModel.position];
    }
    self.zfImageView.hidden = self.detailModel.userModel.othericon.integerValue !=1;
    self.timeLabel.text = self.detailModel.created_at;
    if(self.detailModel.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        self.reportBtn.hidden = YES;
        self.deleteBtn.hidden = NO;
        self.editBtn.hidden = NO;
    }else{
        self.reportBtn.hidden = NO;
        self.deleteBtn.hidden = YES;
        self.editBtn.hidden = YES;
    }
    self.headerAttentBtn.selected = self.detailModel.isattention.integerValue;
    
    if(self.detailModel.ispraise.integerValue){
        [self.toolPraiseBtn setImage:kImageWithName(@"icon_dianzan_yidian") forState:UIControlStateNormal];
        [self.toolPraiseBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
        [self.toolPraiseBtn setTitle:@"" forState:UIControlStateNormal];
    }else{
        [self.toolPraiseBtn setTitle:@" 点赞" forState:UIControlStateNormal];
    }
    
    CGFloat headerHeight = _webHeight+103;
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, WIDTH, headerHeight)];
    [headerView addSubview:tmpView];
    self.headerTableView.frame = CGRectMake(0, 0, WIDTH, headerHeight);
    [tmpView addSubview:self.headerTableView];
    
    self.contentWebView.frame = CGRectMake(69, 65, WIDTH-85, _webHeight);
    [tmpView addSubview:self.contentWebView];
    viewHeight += headerHeight;
    
    if(self.detailModel.praisecount.integerValue){
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight-0.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        UIView *friendsView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, WIDTH, 66)];
        [CommonMethod viewAddGuestureRecognizer:friendsView tapsNumber:1 withTarget:self withSEL:@selector(gotoZanList)];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 25, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [friendsView addSubview:nextImageView];
        CGFloat strWidth = [NSHelper widthOfString:[NSString stringWithFormat:@"%@个人赞过", self.detailModel.praisecount] font:FONT_SYSTEM_SIZE(14) height:50];
        UILabel *friNumLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-33-strWidth, 0, strWidth, 66) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:[NSString stringWithFormat:@"%@个人赞过", self.detailModel.praisecount] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [friendsView addSubview:friNumLabel];
        for (int i=0; i < self.detailModel.praiseusers.count; i++) {
            if(WIDTH-33-strWidth<16+27*i+18){
                break;
            }
            UserModel *model = [[UserModel alloc] initWithDict:self.detailModel.praiseusers[i]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, 16, 34, 34)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            [friendsView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
        [headerView addSubview:friendsView];
        viewHeight += 66;
    }
    
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight-0.5, WIDTH, 0.5)];
    lineLabel1.backgroundColor = kCellLineColor;
    [headerView addSubview:lineLabel1];
    
    if(self.detailModel.reviewcount.integerValue){
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, WIDTH, 36)];
        titleView.backgroundColor = kTableViewBgColor;
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 14, WIDTH-32, 18) font:FONT_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e")];
        titleLabel.text = @"全部评论";
        [titleView addSubview:titleLabel];
        [headerView addSubview:titleView];
        viewHeight += 36;
    }
    
    headerView.frame = CGRectMake(0, 0, WIDTH, viewHeight);
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - 网络请求
- (void)loadViewpointDetailHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.viewpointId, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_POST_VIEWPOINT_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(responseObject[@"data"] == nil){
                [weakSelf createTableView];
            }else{
                weakSelf.detailModel = [[ViewpointDetailModel alloc] initWithDict:responseObject[@"data"]];
                [weakSelf createTableView];
                [[AppDelegate shareInstance] setZhugeTrack:@"浏览观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.topicDetailModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.topicDetailModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.topicDetailModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.topicDetailModel.status]}];
                if(weakSelf.detailModel.reviewcount.integerValue){
                    if(weakSelf.listArray){
                        [weakSelf.listArray removeAllObjects];
                        _currentPage = 1;
                    }
                    [weakSelf loadReviewListHttpData];
                }else{
                    weakSelf.listArray = [NSMutableArray array];
                    [weakSelf.tableView reloadData];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        _noNetWork = YES;
    }];
}

#pragma mark -点赞
- (void)praiseHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.viewpointId forKey:@"reviewid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_PRAISE_SUBREVIEW paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.detailModel.ispraise = @(1);
            weakSelf.detailModel.praisecount = @(weakSelf.detailModel.praisecount.integerValue+1);
            
            [weakSelf.toolPraiseBtn setImage:kImageWithName(@"icon_dianzan_yidian") forState:UIControlStateNormal];
            [weakSelf.toolPraiseBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
            [weakSelf.toolPraiseBtn setTitle:@"" forState:UIControlStateNormal];
            [weakSelf loadViewpointDetailHttpData];
            if(weakSelf.praiseSuccess){
                weakSelf.praiseSuccess();
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark -关注
- (IBAction)attentButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.detailModel.isattention.integerValue==1){
        [self.view showToastMessage:@"你已经关注过啦"];
        return;
    }
       //诸葛监控
    
    [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":self.detailModel.userModel.userId, @"company":[CommonMethod paramStringIsNull:self.detailModel.userModel.company],@"position":[CommonMethod paramStringIsNull:self.detailModel.userModel.position]}];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.detailModel.userModel.userId forKey:@"otherid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_ADDATION paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
            weakSelf.headerAttentBtn.selected = YES;
            weakSelf.detailModel.isattention = @(1);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 列表
- (void)loadReviewListHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",self.viewpointId, [DataModelInstance shareInstance].userModel.userId, (long)_currentPage] forKey:@"param"];
    _currentPage++;
    [self requstType:RequestType_Get apiName:API_NAME_POST_VIEWPOINT_REVIEW_LIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if(_currentPage==2){
            [weakSelf.listArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                ReviewModel *model = [[ReviewModel alloc] initWithDict:dict];
                if(![weakSelf.listArray containsObject:model]){
                    [weakSelf.listArray addObject:model];
                }
            }
            if(array.count!=20){
                [weakSelf.tableView endRefreshNoData];
            }else{
                [weakSelf.tableView endRefresh];
            }
            [weakSelf.tableView reloadData];
        }else{
            [weakSelf.tableView endRefresh];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 删除观点
- (void)deleteTopicHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除观点..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.detailModel.reviewid,[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_POST_DEL_SUB_REVIEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:weakSelf.view];
            if(weakSelf.deleteViewpointDetail){
                weakSelf.deleteViewpointDetail();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - 赞的人列表
- (void)gotoZanList{
    PraiseListViewController *vc = [[PraiseListViewController alloc] init];
    vc.reviewid = self.detailModel.reviewid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 编辑、删除、举报
- (IBAction)headerButtonClicked:(UIButton*)sender{
    if(sender.tag == 101){
        ZSSRichTextEditor *vc = [CommonMethod getVCFromNib:[ZSSRichTextEditor class]];
        vc.publushViewpointSuccess = ^(){
            [self loadViewpointDetailHttpData];
        };
        vc.type = EditotType_Viewpoint;
        TopicDetailModel *tdModel = [[TopicDetailModel alloc] init];
        tdModel.subjectid = self.detailModel.subject_id;
        vc.tdModel = tdModel;
        vc.vpdModel = self.detailModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(sender.tag == 102){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否要删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确认" cancle:^{
            
        } confirm:^{
            [self deleteTopicHttp];
        }];
    }else if(sender.tag == 103){
        ReportViewController *vc = [CommonMethod getVCFromNib:[ReportViewController class]];
        vc.reportType = ReportType_Viewpoint;
        vc.reportId = self.detailModel.reviewid;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
    
    }
}

#pragma mark - 查看合并话题
- (void)lookButtonClicked:(UIButton*)btn{
    TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
    vc.subjectId = self.detailModel.mergeto;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转到个人主页
- (IBAction)gotoHomePageClicked:(id)sender{
    if(self.detailModel.ishidden.integerValue == 0){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.detailModel.user_id;
        if(self.headerAttentBtn.isHidden==NO){
            vc.attentUser = ^(BOOL isAttent){
                self.detailModel.isattention = [NSNumber numberWithBool:isAttent];
                self.headerAttentBtn.selected = isAttent;
            };
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 发布评论
- (IBAction)gotoPublishCommentClicked:(id)sender{
    self.isPush = YES;
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        [[AppDelegate shareInstance] setZhugeTrack:@"评论观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.topicDetailModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.topicDetailModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.topicDetailModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.topicDetailModel.status]}];
        __weak typeof(self) weakSelf = self;
        RichTextViewController *vc = [[RichTextViewController alloc] init];
        vc.commentType = 1;
        vc.reviewId = self.detailModel.reviewid;
        vc.replyMessageSuccess = ^(){
            if(weakSelf.listArray==nil || weakSelf.listArray.count==0){
                [weakSelf loadViewpointDetailHttpData];
            }else{
                [weakSelf.tableView.mj_footer resetNoMoreData];
                _currentPage = 1;
                [weakSelf.tableView scrollRectToVisible:CGRectMake(0, 0, WIDTH, 10) animated:YES];
                [weakSelf loadReviewListHttpData];
            }
            if(weakSelf.publishReview){
                weakSelf.publishReview();
            }
        };
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Review;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)zanButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.detailModel.ispraise.integerValue == 1){
        [self.view showToastMessage:@"你已经点过赞啦"];
    }else{
        [self praiseHttpData];
        [[AppDelegate shareInstance] setZhugeTrack:@"点赞观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.topicDetailModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.topicDetailModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.topicDetailModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.topicDetailModel.status]}];
    }
}

- (IBAction)shareButtonClicked:(id)sender{
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
   if(index==0){
       DynamicModel *model = [[DynamicModel alloc]init];
       DynamicUserModel *useModel = [[DynamicUserModel alloc]init];

        TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
       model.parent_subject_id = self.detailModel.reviewid;
       model.parent_subject_title =  self.titleLabel.text;
       model.parent_subject_photo = self.detailModel.shareimage;
       
      useModel.user_realname = self.detailModel.userModel.realname;
       model.content = self.detailModel.content;
       model.userModel = useModel;
        jinmai.model = model;
        [self presentViewController:jinmai animated:YES completion:nil];
    }else if(index==3){
          DynamicModel *model = [[DynamicModel alloc]init];
        DynamicUserModel *useModel = [[DynamicUserModel alloc]init];
        ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
        
        model.parent_subject_id = self.detailModel.reviewid;
        useModel.user_realname = self.detailModel.userModel.realname;
        useModel.user_image = self.detailModel.userModel.image;
        model.content = self.detailModel.content;
     
        model.userModel = useModel;
        choseCtr.dymodel = model;
        choseCtr.isViewPoint = YES;
        [self.navigationController pushViewController:choseCtr animated:YES];
    }else if(index==4){
            UIPasteboard *paste = [UIPasteboard generalPasteboard];
            [paste setString:[NSString stringWithFormat:@"%@%@", VIEWPOINT_SHARE_URL, self.detailModel.reviewid]];
            [MBProgressHUD showSuccess:@"复制成功" toView:shareSlef.view];
        }else{
            [shareSlef firendClick:index];
        }

    }];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger)index{
    [[AppDelegate shareInstance] setZhugeTrack:@"分享观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.topicDetailModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.topicDetailModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.topicDetailModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.topicDetailModel.status]}];
    NSString *content = @"";
    if([CommonMethod paramStringIsNull:self.detailModel.content].length){
        NSString *html = [self.detailModel.content filterHTML];
        content = html.length>100?[html substringToIndex:100]:html;
    }
    NSString *title = [NSString stringWithFormat:@"%@ -%@的观点", self.detailModel.subjecttitle, self.detailModel.userModel.realname];
    UIImage *imageSource;
    NSString *imageUrl;
    if (self.htmlArray.count > 0) {
        imageUrl = self.htmlArray[0];
    }
    
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
        
    }else{
        imageSource = kImageWithName(@"icon-60");
    }

   
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 1) {
        shareType = UMSocialPlatformType_WechatSession;
    }else {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@%@", VIEWPOINT_SHARE_URL, self.detailModel.reviewid];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.detailModel==nil&&_noNetWork){//没网
        return 1;
    }else if(self.detailModel==nil&&!_noNetWork){//删除话题
        return 1;
    }else if(self.listArray==nil){//未加载到观点列表借口
        return 0;
    }else{
        if(self.listArray.count==0){
            return 0;
        }else{
            return self.listArray.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.detailModel==nil&&_noNetWork){//没网
        return self.tableView.frame.size.height;
    }else if(self.detailModel==nil&&!_noNetWork){//删除话题
        return self.tableView.frame.size.height;
    }else{
        ReviewModel *model = self.listArray[indexPath.row];
        return model.cellHeight;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.detailModel==nil&&_noNetWork){//没网
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else if(self.detailModel==nil&&!_noNetWork){//话题已被删除
        static NSString *identify = @"TopicHasDeletedCell";
        TopicHasDeletedCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TopicHasDeletedCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"ViewpointDetailTableViewCell";
        ViewpointDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"ViewpointDetailTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.backgroundColor = kTableViewBgColor;
        TopicDetailModel *tdModel = [[TopicDetailModel alloc] init];
        tdModel.subjectid = self.detailModel.subject_id;
        [cell updateDisplay:self.listArray[indexPath.row] vpdModel:self.detailModel];
        cell.tag = indexPath.row;
        __weak typeof(self) weakSelf = self;
        cell.replyReviewSuccess = ^(){
            _currentPage=1;
            [weakSelf.listArray removeAllObjects];
            [weakSelf loadReviewListHttpData];
            [[AppDelegate shareInstance] setZhugeTrack:@"回复观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.topicDetailModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.topicDetailModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.topicDetailModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.topicDetailModel.status]}];
        };
        cell.deleteReviewSuccess = ^(ViewpointDetailTableViewCell *delCell){
            [weakSelf.listArray removeObjectAtIndex:delCell.tag];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            weakSelf.detailModel.reviewcount = @(weakSelf.detailModel.reviewcount.integerValue-1);
            if(weakSelf.detailModel.reviewcount.integerValue==0){
                [weakSelf loadViewpointDetailHttpData];
            }
        };
        return cell;
    }
}

#pragma mark -- UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSInteger index = 0;
        for(NSString *str in self.imageUrlArray){
            if([str isEqualToString:path]){
                break;
            }
            index++;
        }
        [self tapPhoneAction:index];
        return NO;
    }
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        if(request.URL.absoluteString && [request.URL.absoluteString hasPrefix:ShareHomePageURL]){
            NSNumber *userId = [NSNumber numberWithInteger:[[request.URL.absoluteString stringByReplacingOccurrencesOfString:ShareHomePageURL withString:@""] integerValue]];
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = userId;
            [self.navigationController pushViewController:vc animated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.imageArray = [NSMutableArray new];
    self.imageUrlArray = [NSMutableArray new];
    //这里是js，主要目的实现对url的获取
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    };\
    return imgScr;\
    };";
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
    for (NSInteger i = 0; i < array.count;i++) {
        NSString *url = array[i];
        if ([url hasSuffix:@"jpg"]||[url hasSuffix:@"png"]) {
            MWPhoto *po = [MWPhoto photoWithURL:[NSURL URLWithString:url]];
            if (![self.imageArray containsObject:po]) {
                [self.imageArray addObject:po];
                [self.imageUrlArray addObject:url];
            }
        }
    }
    //添加图片可点击js
    [webView stringByEvaluatingJavaScriptFromString:@"function registerImageClickAction(){\
     var imgs=document.getElementsByTagName('img');\
     var length=imgs.length;\
     for(var i=0;i<length;i++){\
     img=imgs[i];\
     img.onclick=function(){\
     window.location.href='image-preview:'+this.src}\
     }\
     }"];
    [webView stringByEvaluatingJavaScriptFromString:@"registerImageClickAction();"];
    
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    _webHeight = ceil(height)+10;
    [self createTableHeaderView];
}

#pragma mark - 点击看大图
- (void)tapPhoneAction:(NSInteger)index{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
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
//获取webView中的所有图片URL
- (NSArray *) getImageurlFromHtml:(NSString *) webString
{
    NSMutableArray * imageurlArray = [NSMutableArray arrayWithCapacity:1];
    
    //标签匹配
    NSString *parten = @"<img(.*?)>";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
    
    NSArray* match = [reg matchesInString:webString options:0 range:NSMakeRange(0, [webString length] - 1)];
    
    for (NSTextCheckingResult * result in match) {
        
        //过去数组中的标签
        NSRange range = [result range];
        NSString * subString = [webString substringWithRange:range];
        
        
        //从图片中的标签中提取ImageURL
        NSRegularExpression *subReg = [NSRegularExpression regularExpressionWithPattern:@"http://(.*?)\"" options:0 error:NULL];
        NSArray* match = [subReg matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
        NSTextCheckingResult * subRes = match[0];
        NSRange subRange = [subRes range];
        subRange.length = subRange.length -1;
        NSString * imagekUrl = [subString substringWithRange:subRange];
        
        //将提取出的图片URL添加到图片数组中
        [imageurlArray addObject:imagekUrl];
    }
    
    return imageurlArray;
}


@end
