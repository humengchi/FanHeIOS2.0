//
//  MyCofferViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyCofferViewController.h"
#import "CoffeeHelpViewController.h"
#import "ShareNormalView.h"
#import "MyGetCoffeeViewController.h"
#import "HangMyCoffeeViewController.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"
#import "CoffeeIntroduceViewController.h"
#import "ShareCollectZanViewController.h"
#import "EditPersonalInfoViewController.h"

@interface MyCofferViewController ()<MWPhotoBrowserDelegate>{
    BOOL        _noNetWork;
    CGFloat     _offsetY;
}

@property (nonatomic, strong) MyWallCoffeeModel *model;
@property (nonatomic, strong) UIButton          *showBtnNotWork;

@property (nonatomic, strong) UIImageView       *headerImageView;
@end

@implementation MyCofferViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadHttpData];
    if(self.showBackBtn){
        self.tabBarController.tabBar.hidden = YES;
    }
    if(self.model&&self.headerImageView){
        [self updateHeaderImageView];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脉咖啡";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkChange:) name:kReachabilityChangedNotification object:nil];
    if(self.showBackBtn){
        [self updateVCDisplay];
    }
}

- (void)updateHeaderImageView{
    NSInteger wallCoffeeType = self.model.coffeestatus.integerValue;
    if((wallCoffeeType == WallCoffeeType_CoffeeBeenGot_HasCoffee||wallCoffeeType == WallCoffeeType_CoffeeBeenGot_NoCoffee)&&self.model.getmycoffeephoto.count){
        NSDictionary *userDict = self.model.getmycoffeephoto[0];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:userDict[@"image"]] placeholderImage:KHeadImageDefaultName(userDict[@"realname"])];
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    }
}

#pragma mark - 网络变化
- (void)netWorkChange:(NSNotification *)netWorkChange{
    Reachability *reach = [netWorkChange object];
    [self showNetWorkStatue:reach.currentReachabilityStatus!=NotReachable];
}

- (void)showNetWorkStatue:(BOOL)hasNet{
    if (!hasNet) {
        if (self.showBtnNotWork==nil) {
            _offsetY = 36;
            CGFloat offset_Y = self.tableView.contentInset.top;
            self.showBtnNotWork = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.showBtnNotWork setTitle:@"没有网络连接，请检查网络设置" forState:UIControlStateNormal];
            [self.showBtnNotWork setTitleColor:[UIColor colorWithHexString:@"8B4542"] forState:UIControlStateNormal];
            self.showBtnNotWork.titleLabel.font = [UIFont systemFontOfSize:14];
            self.showBtnNotWork.backgroundColor = [UIColor colorWithHexString:@"FFE1E1"];
            [self.tableView addSubview:self.showBtnNotWork];
            self.showBtnNotWork.frame = CGRectMake(0, -(offset_Y+36), WIDTH, 36);
            [self.tableView setContentInset:UIEdgeInsetsMake(36+offset_Y, 0, 0, 0)];
        }
    }else{
        if(self.showBtnNotWork){
            [self.showBtnNotWork removeFromSuperview];
            self.showBtnNotWork = nil;
            CGFloat offset_Y = self.tableView.contentInset.top;
            [self.tableView setContentInset:UIEdgeInsetsMake(offset_Y-36, 0, 0, 0)];
            _offsetY = 0;
            if(self.model == nil){
                [self loadHttpData];
            }
        }
    }
}

