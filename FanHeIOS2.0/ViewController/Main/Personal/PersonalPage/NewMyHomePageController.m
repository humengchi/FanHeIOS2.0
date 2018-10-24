//
//  NewMyHomePageController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewMyHomePageController.h"
#import "NeedAndSupplyCell.h"
#import "SubjectInterviewCell.h"
#import "NewWorkHistoryCell.h"
#import "CommentCell.h"
#import "DynamicCell.h"
#import "NewLookHistoryCell.h"
#import "NODataTableViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "ContactsLoadDataView.h"
#import "MenuView.h"
#import "EditPersonalInfoViewController.h"
#import "ChatViewController.h"
#import "ShowPhoneView.h"
#import "ShareNormalView.h"
#import "ShareView.h"
#import "NewAddFriendController.h"
#import "ChoiceFriendViewController.h"
#import "IdentityController.h"
#import "PassReviewController.h"
#import "ReviewController.h"
#import "NotPassController.h"
#import "ComFriendsController.h"
#import "InformationDetailController.h"
#import "WorkHistoryController.h"
#import "WallCofferController.h"
#import "TaContactsCtr.h"
#import "CommentPersonController.h"
#import "PhotosController.h"
#import "SearchViewController.h"
#import "PublishNeedSupplyController.h"
#import "WorkHistoryEditorViewController.h"
#import "HonorEditViewController.h"
#import "HonorListViewController.h"
#import "VariousDetailController.h"
#import "NeedSupplyErrorView.h"
#import "CompanyViewController.h"
#import "CofferAlearGetView.h"
#import "GetMyselfCoffer.h"
#import "GetSucceedCofferView.h"
#import "AlreadHaveCofferView.h"
#import "GetWallCoffeeDetailViewController.h"
#import "RichTextViewController.h"
#import "FirstLaunchGuideView.h"
#import "DynamicNotificationCtr.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionType_Need,
    SectionType_Supply,
    SectionType_Subject,
    SectionType_WorkHistory,
    SectionType_Introduce,
    SectionType_Honor,
    SectionType_Tag,
    SectionType_Photo,
    SectionType_Comment,
    
    SectionType_Coffee,
    SectionType_Attention,
    SectionType_LookHistory,
};

@interface NewMyHomePageController ()<MWPhotoBrowserDelegate, WorkHistoryEditorViewControllerDelegate, TZImagePickerControllerDelegate>{
    NSInteger _currentTab;
    BOOL _noNetWork;
    BOOL _isLoadHttp;
    BOOL _isPresentVC;
}

@property (nonatomic,assign) BOOL isMyHomePage;
@property (nonatomic,strong) UIView *navbarView;
@property (nonatomic,strong) UIView *navbarBgView;
@property (nonatomic,strong) UILabel *navbarTitleLabel;
@property (nonatomic,strong) UIButton *navbarBackBtn;
@property (nonatomic,strong) UIButton *navbarMoreBtn;
@property (nonatomic,strong) UIImageView *coverImageView;
@property (nonatomic,strong) UIImageView *headerImageView;

@property (nonatomic,strong) UIView *tabbarView; //tab栏
@property (nonatomic,strong) UIView *tabbarTableView;

@property (nonatomic,strong) UIView *bottomBtnView;

//动态
@property (nonatomic, strong) NSMutableDictionary *cellArrayDict;
@property (nonatomic, strong) NSMutableArray *dynamicArray;

@property (nonatomic, strong) UserModel *userModel;

//概览展示数据array  count
@property (nonatomic, strong) NSMutableArray *summaryArray;
//人脉 数据array  count
@property (nonatomic, strong) NSMutableArray *contactArray;

@property (nonatomic, strong) NSMutableArray *lookHistoryArray;;


@property (nonatomic, strong) MenuView * menuView;
@property (nonatomic, assign) BOOL flag;
@property (nonatomic, strong) ShowPhoneView *showPhoneView;
@property (nonatomic, strong) ShareView *shawView;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSString *authenti_image;

@end

#define Cell_Index_key(index) ([NSString stringWithFormat:@"cell_%ld", (long)index])

@implementation NewMyHomePageController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.flag == NO){
        [self.menuView showMenuWithAnimation:NO];
        self.flag = YES;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if(self.isMyHomePage){
        [self createrIDStart];
    }
    _isPresentVC = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([[UIApplication sharedApplication] statusBarStyle] == UIStatusBarStyleDefault && _isPresentVC == NO) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
    
    _currentTab = 0;
    self.cellArrayDict = [NSMutableDictionary dictionary];
    self.dynamicArray = [NSMutableArray array];
    self.summaryArray = [NSMutableArray array];
    self.contactArray = [NSMutableArray array];
    self.lookHistoryArray = [NSMutableArray array];
    self.userModel = [[UserModel alloc] init];
    self.imageArray = [NSMutableArray array];
    self.flag = YES;
    
    self.isMyHomePage = [DataModelInstance shareInstance].userModel.userId.integerValue==self.userId.integerValue;
    
    [self initGroupedTableView:CGRectMake(0, 0, WIDTH,HEIGHT-55)];
    [self createBottomButtonView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) weakSelf = self;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        if(weakSelf.userModel.userId.integerValue){
            if(_currentTab==0){
                [weakSelf loadCommentListData];
            }else if(_currentTab==1){
                [weakSelf loadHttpDynamicListData];
            }else if(_currentTab==2){
                [weakSelf lookHistoryGetData];
            }
        }else{
            [weakSelf.tableView endRefresh];
        }
    }];
    
    [self createNavBarView];
    [self createTableViewHeaderView];
    [self loadHttpMyHomePageData];
    [self loadHttpDynamicListData];
    
    if (self.zbarModel) {
        if (self.zbarModel.rst.integerValue != 1){
            [self scaningCofferResultShow];
        }
    }
}

//挂墙咖啡
- (void)scaningCofferResultShow{
    /*
     0 --- 失效
     1-正常
     2-别人领取过这杯咖啡
     3-自己领取过这杯咖啡
     4-已领取过此人的其他咖啡并兑换，
     5-领取自己的咖啡
     6 -已有咖啡未兑换
     */
    
    if (self.zbarModel.rst.integerValue == 0) {
        GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [view ceraterTitleLabelShow:NO];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 2){
        GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 3){
        GetSucceedCofferView *view = [CommonMethod getViewFromNib:@"GetSucceedCofferView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [view createrGetCofferCoverImage:self.zbarModel.headimg isMyGet:NO];
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 4) {
        CofferAlearGetView *view = [CommonMethod getViewFromNib:@"CofferAlearGetView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }else if (self.zbarModel.rst.integerValue == 6){
        AlreadHaveCofferView *view = [CommonMethod getViewFromNib:@"AlreadHaveCofferView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        __weak typeof(self) weakSelf = self;
        view.checkGetCofferDetail = ^{
            _isPresentVC = YES;
            GetWallCoffeeDetailViewController *vc = [CommonMethod getVCFromNib:[GetWallCoffeeDetailViewController class]];
            vc.isMygetCoffee = YES;
            vc.coffeegetid = weakSelf.zbarModel.getid;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

- (void)reloadTableView:(NSNotification *)notification{
    if(_currentTab!=1){
        return;
    }
    NSNumber *index = (NSNumber*)notification.object;
    if(index.integerValue>=0){
        for(NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]){
            NSInteger row = indexPath.row;
            if(self.isMyHomePage){
                row -= 1;
            }
            if([self.cellArrayDict.allKeys containsObject:Cell_Index_key(row)]){
                [self.cellArrayDict removeObjectForKey:Cell_Index_key(row)];
            }
            if(row == index.integerValue){
                [self.tableView reloadData];
                break;
            }
        }
    }
}

#pragma mark ------- 导航栏
- (void)createNavBarView{
    //整体view
    self.navbarView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    self.navbarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.navbarView];
    
    //背景颜色
    self.navbarBgView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    self.navbarBgView.backgroundColor = [UIColor whiteColor];
    self.navbarBgView.alpha = 0;
    [self.navbarView addSubview:self.navbarBgView];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.navbarBgView addSubview:lineLabel];
    //返回按钮
    self.navbarBackBtn = [NSHelper createButton:CGRectMake(12, 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_back_normal"] selectImage:nil target:self selector:@selector(backButtonClicked:)];
    [self.navbarView addSubview:self.navbarBackBtn];
    //更多按钮
    if(self.isMyHomePage){
        self.navbarMoreBtn = [NSHelper createButton:CGRectMake(WIDTH - 44, 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_myindex_edit"] selectImage:nil target:self selector:@selector(moreButtonClicked:)];
    }else{
        self.navbarMoreBtn = [NSHelper createButton:CGRectMake(WIDTH - 44, 26, 32, 32) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_more_normal"] selectImage:nil target:self selector:@selector(moreButtonClicked:)];
    }
    [self.navbarView addSubview:self.navbarMoreBtn];
    if (!self.isMyHomePage) {
    }
    //标题
    self.navbarTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, WIDTH-100, 44)];
    self.navbarTitleLabel.hidden = YES;
    self.navbarTitleLabel.textColor = HEX_COLOR(@"383838");
    self.navbarTitleLabel.font = FONT_SYSTEM_SIZE(17);
    self.navbarTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navbarView addSubview:self.navbarTitleLabel];
    [self showNarbarTitleLabelText];
}

- (void)showNarbarTitleLabelText{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:[CommonMethod paramStringIsNull:weakSelf.userModel.realname]];
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:weakSelf.userModel.image]]];
        UIImage *headImage;
        if(data){
            headImage = [UIImage imageWithData:data];
        }else{
            headImage = KHeadImageDefaultName([CommonMethod paramStringIsNull:weakSelf.userModel.realname]);
        }
        attchImage.image = [headImage roundedCornerImageWithCornerRadius:CGRectMake(0, 0, 24, 24)];
        attchImage.bounds = CGRectMake(-4, -6, 24, 24);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr insertAttributedString:stringImage atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navbarTitleLabel.attributedText = attriStr;
        });
    });
}

