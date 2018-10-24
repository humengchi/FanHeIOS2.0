//
//  CompanyViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CompanyViewController.h"
#import "NewLookHistoryCell.h"
#import "ManagerUserCell.h"
#import "WebViewController.h"
#import "LocationMapController.h"
#import "InformationDetailController.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"

typedef NS_ENUM(NSInteger, SectionType) {
    SectionType_Intro,
    SectionType_Business,
    SectionType_Dynamic,
    SectionType_Address,
    SectionType_GongShang,
    SectionType_More,
    
    SectionType_Manager,
    SectionType_Employee,
};

@interface CompanyViewController (){
    NSInteger _currentTab;
    BOOL _noNetWork;
}

@property (nonatomic, strong) UIView *navbarView;
@property (nonatomic, strong) UIView *navbarBgView;
@property (nonatomic, strong) UILabel *navbarTitleLabel;
@property (nonatomic, strong) UIButton *navbarBackBtn;
@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UIView *tabbarView; //tab栏
@property (nonatomic, strong) UIView *tabbarTableView;

@property (nonatomic, strong) UIView *bottomBtnView;

@property (nonatomic, strong) CompanyModel *model;

@property (nonatomic, strong) NSMutableArray *introArray;
@property (nonatomic, strong) NSMutableArray *teamArray;

@end

@implementation CompanyViewController

-  (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView:CGRectMake(0, 0, WIDTH, HEIGHT)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self createNavBarView];
    [self createTabbarView];
    [self createTableViewHeaderView];
    
    [self getHttpDataCompanyDetail];
    // Do any additional setup after loading the view.
}

#pragma mark --- 网络请求数据－公司信息
- (void)getHttpDataCompanyDetail{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.companyId, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_COMPANY_DETAIL paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.introArray = [NSMutableArray array];
        weakSelf.teamArray = [NSMutableArray array];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            weakSelf.model = [[CompanyModel alloc] initWithDict:dict];
//            weakSelf.navbarTitleLabel.text = weakSelf.model.company;
            [weakSelf createTableViewHeaderView];
            if([CommonMethod paramStringIsNull:weakSelf.model.introduction].length){
                [weakSelf.introArray addObject:@{@"type":@(SectionType_Intro), @"typeStr":@""}];
            }
            if([CommonMethod paramArrayIsNull:weakSelf.model.businessArray].count){
                [weakSelf.introArray addObject:@{@"type":@(SectionType_Business), @"typeStr":@"主营业务"}];
            }
            if([CommonMethod paramArrayIsNull:weakSelf.model.dynamicArray].count){
                [weakSelf.introArray addObject:@{@"type":@(SectionType_Dynamic), @"typeStr":@"近期动态"}];
            }
            /********地址、电话、网址***********/
            NSMutableArray *array = [NSMutableArray array];
            if([CommonMethod paramStringIsNull:weakSelf.model.address].length){
                [array addObject:@{@"type":@"address", @"data":weakSelf.model.address, @"icon":@"icon_event_address"}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.telephone].length){
                [array addObject:@{@"type":@"telephone", @"data":weakSelf.model.telephone, @"icon":@"icon_company_tele"}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.website].length){
                [array addObject:@{@"type":@"website", @"data":weakSelf.model.website, @"icon":@"btn_link_b"}];
            }
            if(array.count){
                [weakSelf.introArray addObject:@{@"type":@(SectionType_Address), @"typeStr":@"地址、电话、网址", @"data":array}];
            }
            
            /********工商信息***********/
            NSMutableArray *gsArray = [NSMutableArray array];
            if([CommonMethod paramStringIsNull:weakSelf.model.ic_legal_person].length){
                [gsArray addObject:@{@"type":@"ic_legal_person", @"data":weakSelf.model.ic_legal_person}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.ic_num].length){
                [gsArray addObject:@{@"type":@"ic_num", @"data":weakSelf.model.ic_num, @"nameStr":@"工商注册号："}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.ic_name].length){
                [gsArray addObject:@{@"type":@"ic_name", @"data":weakSelf.model.ic_name, @"nameStr":@"企业名称："}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.ic_type].length){
                [gsArray addObject:@{@"type":@"ic_type", @"data":weakSelf.model.ic_type, @"nameStr":@"企业类型："}];
            }
            if([CommonMethod paramStringIsNull:weakSelf.model.ic_created_at].length){
                [gsArray addObject:@{@"type":@"ic_created_at", @"data":weakSelf.model.ic_created_at, @"nameStr":@"成立时间："}];
            }
            if(gsArray.count){
                [weakSelf.introArray addObject:@{@"type":@(SectionType_GongShang), @"typeStr":@"工商信息", @"data":gsArray}];
            }
            
//            if(weakSelf.introArray.count){
//                [weakSelf.introArray addObject:@{@"type":@(SectionType_More), @"typeStr":@"更多"}];
//            }
            
            /********团队***********/
            if([CommonMethod paramArrayIsNull:weakSelf.model.managerArray].count){
                [weakSelf.teamArray addObject:@{@"type":@(SectionType_Manager), @"typeStr":@"管理层"}];
            }
            if([CommonMethod paramArrayIsNull:weakSelf.model.employeeArray].count){
                [weakSelf.teamArray addObject:@{@"type":@(SectionType_Employee), @"typeStr":@"员工"}];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        weakSelf.introArray = [NSMutableArray array];
        weakSelf.teamArray = [NSMutableArray array];
        [weakSelf.tableView reloadData];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

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
    self.navbarBackBtn = [NSHelper createButton:CGRectMake(0, 20, 64, 44) title:nil unSelectImage:[UIImage imageNamed:@"btn_tab_back_normal"] selectImage:nil target:self selector:@selector(backButtonClicked:)];
    [self.navbarView addSubview:self.navbarBackBtn];
    //标题
    self.navbarTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 20, WIDTH-100, 44)];
    self.navbarTitleLabel.text = self.company;
    self.navbarTitleLabel.hidden = YES;
    self.navbarTitleLabel.textColor = HEX_COLOR(@"383838");
    self.navbarTitleLabel.font = FONT_SYSTEM_SIZE(17);
    self.navbarTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navbarView addSubview:self.navbarTitleLabel];
}

