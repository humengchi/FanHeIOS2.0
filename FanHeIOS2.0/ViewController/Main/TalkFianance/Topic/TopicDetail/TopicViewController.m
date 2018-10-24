//
//  TopicViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/14.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicTableViewCell.h"
#import "ViewpointListViewController.h"
#import "ViewpointDetailViewController.h"
#import "MenuView.h"
#import "ZSSRichTextEditor.h"
#import "InviteAnswerViewController.h"

#import "NONetWorkTableViewCell.h"
#import "TopicHasDeletedCell.h"
#import "TopicNoViewpointCell.h"
#import "TFSearchResultViewController.h"
#import "TopicIdentifyViewController.h"
#import "CreateTopicViewController.h"
#import "ReportViewController.h"
#import "DynamicShareView.h"
#import "TransmitDynamicController.h"
#import "ChoiceFriendViewController.h"

@interface TopicViewController ()<UIWebViewDelegate, MWPhotoBrowserDelegate>{
    BOOL _isShowMenuView;
    NSInteger _currentPage;
    BOOL _noNetWork;
}

@property (nonatomic, strong) MenuView * menuView;
@property (nonatomic, strong) TopicDetailModel *tdModel;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *toolView;
@property (nonatomic, weak) IBOutlet UIButton *moreBtn;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UIWebView *contentWebView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;
@property (nonatomic ,strong) NSArray *htmlArray;

@end

@implementation TopicViewController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(_isShowMenuView == YES){
        [self.menuView showMenuWithAnimation:NO];
        _isShowMenuView = NO;
        self.menuView = nil;
        return NO;
    }
    if (self.navigationController.childViewControllers.count == 1){
        return NO;
    }
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translatedPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        if(translatedPoint.x < 0 || translatedPoint.y){
            return NO;
        }
        if([gestureRecognizer locationInView:self.view].x>50){
            return NO;
        }
    }
    return YES;
}

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
    _currentPage = 1;
    self.view.backgroundColor = kTableViewBgColor;
    [self loadTopicDetailHttpData:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataHttp) name:@"publishOrEditTopicSaveSuccess" object:nil];
}

- (void)reloadDataHttp{
    [self loadTopicDetailHttpData:0];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableView{
    if(self.tableView==nil){
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView tableViewAddUpLoadRefreshing:^{
            [self loadViewpointHttpData];
        }];
        [self.tableView tableViewAddDownLoadRefreshing:^{
            [self loadTopicDetailHttpData:0];
        }];
        self.tableView.hidden = YES;
    }
    if(self.tdModel){
        if(self.tdModel.mergeto.integerValue){
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
            self.toolView.hidden = YES;
        }else{
            self.toolView.hidden = NO;
        }
        
        if(self.tdModel.content && self.tdModel.content.length){
            [self createContentWebView];
        }else{
            [self createTableHeaderView];
        }
    }else{
        self.tableView.hidden = NO;
        self.moreBtn.hidden = YES;
        [self.tableView reloadData];
        self.toolView.hidden = YES;
        self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
    }
}

