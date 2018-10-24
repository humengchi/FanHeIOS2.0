//
//  ReportViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ReportViewController.h"

@interface ReportViewController (){
    NSInteger _index;
}

@property (nonatomic, weak) IBOutlet UIButton *commitBtn;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ReportViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = -1;
    self.dataArray = [NSMutableArray arrayWithObjects:@"淫秽色情", @"营销广告", @"恶意攻击谩骂", @"政治反动", @"欺诈", @"骚扰", @"其他", nil];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回
- (IBAction)navBackClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"举报中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    if (self.reportType == ReportType_Dynamic) {
         [requestDict setObject:@"6" forKey:@"type"];
    }else{
        [requestDict setObject:@(self.reportType) forKey:@"type"]; 
    }
   
    [requestDict setObject:self.reportId forKey:@"repid"];
    [requestDict setObject:self.dataArray[_index] forKey:@"reason"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_REPORT paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"举报成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"举报失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 0, WIDTH-60, 49) font:FONT_SYSTEM_SIZE(17) bkColor:nil textColor:HEX_COLOR(@"41464e")];
    titleLabel.text = self.dataArray[indexPath.row];
    [cell.contentView addSubview:titleLabel];
    
    if(_index == indexPath.row){
        UIImageView *selectedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 15, 18, 14)];
        selectedImgView.image = kImageWithName(@"icon_jb_xz");
        [cell.contentView addSubview:selectedImgView];
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 48.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [cell.contentView addSubview:lineLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_index == indexPath.row){
        _index = -1;
        self.commitBtn.enabled = NO;
    }else{
        self.commitBtn.enabled = YES;
        _index = indexPath.row;
    }
    [self.tableView reloadData];
}

@end
