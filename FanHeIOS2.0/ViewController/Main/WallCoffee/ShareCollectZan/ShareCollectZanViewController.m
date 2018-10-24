//
//  ShareCollectZanViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ShareCollectZanViewController.h"
#import "ShareNormalView.h"

@interface ShareCollectZanViewController (){
    BOOL _noNetWork;
    NSInteger _currentPage;
}

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *leaveCoffNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *zanLabel;

@property (weak, nonatomic) IBOutlet UILabel *zanNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coffImageView;

@property (nonatomic, strong) PraiseActivityModel *paModel;
@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation ShareCollectZanViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    [self createCustomNavigationBar:@"集赞赢咖啡"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.headerView.frame = CGRectMake(0, 0, WIDTH, 453);
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadPraiseListDataHttp];
    }];
    [self loadActivityDataHttp];
}

- (void)updateHeaderView{
    self.leaveCoffNumLabel.text = [NSString stringWithFormat:@"还可获得%@杯人脉咖啡", self.paModel?self.paModel.restcoffeenum:@(10)];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 个赞", self.paModel?self.paModel.restpraisenum:@(5)]];
    [attr addAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(32)} range:NSMakeRange(0, [(self.paModel?self.paModel.restpraisenum.stringValue:@"5") length])];
    self.zanNumLabel.attributedText = attr;
    if(self.paModel.praisenum.integerValue + self.paModel.getcoffeenum.integerValue){
        NSString *text = [NSString stringWithFormat:@"已有%@人为我点赞，获得了%@杯人脉咖啡", self.paModel.praisenum, self.paModel.getcoffeenum];
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:self.paModel.praisenum.stringValue];
        [attrText setAttributes:@{NSForegroundColorAttributeName:kDefaultColor} range:range];
        NSRange range1 = [text rangeOfString:self.paModel.getcoffeenum.stringValue];
        [attrText setAttributes:@{NSForegroundColorAttributeName:kDefaultColor} range:range1];
        self.zanLabel.attributedText = attrText;
    }else{
        self.zanLabel.text = @"还没有人为你点赞";
    }
    NSInteger imageNO = 0;
    if(self.paModel.getcoffeenum.integerValue>=10){
        imageNO = 5;
    }else{
        imageNO = 5-(self.paModel?self.paModel.restpraisenum.integerValue:5);
    }
    self.coffImageView.image = kImageWithName(([NSString stringWithFormat:@"icon_coffee_dz%ld",(long)imageNO]));
}

#pragma mark -网络请求，活动信息
- (void)loadActivityDataHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_WX_ACTIVITY_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.paModel = [[PraiseActivityModel alloc] initWithDict:responseObject[@"data"]];
        }else{
            [MBProgressHUD showError:@"请求失败，请重试" toView:weakSelf.view];
            _noNetWork = YES;
        }
        [weakSelf updateHeaderView];
        [weakSelf loadPraiseListDataHttp];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        _noNetWork = YES;
        [weakSelf updateHeaderView];
        [weakSelf loadPraiseListDataHttp];
    }];
}

#pragma mark -网络请求，点赞列表
- (void)loadPraiseListDataHttp{
    if(self.listArray==nil){
        self.listArray = [NSMutableArray array];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId, _currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_WX_PRAISEME_LIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                PraiseUserModel *model = [[PraiseUserModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
            }
            if(array.count == 10){
                [weakSelf.tableView endRefresh];
                _currentPage++;
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
        }else{
            [weakSelf.tableView endRefresh];
            [MBProgressHUD showError:@"请求失败，请重试" toView:weakSelf.view];
            _noNetWork = YES;
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - method
- (IBAction)shareButtonClicked:(id)sender {
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

#pragma mark-UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.listArray == nil){
        return 0;
    }else if(self.listArray.count){
        return self.listArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        return 74;
    }else{
        return self.tableView.frame.size.height-self.headerView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    if(self.listArray.count){
        PraiseUserModel *model = self.listArray[indexPath.row];
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 44, 44)];
        [CALayer updateControlLayer:headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:model.headimg] placeholderImage:KHeadImageDefaultName(model.name)];
        [cell.contentView addSubview:headerImageView];
        
        UILabel *nameLabel = [UILabel createrLabelframe:CGRectMake(68, 28, 124, 13) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818C9E") test:model.name font:12 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:nameLabel];
        
        UILabel *timeLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-140, 28, 124, 13) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818C9E") test:model.created_at font:12 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:timeLabel];
        if(indexPath.row == 0){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 73, WIDTH-32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }else{
        UILabel *hudLabel = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 50) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:@"赶紧分享到朋友圈请朋友帮你点赞！" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:hudLabel];
    }
    return cell;
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *content = @"花一秒钟，帮我领取人脉咖啡[嘴唇]！";
    NSString *title = @"求你啦！帮我点个赞吧！";
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",WX_COLLECT_ZAN, [DataModelInstance shareInstance].userModel.userId];
    UIImage *imageSource = kImageWithName(@"icon-60");
    
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else if (index == 1) {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = contentUrl;
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.contentOffset.y < 0) {
        self.tableView.scrollEnabled = NO;
        [self.tableView setContentOffset:CGPointMake(0, 0)];
        self.tableView.scrollEnabled = YES;
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

@end