#pragma mark - webview
- (void)createContentWebView{
    self.contentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(16, 0, WIDTH-32, 20)];
    self.contentWebView.delegate = self;
    NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style> body { margin:0; padding:0rem; border:0; font-size:100%; font-family:\"Helvetica Neue\",Helvetica,\"Hiragino Sans GB\",\"Microsoft YaHei\",Arial,sans-serif; vertical-align:baseline; word-break : normal; } p{ margin: 0; font-size: 0.875rem; line-height: 1.5; color: #818C9E; word-break : normal; text-align:justify; text-justify:inter-word; } h1,h2,h3,h4,h5,h6 {margin: 0; font-size: 0.875rem; line-height: 1.25rem; color: #818C9E; font-weight:bold; word-break : normal; text-align:justify; text-justify:inter-word; } img{ max-width: 100%; height: auto; object-fit:scale-down; margin: 0.625rem 0rem 0rem;} a { font-size: 0.875rem; line-height: 1.5; color: #4393E2; padding:0 0.3125rem; text-decoration: none; -webkit-tap-highlight-color:rgba(0,0,0,0); }width:100% !important;}</style></head>"];
    [self.contentWebView loadHTMLString:[NSString stringWithFormat:@"%@<p>%@</p>", style, self.tdModel.content] baseURL:[NSBundle mainBundle].resourceURL];
    self.htmlArray = [[NSArray alloc]init];
   self.htmlArray = [self getImageurlFromHtml:[NSString stringWithFormat:@"%@<p>%@</p>", style, self.tdModel.content]];
    self.contentWebView.scrollView.scrollEnabled = NO;
    self.contentWebView.opaque = NO;
    self.contentWebView.backgroundColor = WHITE_COLOR;
}