#pragma mark ------- headerView
- (void)createTableViewHeaderView{
    CGFloat start_Y = 0;
    CGFloat coverImageHeight = 200*WIDTH/375.0;
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, WIDTH, coverImageHeight+192);
    headerView.backgroundColor = WHITE_COLOR;
    if(!self.coverImageView){
        self.coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, coverImageHeight)];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImageView.clipsToBounds = YES;
    }
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.model.bgimage]] placeholderImage:kImageWithName(@"image_zy_bg")];
    [headerView addSubview:self.coverImageView];
    start_Y += coverImageHeight;
    
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-100)/2.0, coverImageHeight-50, 100, 100)];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:self.model.logo]] placeholderImage:kImageWithName(@"icon_work_company")];
    headImageView.backgroundColor = kTableViewBgColor;
    headImageView.contentMode = UIViewContentModeScaleAspectFill;
    headImageView.clipsToBounds = YES;
    [CALayer updateControlLayer:headImageView.layer radius:5 borderWidth:2.5 borderColor:HEX_COLOR(@"e6e8eb").CGColor];
    [headerView addSubview:headImageView];

    start_Y += 62;
    NSString *nameStr = [CommonMethod paramStringIsNull:self.company];
    CGFloat nameStrWidth = (NSInteger)[NSHelper widthOfString:(nameStr.length==0?@"公司名称":nameStr) font:FONT_SYSTEM_SIZE(17) height:17]+1;
    if(nameStrWidth>WIDTH-32){
        nameStrWidth = WIDTH-32;
    }
    UILabel *nameLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-nameStrWidth)/2.0, start_Y, nameStrWidth, 19) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:(nameStr.length==0?@"公司名称":nameStr) font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [headerView addSubview:nameLabel];
    
    start_Y += 19;
    NSMutableArray *infoArray = [NSMutableArray array];
    NSString *city = [CommonMethod paramStringIsNull:self.model.city];
    if (city.length) {
        [infoArray addObject:city];
    }
    NSString *scaleStr = [CommonMethod paramStringIsNull:self.model.scale_cn];
    if (scaleStr.length) {
        [infoArray addObject:scaleStr];
    }
    if(infoArray.count){
        start_Y += 8;
        UILabel *infoLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:[infoArray componentsJoinedByString:@" | "] font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [headerView addSubview:infoLabel];
        start_Y += 14;
    }
    
    NSMutableArray *industryArray = [NSMutableArray array];
    NSString *industry = [CommonMethod paramStringIsNull:self.model.industry];
    if (industry.length) {
        [industryArray addObject:industry];
    }
    NSString *financing = [CommonMethod paramStringIsNull:self.model.financing];
    if (financing.length) {
        [industryArray addObject:financing];
    }
    if(industryArray.count){
        start_Y += 8;
        UILabel *infoLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:[industryArray componentsJoinedByString:@" | "] font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [headerView addSubview:infoLabel];
        start_Y += 14;
    }
    
    if(!industryArray.count && !infoArray.count){
        start_Y += 8;
        UILabel *infoLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"e6e8eb") test:@"暂无该公司信息数据" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [headerView addSubview:infoLabel];
        start_Y += 14;
    }
    
    start_Y += 16;
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y-0.5, WIDTH, 0.5)];
    lineLabel1.backgroundColor = kCellLineColor;
    [headerView addSubview:lineLabel1];
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 10)];
    lineLabel2.backgroundColor = kTableViewBgColor;
    [headerView addSubview:lineLabel2];
    start_Y += 10;
    
    for(UIView *view in self.tabbarTableView.subviews){
        [view removeFromSuperview];
    }
    self.tabbarTableView = [[UIView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 43)];
    self.tabbarTableView.backgroundColor = WHITE_COLOR;
    CGFloat tabWidth = WIDTH/4;
    NSArray *titles = @[@"简介",@"团队"];
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
        [self.tabbarTableView addSubview:btn];
        if(i == _currentTab){
            btn.selected = YES;
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(tabWidth-50)/2+i*tabWidth, 41.5, 50, 1)];
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
    UILabel *lineLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel3.backgroundColor = kCellLineColor;
    [self.tabbarTableView addSubview:lineLabel3];
    UILabel *lineLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 42.5, WIDTH, 0.5)];
    lineLabel4.backgroundColor = kCellLineColor;
    [self.tabbarTableView addSubview:lineLabel4];
    [headerView addSubview:self.tabbarTableView];
    start_Y += 43;
    headerView.frame = CGRectMake(0, 0, WIDTH, start_Y);
    self.tableView.tableHeaderView = headerView;
}

