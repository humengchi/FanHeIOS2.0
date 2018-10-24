//
//  InformationDetailController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "InformationDetailController.h"
#import "WriteRateController.h"
#import "RateListController.h"
#import "DelectDataView.h"
#import "TFSearchResultViewController.h"
#import "DynamicShareView.h"
#import "TransmitDynamicController.h"
#import "ChoiceFriendViewController.h"

#import "ActivityDetailController.h"
#import "ActivityAboutreadCell.h"


#import "MenuView.h"

@interface InformationDetailController ()<UIWebViewDelegate,UIScrollViewDelegate,MWPhotoBrowserDelegate,UIScrollViewDelegate,WriteRateControllerDelegate,ActivityAboutreadCellDelegate>
@property (nonatomic,assign)  BOOL isShowMenuView;
@property (nonatomic, strong) MenuView * menuView;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutReadLabel;
@property (strong, nonatomic) IBOutlet UIView *NotWorkView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@property (weak, nonatomic) IBOutlet UILabel *rateDetailLabel;
@property (strong, nonatomic) IBOutlet UIView *headerView2;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *titleMessageLabel2;
@property (weak, nonatomic) IBOutlet UILabel *titleMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIButton *attionBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *InterViewImageView;
@property (nonatomic,strong)  UIWebView *webView;
@property (nonatomic,assign)  CGFloat   actualHeight;
@property (nonatomic,assign)  CGFloat slideHeigth;
@property (nonatomic,strong) UIView *navView;
@property (nonatomic,strong)  MWPhotoBrowser *photo;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (strong, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (nonatomic,strong) FinanaceDetailModel *detailModel;
@property (nonatomic,assign)  BOOL netWorkStat;
@property (nonatomic,strong) UITableView *abountTabView;

@property (nonatomic ,strong) UILabel *navTitleLabel;
@property (nonatomic ,strong) DelectDataView *delectView;
@property (nonatomic,assign)  BOOL isPresentVC;
@property (nonatomic ,strong) MBProgressHUD *hud;

@property (nonatomic ,strong) NSMutableArray *hotActivity;

@property (nonatomic ,strong) UIView *scrowerView;
@property (nonatomic ,assign) CGFloat likeCellHeigth;

@property (nonatomic,assign)  BOOL isLikeAction;
@property (nonatomic ,strong) ActivityAboutreadCell *cell;
@property (nonatomic ,strong) UIView *scrowerViewPush;
@property (nonatomic,assign)  BOOL isShow;

@end

@implementation InformationDetailController
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
    if (self.startType == YES) {
        self.isPresentVC = YES;
    }else{
        self.isPresentVC = NO;
        
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault &&     self.isPresentVC == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (_menuView) {
        [self.menuView showMenuWithAnimation:NO];
        _menuView = nil;
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.hotActivity = [NSMutableArray new];
    [self createCustomNavigationBar:@""];
    UIButton *recommendBtn = [NSHelper createButton:CGRectMake(WIDTH - 40 , 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_more"] selectImage:nil target:self selector:@selector(shareBtnAction)];
    [self.view addSubview:recommendBtn];
    
    self.netWorkStat = NO;
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT - 64 - 49)];
    self.scrollView.delegate = self;
    self.webView = [[UIWebView alloc] init];
    [(UIScrollView *)[[self.webView subviews] objectAtIndex:0] setScrollEnabled:NO];
    self.webView.delegate = self;
    [self.webView setScalesPageToFit:NO];
    [self.scrollView addSubview:self.webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isrferGetData) name:InformationRefar object:nil];
    [self getSubjectTalkFianaceDetailData];
}
- (void)shareBtnAction{
    _isShowMenuView = !_isShowMenuView;
    [self.menuView showMenuWithAnimation:_isShowMenuView];
    if(_isShowMenuView==NO){
        self.menuView = nil;
    }
}
//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"分享"}];
        
        CGFloat x = self.view.bounds.size.width / 3 * 2 - 15;
        CGFloat y = 66+7;
        CGFloat width = self.view.bounds.size.width * 0.3 + 20;
        CGFloat height = dataArray.count * 40;
        __weak __typeof(&*self)weakSelf = self;
        
        _menuView = [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            [weakSelf sharViewActivity];
        } backViewTap:^{
            _isShowMenuView = NO;
            _menuView = nil;
        }];
    }
    return _menuView;
}

