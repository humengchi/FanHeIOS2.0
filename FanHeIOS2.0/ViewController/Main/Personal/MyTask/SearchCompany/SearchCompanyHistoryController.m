//
//  SearchCompanyHistoryController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/22.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SearchCompanyHistoryController.h"
#import "WebViewController.h"

@interface SearchCompanyHistoryController ()

@end

@implementation SearchCompanyHistoryController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"浏览历史"];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.separatorColor = kCellLineColor;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str = self.dataArray[indexPath.row];
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(17) width:WIDTH-32]+32;
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSString *str = self.dataArray[indexPath.row];
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(17) width:WIDTH-32]+32;
    UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, (NSInteger)height) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:str font:17 number:0 nstextLocat:NSTextAlignmentLeft];
    [cell.contentView addSubview:contentLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = self.dataArray[indexPath.row];
    WebViewController *vc = [[WebViewController alloc] init];
    vc.customTitle = str;
    vc.webUrl = [NSString stringWithFormat:@"%@/%@/%@", SEARCH_COMPANY_HISTORY_URL, [DataModelInstance shareInstance].userModel.userId, str];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