//滑动到顶部，定住tab栏
- (void)createTabbarView{
    self.tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 43)];
    self.tabbarView.backgroundColor = WHITE_COLOR;
    CGFloat tabWidth = WIDTH/4;
    NSArray *titles = @[@"简介",@"团队"];
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
            UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(start_X+(tabWidth-50)/2+i*tabWidth, 41.5, 50, 1)];
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
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 42.5, WIDTH, 0.5)];
    lineLabel2.backgroundColor = kCellLineColor;
    [self.tabbarView addSubview:lineLabel2];
    self.tabbarView.hidden = YES;
    [self.view addSubview:self.tabbarView];
}

#pragma mark -------  返回
- (void)backButtonClicked:(UIButton*)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -------tab栏点击btn
- (void)tabButtonClicked:(UIButton*)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self.tableView endRefresh];
    [self cancelAllRequest];
    _currentTab = sender.tag-300;
    
    CGFloat tabWidth = WIDTH/4;
    NSInteger tabsNum = 2;
    CGFloat start_X = (WIDTH-tabWidth*tabsNum)/2;
    for(int i = 0; i < tabsNum; i++){
        UIButton *btn1 = (UIButton*)[self.tabbarView subviewWithTag:300+i];
        btn1.selected = NO;
        UIButton *btn2 = (UIButton*)[self.tabbarTableView subviewWithTag:300+i];
        btn2.selected = NO;
    }
    sender.selected = YES;
    
    UILabel *redLabel1 = (UILabel*)[self.tabbarView subviewWithTag:200];
    [UIView animateWithDuration:0.3 animations:^{
        redLabel1.frame = CGRectMake(start_X+(WIDTH/4-50)/2+_currentTab*(WIDTH/4), 41.5, 50, 1);
    }];
    UILabel *redLabel2 = (UILabel*)[self.tabbarTableView subviewWithTag:200];
    [UIView animateWithDuration:0.3 animations:^{
        redLabel2.frame = CGRectMake(start_X+(WIDTH/4-50)/2+_currentTab*(WIDTH/4), 41.5, 50, 1);
    }];
    CGFloat headerViewHeight = self.tableView.tableHeaderView.frame.size.height;
    [self.tableView reloadData];
    if(self.tableView.contentOffset.y > headerViewHeight-64-43){
        [self.tableView setContentOffset:CGPointMake(0, headerViewHeight-64-43) animated:NO];
    }
    if(_currentTab==0){
    }else{
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_currentTab==0){
        if(self.introArray==nil){
            return 0;
        }else if(self.introArray.count==0){
            return 1;
        }else{
            return self.introArray.count;
        }
    }else{
        if(self.teamArray==nil){
            return 0;
        }else if(self.teamArray.count==0){
            return 1;
        }else{
            return self.teamArray.count;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_currentTab==0){
        if(self.teamArray.count==0){
            return 1;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.introArray[section][@"type"]].integerValue;
        NSInteger row = 0;
        switch (type) {
            case SectionType_Intro:{
                row = 1;
            }
                break;
            case SectionType_Business:{
                row = self.model.businessArray.count;
            }
                break;
            case SectionType_Dynamic:{
                row = self.model.dynamicArray.count;
            }
                break;
            case SectionType_Address:{
                row = [CommonMethod paramArrayIsNull:self.introArray[section][@"data"]].count;
            }
                break;
            case SectionType_GongShang:{
                row = [CommonMethod paramArrayIsNull:self.introArray[section][@"data"]].count;
            }
                break;
            case SectionType_More:{
                row = 1;
            }
                break;
            default:
                break;
        }
        return row;
    }else{
        if(self.teamArray.count==0){
            return 1;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.teamArray[section][@"type"]].integerValue;
        NSInteger row = 0;
        switch (type) {
            case SectionType_Manager:{
                row = self.model.managerArray.count;
            }
                break;
            case SectionType_Employee:{
                row = self.model.employeeArray.count;
            }
                break;
            default:
                row = 1;
                break;
        }
        return row;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_currentTab==0){
        if(self.introArray.count==0){
            return 300;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.introArray[indexPath.section][@"type"]].integerValue;
        switch (type) {
            case SectionType_Intro:{
                NSString *intro = self.model.introduction;
                CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
                height += height/FONT_SYSTEM_SIZE(14).lineHeight*7;
                height += 25;
                return height;
            }
                break;
            case SectionType_Business:{
                BusinessModel *businessModel = self.model.businessArray[indexPath.row];
                NSString *intro = businessModel.intro;
                CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
                height += height/FONT_SYSTEM_SIZE(14).lineHeight*7;
                height += 37;
                return height;
            }
                break;
            case SectionType_Dynamic:{
                FinanaceDetailModel *fdModel = self.model.dynamicArray[indexPath.row];
                if(fdModel.image.length){
                    return 84;
                }else{
                    NSString *intro = fdModel.title;
                    CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
                    height += height/FONT_SYSTEM_SIZE(14).lineHeight*7;
                    height += 17;
                    return height;
                }
            }
                break;
            case SectionType_Address:{
                NSArray *array = [CommonMethod paramArrayIsNull:self.introArray[indexPath.section][@"data"]];
                NSDictionary *dict = array[indexPath.row];
                NSString *dataStr = dict[@"data"];
                CGFloat height = [NSHelper heightOfString:dataStr font:FONT_SYSTEM_SIZE(14) width:WIDTH-65];
                height += height/FONT_SYSTEM_SIZE(14).lineHeight*6;
                height += 26;
                return height;
            }
                break;
            case SectionType_GongShang:{
                NSArray * data = [CommonMethod paramArrayIsNull:self.introArray[indexPath.section][@"data"]];
                if([data[indexPath.row][@"type"] isEqualToString:@"ic_name"]){
                    NSString *intro = self.model.address;
                    CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-134];
                    height += height/FONT_SYSTEM_SIZE(14).lineHeight*9;
                    height += 15;
                    return height;
                }else if([data[indexPath.row][@"type"] isEqualToString:@"ic_legal_person"]){
                    return 105;
                }else{
                    return 40;
                }
            }
                break;
            case SectionType_More:{
                return 74;
            }
                break;
            default:
                break;
        }
        return 0;
    }else{
        if(self.teamArray.count==0){
            return 300;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.teamArray[indexPath.section][@"type"]].integerValue;
        switch (type) {
            case SectionType_Manager:{
                return 88;
            }
                break;
            case SectionType_Employee:{
                return 73;
            }
                break;
            default:
                break;
        }
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_currentTab==0){
        if(self.introArray.count==0){
            return 0;
        }
        NSInteger type = [CommonMethod paramNumberIsNull:self.introArray[section][@"type"]].integerValue;
        switch (type) {
            case SectionType_Intro:{
                return 0;
            }
                break;
            case SectionType_Business:{
                return 34;
            }
                break;
            case SectionType_Dynamic:{
                return 34;
            }
                break;
            case SectionType_Address:{
                return 0;
            }
                break;
            case SectionType_GongShang:{
                return 34;
            }
                break;
            case SectionType_More:{
                return 0;
            }
                break;
            default:
                break;
        }
        return 0;
    }else{
        if(self.teamArray.count){
            return 42;
        }else{
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    NSString *titleStr = @"";
    if(_currentTab==0){
        if(self.introArray.count==0){
            return nil;
        }
        height = 34;
        titleStr = [CommonMethod paramStringIsNull:self.introArray[section][@"typeStr"]];
    }else{
        if(self.teamArray.count==0){
            return nil;
        }
        height = 42;
        titleStr = [CommonMethod paramStringIsNull:self.teamArray[section][@"typeStr"]];
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    headerView.backgroundColor = WHITE_COLOR;
    if(_currentTab==0){
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 15, WIDTH-32, 16) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:titleStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:titleLabel];
    }else{
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, 42) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:titleStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:titleLabel];
    }
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
}

