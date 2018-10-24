//
//  NeedSupplyListController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/17.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NeedSupplyListController.h"
#import "NeedAndSupplyCell.h"
#import "NONetWorkTableViewCell.h"
#import "NODataTableViewCell.h"
#import "PublishNeedSupplyController.h"
#import "VariousDetailController.h"
#import "NeedSupplyErrorView.h"

@interface NeedSupplyListController (){
    BOOL _noNetWork;
}

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *addBtn;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation NeedSupplyListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadHttpListData];
    if(self.userId.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        if(self.isNeed){
            self.titleLabel.text = @"我发布的需求";
        }else{
            self.titleLabel.text = @"我发布的供应";
        }
        self.addBtn.hidden = NO;
    }else{
        if(self.isNeed){
            self.titleLabel.text = @"Ta的需求";
        }else{
            self.titleLabel.text = @"Ta的供应";
        }
        self.addBtn.hidden = YES;
    }
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadHttpListData];
    }];
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButtonClicked:(UIButton*)sender{
    sender.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_RESTGX paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        sender.userInteractionEnabled = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSNumber *rest_times = [CommonMethod paramNumberIsNull:dic[@"rest_times"]];
            if (rest_times.integerValue > 0) {
                PublishNeedSupplyController *vc = [CommonMethod getVCFromNib:[PublishNeedSupplyController class]];
                vc.isNeed = self.isNeed;
                vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                    [weakSelf.dataArray removeAllObjects];
                    [weakSelf loadHttpListData];
                    if(weakSelf.needOrSupplyChange){
                        weakSelf.needOrSupplyChange();
                    }
                };
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
                view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                view.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                view.confirmButtonClicked = ^{
                    PublishNeedSupplyController *vc = [CommonMethod getVCFromNib:[PublishNeedSupplyController class]];
                    vc.isNeed = self.isNeed;
                    vc.publishNeedSupplySuccess = ^(BOOL isNeed) {
                        [weakSelf.dataArray removeAllObjects];
                        [weakSelf loadHttpListData];
                        if(weakSelf.needOrSupplyChange){
                            weakSelf.needOrSupplyChange();
                        }
                    };
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                [[UIApplication sharedApplication].keyWindow addSubview:view];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        sender.userInteractionEnabled = YES;
    }];
}

#pragma mark -获取数据
- (void)loadHttpListData{
    _noNetWork = NO;
    NSInteger page = self.dataArray.count/20+(self.dataArray.count%20||self.dataArray.count?1:0);
    page = page?page:1;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@",self.userId, self.isNeed?@(2):@(1),@(page)] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_HISGX paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                NeedModel *model = [[NeedModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
        }
        if(weakSelf.dataArray.count%20==0 && weakSelf.dataArray.count){
            [weakSelf.tableView endRefresh];
        }else{
            [weakSelf.tableView endRefreshNoData];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _noNetWork = YES;
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [weakSelf.tableView endRefresh];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray == nil){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return [NeedAndSupplyCell getCellHeight:self.dataArray[indexPath.row]];
    }else{
        return HEIGHT-64;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"NeedAndSupplyCell";
        NeedAndSupplyCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NeedAndSupplyCell"];
        }
        [cell updateDisplayModel:self.dataArray[indexPath.row]];
        return cell;
    }else if(_noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
        }
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, self.tableView.frame.size.height/2-34, WIDTH, 17) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
        btn.frame = CGRectMake((WIDTH-118)/2, self.tableView.frame.size.height/2, 118, 40);
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        if(self.isNeed){
            label.text = @"告诉别人我需要什么";
            [btn setTitle:@"发布需求" forState:UIControlStateNormal];
        }else{
            label.text = @"告诉别人我有什么";
            [btn setTitle:@"发布供应" forState:UIControlStateNormal];
        }
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NeedModel *model = self.dataArray[indexPath.row];
    if (self.isShare) {
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image]]];
        if (!image) {
            image = kImageWithName([DataModelInstance shareInstance].userModel.realname);
        }
        //创建多个字典
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             model.dynamic_id, @"dynamic_id",
                             model.title, @"title",
                             @"shareSupply", @"money_type_special",  [DataModelInstance shareInstance].userModel.realname, @"realName",
                             [DataModelInstance shareInstance].userModel.image, @"imageUrl",
                             nil];
        EaseMessageModel *messageModel;
        messageModel.message.ext = dic;
        
        EMMessage *message = [EaseSDKHelper sendTextMessage:@"分享一条供需：               " to:self.chartRoomId messageType:self.chatType messageExt:dic];
        message.chatType = self.chatType;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError){
            if (!aError) {
                [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [MBProgressHUD showError:@"发送失败" toView:self.view];
            }
        }];
    }else{
        VariousDetailController *vc = [CommonMethod getVCFromNib:[VariousDetailController class]];
        vc.dynamicid = model.dynamic_id;
        vc.deleteDynamicDetail = ^(NSNumber *dynamicid) {
            NSInteger index = 0;
            for(NeedModel *model in self.dataArray){
                if(model.dynamic_id.integerValue == dynamicid.integerValue){
                    break;
                }
                index++;
            }
            if(self.dataArray.count>index+1){
                [self.dataArray removeObjectAtIndex:index];
                [self.tableView reloadData];
            }
            if(self.needOrSupplyChange){
                self.needOrSupplyChange();
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

@end
