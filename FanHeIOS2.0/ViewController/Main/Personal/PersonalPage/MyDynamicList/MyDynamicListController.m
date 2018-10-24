//
//  MyDynamicListController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyDynamicListController.h"
#import "DynamicCell.h"
#import "DynamicNotificationCtr.h"
#import "VariousDetailController.h"
#import "NODataTableViewCell.h"
#import "NONetWorkTableViewCell.h"

#define Cell_Index_key(index) ([NSString stringWithFormat:@"cell_%ld", (long)index])

@interface MyDynamicListController (){
    NSInteger _currentPage;
    BOOL _noNetWork;
    BOOL _isTaDynamicList;
}

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *notifBtn;
@property (nonatomic, strong) NSMutableDictionary *cellArrayDict;

@end

@implementation MyDynamicListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"reloadTableView" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTableView" object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

- (void)reloadTableView:(NSNotification *)notification{
    NSNumber *index = (NSNumber*)notification.object;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(index.integerValue>0){
            for(NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]){
                if([self.cellArrayDict.allKeys containsObject:Cell_Index_key(indexPath.row)]){
                    [self.cellArrayDict removeObjectForKey:Cell_Index_key(indexPath.row)];
                }
                
                if(indexPath.row == index.integerValue){
                    [self.tableView reloadData];
//                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    });
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellArrayDict = [NSMutableDictionary dictionary];
    if(self.userID.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        self.titleLabel.text = @"我的动态";
        self.notifBtn.hidden = NO;
    }else{
        self.titleLabel.text = @"Ta的动态";
        _isTaDynamicList = YES;
        self.notifBtn.hidden = YES;
    }
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        _currentPage += 1;
        [self loadHttpDynamicListData];
    }];
    _currentPage = 1;
    [self loadHttpDynamicListData];
}

//点击消息通知，进入通知列表
- (IBAction)gotoNoticeVC:(id)sender{
    DynamicNotificationCtr *vc = [[DynamicNotificationCtr alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [[AppDelegate shareInstance] showUnreadCountViewItemNO:0 unReadCountSum:0];
}

//返回
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -获取首页数据(新的接口)
- (void)loadHttpDynamicListData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(_currentPage==1){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@",self.userID, [DataModelInstance shareInstance].userModel.userId,@(_currentPage)] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMIC_MY_DYNAMIC paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(!weakSelf.listArray){
            weakSelf.listArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            NSInteger row = 0;
            for(NSDictionary *dict in array){
                DynamicModel *model = [[DynamicModel alloc] initWithDict:dict cellTag:row];
                model.isTaDynamicList = _isTaDynamicList;
                [weakSelf.listArray addObject:model];
                row++;
            }
            if(array.count){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
        }else{
            [weakSelf.tableView endRefresh];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        _noNetWork = YES;
        if(!weakSelf.listArray){
            weakSelf.listArray = [NSMutableArray array];
        }
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.listArray){
        return 0;
    }else if(self.listArray.count){
        return self.listArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        DynamicModel *model = self.listArray[indexPath.row];
        return model.cellHeight;
    }else{
        return tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        DynamicCell *cell;
        if([self.cellArrayDict.allKeys containsObject:Cell_Index_key(indexPath.row)]){
            cell = self.cellArrayDict[Cell_Index_key(indexPath.row)];
            DynamicModel *model = self.listArray[indexPath.row];
            if(!cell || ![cell isKindOfClass:[DynamicCell class]] || cell.model.dynamic_id.integerValue!= model.dynamic_id.integerValue){
                cell = nil;
            }
        }
        if(!cell){
            cell = [[DynamicCell alloc] initWithDataModel:self.listArray[indexPath.row] identifier:@"DynamicCell"];
            cell.tag = indexPath.row;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self.cellArrayDict setObject:cell forKey:Cell_Index_key(indexPath.row)];
        }
        __weak typeof(self) weakSelf = self;
        cell.refreshDynamicCell = ^(DynamicCell *dc){
            [weakSelf.cellArrayDict removeObjectForKey:Cell_Index_key(dc.tag)];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:dc.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        };
        cell.deleteDynamicCell = ^(DynamicCell *delCell){
            if(weakSelf.listArray.count > delCell.tag){
                [weakSelf.listArray removeObjectAtIndex:delCell.tag];
            }
            [weakSelf.cellArrayDict removeAllObjects];
            if(weakSelf.listArray.count){
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        };
        return cell;
    }else if(_noNetWork){
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
        cell.mainLabel.text = @"没有动态";
        cell.subLabel.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.listArray.count){
        DynamicModel *model = self.listArray[indexPath.row];
        if(model.dynamic_id.integerValue && model.parent_status.integerValue<4){
            VariousDetailController *vc = [[VariousDetailController alloc] init];
            vc.dynamicid = model.dynamic_id;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
    }
}

@end
