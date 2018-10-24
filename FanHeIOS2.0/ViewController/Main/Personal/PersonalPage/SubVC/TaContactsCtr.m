//
//  TaContactsCtr.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/12.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//
#import "TaContactsCtr.h"
#import "NONetWorkTableViewCell.h"
#import "LookHistoryCell.h"
#import "ComFriendsController.h"

@interface TaContactsCtr (){
    BOOL _clickedBtn;//是否点击按钮切换
}

@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) NSMutableArray *taAttionArray;
@property (nonatomic,strong) NSMutableArray *attionTaArray;

@property (nonatomic,assign) NSInteger taAttPage;
@property (nonatomic,assign) NSInteger attTaPage;
@property (nonatomic,assign) NSInteger locationInt;
@property (nonatomic,assign) BOOL  netWorkStat;
@property (nonatomic,strong) NSMutableArray *totalArray;
@property (nonatomic,strong) LookHistoryModel *lookModel;
@property (nonatomic,strong) NSMutableArray *imageArray;
@end

@implementation TaContactsCtr

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.totalArray = [NSMutableArray new];
    self.attTaPage = 1;
    self.taAttPage = 1;
    
    [self createCustomNavigationBar:@"Ta的人脉"];
    [self initTableView:CGRectMake(0,64, WIDTH,HEIGHT - 64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getComFriendsNumber];
    [self taAttionPeopleData:self.taAttPage];
}

#pragma mark - 好友数头像
- (void)getComFriendsNumber{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId,(long)self.userID.integerValue] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_COMFRIENDS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        NSLog(@"%@",responseObject);
        NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
        self.imageArray = dict[@"list"];
        [self createrTATabBerView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [self createrTATabBerView];
    }];
}

#pragma mark -------  创建导航
- (void)createrTATabBerView{
    CGFloat tapHeigth = 44;
    CGFloat heigthView = WIDTH + tapHeigth + 5;
    if (self.comfriendnum.integerValue > 0) {
        tapHeigth = 134;
        heigthView = WIDTH + 134 + 5;
    }else{
        heigthView = WIDTH+5;
    }
    
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, heigthView) backColor:@"FFFFFF"];
    self.tableView.tableHeaderView = view;
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH,WIDTH)];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",NET_RELATION_URL,self.userID]]]];
    [view addSubview:webview];
    
    if(self.comfriendnum.integerValue > 0){
        UIView *comFriendView = [NSHelper createrViewFrame:CGRectMake(0, WIDTH, WIDTH, tapHeigth) backColor:@"FFFFFF"];
        UITapGestureRecognizer *comTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoComFriend)];
        view.userInteractionEnabled = YES;
        if (self.comfriendnum.integerValue > 0) {
            [view addGestureRecognizer:comTap];
        }
        [view addSubview:comFriendView];
        
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0.5, WIDTH - 32, 0.5)];
        lineLabel.backgroundColor = HEX_COLOR(@"D9D9D9");
        [comFriendView addSubview:lineLabel];
        
        UILabel *label = [UILabel createLabel:CGRectMake(16, 17, WIDTH - 31, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        label.text = [NSString stringWithFormat:@"你们在“3号圈”有%ld位共同好友",self.comfriendnum.integerValue];
        [comFriendView addSubview:label];
        NSInteger index = self.imageArray.count;
        if (index > 0) {
            if (index >= 7) {
                index = 6;
            }
            for (NSInteger i = 0; i< index; i++) {
                NSDictionary *userDict = self.imageArray[i];
                UIImageView *headerHimageView = [UIImageView drawImageViewLine:CGRectMake(16+36*i, 60, 44, 44) bgColor:[UIColor clearColor]];
                if(self.imageArray.count >= 7) {
                    if (i == 5) {
                        headerHimageView.image = [UIImage imageNamed:@"icon_zy_more"];
                    }else{
                        [headerHimageView sd_setImageWithURL:[NSURL URLWithString:userDict[@"image"]] placeholderImage:KHeadImageDefaultName(userDict[@"realname"])];
                    }
                }else{
                    [headerHimageView sd_setImageWithURL:[NSURL URLWithString:userDict[@"image"]] placeholderImage:KHeadImageDefaultName(userDict[@"realname"])];
                }
                [CALayer updateControlLayer:headerHimageView.layer radius:22 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
                [comFriendView addSubview:headerHimageView];
            }
        }
        UIImageView *regitImage = [UIImageView drawImageViewLine:CGRectMake(WIDTH - 25, 74, 9, 15) bgColor:[UIColor clearColor]];
        if (self.comfriendnum.integerValue <= 0) {
            label.text = @"你们没有共同好友";
            regitImage.frame = CGRectMake(WIDTH - 25, 17, 9, 15);
        }
        regitImage.image = [UIImage imageNamed:@"icon_next_small"];
        [comFriendView addSubview:regitImage];
    }
    
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, heigthView - 5 , WIDTH, 5) backColor:@"EFEFF4"];
    [view addSubview:backView];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [backView addSubview:lineLabel];
    self.tableView.tableFooterView = [[UIView alloc]init];
}

