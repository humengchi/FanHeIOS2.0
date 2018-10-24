//
//  TicketController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketController.h"
#import "TickerCell.h"
#import "TickerDetailController.h"
@interface TicketController ()
@property (nonatomic,strong) NSMutableArray *outTickArray;
@property (nonatomic ,strong) NSMutableArray * useTickArray;
@end

@implementation TicketController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outTickArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"门票"];
    // Do any additional setup after loading the view.
    self.useTickArray = [[NSMutableArray alloc]initWithArray:self.tickerArray];
    for (TicketModel *model in self.tickerArray) {
        if (model.remainnum.integerValue == 0) {
            [self.outTickArray addObject:model];
            [self.useTickArray removeObject:model];
        }
    }
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.outTickArray.count > 0 && self.useTickArray.count > 0) {
        return 2;
    }else{
        return 1;
    }
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
            return self.useTickArray.count;
    }else{
        return self.outTickArray.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (self.useTickArray.count > 0) {
            return 57;
        }else{
            return 0;
        }
    }
    if (section == 1) {
        if (self.outTickArray.count > 0) {
            return 16.5;
        }else{
            return 0;
        }
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
      CGFloat heigth = 51;
    if (section == 1) {
           heigth = 16;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, heigth)];
    view.backgroundColor = HEX_COLOR(@"EFEFF4");
    if (self.useTickArray.count > 0 && section == 0) {
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(25, 22, WIDTH - 50, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"41464E"]];
        titleLabel.text = @"请选择门票类型：";
        [view addSubview:titleLabel];
    }
        return view;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *identify = @"TickerCell";
        TickerCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TickerCell"];
        }
        cell.array = self.useTickArray;
        cell.index = indexPath.row;
        TicketModel *model = self.useTickArray[indexPath.row];
        [cell tranferTickerCellModel:model];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        return cell;
    }else{
        static NSString *identify = @"TickerCell";
        TickerCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"TickerCell"];
        }
        cell.array = self.outTickArray;
        cell.index = indexPath.row;

        TicketModel *model = self.outTickArray[indexPath.row];
        [cell tranferTickerCellModel:model];
         cell.selectionStyle = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        TicketModel *model = self.useTickArray[indexPath.row];
        TickerDetailController *tick = [[TickerDetailController alloc]init];
        tick.model = model;
        [self.navigationController pushViewController:tick animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//去掉UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 51;//section的高度
     CGFloat Height = 16.5;//section的高度
    if ((scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0)||(scrollView.contentOffset.y<=Height&&scrollView.contentOffset.y>=0)){
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }else if ((scrollView.contentOffset.y>=sectionHeaderHeight)||(scrollView.contentOffset.y>=Height)){
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
