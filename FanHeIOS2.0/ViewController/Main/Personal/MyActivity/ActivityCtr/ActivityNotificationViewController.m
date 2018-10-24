//
//  ActivityNotificationViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityNotificationViewController.h"
#import "ActivityNoteCell.h"

@interface ActivityNotificationViewController (){
    NSInteger _currentpage;
}

@property (nonatomic, strong) NSMutableArray *dataArray;


@end

@implementation ActivityNotificationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavigationBar:@"活动通知"];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _currentpage = 1;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getAskActivityDetailData];
    }];
    [self getAskActivityDetailData];
}

#pragma mark ------  获取问答列表数据
- (void)getAskActivityDetailData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",[DataModelInstance shareInstance].userModel.userId,_currentpage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_NOTE_LIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for(NSDictionary *dict in array){
                ActivityNoteModel *model = [[ActivityNoteModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            _currentpage++;
        }else{
            [weakSelf.tableView endRefresh];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray == nil){
        return 0;
    }else if(self.dataArray.count==0){
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0){
        return self.tableView.frame.size.height;
    }else{
        ActivityNoteModel *model = self.dataArray[indexPath.row];
        return [ActivityNoteCell getCellHeight:model];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0){
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-75)/2, (self.tableView.frame.size.height-20)/2-105, 75, 75)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:kImageWithName(@"icon_no_join_b")];
        [cell.contentView addSubview:imageView];
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(0, (self.tableView.frame.size.height-20)/2, WIDTH, 20) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"还没有人提问" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }else{
        static NSString *identify = @"ActivityNoteCell";
        ActivityNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        ActivityNoteModel *model = self.dataArray[indexPath.row];
        [cell updateDisplyCell:model];
        return cell;
    }
}

@end