#pragma mark-头视图布局
- (void)createTableHeaderView{
    self.tableView.hidden = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT)];
    headerView.backgroundColor = WHITE_COLOR;
    CGFloat viewHeight = 0;
    if(self.tdModel.mergeto.integerValue){
        UIView *mergeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 59)];
        mergeView.backgroundColor = HEX_COLOR(@"ffe1e1");
        [headerView addSubview:mergeView];
        UILabel *label1 = [UILabel createLabel:CGRectMake(16, 12, 200, 16) font:FONT_SYSTEM_SIZE(14) bkColor:HEX_COLOR(@"ffe1e1") textColor:HEX_COLOR(@"8b4542")];
        label1.text = @"原话题已被合并至：";
        [mergeView addSubview:label1];
        
        UILabel *label2 = [UILabel createLabel:CGRectMake(16, 33, WIDTH-104, 16) font:FONT_SYSTEM_SIZE(14) bkColor:HEX_COLOR(@"ffe1e1") textColor:HEX_COLOR(@"8b4542")];
        label2.text = [NSString stringWithFormat:@"%@", self.tdModel.mergetitle];
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
        
        UILabel *grayLineLabel = [UILabel createLabel:CGRectMake(0, viewHeight, WIDTH, 5) font:FONT_SYSTEM_SIZE(1) bkColor:kTableViewBgColor textColor:nil];
        [headerView addSubview:grayLineLabel];
        viewHeight += 5;
    }
    
    NSInteger titleHeight = (NSInteger)[NSHelper heightOfString:self.tdModel.title font:FONT_BOLD_SYSTEM_SIZE(20) width:WIDTH-32 defaultHeight:22];
    titleHeight += titleHeight/24*8;
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 16+viewHeight, WIDTH-32, titleHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:self.tdModel.title font:20 number:0 nstextLocat:NSTextAlignmentLeft];
    titleLabel.font = FONT_BOLD_SYSTEM_SIZE(20);
    [titleLabel setParagraphText:self.tdModel.title lineSpace:6];
    [headerView addSubview:titleLabel];
    viewHeight += 32+titleHeight;
    
    if(self.tdModel.content && self.tdModel.content.length){
        CGRect webFrame = self.contentWebView.frame;
        webFrame.origin.y = viewHeight;
        self.contentWebView.frame = webFrame;
        [headerView addSubview:self.contentWebView];
        viewHeight += self.contentWebView.frame.size.height+12;
    }
    
    self.numLabel = [UILabel createLabel:CGRectMake(16, viewHeight+6, WIDTH-90, 16) font:FONT_SYSTEM_SIZE(12) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
    self.numLabel.text = [NSString stringWithFormat:@"关注 %@   观点 %@   评论 %@", [NSString getNumStr:self.tdModel.attentcount],[NSString getNumStr:self.tdModel.replycount],[NSString getNumStr:self.tdModel.reviewcount]];
    [headerView addSubview:self.numLabel];
    
    if(self.tdModel.mergeto.integerValue==0){
        UIButton *attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        attentionBtn.frame = CGRectMake(WIDTH-80, viewHeight, 64, 28);
        attentionBtn.titleLabel.font = FONT_SYSTEM_SIZE(12);
        if(self.tdModel.isattent.integerValue == 1){
            [attentionBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [attentionBtn setTitleColor:HEX_COLOR(@"AFB6C1") forState:UIControlStateNormal];
            [attentionBtn setBackgroundColor:WHITE_COLOR];
            [CALayer updateControlLayer:attentionBtn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"AFB6C1").CGColor];
        }else{
            [attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
            [attentionBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            [attentionBtn setBackgroundColor:HEX_COLOR(@"e24943")];
            [CALayer updateControlLayer:attentionBtn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"e24943").CGColor];
        }
        [attentionBtn addTarget:self action:@selector(attentionClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:attentionBtn];
    }
    viewHeight += 40;
    
    if(self.tdModel.tags.count){
        UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(16, viewHeight, WIDTH-32, 30)];
        CGFloat start_X = 0;
        CGFloat start_Y = 0;
        for (int i=0; i < self.tdModel.tags.count; i++) {
            UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [tagBtn setTitle:self.tdModel.tags[i] forState:UIControlStateNormal];
            [tagBtn setTitleColor:HEX_COLOR(@"1ABC9C") forState:UIControlStateNormal];
            tagBtn.titleLabel.font = FONT_SYSTEM_SIZE(13);
            CGFloat strWidth = [NSHelper widthOfString:self.tdModel.tags[i] font:FONT_SYSTEM_SIZE(13) height:28]+16;
            if(start_X+strWidth>WIDTH-32){
                if(strWidth>WIDTH-32){
                    strWidth = WIDTH-32;
                }
                start_X = 0;
                start_Y += 34;
            }
            tagBtn.frame = CGRectMake(start_X, start_Y, strWidth, 28);
            tagBtn.tag = i;
            [tagBtn addTarget:self action:@selector(tagClicked:) forControlEvents:UIControlEventTouchUpInside];
            [CALayer updateControlLayer:tagBtn.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(@"1ABC9C").CGColor];
            [tagView addSubview:tagBtn];
            start_X += strWidth+6;
        }
        tagView.frame = CGRectMake(16, viewHeight, WIDTH-32, start_Y+28);
        [headerView addSubview:tagView];
        viewHeight += start_Y+44;
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight-0.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [headerView addSubview:lineLabel];
    
    if(self.tdModel.frdintalkcnt.integerValue){
        UIView *friendsView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, WIDTH, 66)];
        [CommonMethod viewAddGuestureRecognizer:friendsView tapsNumber:1 withTarget:self withSEL:@selector(gotoViewpointList)];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 25, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [friendsView addSubview:nextImageView];
        CGFloat strWidth = [NSHelper widthOfString:[NSString stringWithFormat:@"%@个好友参与讨论", [NSString getNumStr:self.tdModel.frdintalkcnt]] font:FONT_SYSTEM_SIZE(14) height:50];
        UILabel *friNumLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-33-strWidth, 0, strWidth, 66) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:[NSString stringWithFormat:@"%@个好友参与讨论", [NSString getNumStr:self.tdModel.frdintalkcnt]] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [friendsView addSubview:friNumLabel];
        for (int i=0; i < self.tdModel.frdintalk.count; i++) {
            if(WIDTH-33-strWidth<16+27*i+18){
                break;
            }
            UserModel *model = [[UserModel alloc] initWithDict:self.tdModel.frdintalk[i]];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, 16, 34, 34)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            [friendsView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
        [headerView addSubview:friendsView];
        viewHeight += 66;
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, viewHeight-0.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
    }
    
    UILabel *grayLineLabel = [UILabel createLabel:CGRectMake(0, viewHeight, WIDTH, 5) font:FONT_SYSTEM_SIZE(1) bkColor:kTableViewBgColor textColor:nil];
    [headerView addSubview:grayLineLabel];
    viewHeight += 5;
    
    headerView.frame = CGRectMake(0, 0, WIDTH, viewHeight);
    self.tableView.tableHeaderView = headerView;
}

