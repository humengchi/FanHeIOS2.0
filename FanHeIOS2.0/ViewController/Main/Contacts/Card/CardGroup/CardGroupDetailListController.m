//
//  CardGroupDetailListController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardGroupDetailListController.h"
#import "NODataTableViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "CardListCell.h"
#import "CardGroupViewController.h"
#import "CardDetailViewController.h"

@interface CardGroupDetailListController (){
    BOOL _noNetWork;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation CardGroupDetailListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getCardGroupDetailHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:self.model.groupname];
    _noNetWork = NO;
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - 获取我的分组详情列表
- (void)getCardGroupDetailHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, self.model.groupid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USET_GROUPCARDLIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }else{
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                CardScanModel *model = [[CardScanModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 删除名片
- (void)deleteCardHttpData:(NSInteger)row{
    CardScanModel *model = self.dataArray[row];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, model.cardId] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_DELCARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.dataArray removeObjectAtIndex:row];
            if(weakSelf.dataArray.count){
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.dataArray){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 65;
    }else{
        return HEIGHT-64;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"CardListCell";
        CardListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"CardListCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplay:self.dataArray[indexPath.row]];
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
        cell.coverImageView.image = kImageWithName(@"icon_warm_oncard");
        cell.mainLabel.text = @"暂无分组名片";
        cell.subLabel.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork&&self.dataArray.count==0){
    }
    CardScanModel *model = self.dataArray[indexPath.row];
    if(model.cardId.integerValue){
        CardDetailViewController *vc = [CommonMethod getVCFromNib:[CardDetailViewController class]];
        vc.cardId = model.cardId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    CardScanModel *model = self.dataArray[indexPath.row];
    if(model.cardId.integerValue && !model.ismycard.integerValue){
        __weak typeof(self) weakSelf = self;
        NSMutableArray *array = [NSMutableArray array];
        for(int i=0; i<4; i++){
            __block NSInteger tag = i;
            UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"       " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf tapRowAction:indexPath.row type:tag];
            }];
            rowAction.backgroundColor = HEX_COLOR(@"afb6c1");
            [array addObject:rowAction];
        }
        return array;
    }else{
        return @[];
    }
}

- (void)tapRowAction:(NSInteger)row type:(NSInteger)type{
    CardScanModel *model = self.dataArray[row];
    if(type==0){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否删除该名片" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        } confirm:^{
            [self deleteCardHttpData:row];
        }];
    }else if(type==1){
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        CardGroupViewController *vc = [CommonMethod getVCFromNib:[CardGroupViewController class]];
        vc.isShowGroupList = NO;
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(type==2){
        if(model.phone.length==0){
            [self.view showToastMessage:@"手机号为空"];
            return;
        }
        NSString *str = [NSString stringWithFormat:@"tel:%@",model.phone];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];
    }else{
        if(model.phone.length==0){
            [self.view showToastMessage:@"手机号为空"];
            return;
        }
        [self showMessageView:[NSArray arrayWithObjects:model.phone, nil] title:@""];
    }
}

@end