- (void)gotoComFriend{
    ComFriendsController *comfriends = [[ComFriendsController alloc]init];
    comfriends.userID = self.userID;
    [self.navigationController pushViewController:comfriends animated:YES];
}

- (void)backTaBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- UITableViewDelegate
//数据源方法的实现
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSMutableArray *array;
    if (self.type == TaAttionStat) {
        array = self.taAttionArray;
    }else if (self.type == AttionTaStant) {
        array = self.attionTaArray;
    }
    if(array){
        return 1;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *array;
    if (self.type == TaAttionStat) {
        array = self.taAttionArray;
    }else if (self.type == AttionTaStant) {
        array = self.attionTaArray;
    }
    if(array.count){
        return array.count;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array;
    if (self.type == TaAttionStat) {
        array = self.taAttionArray;
    }else if (self.type == AttionTaStant) {
        array = self.attionTaArray;
    }
    if(array.count){
        return 74;
    }else{
        return 350;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array;
    if (self.type == TaAttionStat) {
        array = self.taAttionArray;
    }else if (self.type == AttionTaStant) {
        array = self.attionTaArray;
    }
    if(array.count){
        static NSString *cellReID = @"cellReID";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([LookHistoryCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.lookModel = array[indexPath.row];
        [cell lookHistoryModel:self.lookModel];
        return cell;
    }else if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        return cell;
    }else{
        static NSString *cellID = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UIView *cellView;
        if(self.type == TaAttionStat){
            cellView = [self createrNotDataImage:@"icon_warn_attention" labelText:@"暂无Ta关注的"];
        }else{
            cellView = [self createrNotDataImage:@"icon_warn_follow" labelText:@"暂无关注Ta的"];
        }
        [cell.contentView addSubview:cellView];
        return cell;
    }
}

//组头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

//创建组头视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIControl *view = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 50)];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    NSArray *array = @[@"Ta关注的",@"关注Ta的"];
    for (int i = 0; i<array.count; i++){
        CGRect frame = CGRectMake(WIDTH/array.count*i, 0, WIDTH/array.count ,49);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame  = frame;
        [btn setTitleColor:[UIColor colorWithHexString:@"AFB6C1"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"41464E"] forState:UIControlStateSelected];
        [btn setTitle:array[i] forState:UIControlStateNormal];
        [view addSubview:btn];
        btn.backgroundColor = [UIColor whiteColor];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        //间隔线
        btn.tag = i;
        
        //btn下面的线条
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(WIDTH/2*i, 49.5, WIDTH/2, 0.5)];
        lineView1.backgroundColor = [UIColor colorWithHexString:@"d7d7d7"];;
        [view addSubview:lineView1];
        
        //btn下面的线条
        UIView *lineView = [[UIView alloc]init];
        lineView.backgroundColor = kDefaultColor;
        lineView.tag = 101;
        [view addSubview: lineView];
        if (self.locationInt == i){
            lineView.frame =  CGRectMake(WIDTH/2*self.locationInt, 49, WIDTH/2 ,1);
            btn.selected = YES;
            self.type = self.locationInt;
        }
    }
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array;
    if (self.type == TaAttionStat) {
        array = self.taAttionArray;
    }else if (self.type == AttionTaStant) {
        array = self.attionTaArray;
    }
    if(array.count){
        ContactsModel *model = array[indexPath.row];
        NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
        myHome.userId = model.userid;
        [self.navigationController pushViewController:myHome animated:YES];
    }else if(self.netWorkStat){
        if(self.type == TaAttionStat) {
            [self taAttionPeopleData:self.taAttPage];
        }else {
            [self attionTaPeopeleData:self.attTaPage];
        }
    }
}

- (void)clickBtn:(UIButton *)btn{
    _clickedBtn = YES;
    self.locationInt = btn.tag;
    UIView *lineView = [btn.superview viewWithTag:101];
    lineView.frame =  CGRectMake(WIDTH/2*self.locationInt, 49, WIDTH/2 ,1);
    for (UIView *sub in btn.superview.subviews){
        if ([sub isKindOfClass:[UIButton class]]){
            UIButton *lbtn = (UIButton *)sub;
            lbtn.selected = NO;
        }
    }
    btn.selected = YES;
    if (btn.tag == 0){
        self.type = TaAttionStat;
        [self taAttionPeopleData:self.taAttPage];
    }else if (btn.tag == 1){
        self.type = AttionTaStant;
        [self attionTaPeopeleData:self.attTaPage];
    }
}

#pragma mark ----- 他关注的
- (void)taAttionPeopleData:(NSInteger)pager{
    self.netWorkStat = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.taAttPage == 1) {
        [self.taAttionArray removeAllObjects];
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%ld/%ld",(long)self.userID.integerValue,(long)pager] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_HIS_PEOPLE_HIS_ATTENTION paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(self.taAttionArray==nil){
            self.taAttionArray = [NSMutableArray new];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                weakSelf.lookModel = [[LookHistoryModel alloc] initWithDict:subDic];
                [self.taAttionArray addObject:weakSelf.lookModel];
            }
            if (self.taAttionArray.count < self.hisattentionnum.integerValue && subArray.count){
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_footer removeFromSuperview];
                [self.tableView tableViewAddUpLoadRefreshing:^{
                    if (self.type == TaAttionStat) {
                        self.taAttPage ++;
                        [self taAttionPeopleData:self.taAttPage];
                    }
                }];
            }else{
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_footer removeFromSuperview];
            }
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        if(_clickedBtn){
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y>self.tableView.tableHeaderView.frame.size.height?self.tableView.tableHeaderView.frame.size.height:self.tableView.contentOffset.y) animated:YES];
            _clickedBtn = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(self.taAttionArray==nil){
            self.taAttionArray = [NSMutableArray new];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        self.netWorkStat = YES;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        if(_clickedBtn){
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y>self.tableView.tableHeaderView.frame.size.height?self.tableView.tableHeaderView.frame.size.height:self.tableView.contentOffset.y) animated:YES];
            _clickedBtn = NO;
        }
    }];
}