- (UILabel*)createSubContentLabel:(CGRect)frame{
    NSString * htmlString = self.tdModel.content;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName:FONT_SYSTEM_SIZE(14) } documentAttributes:nil error:nil];
    CGFloat height;
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 0;
    label.attributedText = attrStr;
    height = [label.attributedText boundingRectWithSize:CGSizeMake(WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    frame.size.height = height;
    label.frame = frame;
    label.font = FONT_SYSTEM_SIZE(14);
    label.textColor = HEX_COLOR(@"41464e");
    return label;
}

#pragma mark - 网络请求  1.编辑 2.删除
- (void)loadTopicDetailHttpData:(NSInteger)deleteOrEditTopic{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.subjectId, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_POST_SUBJECT_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if([CommonMethod paramDictIsNull:responseObject[@"data"]].allKeys.count==0){
                [weakSelf createTableView];
            }else{
                weakSelf.tdModel = [[TopicDetailModel alloc] initWithDict:responseObject[@"data"]];
                [weakSelf createTableView];
                [[AppDelegate shareInstance] setZhugeTrack:@"浏览话题" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:weakSelf.tdModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:weakSelf.tdModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[weakSelf.tdModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:weakSelf.tdModel.status]}];
                if(weakSelf.tdModel.replycount.integerValue){
                    if(weakSelf.listArray){
                        [weakSelf.listArray removeAllObjects];
                        _currentPage = 1;
                    }
                    [weakSelf loadViewpointHttpData];
                }else{
                    weakSelf.listArray = [NSMutableArray array];
                    [weakSelf.tableView reloadData];
                }
                if(deleteOrEditTopic){
                    if(self.tdModel.replycount.integerValue){
                        [MBProgressHUD showError:[NSString stringWithFormat:@"该话题下已有观点，无法%@",deleteOrEditTopic==1?@"编辑":@"删除"] toView:weakSelf.view];
                    }else{
                        if(deleteOrEditTopic==1){
                            CreateTopicViewController *vc = [CommonMethod getVCFromNib:[CreateTopicViewController class]];
                            vc.tdModel = self.tdModel;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }else{
                            [[[CommonUIAlert alloc] init] showCommonAlertView:weakSelf title:@"" message:@"是否要删除该话题？" cancelButtonTitle:@"确认" otherButtonTitle:@"取消" cancle:^{
                                [weakSelf deleteTopicHttp];
                            } confirm:^{
                                
                            }];
                        }
                    }
                }
            }
        }else if(weakSelf.subjectId.integerValue == 0){
            [weakSelf createTableView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        _noNetWork = YES;
    }];
}