- (UITableViewCell*)getNoDataOrNoNetworkCell:(UITableView *)tableView{
    if(_noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.mainLabel.text = @"暂无该公司相关介绍";
        cell.subLabel.text = @"";
        cell.coverImageView.image = kImageWithName(@"icon_gs_nojj");
        return cell;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger type;
    if(_currentTab==0){
        if(self.introArray.count==0){
            return [self getNoDataOrNoNetworkCell:tableView];
        }
        type = [CommonMethod paramNumberIsNull:self.introArray[indexPath.section][@"type"]].integerValue;
    }else{
        if(self.teamArray.count==0){
            return [self getNoDataOrNoNetworkCell:tableView];
        }
        type = [CommonMethod paramNumberIsNull:self.teamArray[indexPath.section][@"type"]].integerValue;
    }
    if(type == SectionType_Intro){
        static NSString *identify = @"introCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSString *intro = self.model.introduction;
        CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        if(height>FONT_SYSTEM_SIZE(14).lineHeight){
            height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 16, WIDTH-32, (NSInteger)height+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:intro font:14 number:0 nstextLocat:NSTextAlignmentLeft];
        if(height>FONT_SYSTEM_SIZE(14).lineHeight){
            [contentLabel setParagraphText:intro lineSpace:7];
        }
        [cell.contentView addSubview:contentLabel];
        return cell;
    }else if(type == SectionType_Business){
        static NSString *identify = @"businessCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        BusinessModel *bsModel = self.model.businessArray[indexPath.row];
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 12, WIDTH-32, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:bsModel.name font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        
        NSString *intro = bsModel.intro;
        CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        if(height>FONT_SYSTEM_SIZE(14).lineHeight){
            height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 32, WIDTH-32, (NSInteger)height+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:intro font:14 number:0 nstextLocat:NSTextAlignmentLeft];
        if(height>FONT_SYSTEM_SIZE(14).lineHeight){
            [contentLabel setParagraphText:intro lineSpace:7];
        }
        [cell.contentView addSubview:contentLabel];
        if(self.model.businessArray.count>indexPath.row+1){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+32+11.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
        return cell;
    }else if(type == SectionType_Dynamic){
        static NSString *identify = @"dynamicCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        FinanaceDetailModel *fdModel = self.model.dynamicArray[indexPath.row];
        if(fdModel.image && fdModel.image.length){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 123, 60)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:fdModel.image] placeholderImage:KWidthImageDefault];
            [cell.contentView addSubview:imageView];
            
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(149, 21, WIDTH-165, (NSInteger)FONT_SYSTEM_SIZE(14).lineHeight*2+10) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:fdModel.title font:14 number:0 nstextLocat:NSTextAlignmentLeft];
            [contentLabel setParagraphText:fdModel.title lineSpace:8];
            [cell.contentView addSubview:contentLabel];
            if(self.model.dynamicArray.count>indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 83.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }else{
            NSString *intro = fdModel.title;
            CGFloat height = [NSHelper heightOfString:intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
            if(height>FONT_SYSTEM_SIZE(14).lineHeight){
                height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
            }
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 12, WIDTH-32, (NSInteger)height+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:intro font:14 number:0 nstextLocat:NSTextAlignmentLeft];
            if(height>FONT_SYSTEM_SIZE(14).lineHeight){
                [contentLabel setParagraphText:intro lineSpace:7];
            }
            [cell.contentView addSubview:contentLabel];
            if(self.model.dynamicArray.count>indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+23.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }
        return cell;
    }else if(type == SectionType_Address){
        static NSString *identify = @"addressCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSArray *array = [CommonMethod paramArrayIsNull:self.introArray[indexPath.section][@"data"]];
        NSDictionary *dict = array[indexPath.row];
        NSString *icon = dict[@"icon"];
        NSString *type = dict[@"type"];
        NSString *dataStr = dict[@"data"];
        
        CGFloat height = [NSHelper heightOfString:dataStr font:FONT_SYSTEM_SIZE(14) width:WIDTH-65];
        height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*6;
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(35, 16, WIDTH-65, (NSInteger)height+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:dataStr font:14 number:0 nstextLocat:NSTextAlignmentLeft];
        if(height > FONT_SYSTEM_SIZE(14).lineHeight){
            [contentLabel setParagraphText:dataStr lineSpace:6];
        }
        [cell.contentView addSubview:contentLabel];
        if([type isEqualToString:@"website"]){
            contentLabel.textColor = HEX_COLOR(@"3498db");
        }
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, (height+32)/2-6, 12, 12)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.clipsToBounds = YES;
        iconImageView.image = kImageWithName(icon);
        [cell.contentView addSubview:iconImageView];
        
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, (height+32)/2-8, 9, 15)];
        nextImageView.contentMode = UIViewContentModeScaleAspectFit;
        nextImageView.clipsToBounds = YES;
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
        if(array.count>indexPath.row+1){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+32-0.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
        return cell;
    }else if(type == SectionType_GongShang){
        static NSString *identify = @"gongshangCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSArray *array = [CommonMethod paramArrayIsNull:self.introArray[indexPath.section][@"data"]];
        NSDictionary *dict = array[indexPath.row];
        NSString *nameStr = dict[@"nameStr"];
        NSString *type = dict[@"type"];
        NSString *dataStr = dict[@"data"];
        
        if([type isEqualToString:@"ic_legal_person"]){
            CGFloat width = (WIDTH-42)/2;
            CGFloat start_X = 16;
            if(self.model.ic_legal_person.length){
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(start_X, 12, width, 81)];
                [CALayer updateControlLayer:view.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"afb6c1").CGColor];
                [cell.contentView addSubview:view];
                
                UILabel *titleLabel = [UILabel createLabel:CGRectMake(5, 20, width-10, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
                titleLabel.text = @"法定代表人";
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [view addSubview:titleLabel];
                
                UILabel *contentLabel = [UILabel createLabel:CGRectMake(5, 46, width-10, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
                contentLabel.textAlignment = NSTextAlignmentCenter;
                contentLabel.text = self.model.ic_legal_person;
                [view addSubview:contentLabel];
                start_X += width+10;
            }
            if(self.model.ic_fund.length){
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(start_X, 12, width, 81)];
                [CALayer updateControlLayer:view.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"afb6c1").CGColor];
                [cell.contentView addSubview:view];
                
                UILabel *titleLabel = [UILabel createLabel:CGRectMake(5, 20, width-10, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
                titleLabel.text = @"注册资金";
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [view addSubview:titleLabel];
                
                UILabel *contentLabel = [UILabel createLabel:CGRectMake(5, 46, width-10, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
                contentLabel.text = self.model.ic_fund;
                contentLabel.textAlignment = NSTextAlignmentCenter;
                [view addSubview:contentLabel];
                start_X += width+10;
            }
            if(array.count>indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 104.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }else{
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 12, 100, 14) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
            titleLabel.text = nameStr;
            [cell.contentView addSubview:titleLabel];
            
            CGFloat height = [NSHelper heightOfString:dataStr font:FONT_SYSTEM_SIZE(14) width:WIDTH-134];
            height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*9;
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(118, 12, WIDTH-134, (NSInteger)height+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:dataStr font:14 number:0 nstextLocat:NSTextAlignmentRight];
            if(height > FONT_SYSTEM_SIZE(14).lineHeight){
                [contentLabel setParagraphText:dataStr lineSpace:9];
            }
            [cell.contentView addSubview:contentLabel];
            
            if(array.count>indexPath.row+1){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+24-0.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }
        return cell;
    }else if(type == SectionType_More){
        static NSString *identify = @"moreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(25, 10, WIDTH-50, 40);
        [btn setTitle:@"查看更多数据" forState:UIControlStateNormal];
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
        btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
        [btn addTarget:self action:@selector(moreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(0, 60, WIDTH, 14) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"以上信息由企查查提供" font:14 number:0 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }else if(type == SectionType_Manager){
        static NSString *identify = @"ManagerUserCell";
        ManagerUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"ManagerUserCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplayUserModel:self.model.managerArray[indexPath.row]];
        return cell;
    }else if(type == SectionType_Employee){
        static NSString *identify = @"NewLookHistoryCell";
        NewLookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NewLookHistoryCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplayUserModel:self.model.employeeArray[indexPath.row]];
        return cell;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger type;
    if(_currentTab==0){
        if(self.introArray.count==0){
            return;
        }
        type = [CommonMethod paramNumberIsNull:self.introArray[indexPath.section][@"type"]].integerValue;
    }else{
        if(self.teamArray.count==0){
            return;
        }
        type = [CommonMethod paramNumberIsNull:self.teamArray[indexPath.section][@"type"]].integerValue;
    }
    if(type == SectionType_Dynamic){
        FinanaceDetailModel *fdModel = self.model.dynamicArray[indexPath.row];
        if([fdModel.type isEqualToString:@"url"]){
            WebViewController *vc = [[WebViewController alloc] init];
            vc.webUrl = fdModel.value;
            vc.customTitle = fdModel.title;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            InformationDetailController *vc = [[InformationDetailController alloc] init];
            vc.postID = @(fdModel.value.integerValue);
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if(type == SectionType_Address){
        NSArray *array = [CommonMethod paramArrayIsNull:self.introArray[indexPath.section][@"data"]];
        NSDictionary *dict = array[indexPath.row];
        NSString *type = dict[@"type"];
        if([type isEqualToString:@"address"]){
            [self mapButtonClicked];
        }else if([type isEqualToString:@"telephone"]){
            [self mobileButtonClicked];
        }else{
            if(self.model.website.length){
                WebViewController *vc = [[WebViewController alloc] init];
                vc.webUrl = self.model.website;
                vc.customTitle = self.model.company;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else if(type == SectionType_Manager){
        UserModel *userModel = self.model.managerArray[indexPath.row];
        if(userModel.userId.integerValue){
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = userModel.userId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if(type == SectionType_Employee){
        UserModel *userModel = self.model.employeeArray[indexPath.row];
        if(userModel.userId.integerValue){
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = userModel.userId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark -- 公司主页网站
- (void)moreButtonClicked{
    WebViewController *vc = [[WebViewController alloc] init];
    vc.webUrl = @"https://m.qichacha.com/";
    vc.customTitle = @"公司查询";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- 拨号
- (void)mobileButtonClicked{
    NSString *str = [NSString stringWithFormat:@"tel:%@",self.model.telephone];
    UIWebView *callWebView = [[UIWebView alloc]init];
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebView];
}

#pragma mark -- 地图
- (void)mapButtonClicked{
    LocationMapController *vc = [[LocationMapController alloc]init];
    vc.latitude = self.model.lat.floatValue;
    vc.longitude = self.model.lng.floatValue;
    vc.addressStr = [NSString stringWithFormat:@"%@%@",self.model.city,self.model.address];
    [self.navigationController pushViewController:vc animated:YES];
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
        alpha = 1.2-alpha*2;
        self.navbarBackBtn.alpha = alpha;
    }else{
        alpha = alpha*2-0.8;
        self.navbarBackBtn.alpha = alpha;
        [self.navbarBackBtn setImage:[UIImage imageNamed:@"btn_tab_back"] forState:UIControlStateNormal];
    }
    
    CGFloat tableHeaderHeight = self.tableView.tableHeaderView.frame.size.height;
    if(offset_Y>=tableHeaderHeight-64-43){
        self.tabbarView.hidden = NO;
    }else{
        self.tabbarView.hidden = YES;
    }
}
@end
