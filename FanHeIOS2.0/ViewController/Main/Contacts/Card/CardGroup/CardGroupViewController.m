//
//  CardGroupViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardGroupViewController.h"
#import "CardGroupDetailListController.h"

@interface CardGroupViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, weak) IBOutlet UIButton *confirmBtn;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation CardGroupViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getCardGroupListHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupArray = [NSMutableArray array];
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.tableView.separatorColor = kCellLineColor;
    self.confirmBtn.hidden = self.isShowGroupList;
    if(self.isShowGroupList){
        self.titleLabel.text = @"分组";
    }else{
        self.titleLabel.text = @"添加分组";
    }
}

#pragma mark - 添加分组
- (void)initTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 65)];
    headerView.backgroundColor = kTableViewBgColor;
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, WIDTH, 49)];
    btnView.backgroundColor = WHITE_COLOR;
    [headerView addSubview:btnView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(16, 0, WIDTH-32, 49);
    [btn setImage:kImageWithName(@"icon_bjmp_tj") forState:UIControlStateNormal];
    [btn setTitle:@" 新建分组" forState:UIControlStateNormal];
    [btn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
    btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [btn addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:HEX_COLOR(@"3498db")];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnView addSubview:btn];
    
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - 获取我的分组
- (void)getCardGroupListHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_MYCARDGROUP paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.groupArray removeAllObjects];
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                CardGroupModel *model = [[CardGroupModel alloc] initWithDict:subDic];
                if([weakSelf.model.groups containsObject:model.groupname]){
                    model.isSelected = @(1);
                }
                [weakSelf.groupArray addObject:model];
            }
            [weakSelf initTableHeaderView];
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 添加新的分组
- (void)addCardGroupHttpData:(NSString*)groupname{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"添加中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:groupname forKey:@"groupname"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_ADDGROUP paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            CardGroupModel *model = [[CardGroupModel alloc] initWithDict:dict];
            model.isSelected = @(1);
            [weakSelf.groupArray addObject:model];
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud){
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 删除我的分组
- (void)deleteCardGroupHttpData:(NSInteger)row{
    CardGroupModel *model = self.groupArray[row];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, model.groupid] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_DELCARDGROUP paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.groupArray removeObjectAtIndex:row];
            if(weakSelf.groupArray.count){
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 重命名我的分组
- (void)resetNameCardGroupHttpData:(NSInteger)row name:(NSString*)name{
    CardGroupModel *model = self.groupArray[row];
    if(name.length==0 || [model.groupname isEqualToString:name]){
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:model.groupid forKey:@"groupid"];
    [requestDict setObject:name forKey:@"groupname"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_UPCARDGROUP paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            model.groupname = name;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 添加分组
- (void)createGroup{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"新建分组" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 200;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"请输入";
    textField.returnKeyType = UIReturnKeyDone;
    [alert show];
}

- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmButtonClicked:(id)sender{
    NSMutableArray *array = [NSMutableArray array];
    for(CardGroupModel *model in self.groupArray){
        if(model.isSelected.integerValue){
            [array addObject:model.groupname];
        }
    }
    self.model.groups = [array mutableCopy];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.cardId forKey:@"cardid"];
    [requestDict setObject:[self.model.groups componentsJoinedByString:@","] forKey:@"groupname"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_ADDCARDGROUP paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    CardGroupModel *model = self.groupArray[indexPath.row];
    UILabel *label = [UILabel createLabel:CGRectMake(16, 0, WIDTH-41, 49) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
    label.text = [NSString stringWithFormat:@"%@（%@）", model.groupname, model.cnt];
    [cell.contentView addSubview:label];
    
    if(self.isShowGroupList){
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 17, 9, 15)];
        arrowImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:arrowImageView];
    }else{
        UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-32, 16, 16, 16)];
        if(model.isSelected.integerValue){
            label.textColor = HEX_COLOR(@"41464e");
            selectImageView.image = kImageWithName(@"icon_zf_cg");
        }else{
            selectImageView.image = kImageWithName(@"btn_xz_yxz");
            label.textColor = HEX_COLOR(@"818c9e");
        }
        [cell.contentView addSubview:selectImageView];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.isShowGroupList){
        CardGroupDetailListController *vc = [[CardGroupDetailListController alloc] init];
        vc.model = self.groupArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        CardGroupModel *model = self.groupArray[indexPath.row];
        model.isSelected = model.isSelected.integerValue?@(0):@(1);
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isShowGroupList){
        __weak typeof(self) weakSelf = self;
        UITableViewRowAction *resetNameRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"重命名分组" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 1000+indexPath.row;
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.placeholder = @"请输入";
            textField.returnKeyType = UIReturnKeyDone;
            [alert show];
        }];
        resetNameRowAction.backgroundColor = HEX_COLOR(@"afb6c1");
        
        UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:weakSelf title:@"" message:@"是否删除该分组" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                
            } confirm:^{
                [weakSelf deleteCardGroupHttpData:indexPath.row];
            }];
        }];
        deleteRowAction.backgroundColor = HEX_COLOR(@"e24943");
        
        return @[deleteRowAction, resetNameRowAction];
    }else{
        return @[];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *textField = [alertView textFieldAtIndex:0];
    for(CardGroupModel *model in self.groupArray){
        if([model.groupname isEqualToString:textField.text]){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.view showToastMessage:@"分组已存在，不可重复添加"];
            });
            return;
        }
    }
    if(buttonIndex==1 && textField.text.length){
        if(alertView.tag>=1000){
            [self resetNameCardGroupHttpData:alertView.tag-1000 name:textField.text];
        }else{
            [self addCardGroupHttpData:textField.text];
        }
    }
}
@end
