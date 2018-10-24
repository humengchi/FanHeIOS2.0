//
//  TicketListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketListViewController.h"
#import "TicketListCell.h"
#import "TicketPersonInfoController.h"

@interface TicketListViewController (){
    NSInteger _selectedIndex;
}

@property (nonatomic, weak) IBOutlet UILabel *numLabel;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;
@property (nonatomic, weak) IBOutlet UILabel *freeMoneyLabel;
@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) NSMutableArray *listArray;

@end

@implementation TicketListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedIndex = -1;
    [self createCustomNavigationBar:@"门票"];
    if(self.activityModel.feetype.integerValue == 3){
        self.freeMoneyLabel.hidden = NO;
    }else{
        self.freeMoneyLabel.hidden = YES;
    }
    self.listArray = [NSMutableArray array];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-64-49)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 55)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(16, 22, WIDTH-32, 17) backColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e") test:@"请选择门票类型：" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;
    
    [self loadHttpData];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", self.activityModel.activityid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_TICKET_LIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            NSInteger i = 0;
            for(NSDictionary *dict in array){
                TicketModel *model = [[TicketModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
                if (model.remainnum.integerValue && _selectedIndex==-1) {
                    _selectedIndex = i;
                }
                i++;
            }
        }
        if(weakSelf.listArray.count && _selectedIndex != -1){
            weakSelf.nextBtn.enabled = YES;
            TicketModel *model = weakSelf.listArray[_selectedIndex];
            weakSelf.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", model.price.floatValue];
        }else{
            weakSelf.moneyLabel.text = @"¥0.00";
            weakSelf.nextBtn.enabled = NO;
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView reloadData];
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
    }];
}

#pragma mark - method
- (IBAction)addButtonClicked:(UIButton*)sender{
    if (!self.listArray.count || _selectedIndex == -1) {
        return;
    }
    TicketModel *model = self.listArray[_selectedIndex];
    if(model.remainnum.intValue == -1 || self.numLabel.text.integerValue < model.remainnum.intValue){
        self.numLabel.text = [NSString stringWithFormat:@"%ld", self.numLabel.text.integerValue + 1];
        self.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", self.numLabel.text.integerValue * model.price.floatValue];
    }else{
        [self.view showToastMessage:@"已达到该票购买上限"];
    }
}

- (IBAction)subtractButtonClicked:(UIButton*)sender{
    if (!self.listArray.count || _selectedIndex == -1) {
        return;
    }
    TicketModel *model = self.listArray[_selectedIndex];
    if(self.numLabel.text.integerValue > 1){
        self.numLabel.text = [NSString stringWithFormat:@"%ld", self.numLabel.text.integerValue - 1];
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", self.numLabel.text.integerValue * model.price.floatValue];
}

- (IBAction)nextButtonClicked:(UIButton*)sender{
    __weak typeof(self) weakSelf = self;
    TicketModel *model = self.listArray[_selectedIndex];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", model.ticktid, self.numLabel.text] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_CHECK_TICKET paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            TicketPersonInfoController *vc = [CommonMethod getVCFromNib:[TicketPersonInfoController class]];
            for(InfoFieldModel *model in weakSelf.activityModel.infofields){
                model.infovalue = @"";
            }
            vc.activityModel = weakSelf.activityModel;
            vc.ticketModel = weakSelf.listArray[_selectedIndex];
            vc.ticketNum = weakSelf.numLabel.text.integerValue;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TicketListCell getCellHeight:self.listArray[indexPath.row]];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"TicketListCell";
    TicketListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"TicketListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TicketModel *model = self.listArray[indexPath.row];
    if(indexPath.row == _selectedIndex){
        [cell updateDisplay:model isSelected:YES];
    }else{
        [cell updateDisplay:model isSelected:NO];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TicketModel *model = self.listArray[indexPath.row];
    if(indexPath.row != _selectedIndex && model.remainnum.integerValue!=0){
        if(_selectedIndex >= 0){
            TicketListCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
            TicketModel *model1 = self.listArray[_selectedIndex];
            [cell updateDisplay:model1 isSelected:NO];
        }
        TicketListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell updateDisplay:model isSelected:YES];
        _selectedIndex = indexPath.row;
        self.nextBtn.enabled = YES;
        self.numLabel.text = @"1";
        self.moneyLabel.text = [NSString stringWithFormat:@"¥%.2f", model.price.floatValue];
    }
}

@end