#pragma mark ------- 关注Ta的
- (void)attionTaPeopeleData:(NSInteger)pager{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (self.attTaPage == 1) {
        [self.attionTaArray removeAllObjects];
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%ld/%ld",(long)self.userID.integerValue,(long)pager] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_HIS_PEOPLE_ATTENTION_HE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(self.attionTaArray==nil){
            self.attionTaArray = [NSMutableArray new];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                weakSelf.lookModel = [[LookHistoryModel alloc] initWithDict:subDic];
                [self.attionTaArray addObject:weakSelf.lookModel];
            }
            if (self.attionTaArray.count < self.attentionhenum.integerValue && subArray.count) {
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_footer removeFromSuperview];
                [self.tableView tableViewAddUpLoadRefreshing:^{
                    if (self.type == AttionTaStant) {
                        self.attTaPage ++;
                        [self attionTaPeopeleData:self.attTaPage];
                    }
                }];
            }else{
                [self.tableView.mj_footer endRefreshing];
                [self.tableView.mj_footer removeFromSuperview];
            }
        }
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        if(_clickedBtn){
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y>self.tableView.tableHeaderView.frame.size.height?self.tableView.tableHeaderView.frame.size.height:self.tableView.contentOffset.y) animated:YES];
            _clickedBtn = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(self.attionTaArray==nil){
            self.attionTaArray = [NSMutableArray new];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        self.netWorkStat = YES;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
        if(_clickedBtn){
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y>self.tableView.tableHeaderView.frame.size.height?self.tableView.tableHeaderView.frame.size.height:self.tableView.contentOffset.y) animated:YES];
            _clickedBtn = NO;
        }
    }];
    
}
- (UIView*)createrNotDataImage:(NSString *)image labelText:(NSString *)text{
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 350) backColor:@"FFFFFF"];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 0.5) backColor:@"d9d9d9"];
    [view addSubview:lineView];
    
    UIImageView *notDataImageView = [[UIImageView alloc]initWithFrame:CGRectMake(WIDTH/2 - 37.5, 60, 75, 75)];
    
    notDataImageView.image = [UIImage imageNamed:image];
    [view addSubview:notDataImageView];
    
    UILabel *notDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 165, WIDTH, 18)];
    notDataLabel.text = text;
    notDataLabel.textColor = [UIColor colorWithHexString:@"818C9E"];
    notDataLabel.font = [UIFont systemFontOfSize:17];
    notDataLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:notDataLabel];
    return view;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%lf", scrollView.contentOffset.y);
    if (self.tableView.contentOffset.y < 0) {
        self.tableView.scrollEnabled = NO;
        [self.tableView setContentOffset:CGPointMake(0, 0)];
    }else{
        self.tableView.scrollEnabled = YES;
    }
}

@end