- (void)isrferGetData{
    [self getSubjectTalkFianaceDetailData];
}
#pragma mark ------  获取专访列表数据
- (void)getSubjectTalkFianaceDetailData{
    __weak typeof(self) weakSelf = self;
    _hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.postID, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    //     [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",@"5055",@"91"] forKey:@"param"];
    //     [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",@"16395",@"91"] forKey:@"param"];
    //ttp://api-test.51jinmai.com/v3/post/postdetail/16395/91 这个是活动报道的
    
    //http://api-test.51jinmai.com/v3/post/postdetail/5055/91  这个是专访的
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_DETAILINFORMATION paramDict:requestDict hud:_hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (self.NotWorkView) {
                [self.NotWorkView removeFromSuperview];
            }
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            weakSelf.detailModel = [[FinanaceDetailModel alloc] initWithDict:dict];
            PraiseUserModel *model = [[PraiseUserModel alloc]initWithDict:dict[@"relevantactivity"]];
            weakSelf.detailModel.model = model;
            for (NSDictionary *subDic  in dict[@"hotactivity"]) {
                FinanaceDetailModel *activityModel = [[FinanaceDetailModel alloc]initWithDict:subDic];
                [self.hotActivity addObject:activityModel];
            }
            
            if (self.detailModel.postid.integerValue <= 0) {
                [hud hideAnimated:YES];
                [self delectNewDetail];
            }else{
                //诸葛监控
                
                
                [weakSelf.tableView reloadData];
                [self createrInformationHeaderView];
                [self createrNavDefual];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        weakSelf.netWorkStat = YES;
        [weakSelf.tableView reloadData];
        [self cretaerNotWork];
    }];
    
}
- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ----- 数据被删除
- (void)delectNewDetail{
    [self.scrollView removeFromSuperview];
    self.delectView = [CommonMethod getViewFromNib:NSStringFromClass([DelectDataView class])];
    self.delectView.frame = CGRectMake(0, 64, WIDTH, HEIGHT);
    [self.view addSubview:self.delectView];
}
#pragma mark ----- 无网络
- (void)cretaerNotWork{
    self.NotWorkView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    self.NotWorkView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.NotWorkView];
}
#pragma mark --------  导航头像
- (void)createrNavDefual{
    self.navTitleLabel = [UILabel createLabel:CGRectMake(50, 34, WIDTH - 100, 20) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"383838"]];
    self.navTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.navTitleLabel];
    if (self.detailModel.category.integerValue == 1) {
        self.navView = [NSHelper createrViewFrame:CGRectMake(0, -60, WIDTH, 30) backColor:@"FFFFFF"];
        [self.view addSubview:self.navView];
        UILabel *nameLabel = [UILabel createLabel:CGRectMake(70, 32, WIDTH - 140, 24) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:[UIColor colorWithHexString:@"383838"]];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.navView addSubview:nameLabel];
        
        [CommonMethod viewAddGuestureRecognizer:self.navView tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePage)];
        // 创建一个富文本
        NSMutableAttributedString * attriStr1 = [[NSMutableAttributedString alloc] initWithString:[CommonMethod paramStringIsNull:self.detailModel.realname]];
        /**
         添加图片到指定的位置
         */
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        // 表情图片
        NSString *fileURL = [CommonMethod paramStringIsNull:self.detailModel.image];
        NSData * dateImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        UIImage *imageShar = [UIImage imageWithData: dateImg];
        attchImage.image =[imageShar roundedCornerImageWithCornerRadius:CGRectMake(0, 0, 24, 24)];
        
        // 设置图片大小
        attchImage.bounds = CGRectMake(-4, -4, 24, 24);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr1 insertAttributedString:stringImage atIndex:0];
        nameLabel.attributedText = attriStr1;
        
        NSString *string =  [[CommonMethod paramArrayIsNull:self.detailModel.tags]  componentsJoinedByString:@","];
        [[AppDelegate shareInstance] setZhugeTrack:@"浏览资讯" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.detailModel.title],@"tag":string}];
        self.navTitleLabel.text = @"专访";
        if (self.isShow) {
            self.navTitleLabel.hidden = YES;
        }else{
            self.navTitleLabel.hidden = NO;
        }
    }else if(self.detailModel.category.integerValue == 2){
        self.navTitleLabel.text = @"活动报道";
    }else{
        self.navTitleLabel.text = @"资讯";
    }
}