#pragma mark ------- headerView
- (void)createTableViewHeaderView{
    CGFloat coverImageHeight = 200*WIDTH/375.0;
    UIView *headerView = [[UIView alloc] init];
    if(self.isMyHomePage || [CommonMethod paramNumberIsNull:self.userModel.connectionsCount].integerValue==0){
        headerView.frame = CGRectMake(0, 0, WIDTH, coverImageHeight+199+43);
    }else{
        headerView.frame = CGRectMake(0, 0, WIDTH, coverImageHeight+265+43);
    }
    headerView.backgroundColor = WHITE_COLOR;
    if(!self.coverImageView){
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, coverImageHeight)];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
    }
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.userModel.bgimage]] placeholderImage:kImageWithName(@"image_zy_bg")];
    [headerView addSubview:self.coverImageView];
    if(self.isMyHomePage){
        [CommonMethod viewAddGuestureRecognizer:self.coverImageView tapsNumber:1 withTarget:self withSEL:@selector(changeCoverImageView)];
    }
    if(!self.headerImageView){
        self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-100)/2.0, coverImageHeight-50, 100, 100)];
        self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.headerImageView.clipsToBounds = YES;
        [CALayer updateControlLayer:self.headerImageView.layer radius:50 borderWidth:0 borderColor:nil];
        [CommonMethod viewAddGuestureRecognizer:self.headerImageView tapsNumber:1 withTarget:self withSEL:@selector(showBigHeadImageView)];
    }
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.userModel.image]] placeholderImage:KHeadImageDefaultName([CommonMethod paramStringIsNull:self.userModel.realname]) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(error && !self.isMyHomePage){
            self.headerImageView.userInteractionEnabled = NO;
        }else{
            self.headerImageView.userInteractionEnabled = YES;
        }
    }];
    [headerView addSubview:self.headerImageView];
    
    UIImageView *rzImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, coverImageHeight, 36, 55)];
    NSInteger hasValidUser = [CommonMethod paramNumberIsNull:self.userModel.hasValidUser].integerValue;
    if (hasValidUser == 0) {
        rzImageView.image = [UIImage imageNamed:@"btn_zy_wrz"];
    }else if (hasValidUser == 1) {
        rzImageView.image = [UIImage imageNamed:@"btn_zy_yrz"];
    }else if (hasValidUser == 2) {
        rzImageView.image = [UIImage imageNamed:@"btn_zy_shz"];
    }else if (hasValidUser == 3) {
        rzImageView.image = [UIImage imageNamed:@"btn_zy_rzsb"];
    }
    [headerView addSubview:rzImageView];
    if(self.isMyHomePage){
        [CommonMethod viewAddGuestureRecognizer:rzImageView tapsNumber:1 withTarget:self withSEL:@selector(clickedIdentityMessage)];
    }
    
    if(self.userModel.usertype.integerValue == 9){
        UIImageView *vipImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-100)/2.0+76, coverImageHeight-50+80, 16, 16)];
        vipImageView.image = kImageWithName(@"icon_v_jv");
        [headerView addSubview:vipImageView];
    }
    
    NSString *nameStr = [CommonMethod paramStringIsNull:self.userModel.realname];
    CGFloat nameStrWidth = (NSInteger)[NSHelper widthOfString:(nameStr.length==0?@"姓名":nameStr) font:FONT_SYSTEM_SIZE(17) height:17]+1;
    UILabel *nameLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-nameStrWidth)/2.0, coverImageHeight+61, nameStrWidth, 19) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:(nameStr.length==0?@"姓名":nameStr) font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    nameLabel.text = nameStr.length==0?@"姓名":nameStr;
    nameLabel.textColor = nameStr.length==0?HEX_COLOR(@"e6e8eb"):HEX_COLOR(@"41464e");
    [headerView addSubview:nameLabel];
    
    CGFloat start_X = (WIDTH-nameStrWidth)/2.0+nameStrWidth+6;
    if([CommonMethod paramStringIsNull:self.userModel.relation].length && !self.isMyHomePage){
        CGFloat strWidth = (NSInteger)[NSHelper widthOfString:self.userModel.relation font:FONT_SYSTEM_SIZE(8) height:11]+15+1;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, coverImageHeight+65, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:self.userModel.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [headerView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:self.userModel.othericon].integerValue==1){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, coverImageHeight+65, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [headerView addSubview:iconImageView];
    }
    NSMutableArray *infoArray = [NSMutableArray array];
    NSString *industry = [CommonMethod paramStringIsNull:self.userModel.industry];
    industry = industry.length==0?@"行业":industry;
    [infoArray addObject:industry];
    NSString *city = [CommonMethod paramStringIsNull:self.userModel.city];
    city = city.length==0?@"地区":city;
    [infoArray addObject:city];
    NSString *workyearstr = [CommonMethod paramStringIsNull:self.userModel.workyearstr];
    workyearstr = workyearstr.length==0?@"从业时间":workyearstr;
    [infoArray addObject:workyearstr];
    UILabel *infoLabel = [UILabel createrLabelframe:CGRectMake(16, coverImageHeight+87, WIDTH-32, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:[infoArray componentsJoinedByString:@" | "] font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    if([[infoArray componentsJoinedByString:@" | "] isEqualToString:@"行业 | 地区 | 从业时间"]){
        infoLabel.textColor = HEX_COLOR(@"e6e8eb");
    }
    [headerView addSubview:infoLabel];
    
    UIImageView *companyLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, coverImageHeight+113, 64, 64)];
    [companyLogoImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.userModel.companylogo]] placeholderImage:kImageWithName(@"icon_work_company")];
    companyLogoImageView.contentMode = UIViewContentModeScaleAspectFill;
    companyLogoImageView.clipsToBounds = YES;
    [headerView addSubview:companyLogoImageView];
    [CommonMethod viewAddGuestureRecognizer:companyLogoImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoCompanyDetail)];
    
    NSString *companyStr = [CommonMethod paramStringIsNull:self.userModel.company];
    UILabel *companyNameLabel = [UILabel createrLabelframe:CGRectMake(92, coverImageHeight+125, WIDTH-108, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:companyStr font:17 number:1 nstextLocat:NSTextAlignmentLeft];
    companyNameLabel.text = companyStr.length==0?@"公司":companyStr;
    companyNameLabel.textColor = companyStr.length==0?HEX_COLOR(@"e6e8eb"):HEX_COLOR(@"41464e");
    [headerView addSubview:companyNameLabel];
    
    NSString *positionStr = [CommonMethod paramStringIsNull:self.userModel.position];
    UILabel *positionLabel = [UILabel createrLabelframe:CGRectMake(92, coverImageHeight+148, WIDTH-108, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:positionStr font:17 number:1 nstextLocat:NSTextAlignmentLeft];
    positionLabel.text = positionStr.length==0?@"职位":positionStr;
    positionLabel.textColor = positionStr.length==0?HEX_COLOR(@"e6e8eb"):HEX_COLOR(@"41464e");
    [headerView addSubview:positionLabel];
    
    CGFloat tabbarStartY = 0;
    if(!self.isMyHomePage && [CommonMethod paramNumberIsNull:self.userModel.connectionsCount].integerValue){
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, coverImageHeight+189, WIDTH-32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel];
        
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, coverImageHeight+215, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [headerView addSubview:nextImageView];
        
        CGFloat strWidth = (NSInteger)[NSHelper widthOfString:[NSString stringWithFormat:@"%@个共同好友", [NSString getNumStr:[CommonMethod paramNumberIsNull:self.userModel.connectionsCount]]] font:FONT_SYSTEM_SIZE(14) height:50]+1;
        UILabel *friNumLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-34-strWidth, coverImageHeight+215, strWidth, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:[NSString stringWithFormat:@"%@个共同好友", [NSString getNumStr:[CommonMethod paramNumberIsNull:self.userModel.connectionsCount]]] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [headerView addSubview:friNumLabel];
        for (int i=0; i < [[CommonMethod paramArrayIsNull:self.userModel.connectionsArray] count]; i++) {
            if(WIDTH-56-strWidth<27*(i+1)+7){
                break;
            }
            UserModel *model = self.userModel.connectionsArray[i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+27*i, coverImageHeight+205, 34, 34)];
            if(WIDTH-56-strWidth<27*(i+2)+7){
                imageView.image = kImageWithName(@"icon_index_rmgd");
            }else{
                [imageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.image]] placeholderImage:KHeadImageDefaultName([CommonMethod paramStringIsNull:model.realname])];
            }
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [headerView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, coverImageHeight+254.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, coverImageHeight+255, WIDTH, 10)];
        lineLabel2.backgroundColor = kTableViewBgColor;
        [headerView addSubview:lineLabel2];
        tabbarStartY = coverImageHeight+265;
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, coverImageHeight+189, WIDTH, 66)];
        tapView.backgroundColor = [UIColor clearColor];
        [headerView addSubview:tapView];
        [CommonMethod viewAddGuestureRecognizer:tapView tapsNumber:1 withTarget:self withSEL:@selector(gotoComFriendVC)];
    }else{
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, coverImageHeight+188.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, coverImageHeight+189, WIDTH, 10)];
        lineLabel2.backgroundColor = kTableViewBgColor;
        [headerView addSubview:lineLabel2];
        tabbarStartY = coverImageHeight+199;
    }
    
    for(UIView *view in self.tabbarTableView.subviews){
        [view removeFromSuperview];
    }
    self.tabbarTableView = [[UIView alloc] initWithFrame:CGRectMake(0, tabbarStartY, WIDTH, 43)];
    self.tabbarTableView.backgroundColor = WHITE_COLOR;
    CGFloat tabWidth = WIDTH/4;
    NSArray *titles;
    NSString *dynamicStr = [NSString stringWithFormat:@"动态 %@", [CommonMethod paramNumberIsNull:self.userModel.dynamicnum].integerValue?self.userModel.dynamicnum:@""];
    if(!self.isMyHomePage){
        titles = @[@"概览",dynamicStr,@"人脉"];
    }else{
        titles = @[@"概览",dynamicStr];
    }
    start_X = (WIDTH-tabWidth*titles.count)/2;
    for(int i = 0; i < titles.count; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(start_X+tabWidth*i, 0, tabWidth, 43);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"41464e") forState:UIControlStateSelected];
        btn.tag = i+300;
        btn.titleLabel.font = FONT_SYSTEM_SIZE(15);
        [btn addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabbarTableView addSubview:btn];
        if(i == _currentTab){
            btn.selected = YES;
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(tabWidth-50)/2+i*tabWidth, 42, 50, 1)];
            redLabel.backgroundColor = HEX_COLOR(@"e23608");
            redLabel.tag = 200;
            [self.tabbarTableView addSubview:redLabel];
        }
        if(i < titles.count-1){
            UILabel *vLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(i+1)*tabWidth-0.5, 14, 0.5, 14)];
            vLineLabel.backgroundColor = kCellLineColor;
            [self.tabbarTableView addSubview:vLineLabel];
        }
    }
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel1.backgroundColor = kCellLineColor;
    [self.tabbarTableView addSubview:lineLabel1];
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, WIDTH, 0.5)];
    lineLabel2.backgroundColor = kCellLineColor;
    [self.tabbarTableView addSubview:lineLabel2];
    [headerView addSubview:self.tabbarTableView];
    self.tableView.tableHeaderView = headerView;
    
    [self createTabbarView];
    [self showNarbarTitleLabelText];
}

//滑动到顶部，定住tab栏
- (void)createTabbarView{
    for(UIView *view in self.tabbarView.subviews){
        [view removeFromSuperview];
    }
    if(self.tabbarView){
        [self.tabbarView removeFromSuperview];
        self.tabbarView = nil;
    }
    self.tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 43)];
    self.tabbarView.backgroundColor = WHITE_COLOR;
    CGFloat tabWidth = WIDTH/4;
    NSArray *titles;
    NSString *dynamicStr = [NSString stringWithFormat:@"动态 %@", [CommonMethod paramNumberIsNull:self.userModel.dynamicnum].integerValue?self.userModel.dynamicnum:@""];
    if(!self.isMyHomePage){
        titles = @[@"概览",dynamicStr,@"人脉"];
    }else{
        titles = @[@"概览",dynamicStr];
    }
    CGFloat start_X = (WIDTH-tabWidth*titles.count)/2;
    for(int i = 0; i < titles.count; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(start_X+tabWidth*i, 0, tabWidth, 43);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"41464e") forState:UIControlStateSelected];
        btn.tag = i+300;
        btn.titleLabel.font = FONT_SYSTEM_SIZE(15);
        [btn addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabbarView addSubview:btn];
        if(i == _currentTab){
            btn.selected = YES;
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(tabWidth-50)/2+i*tabWidth, 42, 50, 1)];
            redLabel.backgroundColor = HEX_COLOR(@"e23608");
            redLabel.tag = 200;
            [self.tabbarView addSubview:redLabel];
        }
        if(i < titles.count-1){
            UILabel *vLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(i+1)*tabWidth-0.5, 14, 0.5, 14)];
            vLineLabel.backgroundColor = kCellLineColor;
            [self.tabbarView addSubview:vLineLabel];
        }
    }
//    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
//    lineLabel1.backgroundColor = kCellLineColor;
//    [self.tabbarView addSubview:lineLabel1];
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, WIDTH, 0.5)];
    lineLabel2.backgroundColor = kCellLineColor;
    [self.tabbarView addSubview:lineLabel2];
    self.tabbarView.hidden = YES;
    [self.view addSubview:self.tabbarView];
}

