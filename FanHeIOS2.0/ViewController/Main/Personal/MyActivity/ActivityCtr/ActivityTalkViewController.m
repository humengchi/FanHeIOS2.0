//
//  ActivityTalkViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityTalkViewController.h"
#import "ActivityTalkCell.h"
#import "RichTextViewController.h"

@interface ActivityTalkViewController (){
    NSInteger _currentpage;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ActivityTalkViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentpage = 1;
    self.view.backgroundColor = kTableViewBgColor;
    [self createCustomNavigationBar:@"活动提问"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self getAskActivityDetailData];
    }];
    [self getAskActivityDetailData];
}

#pragma mark ------  获取问答列表数据
- (void)getAskActivityDetailData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.activityid,_currentpage] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_ACTIVITYASKLIST paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for(NSDictionary *dict in array){
                UserModel *model = [[UserModel alloc] initWithDict:dict];
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
        UserModel *model = self.dataArray[indexPath.row];
        return [ActivityTalkCell getCellHeight:model];
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
        UserModel *model = self.dataArray[indexPath.row];
        static NSString *identify;
        if(model.answer.length){
            identify = @"ActivityTalkCell";
        }else{
            identify = @"ActivityTalkCellReply";
        }
        ActivityTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            if(indexPath.row%2==0){
            cell = [CommonMethod getViewFromNib:identify];
            }else{
                cell = [CommonMethod getViewFromNib:identify];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.tag = indexPath.row;
        [cell updateDisplyCell:model];
        cell.selectedCell = ^(ActivityTalkCell *selectedCell){
            RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
            vc.isActivity = YES;
            UserModel *model = self.dataArray[selectedCell.tag];
            vc.model = model;
            vc.savePersonalRemark = ^(NSString *content){
                model.answer = content;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectedCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self presentViewController:vc animated: YES completion:nil];
        };
        return cell;
    }

}

@end
