//
//  WallCofferController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "WallCofferController.h"
#import "CoffeeHelpViewController.h"
#import "MycofferCell.h"
#import "CofferNopeopleCell.h"
#import "ContactsModel.h"
#import "NONetWorkTableViewCell.h"
#import "GetWallCoffeeDetailViewController.h"

@interface WallCofferController ()
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *helpBtn;
@property (nonatomic,strong) UILabel *titleTabBaeLabel;
@property (nonatomic,strong) UILabel *peopleLabel;
@property (nonatomic, strong)NSNumber *getCofferCount;
@property (nonatomic,strong) UIView *getCoffView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger currentPag;
@property (nonatomic,strong) UIView *backHeaderView;
@property (nonatomic,assign) BOOL  netWorkStat;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) NSNumber *coffeegetid;
@end

@implementation WallCofferController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView:CGRectMake(0, 64, WIDTH,HEIGHT-64)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentPag = 1;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        self.currentPag ++;
        [self getTaCofferInformation:self.currentPag];
    }];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        self.currentPag = 1;
        [self getTaCofferInformation:self.currentPag];
    }];
    [self createrTabBerView];
    [self getTaCofferInformation:self.currentPag];
    
}
#pragma mark --- 网络请求数据
- (void)getTaCofferInformation:(NSInteger)page{
    self.netWorkStat = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.currentPag == 1) {
        [self.dataArray removeAllObjects];
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld/%ld", [DataModelInstance shareInstance].userModel.userId,(long)self.userID.integerValue,(long)self.currentPag] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_HIS_READ_COFF_MSG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(self.dataArray==nil){
            self.dataArray = [NSMutableArray new];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSArray *subArray = [CommonMethod paramArrayIsNull:[dict objectForKey:@"gethisuser"]];
            for (NSDictionary *subDic in subArray) {
                ContactsModel *coffModel = [[ContactsModel alloc] initWithDict:subDic];
                [self.dataArray addObject:coffModel];
            }
            if(subArray.count){
                [self.tableView endRefresh];
            }else{
                [self.tableView endRefreshNoData];
            }
            self.getCofferCount = dict[@"gethecoffeecnt"];
            self.coffeegetid = dict[@"coffeeid"];
            NSNumber *index = dict[@"hasget"];
            if (index.integerValue == 1) {
                [self cretaerMyGetCoff];
                self.timeLabel.text =  dict[@"mygettime"];
            }
            
            if(self.getCofferCount.integerValue == 0) {
                self.tableView.userInteractionEnabled = NO;
                self.getCoffView.hidden = YES;
                self.tableView.tableHeaderView = [UIView new];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *str = [NSString stringWithFormat:@"%ld人",(long)self.getCofferCount.integerValue];
                    self.peopleLabel.attributedText = [self tranferStr:str];
                });
            }
            
            [self headerTabVIew];
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(self.dataArray==nil){
            self.dataArray = [NSMutableArray new];
        }
        [self.tableView endRefresh];
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        self.netWorkStat = YES;
        [self.tableView reloadData];
    }];
    
}

#pragma mark -------  创建导航
- (void)createrTabBerView{
    self.backHeaderView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    self.backHeaderView.backgroundColor = HEX_COLOR(@"E24943");
    [self.view addSubview:self.backHeaderView];
    
    self.backBtn = [NSHelper createButton:CGRectMake(0, 20, 44, 44) title:nil unSelectImage:[UIImage imageNamed:@"btn_reture_white"] selectImage:nil target:self selector:@selector(backTaBtnAction)];
    
    [self.backHeaderView addSubview:self.backBtn];
    
    self.helpBtn = [NSHelper createButton:CGRectMake(WIDTH - 60 , 32, 40, 18) title:@"帮助" unSelectImage:nil selectImage:nil target:self selector:@selector(helpBtnAction)];
    [self.helpBtn setTitle:@"帮助" forState:UIControlStateNormal];
    [self.helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backHeaderView addSubview:self.helpBtn];
    self.titleTabBaeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 26, WIDTH, 30)];
    self.titleTabBaeLabel.text = @"人脉咖啡";
    self.titleTabBaeLabel.textColor = [UIColor whiteColor];
    self.titleTabBaeLabel.textAlignment = NSTextAlignmentCenter;
    [self.backHeaderView addSubview:self.titleTabBaeLabel];
}