//底部按钮试图
- (void)createBottomButtonView{
    for(UIView *view in self.bottomBtnView.subviews){
        [view removeFromSuperview];
    }
    if(self.bottomBtnView){
        [self.bottomBtnView removeFromSuperview];
        self.bottomBtnView = nil;
    }
    self.bottomBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-55, WIDTH, 55)];
    self.bottomBtnView.backgroundColor = HEX_COLOR(@"f7f7f7");
    [self.view addSubview:self.bottomBtnView];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.bottomBtnView addSubview:lineLabel];
    
    if(self.isMyHomePage){
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(25, 7, WIDTH-50, 40);
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [shareBtn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
        [shareBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.bottomBtnView addSubview:shareBtn];
        [shareBtn addTarget:self action:@selector(showShareView) forControlEvents:UIControlEventTouchUpInside];
    }else{
        UIButton *attentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        attentBtn.frame = CGRectMake(25, 7, 100, 40);
        if(self.userModel.isattention.integerValue==0){
            [attentBtn setTitle:@"关注一下" forState:UIControlStateNormal];
            [attentBtn setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
            [attentBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        }else{
            [attentBtn setTitle:@" 已关注" forState:UIControlStateNormal];
            
            [attentBtn setBackgroundImage:kImageWithName(@"btn_coffee_qx") forState:UIControlStateNormal];
            [attentBtn setImage:kImageWithName(@"btn_zy_ygz_redsx") forState:UIControlStateNormal];
            [attentBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
        }
        [attentBtn addTarget:self action:@selector(attentionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomBtnView addSubview:attentBtn];
        
        if(!self.userModel.isfriend.integerValue){
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(135, 7, WIDTH-160, 40);
            if (self.zbarModel.rst.integerValue == 1) {
                [addBtn setTitle:@"领取Ta的咖啡，认识一下" forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(editGetCofferMessage) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [addBtn setTitle:@"加为好友" forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(addFriendBtnnAction) forControlEvents:UIControlEventTouchUpInside];
            }
            [addBtn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
            [addBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            [self.bottomBtnView addSubview:addBtn];
            
            attentBtn.enabled = self.userModel.userId.integerValue!=0;
            addBtn.enabled = self.userModel.userId.integerValue!=0;
        }else{
            UIButton *sendMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            sendMsgBtn.frame = CGRectMake(135, 7, WIDTH-210, 40);
            if (self.zbarModel.rst.integerValue == 1) {
                [sendMsgBtn setTitle:@"领取Ta的咖啡" forState:UIControlStateNormal];
                [sendMsgBtn addTarget:self action:@selector(editGetCofferMessage) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [sendMsgBtn setTitle:@"发消息" forState:UIControlStateNormal];
                [sendMsgBtn addTarget:self action:@selector(contactsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }//btn_bg_red
            [sendMsgBtn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
            [sendMsgBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            [self.bottomBtnView addSubview:sendMsgBtn];
            
            UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            phoneBtn.frame = CGRectMake(WIDTH-65, 7, 40, 40);
            [phoneBtn setBackgroundImage:kImageWithName(@"btn_zy_lxfx") forState:UIControlStateNormal];
            [self.bottomBtnView addSubview:phoneBtn];
            [phoneBtn addTarget:self action:@selector(showPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
            
            attentBtn.enabled = self.userModel.userId.integerValue!=0;
            sendMsgBtn.enabled = self.userModel.userId.integerValue!=0;
            phoneBtn.enabled = self.userModel.userId.integerValue!=0;
        }
    }
}

/****************按钮方法*********************/
#pragma mark - 共同好友
- (void)gotoComFriendVC{
    _isPresentVC = YES;
    ComFriendsController *vc = [[ComFriendsController alloc] init];
    vc.userID = self.userId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --评论
- (void)gotoCommentPersonVC{
    _isPresentVC = YES;
    if(self.isMyHomePage){
        ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
        choseCtr.isInviteCommend = YES;
        [self.navigationController pushViewController:choseCtr animated:YES];
    }else{
        __weak typeof(self) weakSelf = self;
        CommentPersonController *vc = [CommonMethod getVCFromNib:[CommentPersonController class]];
        vc.realname = self.userModel.realname;
        vc.userId = self.userId;
        vc.commentSuccess = ^{
            [weakSelf loadHttpMyHomePageData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - sectionheaderview中的添加发布等
- (void)sectionHeaderAddButtonClicked:(UIButton*)sender{
    if(sender.tag==201 || sender.tag==202){
        sender.userInteractionEnabled = NO;
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
        [self requstType:RequestType_Get apiName:API_NAME_GET_USER_RESTGX paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            sender.userInteractionEnabled = YES;
            if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
                NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
                NSNumber *rest_times = [CommonMethod paramNumberIsNull:dic[@"rest_times"]];
                if (rest_times.integerValue > 0) {
                    _isPresentVC = YES;
                    PublishNeedSupplyController *vc = [CommonMethod getVCFromNib:[PublishNeedSupplyController class]];
                    vc.isNeed = sender.tag==201;
                    vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                        [weakSelf loadHttpMyHomePageData];
                    };
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }else{
                    NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
                    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                    view.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                    view.confirmButtonClicked = ^{
                        _isPresentVC = YES;
                        PublishNeedSupplyController *vc = [CommonMethod getVCFromNib:[PublishNeedSupplyController class]];
                        vc.isNeed = sender.tag==201;
                        vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                            [weakSelf loadHttpMyHomePageData];
                        };
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    };
                    [[UIApplication sharedApplication].keyWindow addSubview:view];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            sender.userInteractionEnabled = YES;
        }];
    }else if(sender.tag==203){
        _isPresentVC = YES;
        WorkHistoryEditorViewController *workHistory = [[WorkHistoryEditorViewController alloc]init];
        workHistory.workModel = [[workHistryModel alloc] init];
        workHistory.index = 1;
        workHistory.workDelegate = self;
        [self.navigationController pushViewController:workHistory animated:YES];
    }else if(sender.tag==204){
        _isPresentVC = YES;
        HonorEditViewController *vc = [CommonMethod getVCFromNib:[HonorEditViewController class]];
        vc.honorEditSuccess = ^(HONOR_TYPE type, HonorModel *model) {
            [self.userModel.honorsArray addObject:model];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if(sender.tag==205){
        [self openPhoto];
    }
}

//相册选择器
- (void)openPhoto{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1))];
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray *photos, NSArray *assets, BOOL success) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        NSMutableArray *imagesArray = [NSMutableArray array];
        for (UIImage *image in photos) {
            UIImage *newImage = image;
            //旋转
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp){
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [imagesArray addObject:newImage];
        }
        [self uploadImageHttp:nil imagesArray:imagesArray];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - 上传图片
- (void)uploadImageHttp:(MBProgressHUD*)hud imagesArray:(NSMutableArray*)imagesArray{
    UIImage *image;
    NSInteger index = 0;
    for(id param in imagesArray){
        if([param isKindOfClass:[UIImage class]]){
            image = param;
            break;
        }
        index++;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if(image){
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [requestDict setObject:imageData forKey:@"pphoto"];
        if(hud==nil){
            hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
        }
    }else{
        if(hud==nil){
            hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
        }
        [self savePhotos:hud imagesArray:imagesArray];
        return;
    }
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            imagesArray[index] = urlStr;
            [weakSelf uploadImageHttp:hud imagesArray:imagesArray];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showMessag:@"图片上传失败，请重试！" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        
    }];
}

#pragma mark - 保存相册
- (void)savePhotos:(MBProgressHUD*)hud imagesArray:(NSMutableArray*)imagesArray{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[imagesArray componentsJoinedByString:@","] forKey:@"image"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_UPLOAD_ALBUM paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"上传成功!" toView:weakSelf.view];
            NSMutableArray *array = [NSMutableArray arrayWithArray:weakSelf.userModel.album];
            [array insertObjects:imagesArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, imagesArray.count)]];
            weakSelf.userModel.album = array;
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}


#pragma mark - WorkHistoryEditorViewControllerDelegate
- (void)changeWorkHistory:(workHistryModel *)model delect:(BOOL)isdelect{
    [self loadHttpMyHomePageData];
}

#pragma mark -- 点击头像，放大头像
- (void)showBigHeadImageView{
    if(self.isMyHomePage){
        __weak typeof(self) weakSelf = self;
        UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadHeaderImage];
        view.uploadHeaderImageViewResult = ^(BOOL success){
            if(success){
                weakSelf.userModel.image = [DataModelInstance shareInstance].userModel.image;
                [weakSelf.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:weakSelf.userModel.image]] placeholderImage:KHeadImageDefaultName([CommonMethod paramStringIsNull:weakSelf.userModel.realname])];
            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        [view showShareNormalView];
    }else if([CommonMethod paramStringIsNull:self.userModel.image].length){
        [self photoButtonClicked:0 imageArray:@[self.userModel.image]];
    }
}

#pragma mark -- 点击个人相册，放大图片
- (void)showPhotosImage:(UITapGestureRecognizer*)tap{
    UIImageView *imageView = (UIImageView*)tap.view;
    if(self.userModel.album.count>imageView.tag){
        [self photoButtonClicked:imageView.tag imageArray:self.userModel.album];
    }else if(imageView.tag == 200){
        [self openPhoto];
    }
}

#pragma mark -- 点击公司logo跳转
- (void)gotoCompanyDetail{
    _isPresentVC = YES;
    CompanyViewController *vc = [[CompanyViewController alloc] init];
    vc.companyId = self.userModel.companyid;
    vc.company = self.userModel.company;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- 修改封面
- (void)changeCoverImageView{
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    view.uploadImageViewImage = ^(UIImage *image){
        [weakSelf uploadHeadImage:image];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

//上传封面图片
- (void)uploadHeadImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud =
    [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            [weakSelf saveCoverImage:urlStr hud:hud];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
    }];
}
//保存封面
- (void)saveCoverImage:(NSString*)url hud:(MBProgressHUD*)hud {
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:url forKey:@"bgimage"];
    [requestDict setObject:self.userId forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SET_BGIMG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            weakSelf.userModel.bgimage = url;
            [weakSelf.coverImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:kImageWithName(@"image_zy_bg")];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
    }];
}

#pragma  mark --------认证
- (void)clickedIdentityMessage{
    if(![CommonMethod getUserCanIdentify]){
        __weak typeof(self) weakSelf = self;
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_Identify];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            _isPresentVC = YES;
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^{
                [weakSelf loadHttpMyHomePageData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    if (self.userModel.hasValidUser.integerValue == 0){
        _isPresentVC = YES;
        IdentityController *vc = [CommonMethod getVCFromNib:[IdentityController class]];
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.userModel.hasValidUser.integerValue == 1){
        _isPresentVC = YES;
        PassReviewController *vc = [CommonMethod getVCFromNib:[PassReviewController class]];
        vc.urlImage = self.authenti_image;
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.userModel.hasValidUser.integerValue == 2){
        _isPresentVC = YES;
        ReviewController *vc = [CommonMethod getVCFromNib:[ReviewController class]];
        vc.urlImage = self.authenti_image;
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        _isPresentVC = YES;
        NotPassController *vc = [CommonMethod getVCFromNib:[NotPassController class]];
        vc.rootTmpViewController = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark ---- 更多／编辑
- (void)moreButtonClicked:(UIButton*)sender{
    if(self.isMyHomePage){
        _isPresentVC = YES;
        __weak typeof(self) weakSelf = self;
        EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
        vc.savePersonalInfoSuccess = ^{
            [weakSelf loadHttpMyHomePageData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (self.flag) {
            [self.menuView showMenuWithAnimation:YES];
            self.flag = NO;
        }else{
            [self.menuView showMenuWithAnimation:NO];
            self.flag = YES;
            self.menuView = nil;
        }
    }
}

#pragma mark -------  聊天
- (void)contactsButtonClicked:(UIButton*)sender{
    _isPresentVC = YES;
    NSString *chartId = [NSString stringWithFormat:@"%@",self.userId];
    ChatViewController *chatVC = [[ChatViewController alloc]initWithConversationChatter:chartId conversationType:EMConversationTypeChat];
    chatVC.title = self.userModel.realname;
    chatVC.position = [NSString stringWithFormat:@"%@%@",self.userModel.company,self.userModel.position];
    chatVC.phoneNumber = self.userModel.phone;
    chatVC.pushIndex = 888;
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - 进入个人相册
- (void)gotoPhotosVC{
    _isPresentVC = YES;
    PhotosController *vc = [CommonMethod getVCFromNib:[PhotosController class]];
    vc.userId = self.userId;
    vc.photosChange = ^(NSMutableArray *array) {
        self.userModel.album = array;
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -------  返回
- (void)backButtonClicked:(UIButton*)sender{
    [self.menuView showMenuWithAnimation:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -------tab栏点击btn
- (void)tabButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.tableView endRefresh];
    [self cancelAllRequest];
    _currentTab = sender.tag-300;
    
    CGFloat tabWidth = WIDTH/4;
    NSInteger tabsNum = 0;
    if(!self.isMyHomePage){
        tabsNum = 3;
    }else{
        tabsNum = 2;
    }
    CGFloat start_X = (WIDTH-tabWidth*tabsNum)/2;
    for(int i = 0; i < tabsNum; i++){
        UIButton *btn1 = (UIButton*)[self.tabbarView subviewWithTag:300+i];
        btn1.selected = NO;
        UIButton *btn2 = (UIButton*)[self.tabbarTableView subviewWithTag:300+i];
        btn2.selected = NO;
    }
    sender.selected = YES;
    
    __weak UILabel *redLabel1 = (UILabel*)[self.tabbarView subviewWithTag:200];
    [UIView animateWithDuration:0.3 animations:^{
        redLabel1.frame = CGRectMake(start_X+(WIDTH/4-50)/2+_currentTab*(WIDTH/4), 42, 50, 1);
    }];
    __weak UILabel *redLabel2 = (UILabel*)[self.tabbarTableView subviewWithTag:200];
    [UIView animateWithDuration:0.3 animations:^{
        redLabel2.frame = CGRectMake(start_X+(WIDTH/4-50)/2+_currentTab*(WIDTH/4), 42, 50, 1);
    }];
    CGFloat coverImageHeight = 200*WIDTH/375.0;
    if(self.isMyHomePage || [CommonMethod paramNumberIsNull:self.userModel.connectionsCount].integerValue==0){
        coverImageHeight += 199+43;
    }else{
        coverImageHeight += 265+43;
    }
    [self.tableView reloadData];
    if(self.tableView.contentOffset.y > coverImageHeight-64-43){
        [self.tableView setContentOffset:CGPointMake(0, coverImageHeight-64-43) animated:NO];
    }
    if(_currentTab==0){
        if(self.userModel.evaluationsArray.count%20 || self.userModel.evaluationsArray.count==0){
            [self.tableView endRefreshNoData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        if(self.userModel.evaluationsArray.count==0){
            [self loadCommentListData];
        }else{
            [self.tableView reloadData];
        }
    }else if(_currentTab==1){
        if(self.dynamicArray.count%20 || self.dynamicArray.count==0){
            [self.tableView endRefreshNoData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        if(self.dynamicArray.count==0){
            [self loadHttpDynamicListData];
        }else{
            [self.tableView reloadData];
        }
    }else{
        if(self.lookHistoryArray.count%20 || self.lookHistoryArray.count==0){
            [self.tableView endRefreshNoData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        if(self.lookHistoryArray.count==0){
            [self lookHistoryGetData];
        }else{
            [self.tableView reloadData];
        }
    }
}

#pragma mark -------  取消关注/关注TA
- (void)attentionButtonClicked{
    @weakify(self);
    if(self.userModel.isattention.integerValue == 0){
        [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",self.userId] type:YES];
        self.attentionBtnActionSuccess = ^(){
            @strongify(self);
            self.userModel.isattention = [NSNumber numberWithInteger:1];
            self.userModel.attentionhenum = [NSNumber numberWithInteger:(self.userModel.attentionhenum.integerValue + 1)];
            [self createBottomButtonView];
            if(self.attentUser){
                self.attentUser(YES);
            }
        };
    }else{
        [self attentionBtnAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] other:[NSString stringWithFormat:@"%@",self.userId] type:NO];
        self.attentionBtnActionSuccess = ^(){
            @strongify(self);
            self.userModel.isattention = [NSNumber numberWithInteger:0];
            self.userModel.attentionhenum = [NSNumber numberWithInteger:(self.userModel.attentionhenum.integerValue - 1)];
            [self createBottomButtonView];
            if(self.attentUser){
                self.attentUser(NO);
            }
        };
    }
}

#pragma mark --------- 弹出分享
- (void)sharViewFriends{
    if (!self.isMyHomePage) {
        [[AppDelegate shareInstance] setZhugeTrack:@"分享用户" properties:@{@"useID":self.userId, @"company":[CommonMethod paramStringIsNull:self.userModel.company],@"position":[CommonMethod paramStringIsNull:self.userModel.position],@"address":self.userModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.userModel.goodjobs]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.userModel.industry]}];
    }
    
    if (self.isMyHomePage) {
        ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
        shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        [shareView setCopylink];
        @weakify(self);
        shareView.shareIndex = ^(NSInteger index){
            @strongify(self);
            if(index==2){
                NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareHomePageURL, self.userId];
                UIPasteboard *paste = [UIPasteboard generalPasteboard];
                [paste setString:contentUrl];
                [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
            }else{
                [self firendClick:index];
            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:shareView];
        [shareView showShareNormalView];
    }else{
        self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
        self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
        self.coverView.userInteractionEnabled = YES;
        UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
        [self.coverView addGestureRecognizer:cancleTap];
        
        [self.view addSubview:self.coverView];
        self.shawView = [[ShareView alloc]init];
        self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT - WIDTH * 0.46);
        [ self.shawView createrShareView];
        [self.view addSubview:self.shawView];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.shawView.frame = CGRectMake(0, HEIGHT - WIDTH * 0.46, WIDTH, WIDTH * 0.46);
        } completion:^(BOOL finished) {
        }];
        __weak typeof(self) shareSlef = self;
        [self.shawView setShowShareViewIndex:^(NSInteger index){
            [shareSlef shareFriends:index];
        }];
    }
}

#pragma mark ------ 领取咖啡留言
- (void)editGetCofferMessage{
    RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
    vc.isCoffer = YES;
    vc.cofferId = self.zbarModel.coffid;
    vc.scaningCofferSucceedRestule = ^(BOOL isShow){
        if (isShow) {
            GetSucceedCofferView *view = [CommonMethod getViewFromNib:@"GetSucceedCofferView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [view createrGetCofferCoverImage:self.zbarModel.headimg isMyGet:YES];
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            self.zbarModel.rst = @(0);
            [self createBottomButtonView];
        }else{
            GetMyselfCoffer *view = [CommonMethod getViewFromNib:@"GetMyselfCoffer"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -------  添加好友
- (void)addFriendBtnnAction{
    if(![CommonMethod getUserCanAddFriend]){
        __weak typeof(self) weakSelf = self;
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_AddFriend];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            _isPresentVC = YES;
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^{
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    
    _isPresentVC = YES;
    [[AppDelegate shareInstance] setZhugeTrack:@"好友申请" properties:@{@"useID":self.userId, @"company":[CommonMethod paramStringIsNull:self.userModel.company],@"position":[CommonMethod paramStringIsNull:self.userModel.position],@"address":self.userModel.city,@"goodAt":[[CommonMethod paramArrayIsNull:self.userModel.goodjobs]componentsJoinedByString:@","],@"industry":[CommonMethod paramStringIsNull:self.userModel.industry]}];
    
    NewAddFriendController *vc = [[NewAddFriendController alloc] init];
    vc.userID = self.userModel.userId;
    vc.realname = self.userModel.realname;
    vc.exchangeSuccess = ^(BOOL success){
        if(success){
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ----------- 电话
- (void)showPhoneNumber{
    if (self.coverView == nil) {
        self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT) backColor:@"41464E"];
    }
    [self.view addSubview:self.coverView];
    self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
    self.coverView.userInteractionEnabled = YES;
    UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
    [self.coverView addGestureRecognizer:cancleTap];
    if (self.showPhoneView == nil) {
        self.showPhoneView = [[ShowPhoneView alloc]initWithFrame:CGRectMake(0, HEIGHT , WIDTH, 175)];
        [self.coverView addSubview:self.showPhoneView];
    }
    
    if (self.userModel.phone.length > 0) {
        self.showPhoneView.phoneNumbStr = self.userModel.phone;
    }else{
        self.showPhoneView.phoneNumbStr = @"--";
    }
    if (self.userModel.email.length > 0) {
        self.showPhoneView.emailStr = self.userModel.email;
    }else{
        self.showPhoneView.emailStr = @"--";
    }
    if (self.userModel.weixin.length > 0) {
        self.showPhoneView.weixinNumberStr = self.userModel.weixin;
    }else{
        self.showPhoneView.weixinNumberStr = @"--";
    }
    self.showPhoneView.canviewphone = self.userModel.canviewphone;
    
    [self.showPhoneView createrPhoneView];
    self.showPhoneView.userInteractionEnabled = YES;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.showPhoneView.frame = CGRectMake(0, HEIGHT-175, WIDTH, 175);
    }];
    self.showPhoneView.showPhoneViewIndex = ^(NSInteger index){
        if (index == 3) {
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.showPhoneView.frame = CGRectMake(0, HEIGHT, WIDTH, 175);
            }completion:^(BOOL finished) {
                [weakSelf.coverView removeFromSuperview];
            }];
        }else{
            [weakSelf copyPlayVideoAction:index];
        }
    };
}

- (void)copyPlayVideoAction:(NSInteger)index{
    if (index == 0) {
        NSString *str = [NSString stringWithFormat:@"tel:%@",self.userModel.phone];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];//也可以不加到页面上
    }else if (index == 1) {
        NSString *contentUrl = [NSString stringWithFormat:@"%@",self.userModel.email];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:contentUrl];
        if(contentUrl.length){
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        }
    }else if (index == 2) {
        NSString *contentUrl = [NSString stringWithFormat:@"%@",self.userModel.weixin];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:contentUrl];
        if(contentUrl.length){
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        }
    }
}

#pragma mark -------  删除好友
- (void)delFriendBtnnAction{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"解除关系..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userId] forKey:@"param"];
    
    [self requstType:RequestType_Delete apiName:API_NAME_USER_DEL_DELFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.userModel.isfriend = [NSNumber numberWithInteger:1];
            
            EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.realname]];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = [NSString stringWithFormat:@"%@",self.userId];
            NSDictionary *ext = @{@"NSDictionary":@"NSDictionary"};
            // 生成message
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:ext];
            message.chatType = EMChatTypeChat;// 设置为单聊消息
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
            }];
            
            //删除会话
            [[EMClient sharedClient].chatManager deleteConversation:[NSString stringWithFormat:@"%@",self.userId] isDeleteMessages:YES completion:nil];
            [MBProgressHUD showSuccess:@"好友已删除" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray;
        NSString *str;
        if (self.userModel.isattention.integerValue == 1) {
            str = @"取消关注";
        }else{
            str = @"关注一下";
        }
        NSDictionary *dict1 = @{@"itemName" : str};
        NSString *str1;
        if (self.userModel.isfriend.integerValue == 1) {
            str1 = @"删除好友";
        }else{
            str1 = @"加好友";
        }
        NSDictionary *dict2 = @{@"itemName" : str1};
        NSDictionary *dict3 = @{@"itemName" : @"分享"};
        dataArray = @[dict1,dict2,dict3];
        CGFloat x = self.view.bounds.size.width / 3 * 2 - 15;
        CGFloat y = 66+7;
        CGFloat width = self.view.bounds.size.width * 0.3 + 20;
        CGFloat height = dataArray.count * 40;
        __weak __typeof(&*self)weakSelf = self;
        
        _menuView = [MenuView createMenuWithFrame:CGRectMake(x, y, width, height) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            [weakSelf doSomething:(NSString *)str tag:(NSInteger)tag];
        } backViewTap:^{
            weakSelf.flag = YES;
            _menuView = nil;
        }];
    }
    return _menuView;
}

#pragma mark ----- 下拉菜单点击事件
- (void)doSomething:(NSString *)str tag:(NSInteger)tag{
    if (tag == 0) {
        [self attentionButtonClicked];
    }else if (tag == 1) {
        __weak typeof(self) weakSelf = self;
        if (self.userModel.isfriend.integerValue == 1) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否确定删除好友？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
                [weakSelf delFriendBtnnAction];
            }];
        }else{
            [self addFriendBtnnAction];
        }
    }else if (tag == 2) {
        [self showShareView];
    }
    self.flag = YES;
    [self.menuView showMenuWithAnimation:NO];
    self.menuView = nil;
}

- (void)showShareView{
    self.coverView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT ) backColor:@"41464E"];
    self.coverView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
    self.coverView.userInteractionEnabled = YES;
    UITapGestureRecognizer *cancleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancleCoveView)];
    [self.coverView addGestureRecognizer:cancleTap];
    [self.view addSubview:self.coverView];
    self.shawView = [[ShareView alloc]init];
    self.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT - WIDTH * 0.46);
    [ self.shawView createrShareView];
    [self.view addSubview:self.shawView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.shawView.frame = CGRectMake(0, HEIGHT - WIDTH * 0.46, WIDTH, WIDTH * 0.46);
    } completion:^(BOOL finished) {
    }];
    [self.shawView setShowShareViewIndex:^(NSInteger index){
        [weakSelf shareFriends:index];
    }];
}

#pragma mark -------- 分享页面
- (void)shareFriends:(NSInteger)index{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
        [weakSelf.coverView removeFromSuperview];
    } completion:^(BOOL finished) {
    }];
    [self firendClick:index];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *html = [@[[CommonMethod paramStringIsNull:[NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:self.userModel.company],[CommonMethod paramStringIsNull:self.userModel.position]]],[CommonMethod paramStringIsNull:self.userModel.realname],[CommonMethod paramStringIsNull:self.userModel.city],[CommonMethod paramStringIsNull:self.userModel.workyearstr]] componentsJoinedByString:@"｜"];
    NSString *title = @"推荐你到“3号圈”认识Ta";
    if (self.isMyHomePage) {
        title = @"我的“3号圈”主页";
    }
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *imageUrl = self.userModel.image;
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareHomePageURL, self.userId];
    UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
        
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    switch (index){
        case 0:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 1:{
            title = [NSString stringWithFormat:@"%@的“3号圈”主页", self.userModel.realname];
            if (self.isMyHomePage) {
                title = @"我的“3号圈”主页";
            }
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];break;
        }
        case 2:{
            _isPresentVC = YES;
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.nameCatergoryStr = [@[[CommonMethod paramStringIsNull:self.userModel.realname],[CommonMethod paramStringIsNull:self.userModel.city],[CommonMethod paramStringIsNull:self.userModel.workyearstr]] componentsJoinedByString:@"｜"];
            choseCtr.userID = self.userId;
            choseCtr.position = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:self.userModel.company],[CommonMethod paramStringIsNull:self.userModel.position]];
            choseCtr.imagUrl = self.userModel.image;
            choseCtr.isSendCard = YES;
            NSString *goodAtStr;
            if (self.userModel.goodjobs.count>0) { //business
                for (int i = 0; i < self.userModel.goodjobs.count; i++) {
                    if (i == 0) {
                        goodAtStr  = [NSString stringWithFormat:@"#%@#", self.userModel.goodjobs[i]];
                    }else{
                        goodAtStr = [NSString stringWithFormat:@"%@ #%@#",goodAtStr,self.userModel.goodjobs[i]];
                    }
                }
                choseCtr.gooAtStr = goodAtStr;
            }
            [self.navigationController pushViewController:choseCtr animated:YES];
            return;
        }
        case 3:{
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
            UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
            [generalPasteBoard setString:contentUrl];
            return;
        }
    }
}

- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else{
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
        if (!error) {
            [self updateUserSharNumber];
        }
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

#pragma mark ------ 分享取消按钮
- (void)cancleCoveView{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        if (weakSelf.showPhoneView) {
            weakSelf.showPhoneView.frame = CGRectMake(0,HEIGHT, WIDTH, 175);
        }
        if (weakSelf.shawView) {
            weakSelf.shawView.frame = CGRectMake(0, HEIGHT, WIDTH, WIDTH * 0.46);
        }
        [weakSelf.coverView removeFromSuperview];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 点击标签跳转到搜索
- (void)gotoSearchVC:(UITapGestureRecognizer*)tap{
    _isPresentVC = YES;
    UILabel *label = (UILabel*)tap.view;
    SearchViewController *search = [[SearchViewController alloc]init];
    search.searchTitle = [label.text stringByReplacingOccurrencesOfString:@"#" withString:@""];
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark -获取认证信息
- (void)createrIDStart{
    NSString *uid = [NSString stringWithFormat:@"%@",self.userId];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",uid]forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_MEMBER_GET_IDENTITYSTART_MYSELF paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if ([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dic  = responseObject[@"data"];
            NSNumber *hasValidUser = [CommonMethod paramNumberIsNull:dic[@"hasValidUser"]];
            NSString *imageUrl = [CommonMethod paramStringIsNull:dic[@"authenti_image"]];
            if(self.userModel.hasValidUser.integerValue != hasValidUser.integerValue){
                self.userModel.hasValidUser = hasValidUser;
                [self createTableViewHeaderView];
            }
            self.authenti_image = imageUrl;
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.authenti_image = imageUrl;
            model.hasValidUser = hasValidUser;
            [DataModelInstance shareInstance].userModel = model;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 更新用户分享次数
- (void)updateUserSharNumber{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_UP_SHARE_CNT paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark -获取个人主页数据
- (void)loadHttpMyHomePageData{
    _noNetWork = NO;
    if([CommonMethod paramNumberIsNull:self.userModel.userId].integerValue==0){
        _isLoadHttp = YES;
        [self.tableView reloadData];
        self.tableView.userInteractionEnabled = NO;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",[DataModelInstance shareInstance].userModel.userId, self.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_OTHERHOME paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.tableView.userInteractionEnabled = YES;
            _isLoadHttp = NO;
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [weakSelf.summaryArray removeAllObjects];
                weakSelf.userModel = [[UserModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
                weakSelf.userModel.userId = weakSelf.userId;
                if(weakSelf.isMyHomePage){
                    weakSelf.userModel.userId = weakSelf.userId;
                    // [DataModelInstance shareInstance].userModel = weakSelf.userModel;
                }
                if(!weakSelf.isMyHomePage){
                    if(weakSelf.userModel.needModel.gxid.integerValue){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Need), @"typeStr":@"Ta的需求", @"icon":@"icon_rm_need"}];
                    }
                    if(weakSelf.userModel.supplyModel.gxid.integerValue){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Supply), @"typeStr":@"Ta的供应", @"icon":@"icon_rm_supply"}];
                    }
                    if(weakSelf.userModel.djtalkModel.subjectId.integerValue){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Subject), @"typeStr":@"专栏&访谈", @"icon":@"icon_index_ljr"}];
                    }
                    if(weakSelf.userModel.workHistoryArray.count){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_WorkHistory), @"typeStr":@"工作经历", @"icon":@"icon_zy_experience"}];
                    }
                    if(weakSelf.userModel.remark && weakSelf.userModel.remark.length){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Introduce), @"typeStr":@"个人介绍", @"icon":@"icon_zy_zl"}];
                    }
                    if([CommonMethod paramArrayIsNull:weakSelf.userModel.honorsArray].count){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Honor), @"typeStr":@"个人荣誉", @"icon":@"icon_zy_honor"}];
                    }
                    if([CommonMethod paramArrayIsNull:weakSelf.userModel.selftag].count ||[CommonMethod paramArrayIsNull:weakSelf.userModel.interesttag].count ||[CommonMethod paramArrayIsNull:weakSelf.userModel.goodjobs].count){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Tag), @"typeStr":@"Ta的标签", @"icon":@"icon_zy_scyw"}];
                    }
                    if([CommonMethod paramArrayIsNull:weakSelf.userModel.album].count){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Photo), @"typeStr":@"个人相册", @"icon":@"icon_zy_album"}];
                    }
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Comment), @"typeStr":@"好友评价", @"icon":@"icon_zy_evaluate"}];
                }else{
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Need), @"typeStr":@"个人需求", @"icon":@"icon_rm_need"}];
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Supply), @"typeStr":@"个人供应", @"icon":@"icon_rm_supply"}];
                    if(weakSelf.userModel.djtalkModel.subjectId.integerValue){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Subject), @"typeStr":@"专栏&访谈", @"icon":@"icon_index_ljr"}];
                    }
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_WorkHistory), @"typeStr":@"工作经历", @"icon":@"icon_zy_experience"}];
                    if(weakSelf.userModel.remark && weakSelf.userModel.remark.length){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Introduce), @"typeStr":@"个人介绍", @"icon":@"icon_zy_zl"}];
                    }
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Honor), @"typeStr":@"个人荣誉", @"icon":@"icon_zy_honor"}];
                    if([CommonMethod paramArrayIsNull:weakSelf.userModel.selftag].count ||[CommonMethod paramArrayIsNull:weakSelf.userModel.interesttag].count ||[CommonMethod paramArrayIsNull:weakSelf.userModel.goodjobs].count){
                        [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Tag), @"typeStr":@"我的标签", @"icon":@"icon_zy_scyw"}];
                    }
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Photo), @"typeStr":@"个人相册", @"icon":@"icon_zy_album"}];
                    [weakSelf.summaryArray addObject:@{@"type":@(SectionType_Comment), @"typeStr":@"好友评价", @"icon":@"icon_zy_evaluate"}];
                }
                [weakSelf.contactArray removeAllObjects];
                //人脉列表
                if([CommonMethod paramArrayIsNull:weakSelf.userModel.coffeePhotosArray].count){
                    [weakSelf.contactArray addObject:@{@"type":@(SectionType_Coffee), @"typeStr":@"人脉咖啡", @"icon":@"icon_zy_coffee"}];
                }
                
                [weakSelf.contactArray addObject:@{@"type":@(SectionType_Attention), @"typeStr":@"Ta的影响力", @"icon":@"icon_zy_rm"}];
                
                [weakSelf loadCommentListData];
                [weakSelf createTableViewHeaderView];
                [weakSelf lookHistoryGetData];
                if(!weakSelf.isMyHomePage){
                    [weakSelf createBottomButtonView];
                }
            }
            [weakSelf.tableView reloadData];
            //第一次功能介绍引导
            if (weakSelf.isMyHomePage&&![[NSUserDefaults standardUserDefaults] boolForKey:FirstLaunchGuideViewMarkMySelf]) {
                FirstLaunchGuideView *view = [CommonMethod getViewFromNib:@"FirstLaunchGuideView"];
                view.viewType = FLGV_Type_MyPage;
                [view newUserGuide];
                view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                [[UIApplication sharedApplication].keyWindow addSubview:view];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        _isLoadHttp = NO;
        weakSelf.tableView.userInteractionEnabled = YES;
        if(_currentTab==1){
            [weakSelf.tableView endRefresh];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark -获取个人动态
- (void)loadHttpDynamicListData{
    static int isRefresh = 0;
    if(isRefresh){
        return;
    }
    isRefresh = 1;
    _noNetWork = NO;
    if(self.dynamicArray.count==0){
        _isLoadHttp = YES;
        [self.tableView reloadData];
    }
    NSInteger page = self.dynamicArray.count/20+(self.dynamicArray.count%20||self.dynamicArray.count?1:0);
    page = page?page:1;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@",self.userId, [DataModelInstance shareInstance].userModel.userId,@(page)] forKey:@"param"];
    __block NSInteger tabIndex = _currentTab;
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMIC_MY_DYNAMIC paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isRefresh = 0;
            _isLoadHttp = NO;
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
                NSInteger row = 0;
                for(NSDictionary *dict in array){
                    DynamicModel *model = [[DynamicModel alloc] initWithDict:dict cellTag:row];
                    model.isTaDynamicList = self.isMyHomePage==NO;
                    [weakSelf.dynamicArray addObject:model];
                    row++;
                }
            }
            if(_currentTab==tabIndex && tabIndex==1){
                if(weakSelf.dynamicArray.count%20==0 && weakSelf.dynamicArray.count){
                    [weakSelf.tableView endRefresh];
                }else{
                    [weakSelf.tableView endRefreshNoData];
                }
                [weakSelf.tableView reloadData];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        isRefresh = 0;
        _noNetWork = YES;
        _isLoadHttp = NO;
        [weakSelf.tableView endRefresh];
        if(_currentTab==tabIndex && tabIndex==1){
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark --- 谁看过他的历史
- (void)lookHistoryGetData{
    static int isRefresh = 0;
    if(isRefresh){
        return;
    }
    isRefresh = 1;
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *type;
    NSInteger page = self.lookHistoryArray.count/20+(self.lookHistoryArray.count%20||self.lookHistoryArray.count?1:0);
    page = page?page:1;
    if(self.isMyHomePage) {
        type = API_NAME_GET_VISITORS;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%ld", [DataModelInstance shareInstance].userModel.userId,self.userId,(long)page] forKey:@"param"];
    }else{
        type = API_NAME_USER_LOOKAT_HISTRY;
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userId] forKey:@"param"];
    }
    __block NSInteger tabIndex = _currentTab;
    [self requstType:RequestType_Get apiName:type paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        isRefresh = 0;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                LookHistoryModel *lookModel = [[LookHistoryModel alloc] initWithDict:subDic];
                [weakSelf.lookHistoryArray addObject:lookModel];
            }
            if(weakSelf.lookHistoryArray.count){
                [weakSelf.contactArray addObject:@{@"type":@(SectionType_LookHistory), @"typeStr":@"看了TA的用户还看了", @"icon":@""}];
            }
        }
        if(_currentTab==tabIndex && tabIndex==2){
            if(weakSelf.lookHistoryArray.count%20==0 && weakSelf.lookHistoryArray.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        isRefresh = 0;
        _noNetWork = YES;
        [weakSelf.tableView endRefresh];
        if(_currentTab==tabIndex && tabIndex==2){
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark --- 评价列表
- (void)loadCommentListData{
    _noNetWork = NO;
    if(self.userModel.evaluationsArray==nil){
        self.userModel.evaluationsArray = [NSMutableArray array];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSInteger page = self.userModel.evaluationsArray.count/20+(self.userModel.evaluationsArray.count%20||self.userModel.evaluationsArray.count?1:0);
    page = page?page:1;
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.userId,@(page)] forKey:@"param"];
    __block NSInteger tabIndex = _currentTab;
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_EVALUATIONS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                UserModel *model = [[UserModel alloc] initWithDict:subDic];
                [weakSelf.userModel.evaluationsArray addObject:model];
            }
        }
        if(_currentTab==tabIndex && tabIndex==0){
            if(weakSelf.userModel.evaluationsArray.count%20==0 && weakSelf.userModel.evaluationsArray.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        [weakSelf.tableView endRefresh];
        if(_currentTab==tabIndex && tabIndex==0){
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_currentTab==0){
        if((_isLoadHttp || _noNetWork) && !self.summaryArray.count){
            return 1;
        }else{
            return self.summaryArray.count;
        }
    }else if(_currentTab==1){
        return 1;
    }else{
        if((_isLoadHttp || _noNetWork) && !self.contactArray.count){
            return 1;
        }else{
            return self.contactArray.count;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_currentTab==0){
        if((_isLoadHttp || _noNetWork) && !self.summaryArray.count){
            return 1;
        }else{
            if(self.summaryArray.count == 0){
                return 0;
            }
            NSInteger type = [CommonMethod paramNumberIsNull:self.summaryArray[section][@"type"]].integerValue;
            NSInteger row = 0;
            switch (type) {
                case SectionType_Need:{
                    if(self.userModel.needModel.gxid.integerValue){
                        row=1;
                    }
                }
                    break;
                case SectionType_Supply:{
                    if(self.userModel.supplyModel.gxid.integerValue){
                        row=1;
                    }
                }
                    break;
                case SectionType_WorkHistory:
                    row = self.userModel.workHistoryArray.count;
                    break;
                case SectionType_Honor:
                    row = self.userModel.honorsArray.count;
                    break;
                case SectionType_Tag:{
                    if([CommonMethod paramArrayIsNull:self.userModel.selftag].count){
                        row += 1;
                    }
                    if([CommonMethod paramArrayIsNull:self.userModel.interesttag].count){
                        row += 1;
                    }
                    if([CommonMethod paramArrayIsNull:self.userModel.goodjobs].count){
                        row += 1;
                    }
                }
                    break;
                case SectionType_Photo:{
                    if(self.userModel.album && self.userModel.album.count){
                        row=1;
                    }
                }
                    break;
                case SectionType_Comment:
                    row = self.userModel.evaluationsArray.count;
                    break;
                default:
                    row = 1;
                    break;
            }
            return row;
        }
    }else if(_currentTab==1){
        if(self.dynamicArray.count){
            if(self.isMyHomePage){
                return self.dynamicArray.count+1;
            }else{
                return self.dynamicArray.count;
            }
        }else{
            return 1;
        }
    }else{
        if(_noNetWork && !self.contactArray.count){
            return 1;
        }else{
            if(self.contactArray.count==0){
                return 0;
            }
            NSInteger type = [CommonMethod paramNumberIsNull:self.contactArray[section][@"type"]].integerValue;
            if(type == SectionType_LookHistory){
                return self.lookHistoryArray.count;
            }else{
                return 1;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_currentTab==0){
        if((_isLoadHttp || _noNetWork) && !self.summaryArray.count){
            return 300;
        }else{
            CGFloat height = 0;
            NSInteger type = [CommonMethod paramNumberIsNull:self.summaryArray[indexPath.section][@"type"]].integerValue;
            switch (type) {
                case SectionType_Need:
                    height = [NeedAndSupplyCell getCellHeight:self.userModel.needModel];
                    break;
                case SectionType_Supply:
                    height = [NeedAndSupplyCell getCellHeight:self.userModel.supplyModel];
                    break;
                case SectionType_Subject:
                    height = 246;
                    break;
                case SectionType_WorkHistory:
                    height = [NewWorkHistoryCell getCellHeight:self.userModel.workHistoryArray[indexPath.row]];
                    break;
                case SectionType_Introduce:{
                    height = [NSHelper heightOfString:self.userModel.remark font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
                    height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7+32;
                }
                    break;
                case SectionType_Honor:{
                    HonorModel *honorModel = self.userModel.honorsArray[indexPath.row];
                    height = [NSHelper heightOfString:honorModel.honor font:FONT_SYSTEM_SIZE(14) width:WIDTH-41];
                    height += 28;
                    //                    height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
                }
                    break;
                case SectionType_Tag:{
                    NSMutableArray *tagsArray = [NSMutableArray array];
                    NSMutableArray *jinhaoArray = [NSMutableArray array];
                    if([CommonMethod paramArrayIsNull:self.userModel.goodjobs].count){
                        [tagsArray addObject:self.userModel.goodjobs];
                        [jinhaoArray addObject:@"#"];
                    }
                    if([CommonMethod paramArrayIsNull:self.userModel.selftag].count){
                        [tagsArray addObject:self.userModel.selftag];
                        [jinhaoArray addObject:@""];
                    }
                    if([CommonMethod paramArrayIsNull:self.userModel.interesttag].count){
                        [tagsArray addObject:self.userModel.interesttag];
                        [jinhaoArray addObject:@""];
                    }
                    NSArray *array = tagsArray[indexPath.row];
                    CGFloat start_X = 16;
                    CGFloat start_Y = 40;
                    NSString *jinhao = jinhaoArray[indexPath.row];
                    for(NSString *tagStr in array){
                        NSString *newTagStr = [NSString stringWithFormat:@"%@%@%@", jinhao, tagStr, jinhao];
                        CGFloat width = (NSInteger)[NSHelper widthOfString:newTagStr font:FONT_SYSTEM_SIZE(13) height:29]+16+1;
                        if(start_X+width>WIDTH-32){
                            start_X = 16;
                            start_Y += 38;
                        }
                        start_X += width+8;
                    }
                    height = start_Y+12+29;
                }
                    break;
                case SectionType_Photo:{
                    CGFloat width = (WIDTH-32-10)/3;
                    if(self.userModel.album.count>3){
                        height = 70+width;
                    }else{
                        height = 32+width;
                    }
                }
                    break;
                case SectionType_Comment:
                    height = [CommentCell getCellHeight:self.userModel.evaluationsArray[indexPath.row]];
                    break;
                default:
                    break;
            }
            return height;
        }
    }else if(_currentTab==1){
        if(self.dynamicArray.count){
            if(indexPath.row==0 && self.isMyHomePage){
                return 69;
            }else{
                NSInteger row = indexPath.row;
                if(self.isMyHomePage){
                    row -= 1;
                }
                DynamicModel *model = self.dynamicArray[row];
                return model.cellHeight;
            }
        }else{
            return 300;
        }
    }else{
        if(_noNetWork && !self.contactArray.count){
            return 300;
        }else{
            NSInteger type = [CommonMethod paramNumberIsNull:self.contactArray[indexPath.section][@"type"]].integerValue;
            if(type == SectionType_LookHistory){
                return 73;
            }else{
                return 93;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_currentTab==0){
        if((_isLoadHttp || _noNetWork) && !self.summaryArray.count){
            return 0.0001;
        }else{
            SectionType type = [CommonMethod paramNumberIsNull:self.summaryArray[section][@"type"]].integerValue;
            if(type == SectionType_Comment){
                if(self.userModel.evaluationsArray.count){
                    return 90;
                }else{
                    return 119;
                }
            }
            if(self.isMyHomePage){
                if(type == SectionType_Need && !self.userModel.needModel.gxid.integerValue){
                    return 119;
                }else if(type == SectionType_Supply && !self.userModel.supplyModel.gxid.integerValue){
                    return 119;
                }else if(type == SectionType_WorkHistory && !self.userModel.workHistoryArray.count){
                    return 119;
                }else if(type == SectionType_Honor && !self.userModel.honorsArray.count){
                    return 119;
                }else if(type == SectionType_Photo && !self.userModel.album.count){
                    return 119;
                }
            }
            return 30;
        }
    }else if(_currentTab==2){
        if((_isLoadHttp || _noNetWork) && !self.contactArray.count){
            return 0.0001;
        }else{
            SectionType type = [CommonMethod paramNumberIsNull:self.contactArray[section][@"type"]].integerValue;
            if(type == SectionType_LookHistory){
                return 46;
            }else{
                return 30;
            }
        }
    }else{
        return 0.00001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(_currentTab!=1){
        if(((_isLoadHttp || _noNetWork)&&!self.summaryArray.count&& _currentTab==0)||(_noNetWork&&!self.contactArray.count&&_currentTab==2)){
            return 0.0001;
        }else{
            return 10;
        }
    }else{
        return 0.00001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_currentTab!=1){
        if(((_isLoadHttp || _noNetWork)&&!self.summaryArray.count&& _currentTab==0)||(_noNetWork&&!self.contactArray.count&&_currentTab==2)){
            return nil;
        }
        NSString *str = @"";
        NSString *icon = @"";
        SectionType type = 0;
        if(_currentTab == 0){
            if(self.summaryArray.count==0){
                return nil;
            }
            NSDictionary *dict = self.summaryArray[section];
            str = dict[@"typeStr"];
            icon = dict[@"icon"];
            type = [CommonMethod paramNumberIsNull:self.summaryArray[section][@"type"]].integerValue;
        }else{
            if(self.contactArray.count==0){
                return nil;
            }
            NSDictionary *dict = self.contactArray[section];
            str = dict[@"typeStr"];
            icon = dict[@"icon"];
            type = [CommonMethod paramNumberIsNull:self.contactArray[section][@"type"]].integerValue;
        }
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 46)];
        headerView.backgroundColor = WHITE_COLOR;
        if(_currentTab==2 && type==SectionType_LookHistory){
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 0, WIDTH-32, 46) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
            titleLabel.text = str;
            [headerView addSubview:titleLabel];
        }else{
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 14, 14)];
            iconImageView.image = kImageWithName(icon);
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            [headerView addSubview:iconImageView];
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(36, 16, 200, 14) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
            titleLabel.text = str;
            [headerView addSubview:titleLabel];
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel];
        
        if(type == SectionType_Comment){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
            CGRect frame = CGRectMake((WIDTH-95)/2, 46, 95, 28);
            if(self.isMyHomePage){
                frame = CGRectMake((WIDTH-128)/2, 46, 128, 28);
            }
            if(self.isMyHomePage){
                [btn setTitle:@"邀请好友点评我" forState:UIControlStateNormal];
                [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
                [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
            }else{
                [btn setTitle:@"立即评价" forState:UIControlStateNormal];
                [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
                [btn setBackgroundImage:kImageWithName(@"btn_zixun_follow") forState:UIControlStateNormal];
                [btn setTitle:@"仅好友可评价" forState:UIControlStateDisabled];
                [btn setTitleColor:WHITE_COLOR forState:UIControlStateDisabled];
                [btn setBackgroundImage:kImageWithName(@"btn-register-countdown-on") forState:UIControlStateDisabled];
                btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
                btn.enabled = self.userModel.isfriend.integerValue==1;
            }
            [btn addTarget:self action:@selector(gotoCommentPersonVC) forControlEvents:UIControlEventTouchUpInside];
            if(self.userModel.evaluationsArray.count==0){
                NSString *str = [NSString stringWithFormat:@"还没有人评价%@", self.userModel.realname];
                if(self.isMyHomePage){
                    frame = CGRectMake((WIDTH-128)/2, 75, 128, 28);
                    str = @"邀请好友评价，让更多人了解你";
                }else{
                    frame = CGRectMake((WIDTH-95)/2, 75, 95, 28);
                }
                UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 45, WIDTH, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:str font:17 number:1 nstextLocat:NSTextAlignmentCenter];
                [headerView addSubview:label];
            }
            btn.frame = frame;
            [headerView addSubview:btn];
        }
        
        if(self.isMyHomePage){
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
            btn.frame = CGRectMake((WIDTH-95)/2, 75, 95, 28);
            [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
            [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(sectionHeaderAddButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 45, WIDTH, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:@"" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
            
            if(type == SectionType_Need && !self.userModel.needModel.gxid.integerValue){
                [btn setTitle:@"发布需求" forState:UIControlStateNormal];
                btn.tag = 201;
                [headerView addSubview:btn];
                label.text = @"告诉别人我需要什么";
                [headerView addSubview:label];
            }else if(type == SectionType_Supply && !self.userModel.supplyModel.gxid.integerValue){
                [btn setTitle:@"发布供应" forState:UIControlStateNormal];
                btn.tag = 202;
                [headerView addSubview:btn];
                label.text = @"告诉别人我有什么";
                [headerView addSubview:label];
            }else if(type == SectionType_WorkHistory && !self.userModel.workHistoryArray.count){
                [btn setTitle:@"添加经历" forState:UIControlStateNormal];
                btn.tag = 203;
                [headerView addSubview:btn];
                label.text = @"填写工作经历，让别人快速认识你";
                [headerView addSubview:label];
            }else if(type == SectionType_Honor && !self.userModel.honorsArray.count){
                [btn setTitle:@"添加荣誉" forState:UIControlStateNormal];
                btn.tag = 204;
                [headerView addSubview:btn];
                label.text = @"秀出自己的荣誉，事例";
                [headerView addSubview:label];
            }else if(type == SectionType_Photo && !self.userModel.album.count){
                [btn setTitle:@"上传照片" forState:UIControlStateNormal];
                btn.tag = 205;
                [headerView addSubview:btn];
                label.text = @"展示公司及个人风采";
                [headerView addSubview:label];
            }
            NSInteger tag = 0;
            if(type == SectionType_Need){
                tag = 201;
            }else if(type == SectionType_Supply){
                tag = 202;
            }else if(type == SectionType_WorkHistory){
                tag = 203;
            }else if(type == SectionType_Honor){
                tag = 204;
            }else if(type == SectionType_Photo){
                tag = 205;
            }
            if(tag){
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = tag;
                btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
                btn.frame = CGRectMake(WIDTH-60, 0, 60, 46);
                [btn setTitleColor:HEX_COLOR(@"3498db") forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(sectionHeaderAddButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:@"添加" forState:UIControlStateNormal];
                [headerView addSubview:btn];
            }
        }
        return headerView;
    }else{
        return nil;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(_currentTab!=1){
        if(((_isLoadHttp || _noNetWork)&&!self.summaryArray.count&& _currentTab==0)||(_noNetWork&&!self.contactArray.count&&_currentTab==2)){
            return nil;
        }
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
        footerView.backgroundColor = kTableViewBgColor;
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [footerView addSubview:lineLabel];
        return footerView;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_currentTab==0){
        if(_noNetWork && !self.summaryArray.count){
            static NSString *cellId = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }else if(_isLoadHttp && !self.summaryArray.count){
            static NSString *cellID = @"ContactsLoadDataView1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                if (view.tag == 200) {
                    ContactsLoadDataView *loadView = (ContactsLoadDataView*)[view viewWithTag:300];
                    if(loadView){
                        [loadView stopProgressing];
                    }
                }
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 300)];
            view.tag = 200;
            ContactsLoadDataView *loadDataView = [CommonMethod getViewFromNib:NSStringFromClass([ContactsLoadDataView class])];
            loadDataView.showLabel.text = @"加载中...";
            loadDataView.frame = CGRectMake(0, 0, WIDTH, 300);
            [loadDataView startProgressing];
            loadDataView.tag = 300;
            [view addSubview:loadDataView];
            [cell.contentView addSubview:view];
            return cell;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.summaryArray[indexPath.section][@"type"]].integerValue;
        if(type == SectionType_Need || type == SectionType_Supply){
            static NSString *cellID = @"NeedAndSupplyCell";
            NeedAndSupplyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:@"NeedAndSupplyCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.userId = self.userId;
            __weak typeof(self) weakSelf = self;
            if(type == SectionType_Supply){
                cell.isNeed = NO;
                [cell updateDisplayModel:weakSelf.userModel.supplyModel];
            }else{
                cell.isNeed = YES;
                [cell updateDisplayModel:weakSelf.userModel.needModel];
            }
            cell.needOrSupplyChange = ^{
                [weakSelf loadHttpMyHomePageData];
            };
            return cell;
        }else if(type == SectionType_Subject){
            static NSString *cellID = @"SubjectInterviewCell";
            SubjectInterviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:@"SubjectInterviewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell tranferSubjectInterview:self.userModel.djtalkModel];
            return cell;
        }else if(type == SectionType_WorkHistory){
            static NSString *cellID = @"NewWorkHistoryCell";
            NewWorkHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:@"NewWorkHistoryCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateDisplayModel:self.userModel.workHistoryArray[indexPath.row]];
            if(self.userModel.workHistoryArray.count > indexPath.row+1){
                cell.lineLabel.hidden = NO;
            }else{
                cell.lineLabel.hidden = YES;
            }
            return cell;
        }else if(type == SectionType_Introduce){
            static NSString *cellID = @"IntroduceCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            CGFloat height = [NSHelper heightOfString:self.userModel.remark font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
            height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
            UILabel *contentLabel = [UILabel createLabel:CGRectMake(16, 16, WIDTH-32, (NSInteger)height+1) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
            contentLabel.numberOfLines = 0;
            [contentLabel setParagraphText:self.userModel.remark lineSpace:7];
            [cell.contentView addSubview:contentLabel];
            return cell;
        }else if(type == SectionType_Honor){
            static NSString *cellID = @"HonorCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            UILabel *pointLabel = [UILabel createLabel:CGRectMake(16, 17, 10, 14) font:FONT_BOLD_SYSTEM_SIZE(16) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
            pointLabel.text = @"·";
            [cell.contentView addSubview:pointLabel];
            
            HonorModel *honorModel = self.userModel.honorsArray[indexPath.row];
            CGFloat height = [NSHelper heightOfString:honorModel.honor font:FONT_SYSTEM_SIZE(14) width:WIDTH-41];
            //            height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
            UILabel *contentLabel = [UILabel createLabel:CGRectMake(25, 16, WIDTH-41, (NSInteger)height+1) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
            contentLabel.numberOfLines = 0;
            contentLabel.text = honorModel.honor;
            [cell.contentView addSubview:contentLabel];
            if(self.userModel.honorsArray.count > indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+27.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
            return cell;
        }else if(type == SectionType_Tag){
            static NSString *cellID = @"TagsCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            UILabel *contentLabel = [UILabel createLabel:CGRectMake(16, 16, WIDTH-32, 14) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
            contentLabel.numberOfLines = 0;
            [cell.contentView addSubview:contentLabel];
            
            NSMutableArray *tagsArray = [NSMutableArray array];
            NSMutableArray *strsArray = [NSMutableArray array];
            NSMutableArray *colorArray = [NSMutableArray array];
            NSMutableArray *jinhaoArray = [NSMutableArray array];
            if([CommonMethod paramArrayIsNull:self.userModel.goodjobs].count){
                [tagsArray addObject:self.userModel.goodjobs];
                [strsArray addObject:@"擅长业务"];
                [colorArray addObject:@"1abc9c"];
                [jinhaoArray addObject:@"#"];
            }
            if([CommonMethod paramArrayIsNull:self.userModel.selftag].count){
                [tagsArray addObject:self.userModel.selftag];
                [strsArray addObject:@"个人标签"];
                [colorArray addObject:@"1abc9c"];
                [jinhaoArray addObject:@""];
            }
            NSArray *myInterestTagArray;
            if([CommonMethod paramArrayIsNull:self.userModel.interesttag].count){
                [tagsArray addObject:self.userModel.interesttag];
                [strsArray addObject:@"兴趣标签"];
                [colorArray addObject:@"3498db"];
                [jinhaoArray addObject:@""];
                myInterestTagArray = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.interesttag];
            }
            contentLabel.text = strsArray[indexPath.row];
            NSArray *array = tagsArray[indexPath.row];
            NSString *color = colorArray[indexPath.row];
            NSString *jinhao = jinhaoArray[indexPath.row];
            CGFloat start_X = 16;
            CGFloat start_Y = 40;
            for(NSString *tagStr in array){
                NSString *newTagStr = [NSString stringWithFormat:@"%@%@%@", jinhao, tagStr, jinhao];
                CGFloat width = (NSInteger)[NSHelper widthOfString:newTagStr font:FONT_SYSTEM_SIZE(13) height:29]+16+1;
                if(start_X+width>WIDTH-32){
                    start_X = 16;
                    start_Y += 38;
                }
                UILabel *taglabel = [UILabel createrLabelframe:CGRectMake(start_X, start_Y, width, 29) backColor:WHITE_COLOR textColor:HEX_COLOR(color) test:newTagStr font:13 number:1 nstextLocat:NSTextAlignmentCenter];
                [CALayer updateControlLayer:taglabel.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(color).CGColor];
                [cell.contentView addSubview:taglabel];
                start_X += width+8;
                if(jinhao.length){
                    [CommonMethod viewAddGuestureRecognizer:taglabel tapsNumber:1 withTarget:self withSEL:@selector(gotoSearchVC:)];
                }
                //当浏览的用户和自己的兴趣标签相同时，特殊显示
                /*if(myInterestTagArray && myInterestTagArray.count && [myInterestTagArray containsObject:tagStr] && !self.isMyHomePage){
                 taglabel.backgroundColor = HEX_COLOR(color);
                 taglabel.textColor = WHITE_COLOR;
                 }*/
            }
            if(tagsArray.count > indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, start_Y+29+12-0.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
            return cell;
        }else if(type == SectionType_Photo){
            static NSString *cellID = @"ImagesCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            CGFloat width = (WIDTH-32-10)/3;
            for(int i=0; i<3; i++){
                UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+(width+5)*i, 16, width, width)];
                if(self.userModel.album.count>i){
                    NSString *imageUrl = [CommonMethod paramStringIsNull:self.userModel.album[i]];
                    [headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KSquareImageDefault];
                    headImageView.tag = i;
                    [CommonMethod viewAddGuestureRecognizer:headImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoPhotosVC)];
                }else if(self.userModel.album.count==i && self.isMyHomePage){
                    headImageView.image = kImageWithName(@"image_my_addphoto");
                    headImageView.tag = 200;
                    [CommonMethod viewAddGuestureRecognizer:headImageView tapsNumber:1 withTarget:self withSEL:@selector(showPhotosImage:)];
                }else{
                    break;
                }
                headImageView.contentMode = UIViewContentModeScaleAspectFill;
                headImageView.clipsToBounds = YES;
                [cell.contentView addSubview:headImageView];
            }
            if(self.userModel.album.count>3){
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake((WIDTH-112)/2, 28+width, 112, 30);
                [btn setTitle:@"查看全部" forState:UIControlStateNormal];
                [btn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
                btn.titleLabel.font = FONT_SYSTEM_SIZE(14);
                [btn setBackgroundImage:kImageWithName(@"btn_my_kkqb") forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(gotoPhotosVC) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn];
            }
            return cell;
        }else{
            static NSString *cellID = @"CommentCell";
            CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:@"CommentCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.tag = indexPath.row;
            [cell updateDisplayModel:self.userModel.evaluationsArray[indexPath.row] isMyHomePage:self.isMyHomePage];
            cell.deleteComment = ^(CommentCell *delCell) {
                [self.userModel.evaluationsArray removeObjectAtIndex:delCell.tag];
                [self.tableView reloadData];
            };
            return cell;
        }
    }else if(_currentTab==1){
        if(_noNetWork && !self.dynamicArray.count){
            static NSString *cellId = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }else if(_isLoadHttp && !self.dynamicArray.count){
            static NSString *cellID = @"ContactsLoadDataView";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                if (view.tag == 200) {
                    ContactsLoadDataView *loadView = (ContactsLoadDataView*)[view viewWithTag:300];
                    if(loadView){
                        [loadView stopProgressing];
                    }
                }
            }
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 300)];
            view.tag = 200;
            ContactsLoadDataView *loadDataView = [CommonMethod getViewFromNib:NSStringFromClass([ContactsLoadDataView class])];
            loadDataView.showLabel.text = @"加载中...";
            loadDataView.frame = CGRectMake(0, 0, WIDTH, 300);
            [loadDataView startProgressing];
            loadDataView.tag = 300;
            [view addSubview:loadDataView];
            [cell.contentView addSubview:view];
            return cell;
        }else if(self.dynamicArray.count){
            if(indexPath.row==0&&self.isMyHomePage){
                static NSString *cellID = @"noti";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                for(UIView *view in cell.contentView.subviews){
                    [view removeFromSuperview];
                }
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 70)];
                view.backgroundColor = kTableViewBgColor;
                [cell.contentView addSubview:view];
                UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, WIDTH, 54)];
                whiteView.backgroundColor = WHITE_COLOR;
                [view addSubview:whiteView];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 29, 29)];
                imageView.image = kImageWithName(@"icon_misson_tz");
                [whiteView addSubview:imageView];
                UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(53, 0, 100, 54) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"通知" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
                [whiteView addSubview:titleLabel];
                UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 18, 9, 15)];
                arrowImageView.image = kImageWithName(@"icon_next_gray");
                [whiteView addSubview:arrowImageView];
                return cell;
            }else{
                DynamicCell *cell;
                NSInteger row = indexPath.row;
                if(self.isMyHomePage){
                    row -= 1;
                }
                if([self.cellArrayDict.allKeys containsObject:Cell_Index_key(row)]){
                    cell = self.cellArrayDict[Cell_Index_key(row)];
                    DynamicModel *model = self.dynamicArray[row];
                    if(!cell || ![cell isKindOfClass:[DynamicCell class]] || cell.model.dynamic_id.integerValue!= model.dynamic_id.integerValue){
                        cell = nil;
                    }
                }
                if(!cell){
                    cell = [[DynamicCell alloc] initWithDataModel:self.dynamicArray[row] identifier:@"DynamicCell"];
                    cell.tag = row;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [self.cellArrayDict setObject:cell forKey:Cell_Index_key(row)];
                    [cell updateDisplay:self.dynamicArray[row]];
                }
                __weak typeof(self) weakSelf = self;
                cell.refreshDynamicCell = ^(DynamicCell *dc){
                    NSInteger indexPathForRow = dc.tag;
                    if(weakSelf.isMyHomePage){
                        indexPathForRow += 1;
                    }
                    [weakSelf.cellArrayDict removeObjectForKey:Cell_Index_key(dc.tag)];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPathForRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                };
                cell.deleteDynamicCell = ^(DynamicCell *delCell){
                    if(weakSelf.dynamicArray.count > delCell.tag){
                        [weakSelf.dynamicArray removeObjectAtIndex:delCell.tag];
                    }
                    NSInteger indexPathForRow = delCell.tag;
                    if(weakSelf.isMyHomePage){
                        indexPathForRow += 1;
                    }
                    [weakSelf.cellArrayDict removeAllObjects];
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPathForRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView endUpdates];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                    if(weakSelf.dynamicArray.count==0){
                        [weakSelf.tableView.mj_header beginRefreshing];
                    }
                };
                cell.deleteUserDynamic = ^(NSNumber *userId){
                    NSMutableArray *tmpList = [NSMutableArray array];
                    for(int i=0; i<weakSelf.dynamicArray.count; i++){
                        if([weakSelf.dynamicArray[i] isKindOfClass:[DynamicModel class]]){
                            DynamicModel *model = weakSelf.dynamicArray[i];
                            if(model.userModel.user_id.integerValue != userId.integerValue){
                                [tmpList addObject:weakSelf.dynamicArray[i]];
                            }
                        }else{
                            [tmpList addObject:weakSelf.dynamicArray[i]];
                        }
                    }
                    weakSelf.dynamicArray = tmpList;
                    [weakSelf.cellArrayDict removeAllObjects];
                    [weakSelf.tableView reloadData];
                    if(weakSelf.dynamicArray.count==0){
                        [weakSelf.tableView.mj_header beginRefreshing];
                    }
                };
                DynamicModel *model = self.dynamicArray[row];
                cell.attentUser = ^(BOOL isAttent){
                    for(DynamicModel *tmpModel in weakSelf.dynamicArray){
                        if(tmpModel.userModel.user_id.integerValue == model.userModel.user_id.integerValue){
                            if(isAttent){
                                tmpModel.userModel.relationship = @"关注";
                            }else{
                                tmpModel.userModel.relationship = @"推荐";
                            }
                        }
                    }
                    [weakSelf.cellArrayDict removeAllObjects];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                    });
                };
                return cell;
            }
        }else{
            static NSString *cellID = @"NODataTableViewCell";
            NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.mainLabel.text = @"暂未发布任何动态";
            cell.subLabel.text = @"";
            cell.coverImageView.image = kImageWithName(@"icon_dt_nonexq");
            return cell;
        }
    }else{
        if(_noNetWork && !self.contactArray.count){
            static NSString *cellId = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.contactArray[indexPath.section][@"type"]].integerValue;
        if(type == SectionType_Coffee || type == SectionType_Attention){
            static NSString *cellID = @"CoffeeCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            for(UIView *view in cell.contentView.subviews){
                [view removeFromSuperview];
            }
            UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 34, 9, 15)];
            nextImageView.image = kImageWithName(@"icon_next_gray");
            [cell.contentView addSubview:nextImageView];
            if(type==SectionType_Attention&&self.userModel.attenthimlistArray.count==0){
                UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(0, 33, WIDTH, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:@"还没有人关注Ta哦" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
                [cell.contentView addSubview:contentLabel];
            }else{
                NSString *str = @"";
                NSArray *array;
                if(type == SectionType_Coffee){
                    str = [NSString stringWithFormat:@"%@个用户领取", [NSString getNumStr:self.userModel.coffeeCnt]];
                    array = self.userModel.coffeePhotosArray;
                }else{
                    str = [NSString stringWithFormat:@"%@人关注Ta", [NSString getNumStr:self.userModel.attentionhenum]];
                    array = self.userModel.attenthimlistArray;
                }
                CGFloat strWidth = (NSInteger)[NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(14) height:50]+1;
                CGFloat start_X = 0;
                for (int i=0; i < array.count; i++) {
                    if(WIDTH-60-strWidth<35*(i+1)+9){
                        break;
                    }
                    start_X = 16+35*i;
                    UserModel *model = array[i];
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 20, 44, 44)];
                    if(WIDTH-60-strWidth<35*(i+2)+9){
                        imageView.image = kImageWithName(@"icon_index_rmgd");
                    }else{
                        [imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
                    }
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.clipsToBounds = YES;
                    [cell.contentView addSubview:imageView];
                    [CALayer updateControlLayer:imageView.layer radius:22 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
                }
                UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(start_X+44+10, 35, strWidth, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:str font:14 number:1 nstextLocat:NSTextAlignmentRight];
                [cell.contentView addSubview:numLabel];
            }
            return cell;
        }else{
            static NSString *cellReID = @"NewLookHistoryCell";
            NewLookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
            if (!cell) {
                cell = [CommonMethod getViewFromNib:NSStringFromClass([NewLookHistoryCell class])];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateDisplayModel:self.lookHistoryArray[indexPath.row]];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_currentTab==0){
        if(_noNetWork && !self.summaryArray.count){
            [self loadHttpMyHomePageData];
        }else if(_isLoadHttp && !self.summaryArray.count){
        }else{
            NSInteger type = [CommonMethod paramNumberIsNull:self.summaryArray[indexPath.section][@"type"]].integerValue;
            if(type == SectionType_Need){
                _isPresentVC = YES;
                VariousDetailController *vc = [CommonMethod getVCFromNib:[VariousDetailController class]];
                vc.dynamicid = self.userModel.needModel.dynamic_id;
                vc.deleteDynamicDetail = ^(NSNumber *dynamicid) {
                    [self loadHttpMyHomePageData];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }else if(type == SectionType_Supply){
                _isPresentVC = YES;
                VariousDetailController *vc = [CommonMethod getVCFromNib:[VariousDetailController class]];
                vc.dynamicid = self.userModel.supplyModel.dynamic_id;
                vc.deleteDynamicDetail = ^(NSNumber *dynamicid) {
                    [self loadHttpMyHomePageData];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }else if(type == SectionType_Subject){
                _isPresentVC = YES;
                InformationDetailController *vc = [[InformationDetailController alloc] init];
                vc.postID = self.userModel.djtalkModel.subjectId;
                [self.navigationController pushViewController:vc animated:YES];
            }else if(type == SectionType_WorkHistory){
                _isPresentVC = YES;
                workHistryModel *workModel = self.userModel.workHistoryArray[indexPath.row];
                WorkHistoryController *workHistory = [[WorkHistoryController alloc]init];
                workHistory.workHistoryDetailChange = ^(BOOL isEdit, workHistryModel *model) {
                    NSInteger index = 0;
                    for(workHistryModel *whModel in self.userModel.workHistoryArray){
                        if(whModel.careerid.integerValue == model.careerid.integerValue){
                            break;
                        }
                        index++;
                    }
                    if(isEdit){
                        self.userModel.workHistoryArray[index] = model;
                    }else{
                        [self.userModel.workHistoryArray removeObjectAtIndex:index];
                    }
                    [self.tableView reloadData];
                };
                workHistory.isMyPage = self.isMyHomePage;
                workHistory.isfriend = self.userModel.isfriend;
                workHistory.workModel = workModel;
                [self.navigationController pushViewController:workHistory animated:YES];
            }else if(type == SectionType_Introduce){
            }else if(type == SectionType_Honor){
                if(self.isMyHomePage){
                    _isPresentVC = YES;
                    HonorListViewController *vc = [CommonMethod getVCFromNib:[HonorListViewController class]];
                    vc.honorArray = self.userModel.honorsArray;
                    vc.honorListChange = ^(NSMutableArray *honorArray) {
                        self.userModel.honorsArray = honorArray;
                        [self.tableView reloadData];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else if(type == SectionType_Tag){
            }else if(type == SectionType_Photo){
            }else{//评论
                _isPresentVC = YES;
                UserModel *model = self.userModel.evaluationsArray[indexPath.row];
                NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
                vc.userId = model.userId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else if(_currentTab==1){
        if(_noNetWork && !self.dynamicArray.count){
            [self loadHttpDynamicListData];
        }else if(_isLoadHttp && !self.dynamicArray.count){
        }else if(self.dynamicArray.count){
            if(indexPath.row==0&&self.isMyHomePage){
                DynamicNotificationCtr *vc = [[DynamicNotificationCtr alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:0];
            }else{
                NSInteger row = indexPath.row;
                if(self.isMyHomePage){
                    row -= 1;
                }
                DynamicModel *model = self.dynamicArray[row];
                if(model.dynamic_id.integerValue > 0 && model.parent_status.integerValue<4){
                    _isPresentVC = YES;
                    __weak typeof(self) weakSelf = self;
                    VariousDetailController *vc = [[VariousDetailController alloc] init];
                    vc.dynamicid = model.dynamic_id;
                    vc.deleteDynamicDetail = ^(NSNumber *dynamicid){
                        for(DynamicModel *tmpModel in weakSelf.dynamicArray){
                            if(tmpModel.dynamic_id.integerValue == dynamicid.integerValue){
                                [weakSelf.dynamicArray removeObject:tmpModel];
                                break;
                            }
                        }
                        [weakSelf.cellArrayDict removeAllObjects];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.tableView reloadData];
                        });
                    };
                    vc.attentUser = ^(BOOL isAttent){
                        for(DynamicModel *tmpModel in weakSelf.dynamicArray){
                            if(tmpModel.userModel.user_id.integerValue == model.userModel.user_id.integerValue){
                                if(isAttent){
                                    tmpModel.userModel.relationship = @"关注";
                                }else{
                                    tmpModel.userModel.relationship = @"推荐";
                                }
                            }
                        }
                        [weakSelf.cellArrayDict removeAllObjects];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf.tableView reloadData];
                        });
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }else{
        if(_noNetWork && !self.contactArray.count){
            [self loadHttpDynamicListData];
            return;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.contactArray[indexPath.section][@"type"]].integerValue;
        if(type==SectionType_Attention&&self.userModel.attenthimlistArray.count==0){
        }else if(type == SectionType_Attention){
            _isPresentVC = YES;
            TaContactsCtr *contacts = [[TaContactsCtr alloc]init];
            contacts.userID = self.userId;
            contacts.hisattentionnum = self.userModel.hisattentionnum;
            contacts.attentionhenum = self.userModel.attentionhenum ;
            contacts.comfriendnum = self.userModel.comfriendnum;
            contacts.friendnum = self.userModel.friendnum;
            [self.navigationController pushViewController:contacts animated:YES];
        }else if(type == SectionType_Coffee){
            _isPresentVC = YES;
            WallCofferController *wall = [[WallCofferController alloc]init];
            wall.userID = self.userId;
            [self.navigationController pushViewController:wall animated:YES];
        }else{
            _isPresentVC = YES;
            NewMyHomePageController *vc = [[NewMyHomePageController alloc]init];
            LookHistoryModel *lookModel = self.lookHistoryArray[indexPath.row];
            vc.userId = lookModel.userid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat coverImageHeight = 200*WIDTH/375.0;
    if(scrollView.contentOffset.y < 0){
        self.coverImageView.frame = CGRectMake(375*scrollView.contentOffset.y/200.0/2.0, scrollView.contentOffset.y, WIDTH-375*scrollView.contentOffset.y/200.0, coverImageHeight-scrollView.contentOffset.y);
    }
    
    CGFloat offHeight = coverImageHeight-64;
    CGFloat offset_Y = scrollView.contentOffset.y;
    CGFloat alpha = offset_Y/offHeight;
    self.navbarTitleLabel.hidden = NO;
    self.navbarTitleLabel.alpha = alpha-0.1;
    self.navbarBgView.alpha = alpha;
    if (offset_Y < offHeight/2){
        [self.navbarBackBtn setImage:[UIImage imageNamed:@"btn_tab_back_normal"] forState:UIControlStateNormal];
        if(self.isMyHomePage){
            [self.navbarMoreBtn setImage:[UIImage imageNamed:@"btn_myindex_edit"] forState:UIControlStateNormal];
        }else{
            [self.navbarMoreBtn setImage:[UIImage imageNamed:@"btn_tab_more_normal"] forState:UIControlStateNormal];
        }
        alpha = 1.2-alpha*2;
        self.navbarBackBtn.alpha = alpha;
        self.navbarMoreBtn.alpha = alpha;
    }else{
        alpha = alpha*2-0.8;
        self.navbarBackBtn.alpha = alpha;
        self.navbarMoreBtn.alpha = alpha;
        [self.navbarBackBtn setImage:[UIImage imageNamed:@"btn_tab_back"] forState:UIControlStateNormal];
        if(self.isMyHomePage){
            [self.navbarMoreBtn setImage:[UIImage imageNamed:@"btn_myindex_editgrey"] forState:UIControlStateNormal];
        }else{
            [self.navbarMoreBtn setImage:[UIImage imageNamed:@"btn_tab_more"] forState:UIControlStateNormal];
        }
    }
    
    CGFloat tableHeaderHeight = coverImageHeight;
    if(self.isMyHomePage || [CommonMethod paramNumberIsNull:self.userModel.connectionsCount].integerValue==0){
        tableHeaderHeight += 199;
    }else{
        tableHeaderHeight += 265;
    }
    if(offset_Y>=tableHeaderHeight-64){
        self.tabbarView.hidden = NO;
    }else{
        self.tabbarView.hidden = YES;
    }
}

#pragma mark - 点击图片
- (void)photoButtonClicked:(NSInteger)index imageArray:(NSArray*)image{
    self.imageArray = [image mutableCopy];
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = YES;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.autoPlayOnAppear = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:index];
    photoBrowser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imageArray.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSString *imageUrl = self.imageArray[index];
    NSURL *url = [NSURL URLWithString:imageUrl];
    MWPhoto *photo = [MWPhoto photoWithURL:url];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
