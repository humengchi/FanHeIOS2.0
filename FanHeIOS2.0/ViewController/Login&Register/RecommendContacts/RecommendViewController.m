//
//  RecommendViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RecommendViewController.h"
#import "RecommendTableViewCell.h"

@interface RecommendViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedUserArray;

@end

@implementation RecommendViewController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.selectedUserArray = [NSMutableArray array];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-55)];
    self.tableView.backgroundColor = WHITE_COLOR;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UILabel *headerLabel = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 48) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:@"关注优质人脉 拓展靠谱业务" font:20 number:1 nstextLocat:NSTextAlignmentCenter];
    headerLabel.font = FONT_BOLD_SYSTEM_SIZE(20);
    self.tableView.tableHeaderView = headerLabel;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView reloadData];
    
    [self loadHttpData];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    [requestDict setObject:@"" forKey:@"strphone"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_GOOD_USER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dataDict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            if([[CommonMethod paramArrayIsNull:dataDict[@"mayknowpeople"]] count] == 3){
                RecommendModel *model = [[RecommendModel alloc] initWithArray:dataDict[@"mayknowpeople"] keyName:@"你可能认识他们"];
                [weakSelf.dataArray addObject:model];
            }
            if([[CommonMethod paramArrayIsNull:dataDict[@"gooduser"]] count] == 3){
                RecommendModel *model = [[RecommendModel alloc] initWithArray:dataDict[@"gooduser"] keyName:@"优质人脉推荐"];
                [weakSelf.dataArray addObject:model];
            }
            if([[CommonMethod paramArrayIsNull:dataDict[@"bestbusiness"]] count]){
                for(NSDictionary *dict in dataDict[@"bestbusiness"]){
                    if([[CommonMethod paramArrayIsNull:dict[@"val"]] count] == 3){
                        RecommendModel *model = [[RecommendModel alloc] initWithArray:dict[@"val"] keyName:dict[@"name"]];
                        model.hasSelectedAll = YES;
                        [weakSelf.dataArray addObject:model];
                    }
                }
            }
            for(RecommendModel *model in weakSelf.dataArray){
                for(UserModel *userModel in model.userArray){
                    if(userModel.userId){
                        [weakSelf.selectedUserArray addObject:userModel.userId];
                    }
                }
            }
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"请检查网络" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"请检查网络" toView:self.view];
    }];
}

- (void)setAttentionUsersHttpData{
    if([DataModelInstance shareInstance].userModel == nil){
        [[AppDelegate shareInstance] updateWindowRootVC];
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"关注中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[self.selectedUserArray componentsJoinedByString:@","] forKey:@"otherid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_SET_ATTENT_USER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
            [UIView animateWithDuration:0.3 animations:^{
                
            } completion:^(BOOL finished) {
                  [[AppDelegate shareInstance] updateWindowRootVC];
            }];
        }else{
            [MBProgressHUD showError:@"关注失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"关注失败，请重试" toView:weakSelf.view];
    }];
}

#pragma mark - method
- (IBAction)gotoButtonClicked:(id)sender{
    [[AppDelegate shareInstance] updateWindowRootVC];
}

- (IBAction)attentionUserButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.selectedUserArray.count){
        [self setAttentionUsersHttpData];
    }
}

#pragma mark -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecommendModel *model = self.dataArray[indexPath.row];
    if(model.canChoiceAll){
        return 183;
    }else{
        return 199;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"RecommendTableViewCell";
    RecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"RecommendTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    RecommendModel *model = self.dataArray[indexPath.row];
    [cell updateDisplay:model];
    cell.selectedUser = ^(NSArray *array){
        for(UserModel *model in array){
            NSNumber *userId = model.userId;
            if(![self.selectedUserArray containsObject:userId]){
                [self.selectedUserArray addObject:userId];
            }
        }
    };
    cell.removeUser = ^(NSArray *array){
        for(UserModel *model in array){
            NSNumber *userId = model.userId;
            if([self.selectedUserArray containsObject:userId]){
                [self.selectedUserArray removeObject:userId];
            }
        }
    };
    return cell;
}

@end