#pragma mark -预加载
- (void)updateVCDisplay{
    if(self.showBackBtn){
        [self initDefaultLeftNavbar];
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    }else{
        [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self intNavBarButtonItem:YES frame:CGRectMake(0, 0, 60, 44) imageName:nil buttonName:@"帮助"];
    [self loadHttpData];
}

#pragma mark - 头部初始化view
- (void)initTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH)];
    headerView.backgroundColor = kTableViewBgColor;
    //咖啡状态
    NSInteger wallCoffeeType = self.model.coffeestatus.integerValue;
    CGFloat height = 112;
    //第一部分view
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    firstView.backgroundColor = kDefaultColor;
    [headerView addSubview:firstView];
    //头像
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(24, 24, 64, 64)];
    [CALayer updateControlLayer:headerImageView.layer radius:32 borderWidth:2 borderColor:[WHITE_COLOR colorWithAlphaComponent:0.7].CGColor];
    [headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    [firstView addSubview:headerImageView];
    if((wallCoffeeType == WallCoffeeType_CoffeeBeenGot_HasCoffee||wallCoffeeType == WallCoffeeType_CoffeeBeenGot_NoCoffee)&&self.model.getmycoffeephoto.count){
        NSDictionary *userDict = self.model.getmycoffeephoto[0];
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:userDict[@"image"]] placeholderImage:KHeadImageDefaultName(userDict[@"realname"])];
    }else{
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    }
    self.headerImageView = headerImageView;
    NSLog(@"%ld",wallCoffeeType);
    //状态
    if(wallCoffeeType == WallCoffeeType_NotHang_NoCoffee){
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, 34, WIDTH-127, 18) backColor:kDefaultColor textColor:WHITE_COLOR test:@"还未开启人脉咖啡" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
        UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        subBtn.frame = CGRectMake(103, 63, WIDTH-127, 15);
        NSString *str = @"什么是人脉咖啡？";
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
        [attr setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FONT_SYSTEM_SIZE(14),NSFontAttributeName, HEX_COLOR(@"E6E8EB"),NSForegroundColorAttributeName,@(1),NSUnderlineStyleAttributeName,nil] range:NSMakeRange(0, [str length])];
        [subBtn setAttributedTitle:attr forState:UIControlStateNormal];
        [subBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [subBtn addTarget:self action:@selector(coffeeIntroduceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [firstView addSubview:subBtn];
    }else if(wallCoffeeType == WallCoffeeType_NotHang_HasCoffee){
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, 24, WIDTH-127, 18) backColor:kDefaultColor textColor:WHITE_COLOR test:@"开启我的人脉咖啡" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
        UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        subBtn.frame = CGRectMake(103, 54, 100, 32);
        [subBtn setTitle:@"启用" forState:UIControlStateNormal];
        [subBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [subBtn setBackgroundColor:WHITE_COLOR];
        subBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        [subBtn addTarget:self action:@selector(hangCoffeeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [CALayer updateControlLayer:subBtn.layer radius:5 borderWidth:0 borderColor:nil];
        [firstView addSubview:subBtn];
    }else if(wallCoffeeType == WallCoffeeType_WaitHang){
        NSString *str = @"一般需要2个工作日为你完成人脉咖啡制作";
        CGFloat strheight = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(14) width:WIDTH-127 defaultHeight:15];
        UILabel *subTitle = [UILabel createrLabelframe:CGRectMake(103, (112-(strheight+12+18))/2+30, WIDTH-127, strheight) backColor:kDefaultColor textColor:HEX_COLOR(@"E6E8EB") test:str font:14 number:0 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:subTitle];
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, (112-(strheight+12+18))/2, WIDTH-127, 18) backColor:kDefaultColor textColor:WHITE_COLOR test:@"正在为您处理..." font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
    }else if(wallCoffeeType == WallCoffeeType_HasHang){
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, 24, WIDTH-127, 18) backColor:kDefaultColor textColor:WHITE_COLOR test:@"我的人脉咖啡已上架" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
        UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        subBtn.frame = CGRectMake(103, 54, 100, 32);
        [subBtn setTitle:@"秀一秀" forState:UIControlStateNormal];
        [subBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [subBtn setBackgroundColor:WHITE_COLOR];
        subBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        [subBtn addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [CALayer updateControlLayer:subBtn.layer radius:5 borderWidth:0 borderColor:nil];
        [firstView addSubview:subBtn];
    }else if(wallCoffeeType == WallCoffeeType_CoffeeBeenGot_HasCoffee){
        NSString *str = [NSString stringWithFormat:@"%@领取了我的咖啡",self.model.lastperson];
        CGFloat strheight = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(17) width:WIDTH-127 defaultHeight:18];
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, (112-strheight-12-32)/2.0, WIDTH-127, strheight) backColor:kDefaultColor textColor:WHITE_COLOR test:str font:17 number:0 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
        UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        subBtn.frame = CGRectMake(103, (112-strheight-12-32)/2.0+12+strheight, 100, 32);
        [subBtn setTitle:@"再来一杯" forState:UIControlStateNormal];
        [subBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [subBtn setBackgroundColor:WHITE_COLOR];
        subBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        [CALayer updateControlLayer:subBtn.layer radius:5 borderWidth:0 borderColor:nil];
        [subBtn addTarget:self action:@selector(hangCoffeeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [firstView addSubview:subBtn];
    }else if(wallCoffeeType == WallCoffeeType_CoffeeBeenGot_NoCoffee){
        NSString *str = [NSString stringWithFormat:@"%@领取了我的咖啡",self.model.lastperson];
        CGFloat strheight = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(17) width:WIDTH-127 defaultHeight:18];
        UILabel *mainTitle = [UILabel createrLabelframe:CGRectMake(103, (112-strheight)/2.0, WIDTH-127, strheight) backColor:kDefaultColor textColor:WHITE_COLOR test:str font:17 number:0 nstextLocat:NSTextAlignmentLeft];
        [firstView addSubview:mainTitle];
    }
    
    //挂出咖啡展示图片view
    if(wallCoffeeType == WallCoffeeType_HasHang){
        //三角形
        UIImageView *sanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48, height-10, 16, 10)];
        sanImageView.image = kImageWithName(@"bg_cf_sj");
        [headerView addSubview:sanImageView];
        
        CGFloat imagesViewHeight = 136*WIDTH/375.0;
        CGFloat imageWidth = 100*WIDTH/375.0;
        CGFloat startX = (WIDTH-imageWidth*3)/3.0;
        CGFloat startY = (imagesViewHeight-imageWidth)/2.0;
        
        UIView *imagesView = [[UIView alloc] initWithFrame:CGRectMake(0, height, WIDTH, imagesViewHeight)];
        imagesView.backgroundColor = HEX_COLOR(@"f8f8fa");
        [headerView addSubview:imagesView];
            for(int i=0; i<self.model.image.count; i++){
                NSString *imgStr = self.model.image[i];
                UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                imageBtn.frame = CGRectMake(startX+(imageWidth+startX/2.0)*i, startY, imageWidth, imageWidth);
                [imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:imgStr] forState:UIControlStateNormal placeholderImage:KEqualWHImageDefault];
                [imagesView addSubview:imageBtn];
                [imageBtn addTarget:self action:@selector(photoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                imageBtn.tag = i;
            }
        height += imagesViewHeight;
    }
    
    //第二部分view
    NSInteger coffNum = self.model.remainingcnt.integerValue;
    CGFloat secondHeight = coffNum>0?155:126;
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0, height, WIDTH, secondHeight)];
    secondView.backgroundColor = WHITE_COLOR;
    [headerView addSubview:secondView];
    height += secondHeight;
    
    if(coffNum>0){
        UILabel *hasCoffLabel = [UILabel createrLabelframe:CGRectMake(0, 18, WIDTH, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:[NSString stringWithFormat:@"剩余%@杯“人脉咖啡”",self.model.remainingcnt] font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [secondView addSubview:hasCoffLabel];
        UIView *coffView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, WIDTH, 19)];
        for(int i=0; i < coffNum; i++){
            if(i==5){
                UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(50*i, 0, 25, 19) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818C9E") test:[NSString stringWithFormat:@"X%@", self.model.remainingcnt] font:14 number:1 nstextLocat:NSTextAlignmentRight];
                [coffView addSubview:numLabel];
                break;
            }else{
                UIImageView *glassImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50*i, 0, 25, 19)];
                glassImageView.image = kImageWithName(@"icon_coffee_one");
                [coffView addSubview:glassImageView];
            }
        }
        if(coffNum>5){
            coffView.frame = CGRectMake((WIDTH-50*5-25)/2, 44, 50*5+25, 19);
        }else{
            coffView.frame = CGRectMake((WIDTH-50*(coffNum-1)-25)/2, 44, 50*(coffNum-1)+25, 19);
        }
        [secondView addSubview:coffView];
    }else{
        UILabel *zanLabel = [UILabel createrLabelframe:CGRectMake(0, 18, WIDTH, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"暂无可使用的人脉咖啡" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [secondView addSubview:zanLabel];
    }
    
    //集赞赢咖啡
    UIButton *collectZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectZanBtn.frame = CGRectMake((WIDTH-250)/2, secondHeight-78, 250, 40);
    [CALayer updateControlLayer:collectZanBtn.layer radius:5 borderWidth:0 borderColor:nil];
    collectZanBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [collectZanBtn addTarget:self action:@selector(collectZanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:collectZanBtn];
    
    //已有多少人给我点赞
    UIButton *lookZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lookZanBtn.frame = CGRectMake((WIDTH-250)/2, secondHeight-18-12, 250, 14);
    [lookZanBtn setTitleColor:HEX_COLOR(@"AFB6C1") forState:UIControlStateNormal];
    lookZanBtn.titleLabel.font = FONT_SYSTEM_SIZE(12);
    [lookZanBtn addTarget:self action:@selector(collectZanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger praiseNum = self.model.praisenum.integerValue;
    if(praiseNum){
        [secondView addSubview:lookZanBtn];
    }
    if(praiseNum >= 50){
        collectZanBtn.userInteractionEnabled = NO;
        [lookZanBtn setTitle:@"敬请期待下次活动" forState:UIControlStateNormal];
        [collectZanBtn setBackgroundColor:HEX_COLOR(@"E6E8EB")];
        [collectZanBtn setTitle:@"已集齐50个赞" forState:UIControlStateNormal];
        [collectZanBtn setTitleColor:KTextColor forState:UIControlStateNormal];
        collectZanBtn.userInteractionEnabled = NO;
    }else{
        [lookZanBtn setTitle:[NSString stringWithFormat:@"已有%@个朋友为我点赞",self.model.praisenum] forState:UIControlStateNormal];
        [collectZanBtn setBackgroundColor:HEX_COLOR(@"1ABC9C")];
        [collectZanBtn setTitle:@"集赞赢咖啡" forState:UIControlStateNormal];
        [collectZanBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    }
    
    headerView.frame = CGRectMake(0, 0, WIDTH, height+5);
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView reloadData];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    MyWallCoffeeModel *tmpModel = self.model;
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_MYCOFF paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model = [[MyWallCoffeeModel alloc] initWithDict:responseObject[@"data"]];
        }else{
            _noNetWork = YES;
        }
        if(weakSelf.model){
            if(tmpModel==nil || ![tmpModel compareModel:weakSelf.model]){
                [weakSelf initTableHeaderView];
            }
        }else{
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        if(weakSelf.model){
            if(tmpModel==nil || ![tmpModel compareModel:weakSelf.model]){
                [weakSelf initTableHeaderView];
            }
        }else{
            [weakSelf.tableView reloadData];
        }
        [weakSelf showNetWorkStatue:[CommonMethod webIsLink]];
    }];
}

#pragma mark - 帮助
- (void)rightButtonClicked:(id)sender{
    CoffeeHelpViewController *vc = [[CoffeeHelpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -按钮点击方法
//咖啡宣传界面
- (void)coffeeIntroduceButtonClicked:(UIButton*)sender{
    CoffeeIntroduceViewController *vc = [[CoffeeIntroduceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//挂出咖啡
- (void)hangCoffeeButtonClicked:(UIButton *)sender {
    if(![CommonMethod getUserCanAddFriend]){
        CompleteUserInfoView *completeUserInfoView  = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_HangCoffee];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }else{
        HangMyCoffeeViewController *vc = [CommonMethod getVCFromNib:[HangMyCoffeeViewController class]];
        vc.hangCoffeeSuccess = ^(){
            [self loadHttpData];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}

//集赞赢咖啡
- (void)collectZanButtonClicked:(UIButton*)sender{
    ShareCollectZanViewController *vc = [CommonMethod getVCFromNib:[ShareCollectZanViewController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

//秀一秀
- (void)shareButtonClicked:(id)sender{
    ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
    shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    shareView.messageView.hidden = NO;
    @weakify(self);
    shareView.shareIndex = ^(NSInteger index){
        @strongify(self);
        [self firendClick:index];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showShareNormalView];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *content = @"赶紧来领取我赠送的咖啡";
    NSString *title = @"我在泛合金融俱乐部挂出一杯咖啡";
    UIImage *imageSource;
    NSString *imageUrl;
    if(self.model.image.count){
        imageUrl = self.model.image.firstObject;
    }
    if(imageUrl==nil||imageUrl.length==0){
        imageSource = kImageWithName(@"icon-60");
    }else{
        imageSource = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    }
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else if (index == 1) {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.shareImage = imageSource;
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

//点击图片
- (void)photoButtonClicked:(UIButton*)sender{
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = YES;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.autoPlayOnAppear = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:sender.tag];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.model){
        return 2;
    }else if(_noNetWork == YES){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model){
        NSInteger num = 0;
        if(indexPath.row == 0){
            num = self.model.getmycoffeecnt.integerValue;
        }else{
            num = self.model.mygetcnt.integerValue;
        }
        if(num){
            return 121;
        }else{
            return 65;
        }
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model){
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        
        NSArray *array;
        NSInteger newMessageNum = 0;
        NSInteger getCoffeeNum = 0;
        
        if(indexPath.row == 0){
            array = self.model.getmycoffeephoto;
            newMessageNum = self.model.getmycoffeemsgcnt.integerValue;
            getCoffeeNum = self.model.getmycoffeecnt.integerValue;
        }else{
            array = self.model.mygetphoto;
            newMessageNum = self.model.mygetmsgcnt.integerValue;
            getCoffeeNum = self.model.mygetcnt.integerValue;
        }
        if(array.count){
            UILabel *label = [UILabel createLabel:CGRectMake(16, 15, WIDTH-40, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:KTextColor];
            if(indexPath.row == 0){
                label.text = [NSString stringWithFormat:@"%ld人领取了我的“人脉咖啡”", (long)getCoffeeNum];
            }else{
                label.text = [NSString stringWithFormat:@"我领取了%ld杯“人脉咖啡”", (long)getCoffeeNum];
            }
            [cell.contentView addSubview:label];
            
            CGRect frame = CGRectMake(16, 54, 46, 46);
            for(int i = 0; i<array.count; i++){
                NSDictionary *userDict = array[i];
                NSString *imageUrl = [CommonMethod paramStringIsNull:userDict[@"image"]];
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
                [CALayer updateControlLayer:imageView.layer radius:23 borderWidth:2 borderColor:WHITE_COLOR.CGColor];
                [cell.contentView addSubview:imageView];
                if(i == 5){
                    imageView.image = kImageWithName(@"icon_index_rmgd");
                    break;
                }else{
                    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KHeadImageDefaultName(userDict[@"realname"])];
                }
                frame.origin.x += 36;
            }
            if(!newMessageNum){
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 69, 8, 15)];
                imageView.image = kImageWithName(@"icon_next_gray");
                [cell.contentView addSubview:imageView];
            }else{
                UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-42, 62, 26, 26) backColor:HEX_COLOR(@"E24943") textColor:WHITE_COLOR test:[NSString stringWithFormat:@"%ld",(long)newMessageNum] font:13 number:1 nstextLocat:NSTextAlignmentCenter];
                [CALayer updateControlLayer:numLabel.layer radius:13 borderWidth:0 borderColor:WHITE_COLOR.CGColor];
                [cell.contentView addSubview:numLabel];
            }
        }else{
            UILabel *label = [UILabel createLabel:CGRectMake(16, 10, WIDTH-40, 45) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
            if(indexPath.row == 0){
                label.text = @"还没有人领取过我的“人脉咖啡”";
            }else{
                label.text = @"我还没有领取过“人脉咖啡”";
            }
            [cell.contentView addSubview:label];
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, getCoffeeNum?120.5:64.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        return cell;
    }else{//if(_noNetWork == YES)
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.model){
        NSInteger num = 0;
        if(indexPath.row == 0){
            num = self.model.getmycoffeecnt.integerValue;
        }else{
            num = self.model.mygetcnt.integerValue;
        }
        if(num){
            MyGetCoffeeViewController *vc = [CommonMethod getVCFromNib:[MyGetCoffeeViewController class]];
            vc.isMygetCoffee = indexPath.row;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        [self loadHttpData];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.contentOffset.y < -_offsetY) {
        self.tableView.scrollEnabled = NO;
        [self.tableView setContentOffset:CGPointMake(0, -_offsetY)];
        self.tableView.scrollEnabled = YES;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.model.image.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSURL *url = [NSURL URLWithString:self.model.image[index]];
    MWPhoto *photo = [MWPhoto photoWithURL:url];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