- (void)headerTabVIew{
    self.headerView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 155) backColor:@"E24943"];
    self.tableView.tableHeaderView = self.headerView;
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 50, 54, 54)];
    iconImageView.image = [UIImage imageNamed:@"icon_coffee_white_have"];
    [self.headerView addSubview:iconImageView];
    UILabel *peopleCountlabel = [[UILabel alloc]initWithFrame:CGRectMake(88, 83, WIDTH - 88 - 24, 18)];
    peopleCountlabel.text = @"领取了Ta的人脉咖啡";
    peopleCountlabel.font = [UIFont systemFontOfSize:18];
    peopleCountlabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:peopleCountlabel];
    
    self.peopleLabel = [[UILabel alloc]initWithFrame:CGRectMake(88, 50, WIDTH - 88 - 25, 28)];
    self.peopleLabel.font = [UIFont systemFontOfSize:28];
    self.peopleLabel.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.peopleLabel];
}

- (void)cretaerMyGetCoff{
    self.headerView.frame = CGRectMake(0, 0, WIDTH, 155+57);
    
    self.tableView.tableHeaderView = self.headerView;
    self.getCoffView = [NSHelper createrViewFrame:CGRectMake(0, 155, WIDTH,  57) backColor:@"FFFFFF"];
    [self.headerView addSubview:self.getCoffView];
    
    UIImageView *coffIamge = [UIImageView drawImageViewLine:CGRectMake(19, 19, 15, 15) bgColor:[UIColor clearColor]];
    coffIamge.image = [UIImage imageNamed:@"icon_coffee_receive"];
    [self.getCoffView addSubview:coffIamge];
    UILabel *getLabel = [UILabel createLabel:CGRectMake(37, 19, 65, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    getLabel.text = @"您已领取";
    [self.getCoffView addSubview:getLabel];
    self.timeLabel = [UILabel createLabel:CGRectMake(WIDTH - 190, 19, 167, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.getCoffView addSubview:self.timeLabel];
    UIImageView *leftIamge = [UIImageView drawImageViewLine:CGRectMake(WIDTH - 16, 21, 6, 10) bgColor:[UIColor clearColor]];
    leftIamge.image = [UIImage imageNamed:@"icon_next_gray"];
    [self.getCoffView addSubview:leftIamge];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 52, WIDTH, 5) backColor:@"EFEFF4"];
    [self.getCoffView addSubview:lineView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getCofferDetail)];
    [self.getCoffView addGestureRecognizer:tap];
}

//领取详情
- (void)getCofferDetail{
    GetWallCoffeeDetailViewController *getCoff =[[GetWallCoffeeDetailViewController alloc]init];
    getCoff.coffeegetid = self.coffeegetid;
    getCoff.isMygetCoffee = YES;
    [self.navigationController pushViewController:getCoff animated:YES];
}

- (void)backTaBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------  帮助按钮
- (void)helpBtnAction{
    CoffeeHelpViewController *iden = [[CoffeeHelpViewController alloc]init];
    [self.navigationController pushViewController:iden animated:YES];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.dataArray == nil){
        return 0;
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray.count){
        return self.dataArray.count;
    }else if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else if (self.getCofferCount.integerValue == 0){
        return 1;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else if (self.getCofferCount.integerValue == 0){
        return tableView.frame.size.height;
    }else{
        ContactsModel *model = self.dataArray[indexPath.row];
        return [MycofferCell tableFrameBackCellHeigthContactsModel:model];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else if(self.getCofferCount.integerValue != 0){
        static NSString *cellID = @"MycofferCell";
        MycofferCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([MycofferCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ContactsModel *model = self.dataArray[indexPath.row];
        [cell myRelationFriendContactsModel:model];
        return cell;
    }else{
        static NSString *string = @"FriendsCell";
        CofferNopeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
        if (!cell){
            cell = [CommonMethod getViewFromNib:NSStringFromClass([CofferNopeopleCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        [self getTaCofferInformation:self.currentPag];
        return;
    }
    if (self.getCofferCount.integerValue == 0) {
        return;
    }
    ContactsModel *model = self.dataArray[indexPath.row];
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = model.userid;
    [self.navigationController pushViewController:myHome animated:YES];
}

- (NSMutableAttributedString *)tranferStr:(NSString *)str{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0] range:NSMakeRange(str.length - 1, 1)];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:WHITE_COLOR range:NSMakeRange(0, str.length)];
    return AttributedStr;
}

#pragma mark -------- 导航颜色变化
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.y<0){
        scrollView.scrollEnabled = NO;
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        scrollView.scrollEnabled = YES;
    }else{
        scrollView.scrollEnabled = YES;
    }
}


@end