#pragma mark ------- 导航上去主页
- (void)gotoHomePage{
    self.isPresentVC = YES;
    NewMyHomePageController *myPage = [[NewMyHomePageController alloc]init];
    myPage.userId = self.detailModel.postuserid;
    [self.navigationController pushViewController:myPage animated:YES];
}

#pragma mark ------  标题
- (void)createrInformationHeaderView{
    CGFloat heigth = [self getSpaceLabelHeight:[CommonMethod paramStringIsNull:self.detailModel.title] withFont:[UIFont boldSystemFontOfSize:24] withWidth:WIDTH - 32];
    heigth += (heigth/FONT_BOLD_SYSTEM_SIZE(24).lineHeight)*8;
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:[CommonMethod paramStringIsNull:self.detailModel.title]];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:8];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [[CommonMethod paramStringIsNull:self.detailModel.title] length])];
    [self.titleMessageLabel setAttributedText:attributedString1];
    [self.titleMessageLabel2 setAttributedText:attributedString1];
    
    if (self.detailModel.postuserid.integerValue > 0) {
        self.headerView.frame = CGRectMake(0, 0, WIDTH, heigth + 90);
        self.headerView.userInteractionEnabled = YES;
        
        self.headerImageView.userInteractionEnabled = YES;
        self.headerImageView.layer.masksToBounds = YES;
        self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.width/2.0;
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.detailModel.image]] placeholderImage:KHeadImageDefault];
        if (self.detailModel.usertype.integerValue != 9) {
            self.memberImageView.hidden = YES;
        }
        self.positionLabel.text = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:self.detailModel.company],[CommonMethod paramStringIsNull:self.detailModel.position]];
        self.nameLabel.text = [CommonMethod paramStringIsNull:self.detailModel.realname];
        if (self.detailModel.isattention.integerValue == 1) {
            
            [self.attionBtn setBackgroundImage:kImageWithName(@"btn_zixun_followed") forState:UIControlStateNormal];
            [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"AFB6C1"] forState:UIControlStateNormal];
            [self.attionBtn setTitle:@"已关注" forState:UIControlStateNormal];
        }else{
            [self.attionBtn setBackgroundImage:kImageWithName(@"btn_zixun_follow") forState:UIControlStateNormal];
            [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
            [self.attionBtn setTitle:@"关注" forState:UIControlStateNormal];
        }
        [self.attionBtn.layer setMasksToBounds:YES];
        [self.attionBtn.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
        
        if (self.detailModel.othericon.integerValue != 1) {
            self.InterViewImageView.hidden = YES;
        }
        
        heigth = heigth + 90;
        [self.scrollView addSubview:self.headerView];
    }else {
        heigth = heigth+24+12;
        self.headerView2.frame = CGRectMake(0, 0, WIDTH, heigth);
        self.headerView2.userInteractionEnabled = NO;
        [self.scrollView addSubview:self.headerView2];
    }
    _actualHeight = heigth;
    _slideHeigth = heigth;
    [self createMainBody];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------ //创建正文
- (void)createMainBody{
    //    NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style>\
    //                       body img{width:100% !important;}\
    //                       body .rich_media_content {width:100%,user-scalable=yes;!important;}\
    //                       </style></head>"];
    //
    //  NSString *html = self.detailModel.content;    NSString *strHTML =[NSString stringWithFormat:@"%@%@",style,html];
    
    NSString *strHTML = [CommonMethod paramStringIsNull:self.detailModel.content];
    
    [self.webView loadHTMLString:strHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    self.webView.frame = CGRectMake(16, _actualHeight, WIDTH - 32, 0);
    
}

#pragma mark ----------//UIWebview代理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSMutableArray *array = [NSMutableArray new];
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *str = [requestString substringFromIndex:17];
        array = (NSMutableArray *)[str componentsSeparatedByString:@"+"];
        [self tapPhoneAction:array];
        return NO;
    }
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (webView.isLoading) {
        return;
    }
    NSString *js = @"function imgAutoFit() { \
    var imgs = document.getElementsByTagName('img'); \
    for (var i = 0; i < imgs.length; ++i) {\
    var img = imgs[i];   \
    img.style.maxWidth = %f;   \
    } \
    }";
    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
    [self.webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    
    height = ceil(height) + 10;
    //    _actualHeight+=height;
    CGRect frame = webView.frame;
    self.webView.frame = CGRectMake(16, frame.origin.y, WIDTH - 32, height);
    //js方法遍历图片添加点击事件 返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    var str = this.src;\
    for(var j=0;j<objs.length;j++){\
    str +=\"+\"+objs[j].src\
    }\
    document.location=\"myweb:imageClick:\"+str;\
    };\
    };\
    return objs.length;\
    };";
    
    [self.webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    //注入自定义的js方法后别忘了调用 否则不会生效（不调用也一样生效了，，，不明白）
    [self.webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    //     [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.background='#000000'"];
    [_hud hideAnimated:YES];
    CGSize actualSize = [ self.webView sizeThatFits:CGSizeZero];
    CGRect newFrame =  self.webView.frame;
    newFrame.size.height = actualSize.height;
    self.webView.frame = newFrame;
    _actualHeight = self.webView.frame.size.height + self.webView.frame.origin.y ;
    
    
    if (self.detailModel.category.integerValue == 1) {
        [self createrLikeViewAndTag];
    }else if (self.detailModel.category.integerValue ==2 ){
        self.likeCellHeigth = _actualHeight;
        [self likeReportView];
        
    }else{
        [self createrLikeViewAndTag];
        
    }
}

#pragma mark ----------  点赞试图
- (void)likeReportView{
    _actualHeight = self.likeCellHeigth;
    if(self.isLikeAction){
        [self.cell tranferActivityAboutreadCellModel:self.detailModel];
    }else{
        if (self.scrowerView ) {
            [self.scrowerView removeFromSuperview];
        }
        self.scrowerView = [[UIView alloc]initWithFrame:CGRectMake(0, _actualHeight, WIDTH, 169)];
        self.cell = [CommonMethod getViewFromNib:NSStringFromClass([ActivityAboutreadCell class])];
        self.cell.frame = CGRectMake(0, 0, WIDTH, 169);
        _actualHeight += 169;
        if (self.detailModel.model.name.length <= 0) {
            self.scrowerView.frame = CGRectMake(0, _actualHeight, WIDTH, 100);
            self.cell.frame = CGRectMake(0, 0, WIDTH, 100);
            _actualHeight += 109;
        }
        [self.scrollView addSubview:self.scrowerView];
        
        self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cell.activityAboutreadCellDelegate = self;
        [self.cell tranferActivityAboutreadCellModel:self.detailModel];
        self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [ self.scrowerView addSubview:self.cell];
        
        self.scrollView.contentSize = CGSizeMake(0, _actualHeight);
        [self createrReportView];
    }
}
#pragma mark ------ActivityAboutreadCellDelegate

#pragma mark ----- 去搜索
- (void)searchTagActovity:(NSInteger)index{
    NSString *tagStr  =  self.detailModel.tags[index];
    TFSearchResultViewController *tfSearch = [[TFSearchResultViewController alloc]init];
    tfSearch.type = TFSearchResult_Report;
    tfSearch.tagStr = tagStr;
    [self.navigationController pushViewController:tfSearch animated:YES];
    
}
#pragma mark ----  点赞
- (void)likeTapActionBtn{
    if (self.detailModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.postID, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_LIKEDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSNumber *type = dict[@"type"];
            if (type.integerValue == 1) {
                [weakSelf.view showToastMessage:@"你已经点过赞啦"];
            }else{
                [MBProgressHUD showSuccess:@"点赞成功" toView:weakSelf.view];
                self.detailModel.praisecount = @(self.detailModel.praisecount.integerValue + 1);
                self.detailModel.ispraise = @1;
                //一个cell刷新
                self.isLikeAction = YES;
                [self likeReportView];
                
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark --------   点赞页面变化
- (void)createrLikeViewAndTag{
    CGFloat heigthAbounRaad  = 0;
    if (self.detailModel.relatepost.count > 0) {
        heigthAbounRaad =   81 + 47;
    }else{
        heigthAbounRaad =   81 ;
        
    }
    self.likeView.frame = CGRectMake(0, _actualHeight,WIDTH, heigthAbounRaad);
    [self.scrollView addSubview:self.likeView];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@",self.detailModel.praisecount];
    self.timeLabel.text = self.detailModel.publish_at;
    if (self.detailModel.ispraise.integerValue == 1) {
        self.likeCountLabel.textColor = [UIColor colorWithHexString:@"E24943"];
        self.likeBtn.selected = YES;
    }else{
        self.likeCountLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
    }
    
    CGFloat gX = 16;
    CGFloat gY = 16;
    for (NSInteger i = 0; i < self.detailModel.tags.count; i++) {
        CGFloat wideth = [NSHelper widthOfString:self.detailModel.tags[i] font:[UIFont systemFontOfSize:12] height:20] + 8;
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:12];
        label.text = self.detailModel.tags[i];
        label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
        label.textAlignment = NSTextAlignmentCenter;
        label.layer.cornerRadius = 2;
        label.layer.borderWidth = 0.5;
        label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
        
        label.frame = CGRectMake(gX, gY, wideth, 20);
        gX = gX + wideth + 6 ;
        label.tag = i;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchTag:)];
        [label addGestureRecognizer:tapg];
        [self.likeView addSubview:label];
    }
    
    if (self.detailModel.relatepost.count > 0) {
        _actualHeight = _actualHeight + 81 + 47;
    }else{
        _actualHeight = _actualHeight + 81;
        self.aboutReadLabel.hidden = YES;
        self.backLabel.hidden = YES;
    }
    
    self.scrollView.contentSize = CGSizeMake(WIDTH, _actualHeight);
    
    [self createrAboutRead];
    
}
#pragma mark ---- 去标签搜索
- (void)searchTag:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    TFSearchResultViewController *tfSearch = [[TFSearchResultViewController alloc]init];
    tfSearch.type = TFSearchResult_Information;
    tfSearch.tagStr = self.detailModel.tags[index];
    [self.navigationController pushViewController:tfSearch animated:YES];
}
#pragma mark ------  相关阅读
- (void)createrAboutRead{
    CGFloat heigth = 15;
    for (NSInteger i = 0; i < self.detailModel.relatepost.count; i++) {
        CGFloat heigth1 = [self getSpaceLabelHeight:self.detailModel.relatepost[i][@"title"] withFont:[UIFont systemFontOfSize:14] withWidth:WIDTH - 50];
        if (heigth1 > 30) {
            heigth1 = 40;
        }else{
            heigth1 = 14;
        }
        UILabel  *label = [UILabel createLabel:CGRectMake(33, heigth, WIDTH - 50, heigth1) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:HEX_COLOR(@"818C9E")];
        label.numberOfLines = 2;
        label.text = [CommonMethod paramStringIsNull:self.detailModel.relatepost[i][@"title"]];
        UIView *abountView = [NSHelper createrViewFrame:CGRectMake(0, _actualHeight, WIDTH, heigth1+30) backColor:@"FFFFFF"];
        [abountView addSubview:label];
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, heigth1+29.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
        [abountView addSubview:lineLabel];
        
        UITapGestureRecognizer *readTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(intViewAboutDetail:)];
        UIView *dotView = [NSHelper createrViewFrame:CGRectMake(20, (heigth1+30)/2.0 - 2.5, 5, 5) backColor:@"818C9E"];
        [dotView.layer setMasksToBounds:YES];
        [dotView.layer setCornerRadius:2.5]; //设置矩形四个圆角半径
        abountView.tag = i;
        abountView.userInteractionEnabled = YES;
        [abountView addGestureRecognizer:readTap];
        [abountView addSubview:dotView];
        [self.scrollView addSubview:abountView];
        _actualHeight += heigth1+30;
        
    }
    self.scrollView.contentSize = CGSizeMake(WIDTH, _actualHeight);
    [self createrFootView];
}

#pragma mark ----- 创建报道推荐
- (void)createrReportView{
    if ( self.scrowerViewPush) {
        [self.scrowerViewPush removeFromSuperview];
    }
    self.scrowerViewPush = [[UIView alloc]initWithFrame:CGRectMake(0, _actualHeight, WIDTH, 273)];
    [self.scrollView addSubview: self.scrowerViewPush];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 16, WIDTH - 32, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor whiteColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    titleLabel.text = @"活动推荐";
    [ self.scrowerViewPush addSubview:titleLabel];
    UIScrollView *scrrolView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 43, WIDTH, 230)];
    for (NSInteger i = 0; i < self
         .hotActivity.count; i++) {
        FinanaceDetailModel *activityModel = self.hotActivity[i];
        UIView *view = [self createrSlidView:activityModel xwideth:i];
        [scrrolView addSubview:view];
        view.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hisMainPage:)];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }
    CGFloat wideth = self.hotActivity.count * (16+240)+16;
    scrrolView.showsHorizontalScrollIndicator = NO;
    scrrolView.contentSize = CGSizeMake(wideth, 204);
    [ self.scrowerViewPush addSubview:scrrolView];
    _actualHeight += 273 ;
    self.scrollView.contentSize = CGSizeMake(0, _actualHeight);
    [self createrFootView];
}

