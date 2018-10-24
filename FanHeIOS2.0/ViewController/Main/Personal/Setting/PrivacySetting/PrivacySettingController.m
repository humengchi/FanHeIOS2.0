//
//  PrivacySettingController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PrivacySettingController.h"
#import "QuestionSettingController.h"

@interface PrivacySettingController ()

@end

@implementation PrivacySettingController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"联系人和隐私"];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return 34;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 49;
    }else{
        UserModel *model = [DataModelInstance shareInstance].userModel;
        NSString *str = [NSString stringWithFormat:@"[问题] %@",model.askcheck.length?model.askcheck:model.asksubject];
        if(model.hasaskcheck.integerValue==1){
            return 49+30+[NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(15) width:WIDTH-32];
        }else{
            return 49;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(section==1){
        return nil;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 34)];
    footerView.backgroundColor = kTableViewBgColor;
    NSString *str;
    if([DataModelInstance shareInstance].userModel.canviewphone.integerValue==1){
        str = @"关闭后好友将无法看到你的手机号、邮箱、微信号。";
    }else{
        str = @"开启后好友将可以看到你的手机号、邮箱、微信号。";
    }
    UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, 34) backColor:kTableViewBgColor textColor:KTextColor test:str font:12 number:1 nstextLocat:NSTextAlignmentLeft];
    [footerView addSubview:contentLabel];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [footerView addSubview:lineLabel];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-32, 49) backColor:WHITE_COLOR textColor:KTextColor test:@"" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
    [cell.contentView addSubview:titleLabel];
    if(indexPath.section==0){
        titleLabel.text = @"联系方式好友可见";
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH-67, 9, 51, 31)];
        [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        switchBtn.on = [DataModelInstance shareInstance].userModel.canviewphone.boolValue;
        [cell.contentView addSubview:switchBtn];
    }else{
        titleLabel.text = @"加好友需回答问题";
        UserModel *model = [DataModelInstance shareInstance].userModel;
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 18, 9, 15)];
        arrowImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:arrowImageView];
        UILabel *stateLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-80, 0, 50, 49) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:(model.hasaskcheck.integerValue==1?@"是":@"否") font:17 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:stateLabel];
        
        if(model.hasaskcheck.integerValue==1){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 49, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
            NSString *str = [NSString stringWithFormat:@"[问题] %@",model.askcheck.length?model.askcheck:model.asksubject];
            UILabel *questionLabel = [UILabel createrLabelframe:CGRectMake(16, 49.5, WIDTH-32, 30+[NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(15) width:WIDTH-32]) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:str font:15 number:0 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:questionLabel];
        }
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [cell.contentView addSubview:lineLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        QuestionSettingController *vc = [[QuestionSettingController alloc] init];
        vc.questionSettingSuccess = ^(){
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UISwitch
- (void)switchButtonClicked:(UISwitch*)sender{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"修改中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[NSNumber numberWithBool:sender.isOn] forKey:@"canview"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_UP_CAN_VIEW_PHONE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"修改成功" toView:weakSelf.view];
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.canviewphone = [NSNumber numberWithBool:sender.isOn];
            [DataModelInstance shareInstance].userModel = model;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
            sender.on = !sender.isOn;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

@end
