//
//  ApplyManagerViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplyManagerViewController.h"
#import "LookHistoryCell.h"
#import "ApplyDetailViewController.h"
#import "NONetWorkTableViewCell.h"

@interface ApplyManagerViewController ()<UIAlertViewDelegate>{
    NSInteger _currentPage;
    BOOL _noNetWork;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIView *toolView;

@end

@implementation ApplyManagerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    self.view.backgroundColor = kTableViewBgColor;
    [self createCustomNavigationBar:@"报名管理"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getHttpData];
    }];
    [self.tableView tableViewAddDownLoadRefreshing:^{
        _currentPage = 1;
        [self getHttpData];
    }];
    
    [self getHttpData];
    
    [self initToolView];
}

- (void)initToolView{
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-49, WIDTH, 49)];
    self.toolView.backgroundColor = HEX_COLOR(@"f7f7f7");
    self.toolView.hidden = YES;
    [self.view addSubview:self.toolView];
    
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn setBackgroundColor:WHITE_COLOR];
    messageBtn.frame = CGRectMake(16, 6, 130, 36);
    [messageBtn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
    [messageBtn setTitleColor:kDefaultColor forState:UIControlStateHighlighted];
    [messageBtn setTitle:@"群发短信" forState:UIControlStateNormal];
    messageBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [CALayer updateControlLayer:messageBtn.layer radius:5 borderWidth:0.3 borderColor:HEX_COLOR(@"afb6c1").CGColor];
    [messageBtn addTarget:self action:@selector(messageButtonClicekd:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:messageBtn];
    
    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailBtn setBackgroundColor:HEX_COLOR(@"1abc9c")];
    emailBtn.frame = CGRectMake(156, 6, WIDTH-156-16, 36);
    [emailBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [emailBtn setTitleColor:KTextColor forState:UIControlStateHighlighted];
    [emailBtn setTitle:@"导出名单至邮箱" forState:UIControlStateNormal];
    emailBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [CALayer updateControlLayer:emailBtn.layer radius:5 borderWidth:0 borderColor:nil];
    [emailBtn addTarget:self action:@selector(emailButtonClicekd:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:emailBtn];
}

#pragma mark - 按钮
- (void)messageButtonClicekd:(UIButton*)sender{
    NSMutableArray *array = [NSMutableArray array];
    for(LookHistoryModel *model in self.dataArray){
        if([CommonMethod paramStringIsNull:model.phone].length){
            [array addObject:model.phone];
        }
    }
    if(array.count){
        [self showMessageView:array title:@""];
    }
}

- (void)emailButtonClicekd:(UIButton*)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"导出到邮箱" message:@"请输入邮箱地址" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认导出", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtName = [alert textFieldAtIndex:0];
    txtName.placeholder = @"输入邮箱";
    [alert show];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *txtName = [alertView textFieldAtIndex:0];
    if(buttonIndex==1 && txtName.text.length){
        if([NSHelper justEmail:txtName.text]){
            [self importNameHttpData:txtName.text];
        }else{
            [MBProgressHUD showError:@"邮箱格式不正确！" toView:self.view];
        }
    }
}

#pragma mark - 管理网络请求
- (void)getHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(self.dataArray==nil){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    _noNetWork = NO;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld/1", self.activityid, _currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_APPLY_LISTNEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if(_currentPage==1){
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                LookHistoryModel *model = [[LookHistoryModel alloc] initWithDict:dict];
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
        _currentPage++;
        if(weakSelf.dataArray.count){
            weakSelf.toolView.hidden = NO;
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        _noNetWork = YES;
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

//导出到邮箱
- (void)importNameHttpData:(NSString*)email{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"导出中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.activityid, email] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_SEND_APPLYLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"导出成功" toView:weakSelf.view];
        }else{
            [MBProgressHUD showError:[CommonMethod paramStringIsNull:responseObject[@"msg"]] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil){
        return 0;
    }else if(self.dataArray.count == 0){
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else{
        return 74;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0 && _noNetWork==NO){
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-75)/2, (self.tableView.frame.size.height-40)/2-105, 75, 75)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:kImageWithName(@"icon_no_join_b")];
        [cell.contentView addSubview:imageView];
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(0, (self.tableView.frame.size.height-40)/2, WIDTH, 50) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"还没有人报名您的活动\n赶快邀请你的伙伴报名" font:17 number:2 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }else if(self.dataArray.count == 0 && _noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"LookHistoryCell";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"LookHistoryCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        LookHistoryModel *model = self.dataArray[indexPath.row];
        [cell lookHistoryModel:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArray.count){
        ApplyDetailViewController *vc = [[ApplyDetailViewController alloc] init];
        LookHistoryModel *model = self.dataArray[indexPath.row];
        vc.ordernum = model.ordernum;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.dataArray.count == 0 && _noNetWork){
        [self getHttpData];
    }
}

@end