#pragma mark ------- 底部视图
- (void)createrFootView{
    self.footView.frame = CGRectMake(0, HEIGHT - 55, WIDTH, 55);
    self.footView.userInteractionEnabled = YES;
    [self.view addSubview:self.footView];
    self.rateDetailLabel.userInteractionEnabled = YES;
    self.rateLabel.userInteractionEnabled = YES;
    self.rateLabel.layer.borderColor = [UIColor colorWithHexString:@"D9D9D9"].CGColor;
    self.rateLabel.layer.borderWidth =1.0;//该属性显示外边框
    self.rateLabel.layer.masksToBounds = YES;
    self.rateLabel.layer.cornerRadius = 15;
    
    if (self.detailModel.ispraise.integerValue == 1) {
        self.likeCountLabel.textColor = [UIColor redColor];
        self.likeBtn.selected = YES;
        
    }
    if (self.detailModel.reviewcount.integerValue == 0) {
        self.rateDetailLabel.text = @"评论";
    }else{
        self.rateDetailLabel.text = [NSString getNumStr:self.detailModel.reviewcount];
    }
}

#pragma mark ---------  导航头部变化
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = _slideHeigth;
    if (self.detailModel.category.integerValue == 1){
        if (scrollView.contentOffset.y<=sectionHeaderHeight) {
            self.isShow = NO;
            self.navTitleLabel.hidden = NO;
            self.navView.transform = CGAffineTransformMakeTranslation(0, -56);
        }else {
            self.isShow = YES;
            self.navTitleLabel.hidden = YES;
            self.navView.transform = CGAffineTransformMakeTranslation(0,56);
        }
    }else{
        if (scrollView.contentOffset.y<=sectionHeaderHeight) {
            if (self.detailModel.category.integerValue == 2){
                self.navTitleLabel.text = @"报道";
            }else{
                self.navTitleLabel.text = @"资讯";
            }
        }else {
            self.navTitleLabel.text = self.detailModel.title;
        }
    }
}

