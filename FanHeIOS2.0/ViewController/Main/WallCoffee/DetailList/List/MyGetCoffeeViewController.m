//
//  MyGetCoffeeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyGetCoffeeViewController.h"
#import "MyGetCoffeeTableViewCell.h"
#import "CoffeeHelpViewController.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"
#import "GetWallCoffeeDetailViewController.h"

@interface MyGetCoffeeViewController (){
    NSInteger _currentPage;
    BOOL    _noNetWork;
}

@property (nonatomic, strong) NSMutableArray    *dataArray;

@end

@implementation MyGetCoffeeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
//    if(self.dataArray){
//        BOOL needLoadHttp = NO;
//        for(MyGetCoffeeModel *model in self.dataArray){
//            if(model.exchange.integerValue==0&&self.isMygetCoffee){
//                needLoadHttp = YES;
//                break;
//            }
//        }
//        if(needLoadHttp){
//            [self.dataArray removeAllObjects];
//            _currentPage = 1;
//            [self loadHttpDataMyGetCoffee];
//        }
//    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage = 1;
    if(self.isMygetCoffee){
        [self createCustomNavigationBar:@"我领取的人脉咖啡"];
    }else{
        [self createCustomNavigationBar:@"被领取的人脉咖啡"];
    }
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadHttpDataMyGetCoffee];
    }];
    
    [self loadHttpDataMyGetCoffee];
}

#pragma mark -网络请求
- (void)loadHttpDataMyGetCoffee{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSString *apiStr;
    if(self.isMygetCoffee){
        apiStr = API_NAME_USER_MY_GET_COFFEE_INFO;
    }else{
        apiStr = API_NAME_USER_GET_MYCOFFEE_INFO;
    }
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId, (long)_currentPage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:apiStr paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                MyGetCoffeeModel *model = [[MyGetCoffeeModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count){
                [weakSelf.tableView.mj_footer endRefreshing];
                _currentPage ++;
            }else{
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            [MBProgressHUD showError:@"请求失败，请重试" toView:weakSelf.view];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        [weakSelf.tableView.mj_footer endRefreshing];
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 帮助
- (IBAction)gotoHelpButtonClicked:(id)sender{
    CoffeeHelpViewController *vc = [[CoffeeHelpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray){
        return self.dataArray.count?self.dataArray.count:1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        MyGetCoffeeModel *model = self.dataArray[indexPath.section];
        return model.cellHeight;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"MyGetCoffeeTableViewCell";
        MyGetCoffeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"MyGetCoffeeTableViewCell"];
        }
        MyGetCoffeeModel *model = self.dataArray[indexPath.row];
        [(MyGetCoffeeTableViewCell*)cell updateDisplay:model isMyGetCoffee:self.isMygetCoffee];
        return cell;
    }else{
        if(_noNetWork){
            static NSString *identify = @"NONetWorkTableViewCell";
            NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            }
            return cell;
        }else{
            static NSString *identify = @"NODataTableViewCell";
            NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            }
            cell.mainLabel.text = @"暂无数据";
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArray.count){
        MyGetCoffeeModel *model = self.dataArray[indexPath.row];
        GetWallCoffeeDetailViewController *vc = [CommonMethod getVCFromNib:[GetWallCoffeeDetailViewController class]];
        vc.coffeegetid = model.coffeegetid;
        vc.isMygetCoffee = self.isMygetCoffee;
        vc.type = model.type;
        vc.replySuccess = ^(NSString *revert){
            model.revert = revert;
            MyGetCoffeeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell updateDisplay:model isMyGetCoffee:self.isMygetCoffee];
        };
        [self.navigationController pushViewController:vc animated:YES];
        if(model.type.integerValue == 1){
            model.type = @(0);
            MyGetCoffeeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell updateDisplay:model isMyGetCoffee:self.isMygetCoffee];
        }
    }else{
        [self loadHttpDataMyGetCoffee];
    }
}


@end
