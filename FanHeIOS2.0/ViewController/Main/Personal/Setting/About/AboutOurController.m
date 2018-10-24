

//
//  AboutOurController.m
//  JinMai
//
//  Created by renhao on 16/5/11.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "AboutOurController.h"
//#import "BannerDetailViewController.h"
#import "PolicyShowView.h"

@interface AboutOurController ()
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) NSMutableArray        *sourcceArray;
@end

@implementation AboutOurController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(@"f7f7f7");
    [self createCustomNavigationBar:@"关于3号圈"];
    
    self.dataArray = [NSMutableArray arrayWithObjects:@[@"官方网站",@"微信公众号",@"客服电话"], nil];
    self.sourcceArray  = [NSMutableArray arrayWithObjects:@[@"www.51jinmai.com",@"jinmaicafe",@"400-1799-686"], nil];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-70)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HEX_COLOR(@"f7f7f7");
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 150)];
    imageView.image = [UIImage imageNamed:@"logo_jinmai+_s"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = kBackgroundColorDefault;
    UILabel *versionLabel = [UILabel createLabel:CGRectMake(0, 127, WIDTH, 15) font:FONT_SYSTEM_SIZE(13) bkColor:nil textColor:HEX_COLOR(@"999999")];
    versionLabel.text = [NSString stringWithFormat:@"版本号 %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:versionLabel];
    self.tableView.tableHeaderView = imageView;
    
    UILabel *footrLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, HEIGHT- 47, WIDTH-24, 37)];
    footrLabel.numberOfLines = 2;
    footrLabel.text = @"上海泛合投资股份有限公司 版权所有\n©2016 51jinmai.com All Rights Reserverd";
    footrLabel.textAlignment = NSTextAlignmentCenter;
    footrLabel.textColor = HEX_COLOR(@"999999");
    footrLabel.font = FONT_SYSTEM_SIZE(13);
    [self.view addSubview:footrLabel];
    
    UIButton *policyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [policyButton setTitle:@"服务协议" forState:UIControlStateNormal];
    [policyButton setTitleColor:kDefaultColor forState:UIControlStateNormal];
    policyButton.titleLabel.font = FONT_SYSTEM_SIZE(13);
    policyButton.frame = CGRectMake(0, HEIGHT-70, WIDTH, 20);
    [policyButton addTarget:self action:@selector(lookPolicyViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:policyButton];
}

- (void)lookPolicyViewClicked:(UIButton*)sender {
    PolicyShowView *policyView = [CommonMethod getViewFromNib:NSStringFromClass([PolicyShowView class])];
    policyView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [[UIApplication sharedApplication].keyWindow addSubview:policyView];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSMutableArray*)self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return 0;
    }
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    headerView.backgroundColor = HEX_COLOR(@"f7f7f7");
    return headerView;
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
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 54.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = HEX_COLOR(@"D9D9D9");
    [cell.contentView addSubview:lineLabel];
    if (indexPath.section == 0){//1
        if (indexPath.row == 0){
            UILabel *lineLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
            lineLabel2.backgroundColor = HEX_COLOR(@"D9D9D9");
            [cell.contentView addSubview:lineLabel2];
        }
        if (indexPath.row == 3){
            UILabel *lineLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 54.5, WIDTH, 0.5)];
            lineLabel1.backgroundColor = HEX_COLOR(@"D9D9D9");
            [cell.contentView addSubview:lineLabel1];
        }
    }
    
    cell.textLabel.font = FONT_SYSTEM_SIZE(18);
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    cell.textLabel.textColor = HEX_COLOR(@"818C9E");
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-24, 20, 9, 15)];
    arrowImageView.image = kImageWithName(@"next_arrow");
    [cell.contentView addSubview:arrowImageView];
   
    UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15,WIDTH- 30, 25)];
    sizeLabel.textAlignment = NSTextAlignmentRight;
    sizeLabel.text = self.sourcceArray[indexPath.section][indexPath.row];
    sizeLabel.tag = indexPath.row;
    sizeLabel.textColor = HEX_COLOR(@"41464E");
    sizeLabel.font = FONT_SYSTEM_SIZE(18);

    [cell.contentView addSubview:sizeLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.51jinmai.com"]];
        }else if (indexPath.row == 1) {
            [MBProgressHUD showSuccess:@"已成功复制微信公众号" toView:nil];
            UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
            
            [generalPasteBoard setString: self.sourcceArray[indexPath.section][indexPath.row]];
        }else if (indexPath.row == 2){
            NSString *str = [NSString stringWithFormat:@"tel:%@",self.sourcceArray[indexPath.section][indexPath.row]];
            UIWebView *callWebView = [[UIWebView alloc]init];
            [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebView];
        }
    }
}

//去掉UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 10;//section的高度
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0){
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }else if (scrollView.contentOffset.y>=sectionHeaderHeight){
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
