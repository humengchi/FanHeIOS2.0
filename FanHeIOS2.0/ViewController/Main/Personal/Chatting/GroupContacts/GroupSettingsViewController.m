//
//  GroupSettingsViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GroupSettingsViewController.h"
#import "GroupListController.h"
#import "GroupAddFriendsController.h"
#import "ChangeGroupNameViewController.h"
#import "ChangeDescrGroupViewController.h"
#import "GroupMangeViewController.h"
#import "GroupListController.h"
//#import "GroupQRCodeController.h"
#import "RemoveGroupViewController.h"
#import "MyGroupViewController.h"

@interface GroupSettingsViewController ()
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) NSMutableArray        *addFriensArray;
@property (nonatomic, strong) EMGroup *aGroupCurrue;
@property (nonatomic, strong) EMCursorResult *listResult;
@property (nonatomic, strong) NSString  *strUid;
@property (nonatomic, strong) UIImageView *addImageViw;
@property (nonatomic, strong)  UIImageView *ddelectImageViw;
@property (nonatomic, strong) UIImageView *coverImageViw;
@end

@implementation GroupSettingsViewController
- (void)getGroupMemberListFromServerWithId:(NSString *)aGroupId cursor:(NSString *)aCursor pageSize:(NSInteger)aPageSize completion:(void (^)(EMCursorResult *aResult, EMError *aError))aCompletionBlock{
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    EMError *error = nil;
   self.listResult =   [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupID cursor:@"" pageSize:1000 error:&error];
    
    self.aGroupCurrue =   [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID error:&error];
     [self getGroupFriendsNameAndHeader:self.listResult.list];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"群组设置"];
    self.addFriensArray = [NSMutableArray new];
    self.view.backgroundColor = kTableViewBgColor;
    EMError *error = nil;
    self.aGroupCurrue =   [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID  error:&error];
    
    self.strUid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 80)];
    footView.userInteractionEnabled = YES;
    UIButton *quitBtn =  [NSHelper createButton:CGRectMake(62, footView.frame.size.height - 40, WIDTH - 124, 40) title:@"退出群组" unSelectImage:[UIImage imageNamed:@""] selectImage:nil target:self selector:@selector(quitGroupBtnAction:)];
    [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_rm_off_red"] forState:UIControlStateNormal];
    footView.backgroundColor = kTableViewBgColor;
    [footView addSubview:quitBtn];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = footView;
    if ([self.aGroupCurrue.owner isEqualToString:self.strUid]) {
        self.dataArray = [NSMutableArray arrayWithObjects:@[@"群成员"], @[@"群聊名称",@"群转让",@"群简介"],@[@"消息免打扰",@"置顶聊天"],@[@"清空聊天记录"], nil];
        [quitBtn setTitle:@"解散群组" forState:UIControlStateNormal];
    }else{
        self.dataArray = [NSMutableArray arrayWithObjects:@[@"群成员"], @[@"群聊名称",@"群简介"],@[@"消息免打扰",@"置顶聊天"],@[@"清空聊天记录"], nil];
    }
    
    
    
    
    // Do any additional setup after loading the view.
}
- (void)getGroupFriendsNameAndHeader:(NSArray *)array{
    
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = nil;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (array.count > 0) {
        [requestDict setObject:[array componentsJoinedByString:@","] forKey:@"userid"];
    }
    
    [self requstType:RequestType_Post apiName:API_NAME_POST_CHECKUSER_HEADERANDNAME paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            [self.addFriensArray  removeAllObjects];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [self.addFriensArray addObject:model];
            }
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

#pragma maek ----- 推出群组
- (void)quitGroupBtnAction:(UIButton *)btn{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"退出群聊后不再接收群消息，同时清除聊天记录，是否确认退出？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        EMError *error = nil;
        NSString  *strUid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
        if ([self.aGroupCurrue.owner isEqualToString:strUid]) {
            //解散群主
            [[EMClient sharedClient].groupManager destroyGroup:self.groupID finishCompletion:^(EMError *aError) {
                if (!error) {
                    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                    [self.navigationController popToViewController:vc animated:YES];
                    if([vc isKindOfClass:[MyGroupViewController class]]){
                        ((MyGroupViewController*)vc).deleteGroup(self.groupID);
                    }
                }
            }];
        }else{
            //退出群组
            [[EMClient sharedClient].groupManager leaveGroup:self.groupID error:&error];
            if (!error) {
                UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:vc animated:YES];
                if([vc isKindOfClass:[MyGroupViewController class]]){
                    ((MyGroupViewController*)vc).deleteGroup(self.groupID);
                }
            }
        }
        
    }];
    
}
#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([DataModelInstance shareInstance].userModel){
        return self.dataArray.count;
    }else{
        return self.dataArray.count-1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSMutableArray*)self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 97;
    }
    CGFloat heigth = [NSHelper heightOfString:self.aGroupCurrue.description font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (indexPath.section == 1) {
        if ([self.aGroupCurrue.owner isEqualToString:self.strUid]) {
            if (indexPath.row == 2) {
                if (self.aGroupCurrue.description.length > 0) {
                    return heigth + 60;
                }else{
                    return 80;
                }
  
            }
        }else{
            if (indexPath.row == 1) {
                if (self.aGroupCurrue.description.length > 0) {
                   return heigth + 60;
                }else{
                    return 80;

                }

            }
   
        }

    }
       return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    return headerView;
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
    if (indexPath.row == 0){
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        UILabel *lineLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(16, 49.5, WIDTH - 32, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel1];
    }else if (indexPath.row == [(NSArray*)self.dataArray[indexPath.section] count]-1){
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 49.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
//        [cell.contentView addSubview:lineLabel];
    }else{
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 49.5, WIDTH - 32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }
    if (indexPath.section == 0) {
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, WIDTH-100, 15)];
        sizeLabel.textAlignment = NSTextAlignmentLeft;
        sizeLabel.text = self.dataArray[indexPath.section][indexPath.row];
        sizeLabel.textColor = HEX_COLOR(@"41464E");
        sizeLabel.font = FONT_SYSTEM_SIZE(17);
        [cell.contentView addSubview:sizeLabel];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, 17, WIDTH-110, 15)];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.text = [NSString stringWithFormat:@"%ld人", self.aGroupCurrue.occupants.count];
        countLabel.textColor = HEX_COLOR(@"41464E");
        countLabel.font = FONT_SYSTEM_SIZE(17);
        [cell.contentView addSubview:countLabel];
        CGFloat x = 0;
        for (NSInteger i = 0; i < self.addFriensArray.count; i++) {
            if (x < 200) {
            self.coverImageViw  = [[UIImageView alloc]initWithFrame:CGRectMake(16+x, 45, 36, 36)];
                ChartModel *model1 = self.addFriensArray[i];
                if (model1.image.length != 0) {
                    [self.coverImageViw sd_setImageWithURL:[NSURL URLWithString:model1.image] placeholderImage:KHeadImageDefaultName(model1.realname)];
                }else{
                    self.coverImageViw.image = KHeadImageDefaultName(@"头像");
                }
                // 设置圆角的大小
                self.coverImageViw.backgroundColor = [UIColor redColor];
                self.coverImageViw.layer.cornerRadius = 18;
                [self.coverImageViw.layer setMasksToBounds:YES];
                [cell.contentView addSubview:self.coverImageViw];
                x += 46;
            }
        }
        if (x != 0) {
            [self.addImageViw removeFromSuperview];
             [self.ddelectImageViw removeFromSuperview];
           self.addImageViw  = [[UIImageView alloc]initWithFrame:CGRectMake(241, 45, 36, 36)];
             self.addImageViw.layer.cornerRadius = 18;
             self.addImageViw.image = [UIImage imageNamed:@"btn_ql_yqcy"];
            [ self.addImageViw.layer setMasksToBounds:YES];
            [cell addSubview:self.addImageViw];
             self.addImageViw.userInteractionEnabled = YES;
            UITapGestureRecognizer *addGruopFriends = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addFriendsGroup:)];
            [self.addImageViw addGestureRecognizer:addGruopFriends];
            NSString  *strUid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
           self.ddelectImageViw  = [[UIImageView alloc]initWithFrame:CGRectMake(241 + 46, 45, 36, 36)];
            self.ddelectImageViw.userInteractionEnabled = YES;
            if ([self.aGroupCurrue.owner isEqualToString:strUid]) {
                self.ddelectImageViw.layer.cornerRadius = 18;
                self.ddelectImageViw.image = [UIImage imageNamed:@"btn_ql_sccy"];
                [self.ddelectImageViw.layer setMasksToBounds:YES];
                UITapGestureRecognizer *removeGruopFriends = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeFriendsFromeGroup:)];
                [self.ddelectImageViw addGestureRecognizer:removeGruopFriends];
                [cell.contentView addSubview:self.ddelectImageViw];
            }
            
            if (x <= 241) {
                 self.addImageViw.frame = CGRectMake(x + 16, 45, 36, 36);
                self.ddelectImageViw.frame = CGRectMake(x + 60, 45, 36, 36);
            }
        }
    }else{
        cell.textLabel.textColor = KTextColor;
        cell.textLabel.font = FONT_SYSTEM_SIZE(17);
        if ([self.aGroupCurrue.owner isEqualToString:self.strUid]) {
            if (indexPath.row != 2){
                cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
            }
        }else{
            if (indexPath.row != 1){
               cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
            }
        }
       
    }
    if(indexPath.section == 1 ||indexPath.section == 0){
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-24, 17, 9, 16)];
        arrowImageView.image = kImageWithName(@"icon_next_gray");
        if (indexPath.section == 1) {
            if ([self.aGroupCurrue.owner isEqualToString:self.strUid]) {
                if (indexPath.row != 3){
                     [cell.contentView addSubview:arrowImageView];
                }
            }else{
                if (indexPath.row != 2){
                      [cell.contentView addSubview:arrowImageView];
                }
            }

        }else{
            [cell.contentView addSubview:arrowImageView];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0){
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 18, WIDTH-110, 15)];
            sizeLabel.textAlignment = NSTextAlignmentRight;
               sizeLabel.text = self.aGroupCurrue.subject;
            sizeLabel.textColor = HEX_COLOR(@"41464E");
            sizeLabel.font = FONT_SYSTEM_SIZE(17);
            [cell.contentView addSubview:sizeLabel];
        }else {
            CGFloat heigth = [NSHelper heightOfString:self.aGroupCurrue.description font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 44, WIDTH - 32, heigth)];
            sizeLabel.font = FONT_SYSTEM_SIZE(17);
            if (self.aGroupCurrue.description.length > 0) {
                sizeLabel.text = self.aGroupCurrue.description;
                sizeLabel.textColor = HEX_COLOR(@"41464E");
            }else{
                sizeLabel.text = @"暂无";
                sizeLabel.textColor = HEX_COLOR(@"E6E8EB");
            }
            if ([self.aGroupCurrue.owner isEqualToString:self.strUid]) {
                if (indexPath.row == 2){
                    UILabel *sizeLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, WIDTH-100, 15)];
                    sizeLabelTitle.textAlignment = NSTextAlignmentLeft;
                    sizeLabelTitle.text = self.dataArray[indexPath.section][indexPath.row];
                    sizeLabelTitle.textColor = HEX_COLOR(@"41464E");
                    sizeLabelTitle.font = FONT_SYSTEM_SIZE(17);
                    [cell.contentView addSubview:sizeLabelTitle];
                    [cell.contentView addSubview:sizeLabel];
                }
            }else{
                if (indexPath.row == 3){
                    UILabel *sizeLabelTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, WIDTH-100, 15)];
                    sizeLabelTitle.textAlignment = NSTextAlignmentLeft;
                    sizeLabelTitle.text = self.dataArray[indexPath.section][indexPath.row];
                    sizeLabelTitle.textColor = HEX_COLOR(@"41464E");
                    sizeLabelTitle.font = FONT_SYSTEM_SIZE(17);
                    [cell.contentView addSubview:sizeLabelTitle];
                   [cell.contentView addSubview:sizeLabel];
                }
            }
          
           
        }
    }
    
    if(indexPath.section == 2){
        if (indexPath.row == 0) {
            UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 66, 10, 51, 10)];
            [switchButton setOn:self.aGroupCurrue.isBlocked animated:NO];
            [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchButton];
        }
        if (indexPath.row == 1) {
            
            UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 66, 10, 51, 10)];
            if ([self.conversation.ext[@"isTop"] isEqualToString:@"1"]) {
                 [switchButton setOn:YES];
            }else{
                  [switchButton setOn:NO];
            }
            [switchButton addTarget:self action:@selector(switchTopAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchButton];
        }
        
    }
    return cell;
}
#pragma mark ----- 去添加好友
- (void)addFriendsGroup:(UITapGestureRecognizer *)g{
    GroupAddFriendsController *groupAdd = [[GroupAddFriendsController alloc]init];
    groupAdd.groupID = self.groupID;
    [self.navigationController pushViewController:groupAdd animated:YES];
}
#pragma mark ----- 移除好友
- (void)removeFriendsFromeGroup:(UITapGestureRecognizer *)g{
    RemoveGroupViewController *groupAdd = [[RemoveGroupViewController alloc]init];
    groupAdd.groupID = self.groupID;
    groupAdd.groupArray = self.aGroupCurrue.occupants;
    [self.navigationController pushViewController:groupAdd animated:YES];
}
#pragma mark --- 消息免打扰
-(void)switchAction:(UISwitch *)switchAction{
    if (switchAction.on) {
        [[EMClient sharedClient].groupManager blockGroup:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
            [self showHint:@"屏蔽成功"];
        }];
    }else{
        [[EMClient sharedClient].groupManager unblockGroup:self.groupID completion:^(EMGroup *aGroup, EMError *aError) {
            [self showHint:@"取消屏蔽"];
        }];
    }
}
#pragma mark --- 群组置顶
-(void)switchTopAction:(UISwitch *)switchAction{
      NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.conversation.ext];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    if (switchAction.on) {
         [dic setObject:@"1" forKey:@"isTop"];
    }else{
        [dic setObject:@"0" forKey:@"isTop"];
    }
    self.conversation.ext = dic;
 }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        GroupListController *groupAdd = [[GroupListController alloc]init];
        groupAdd.groupID = self.groupID;
        groupAdd.groupArray = self.aGroupCurrue.occupants;
        [self.navigationController pushViewController:groupAdd animated:YES];
        
    }else if (indexPath.section == 1) {
        NSString  *strUid = [NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId];
        if ([self.aGroupCurrue.owner isEqualToString:strUid]) {
            if (indexPath.row == 0) {
                ChangeGroupNameViewController *groupAdd = [[ChangeGroupNameViewController alloc]init];
                groupAdd.groupName = self.aGroupCurrue.subject;
                groupAdd.groupID = self.groupID;
                [self.navigationController pushViewController:groupAdd animated:YES];
            }else if (indexPath.row == 1){
                GroupMangeViewController *groupAdd = [[GroupMangeViewController alloc]init];
                groupAdd.groupID = self.groupID;
                groupAdd.groupArray = self.aGroupCurrue.occupants;
                [self.navigationController pushViewController:groupAdd animated:YES];
            }else if (indexPath.row == 2){
                ChangeDescrGroupViewController *groupAdd = [[ChangeDescrGroupViewController alloc]init];
                NSString *str = self.aGroupCurrue.description;
                groupAdd.descriptionStr = str;
                groupAdd.groupID = self.groupID;
                [self.navigationController pushViewController:groupAdd animated:YES];
            }
            
        }
    }else if (indexPath.section == 3) {
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"清空聊天记录，是否确认清空聊天信息？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            
        } confirm:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"delectMessage" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