#pragma mark - 观点列表
- (void)loadViewpointHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld",self.subjectId, [DataModelInstance shareInstance].userModel.userId, (long)_currentPage] forKey:@"param"];
    _currentPage++;
    [self requstType:RequestType_Get apiName:API_NAME_POST_VIEWPOINT_LIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                ViewpointModel *model = [[ViewpointModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
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

#pragma mark - 添加／取消关注
- (void)attentionHttp:(UIButton*)attentionBtn{
    __weak MBProgressHUD *hud;//
    NSString *apiStr;
    if(self.tdModel.isattent.integerValue==1){
        hud = [MBProgressHUD showMessag:@"取消关注..." toView:self.view];
        apiStr = API_NAME_POST_UN_ATTENT_SUBJECT;
    }else{
        hud = [MBProgressHUD showMessag:@"关注中..." toView:self.view];
        apiStr = API_NAME_POST_ATTENT_SUBJECT;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.subjectId forKey:@"subjectid"];
    [self requstType:RequestType_Post apiName:apiStr paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.tdModel.isattent.integerValue!=1){
                [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
                weakSelf.tdModel.isattent = @(1);
                weakSelf.tdModel.attentcount = @(weakSelf.tdModel.attentcount.integerValue+1);
                [attentionBtn setTitle:@"已关注" forState:UIControlStateNormal];
                [attentionBtn setTitleColor:HEX_COLOR(@"AFB6C1") forState:UIControlStateNormal];
                [attentionBtn setBackgroundColor:WHITE_COLOR];
                [CALayer updateControlLayer:attentionBtn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"AFB6C1").CGColor];
            }else{
                [MBProgressHUD showSuccess:@"取消关注" toView:weakSelf.view];
                weakSelf.tdModel.isattent = @(0);
                weakSelf.tdModel.attentcount = @(weakSelf.tdModel.attentcount.integerValue-1);
                [attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
                [attentionBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
                [attentionBtn setBackgroundColor:HEX_COLOR(@"e24943")];
                [CALayer updateControlLayer:attentionBtn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"e24943").CGColor];
            }
            weakSelf.numLabel.text = [NSString stringWithFormat:@"关注 %@   观点 %@   评论 %@", [NSString getNumStr:weakSelf.tdModel.attentcount],[NSString getNumStr:weakSelf.tdModel.replycount],[NSString getNumStr:weakSelf.tdModel.reviewcount]];
        }else{
            [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - 删除话题
- (void)deleteTopicHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除话题..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.subjectId, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_POST_DEL_SUBJECT paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:weakSelf.view];
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

#pragma mark - 点击标签，搜索
- (void)tagClicked:(UIButton*)sender{
    TFSearchResultViewController *vc = [[TFSearchResultViewController alloc] init];
    vc.tagStr = self.tdModel.tags[sender.tag];
    vc.type = TFSearchResult_Topic;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 查看合并话题
- (void)lookButtonClicked:(UIButton*)btn{
    TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
    vc.subjectId = self.tdModel.mergeto;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 关注
- (void)attentionClicked:(UIButton*)attentionBtn{
    [self newThreadForAvoidButtonRepeatClick:attentionBtn];
    [[AppDelegate shareInstance] setZhugeTrack:@"关注话题" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.tdModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.tdModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.tdModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.tdModel.status]}];
    [self attentionHttp:attentionBtn];
}

#pragma mark -- 跳转方法
- (void)gotoViewpointList{
    ViewpointListViewController *vc = [[ViewpointListViewController alloc] init];
    vc.tdModel = self.tdModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 更多
- (IBAction)moreButtonClicked:(id)sender {
    if(self.tdModel.mergeto.integerValue==0){
        _isShowMenuView = !_isShowMenuView;
        [self.menuView showMenuWithAnimation:_isShowMenuView];
        if(_isShowMenuView==NO){
            self.menuView = nil;
        }
    }
}

#pragma mark -点击头部返回顶部页面
- (IBAction)topButtonClicked:(id)sender{
    [self.tableView scrollsToTop];
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    if (_menuView) {
        [self.menuView showMenuWithAnimation:NO];
        self.menuView = nil;
        _isShowMenuView = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pubilshViewpointClicked:(id)sender{
    if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
        __weak typeof(self) weakSelf = self;
        ZSSRichTextEditor *vc = [CommonMethod getVCFromNib:[ZSSRichTextEditor class]];
        vc.tdModel = self.tdModel;
        vc.type = EditotType_Viewpoint;
        vc.publushViewpointSuccess = ^(){
            [self.tableView.mj_footer resetNoMoreData];
            _currentPage = 1;
            if(self.listArray){
                [self.listArray removeAllObjects];
            }
            [weakSelf loadViewpointHttpData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
        vc.publishType = PublishType_Viewpoint;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)inviteAnswerClicked:(id)sender{
    InviteAnswerViewController *vc = [[InviteAnswerViewController alloc] init];
    vc.tdModel = self.tdModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)shareButtonClicked:(id)sender{
    [self shareTopic];
}
- (void)shareTopic{
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
        //转发
        if (index == 0){
            TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
            DynamicModel *model = [[DynamicModel alloc]init];
            
            model.subject_id = shareSlef.tdModel.subjectid;
            if (self.htmlArray.count > 0) {
                model.subject_photo = self.htmlArray[0];
 
            }
        if (shareSlef.tdModel.frdintalk.count > 0) {
                NSDictionary *dict = shareSlef.tdModel.frdintalk[0];
                model.subject_photo = dict[@"image"];
            }
            model.subject_title = shareSlef.tdModel.title;
            jinmai.model = model;
            
            [shareSlef presentViewController:jinmai animated:YES completion:nil];
        }else if(index== 1 || index == 2){
            [shareSlef firendClick:index];
        }else if (index == 3){
            //金脉好友
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            UserModel *model = [[UserModel alloc]init];
            model.realname = self.tdModel.title;
            model.image = self.tdModel.image;
            model.userId = self.subjectId;
            model.sex = @1;
            choseCtr.useModel = model;
            [shareSlef.navigationController pushViewController:choseCtr animated:YES];
        }else if(index== 4){
            UIPasteboard *paste = [UIPasteboard generalPasteboard];
            [paste setString:[NSString stringWithFormat:@"%@%@", TOPIC_SHARE_URL, shareSlef.tdModel.subjectid]];
            [MBProgressHUD showSuccess:@"复制成功" toView:shareSlef.view];
        }
        
    }];

}
#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger)index{
    [[AppDelegate shareInstance] setZhugeTrack:@"分享话题" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.tdModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.tdModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.tdModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.tdModel.status]}];
    NSString *content = [NSString stringWithFormat:@"关注 %@   观点 %@   评论 %@", [NSString getNumStr:self.tdModel.attentcount],[NSString getNumStr:self.tdModel.replycount],[NSString getNumStr:self.tdModel.reviewcount]];
    NSString *title = self.tdModel.title;
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
    }else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@%@", TOPIC_SHARE_URL, self.tdModel.subjectid];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray;
        if(self.tdModel.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
            
            dataArray = @[@{@"itemName" : @"分享"},@{@"itemName" : @"编辑"}, @{@"itemName" : @"删除"}];
        }else{
            dataArray = @[@{@"itemName" : @"分享"},@{@"itemName" : @"举报"}];
        }
        CGFloat x = self.view.bounds.size.width / 3 * 2 - 15;
        CGFloat y = 66+7;
        CGFloat width = self.view.bounds.size.width * 0.3 + 20;
        CGFloat height = dataArray.count * 40;
        __weak __typeof(&*self)weakSelf = self;
        
        _menuView = [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            
            [weakSelf menuViewClicked:tag];
        } backViewTap:^{
            _isShowMenuView = NO;
            _menuView = nil;
        }];
    }
    return _menuView;
}

#pragma mark-右上角弹出框，点击事件
- (void)menuViewClicked:(NSInteger)tag{
    if(self.tdModel.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
    if((self.tdModel.replycount.integerValue == 0 && tag == 1) || (self.tdModel.replycount.integerValue == 0 && tag == 2)){
            [self loadTopicDetailHttpData:tag];
        }else{
            if (tag== 0) {
                  [self shareTopic];
            }else if(tag==1){
                if(self.tdModel.replycount.integerValue){
                    [MBProgressHUD showError:[NSString stringWithFormat:@"该话题下已有观点，无法%@",tag==1?@"编辑":@"删除"] toView:self.view];
                    return;
                }else{
                    CreateTopicViewController *vc = [CommonMethod getVCFromNib:[CreateTopicViewController class]];
                    vc.tdModel = self.tdModel;
                    [self.navigationController pushViewController:vc animated:YES];
                }

               
            }else{
                if(self.tdModel.replycount.integerValue){
                    [MBProgressHUD showError:[NSString stringWithFormat:@"该话题下已有观点，无法%@",tag==1?@"编辑":@"删除"] toView:self.view];
                    return;
                }else{
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否要删除该话题？" cancelButtonTitle:@"确认" otherButtonTitle:@"取消" cancle:^{
                    [self deleteTopicHttp];
                } confirm:^{
                    
                }];
                }
            }
        }
    }else{//举报
        if (tag== 0) {
             [self shareTopic];
        }else{
            ReportViewController *vc = [CommonMethod getVCFromNib:[ReportViewController class]];
            vc.reportType = ReportType_Topic;
            vc.reportId = self.tdModel.subjectid;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    [self.menuView showMenuWithAnimation:NO];
    self.menuView = nil;
    _isShowMenuView = NO;
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.tdModel==nil&&_noNetWork){//没网
        return 1;
    }else if(self.tdModel==nil&&!_noNetWork){//删除话题
        return 1;
    }else if(self.listArray==nil){//未加载到观点列表借口
        return 0;
    }else{
        if(self.listArray.count==0){
            return 1;
        }else{
            return self.listArray.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tdModel==nil&&_noNetWork){//没网
        return self.tableView.frame.size.height;
    }else if(self.tdModel==nil&&!_noNetWork){//删除话题
        return self.tableView.frame.size.height;
    }else{
        if(self.listArray.count==0){
            return 130;
        }else{
            ViewpointModel *model = self.listArray[indexPath.row];
            return model.cellHeight;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tdModel==nil&&_noNetWork){//没网
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else if(self.tdModel==nil&&!_noNetWork){//删除话题
        static NSString *identify = @"TopicHasDeletedCell";
        TopicHasDeletedCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TopicHasDeletedCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        if(self.listArray.count==0){
            static NSString *identify = @"TopicNoViewpointCell";
            TopicNoViewpointCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"TopicNoViewpointCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.backgroundColor = kTableViewBgColor;
            return cell;
        }else{
            static NSString *identify = @"TopicTableViewCell";
            TopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"TopicTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateDisplay:self.listArray[indexPath.row]];
            __weak typeof(self) weakSelf = self;
            cell.selectCell = ^(UITapGestureRecognizer *tap){
                CGPoint point = [tap locationInView:weakSelf.tableView];
                [weakSelf tableView:weakSelf.tableView didSelectRowAtIndexPath:[weakSelf.tableView indexPathForRowAtPoint:point]];
            };
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(self.listArray.count){
        ViewpointModel *model = self.listArray[indexPath.row];
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
        vc.viewpointId = model.reviewid;
        TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
        topicDetailModel.subjectid = self.subjectId;
        topicDetailModel.title = @"";
        vc.topicDetailModel = topicDetailModel;
        __weak NSIndexPath *index = indexPath;
        __weak typeof(self) weakSelf = self;
        vc.deleteViewpointDetail = ^(){
            [weakSelf.listArray removeObjectAtIndex:index.row];
            [weakSelf.tableView reloadData];
        };
        vc.praiseSuccess = ^(){
            ViewpointModel *model = weakSelf.listArray[index.row];
            model.praisecount = @(model.praisecount.integerValue+1);
            [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
        };
        vc.publishReview = ^(){
            ViewpointModel *model = weakSelf.listArray[index.row];
            model.reviewcount = @(model.reviewcount.integerValue+1);
            [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationNone];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.tdModel){
        if(scrollView.contentOffset.y>100){
            self.titleLabel.text = self.tdModel.title;
        }else{
            self.titleLabel.text = @"话题讨论";
        }
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
        NSLog(@"%@",request.URL.absoluteString);
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
    height = ceil(height)+10;
    webView.frame = CGRectMake(16, 0, WIDTH-32, height);
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