#pragma mark ------ 进入活动推荐详情
- (void)hisMainPage:(UITapGestureRecognizer *)g{
    _isPresentVC = YES;
    NSInteger index = g.view.tag;
    FinanaceDetailModel *activityModel = self.hotActivity[index];
    ActivityDetailController *detail = [[ActivityDetailController alloc]init];
    detail.activityid = activityModel.activityid;
    [self.navigationController pushViewController:detail animated:YES];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
/**
 *  通过下标获取图片
 */
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

#pragma mark - 点击看大图
- (void)tapPhoneAction:(NSMutableArray *)array{
    NSString *selectImageURl = array[0];
    [array removeObjectAtIndex:0];
    NSInteger index = [array indexOfObject:selectImageURl];
    // Create browser
    self.imageArray = [NSMutableArray new];
    
    for (NSInteger i =0; i < array.count; i++){
        MWPhoto *po = [MWPhoto photoWithURL:[NSURL URLWithString:array[i]]];
        [self.imageArray addObject:po];
    }
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

#pragma mark ----  关注
- (IBAction)attentionMessageDetail:(UIButton *)sender {
    BOOL aplyType;
    if (self.detailModel.isattention.integerValue == 1) {
        aplyType = NO;
    }else{
        //诸葛监控
        [[AppDelegate shareInstance] setZhugeTrack:@"关注用户" properties:@{@"useID":self.detailModel.postuserid, @"company":[CommonMethod paramStringIsNull:self.detailModel.company] ,@"position":[CommonMethod paramStringIsNull:self.detailModel.position]}];
        aplyType = YES;
    }
    [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",self.detailModel.postuserid] type:aplyType];
    @weakify(self);
    self.attentionBtnActionSuccess = ^(){
        @strongify(self);
        if (self.detailModel.isattention.integerValue == 1) {
            self.detailModel.isattention = [NSNumber numberWithInteger:0];
            [self.attionBtn setBackgroundImage:kImageWithName(@"btn_zixun_follow") forState:UIControlStateNormal];
            [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
            [self.attionBtn setTitle:@"关注" forState:UIControlStateNormal];
        }else{
            self.detailModel.isattention = [NSNumber numberWithInteger:1];
            [self.attionBtn setBackgroundImage:kImageWithName(@"btn_zixun_followed") forState:UIControlStateNormal];
            [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"AFB6C1"] forState:UIControlStateNormal];
            [self.attionBtn setTitle:@"已关注" forState:UIControlStateNormal];
        }
    };
}

#pragma mark ----  点赞
- (IBAction)likeTapActionBtn:(UIButton *)sender {
    if (self.detailModel.ispraise.integerValue == 1) {
        [self.view showToastMessage:@"你已经点过赞啦"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    //诸葛监控
    NSString *string =  [[CommonMethod paramArrayIsNull:self.detailModel.tags]  componentsJoinedByString:@","];
    [[AppDelegate shareInstance] setZhugeTrack:@"点赞资讯" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.detailModel.title],@"tag":string}];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",self.postID, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_TalkFINANACE_LIKEDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        weakSelf.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            
            
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSNumber *type = dict[@"type"];
            if (type.integerValue == 1) {
                [weakSelf.view showToastMessage:@"你已经点过赞啦"];
            }else{
                [MBProgressHUD showSuccess:@"点赞成功" toView:weakSelf.view];
                self.likeCountLabel.text = [NSString stringWithFormat:@"%ld",(self.detailModel.praisecount.integerValue + 1)];
                self.detailModel.ispraise = @1;
                self.likeCountLabel.textColor = [UIColor redColor];
                self.likeBtn.selected = YES;
                
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark ------- 评论事件
- (IBAction)ratePageTapAction:(UITapGestureRecognizer *)sender {
    self.isPresentVC = YES;
    RateListController *rate = [[RateListController alloc]init];
    rate.shareUrl = [NSString stringWithFormat:@"%@%@", INFORMATION_SHARE_URL, self.postID];
    rate.shareImage = self.detailModel.headimg;
    rate.shareTitle = self.detailModel.title;
    rate.shareCount = self.detailModel.subcontent;
    rate.postID = self.postID;
    rate.activityTitle = self.detailModel.title;
    rate.tag = [self.detailModel.tags  componentsJoinedByString:@","];
    [self.navigationController pushViewController:rate animated:YES];
}

#pragma mark ------- 分享
- (IBAction)shareDetailAction:(UIButton *)sender {
    //诸葛监控
    NSString *string =  [[CommonMethod paramArrayIsNull:self.detailModel.tags]  componentsJoinedByString:@","];
    [[AppDelegate shareInstance] setZhugeTrack:@"分享资讯" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.detailModel.title],@"tag":string}];
    
    [self sharViewActivity];
}

- (void)sharViewActivity{
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
        //转发
        if (index == 0){
            TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
            DynamicModel *model = [[DynamicModel alloc]init];
            model.post_id = shareSlef.postID;
            model.post_image = shareSlef.detailModel.headimg;
            model.post_title = shareSlef.detailModel.title;
            jinmai.model = model;
            [shareSlef presentViewController:jinmai animated:YES completion:nil];
        }else if(index== 1 || index == 2){
            [shareSlef firendClickWX:index];
        }else if (index == 3){
            //金脉好友
            //金脉好友
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            UserModel *model = [[UserModel alloc]init];
            model.realname = self.detailModel.title;
            model.image = self.detailModel.image;
            model.userId = self.postID;
            model.sex = @2;
            choseCtr.useModel = model;
            [shareSlef.navigationController pushViewController:choseCtr animated:YES];
        }else if(index== 4){
            UIPasteboard *paste = [UIPasteboard generalPasteboard];
            [paste setString:[NSString stringWithFormat:@"%@%@", INFORMATION_SHARE_URL, shareSlef.postID]];
            [MBProgressHUD showSuccess:@"复制成功" toView:shareSlef.view];
        }
    }];
}

#pragma mark ----------分享 ---
- (void)firendClickWX:(NSInteger)index{
    NSString *html = self.detailModel.subcontent;
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    
    NSString *title = self.detailModel.title;
    NSString *imageUrl = self.detailModel.headimg;
    id imageSource;
    if(imageUrl && imageUrl.length){
        if([imageUrl hasPrefix:@"http://image2."]){
            imageUrl = [imageUrl stringByAppendingString:@"?imageView2/1/w/80/h/80"];
        }
        imageSource = imageUrl;
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 1) {
        shareType = UMSocialPlatformType_WechatSession;
    }else  {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@%@", INFORMATION_SHARE_URL, self.postID];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

#pragma mark ------- 标题她的主页
- (IBAction)hisPageCtr:(UITapGestureRecognizer *)sender {
    self.isPresentVC = YES;
    NewMyHomePageController *myPage = [[NewMyHomePageController alloc]init];
    myPage.userId = self.detailModel.postuserid;
    [self.navigationController pushViewController:myPage animated:YES];
    
}

#pragma mark ------  相关阅读
- (void)intViewAboutDetail:(UITapGestureRecognizer *)g{
    NSInteger  index = g.view.tag;
    self.isPresentVC = YES;
    InformationDetailController *inforDetail = [[InformationDetailController alloc]init];
    inforDetail.postID = self.detailModel.relatepost[index][@"postid"];
    inforDetail.startType = YES;
    [self.navigationController pushViewController:inforDetail animated:YES];
    
}

- (IBAction)notWorkTapGetData:(UITapGestureRecognizer *)sender {
    [self getSubjectTalkFianaceDetailData];
}

#pragma mark ------  发表评论
- (IBAction)rateTapAction:(UITapGestureRecognizer *)sender {
    //诸葛监控
    NSString *string =  [[CommonMethod paramArrayIsNull:self.detailModel.tags]  componentsJoinedByString:@","];
    [[AppDelegate shareInstance] setZhugeTrack:@"评论资讯" properties:@{@"postID":self.postID, @"activityName":[CommonMethod paramStringIsNull:self.detailModel.title],@"tag":string}];
    
    self.isPresentVC = YES;
    WriteRateController *writeCtr = [[WriteRateController alloc]init];
    writeCtr.postID = self.postID;
    writeCtr.writeRateControllerDelegate = self;
    [self presentViewController:writeCtr animated:YES completion:nil];
}

#pragma mark ---- 发表评论writeRateControllerDelegate
- (void)senderRateSuccendBack:(BOOL)isRefer{
    if ((self.detailModel.reviewcount.integerValue +1) >= 10000) {
        self.rateDetailLabel.text = [NSString stringWithFormat:@"%ld万",(self.detailModel.reviewcount.integerValue+1)/10000];
    }else{
        self.rateDetailLabel.text = [NSString stringWithFormat:@"%ld",(self.detailModel.reviewcount.integerValue+1)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:InformationRefar object:nil];
}

//间距高度
-(CGFloat)getSpaceLabelHeight:(NSString*)str withFont:(UIFont*)font withWidth:(CGFloat)width {
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = 12;
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

#pragma mark ------ 创建滚动View
- (UIView *)createrSlidView:(FinanaceDetailModel *)model xwideth:(CGFloat)xWideth{
    CGFloat x = 16;
    CGFloat y = 0;
    UIView *homeView = [NSHelper createrViewFrame:CGRectMake(x + (240+16)*xWideth, y,240, 204) backColor:@"FAFAFB"];
    UIImageView *coverImageView = [UIImageView drawImageViewLine:CGRectMake(10, 10, 220, 123) bgColor:[UIColor clearColor]];
    [coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    coverImageView.clipsToBounds = YES;
    [homeView addSubview:coverImageView];
    CGFloat heigth = coverImageView.frame.origin.y+coverImageView.frame.size.height + 9;
    UILabel *nameLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 15) font:[UIFont systemFontOfSize:15] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"41464E"]];
    nameLabel.text = model.name;
    [homeView addSubview:nameLabel];
    heigth = heigth + 22;
    UILabel *companyLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 12) font:[UIFont systemFontOfSize:12] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    companyLabel.text = model.timestr;
    [homeView addSubview:companyLabel];
    heigth = heigth + 18;
    UILabel *positionLabel = [UILabel createLabel:CGRectMake(10, heigth, 220, 14) font:[UIFont systemFontOfSize:12] bkColor:[UIColor colorWithHexString:@"FAFAFB"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    
    positionLabel.text = [NSString stringWithFormat:@"%@%@",model.cityname,model.districtname];
    [homeView addSubview:positionLabel];
    homeView.layer.borderWidth = 0.5;
    homeView.layer.borderColor = [[UIColor colorWithHexString:@"D9D9D9"] CGColor];
    
    return homeView;
}


@end
