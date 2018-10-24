//
//  FriendFriendsViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "FriendFriendsViewController.h"
#import "NewLookHistoryCell.h"

@interface FriendFriendsViewController (){
    NSInteger _currentPage;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation FriendFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    self.dataArray = [NSMutableArray array];
    
    [self createCustomNavigationBar:[NSString stringWithFormat:@"%@的好友",self.model.realname]];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self createTableHeaderView];
    
    [self loadHttpData];
    [self.tableView tableViewAddUpLoadRefreshing:^{
        _currentPage++;
        [self loadHttpData];
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取user列表
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", self.model.contentid, _currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_DYNAMIC_HISNEWFRIEND paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for (NSDictionary *dict in array) {
                UserModel *model = [[UserModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count==0){
                [weakSelf.tableView endRefreshNoData];
            }
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - tableviewHeader
- (void)createTableHeaderView{
    NSMutableArray *infoArray = [NSMutableArray array];
    if([CommonMethod paramStringIsNull:self.model.realname].length){
        [infoArray addObject:self.model.realname];
    }
    NSString *companyStr = [NSString stringWithFormat:@"%@%@", [CommonMethod paramStringIsNull:self.model.company],[CommonMethod paramStringIsNull:self.model.position]];
    if(companyStr.length){
        [infoArray addObject:companyStr];
    }
    NSString *contentStr = [NSString stringWithFormat:@"好友 %@ 认识了%@个新朋友。", [infoArray componentsJoinedByString:@" | "], self.model.friendcount];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:contentStr];
//    [attr addAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(14), NSForegroundColorAttributeName:HEX_COLOR(@"818c9e")} range:NSMakeRange(0, contentStr.length)];
    [attr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"3498db")} range:[contentStr rangeOfString:[infoArray componentsJoinedByString:@" | "]]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:9];
    [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contentStr.length)];
    
    CGFloat height = [attr boundingRectWithSize:CGSizeMake(WIDTH-32, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height+11)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *contentLabel = [UILabel createLabel:CGRectMake(16, 10, WIDTH-32, height) font:FONT_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e")];
    contentLabel.numberOfLines = 0;
    contentLabel.attributedText = attr;
    [CommonMethod viewAddGuestureRecognizer:contentLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoFriendHomePage)];
    [headerView addSubview:contentLabel];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - 好友的主页
- (void)gotoFriendHomePage{
    if(self.model.userid.integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.model.userid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"NewLookHistoryCell";
    NewLookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"NewLookHistoryCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updateDisplayUserModel:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserModel *userModel = self.dataArray[indexPath.row];
    if(userModel.userId.integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = userModel.userId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
