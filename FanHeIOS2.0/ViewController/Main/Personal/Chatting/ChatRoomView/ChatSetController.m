//
//  ChatSetController.m
//  JinMai
//
//  Created by renhao on 16/5/22.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ChatSetController.h"

#define hBlackList  @"black"

@interface ChatSetController ()

@end

@implementation ChatSetController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"聊天设置"];

     [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HEX_COLOR(@"F7F7F7");
    [self createrFootTabView];
}

- (void)createrFootTabView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 224, WIDTH, HEIGHT - 224)];
    self.tableView.tableFooterView = view;
    view.userInteractionEnabled = YES;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(30, 50, WIDTH - 60, 50);
    btn.backgroundColor = HEX_COLOR(@"E23000");
    btn.layer.cornerRadius = 5;
    [btn setTitle:@"删除好友" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(delectGoodFriends) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
}
#pragma mark ------- 删除好友
- (void)delectGoodFriends{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否删除该好友？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [self delectFriends];
    }];
  
}
- (void)delectFriends{
   
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.chatId] forKey:@"param"];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"解除关系中" toView:self.view];
    [self requstType:RequestType_Delete apiName:API_NAME_USER_DEL_DELFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            
            EMCmdMessageBody *body = [[EMCmdMessageBody alloc] initWithAction:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.realname]];
            NSString *from = [[EMClient sharedClient] currentUsername];
            NSString *to = self.chatId;
            NSDictionary *ext = @{@"NSDictionary":@"NSDictionary"};
            // 生成message
            EMMessage *message = [[EMMessage alloc] initWithConversationID:to from:from to:to body:body ext:ext];
            message.chatType = EMChatTypeChat;// 设置为单聊消息
            [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                
            }];
            
            //删除会话
            [[EMClient sharedClient].chatManager deleteConversation:self.chatId isDeleteMessages:YES completion:nil];

            [[NSNotificationCenter defaultCenter]postNotificationName:MyFriendsChange object:nil];
            [MBProgressHUD showSuccess:@"好友已删除" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                [self.navigationController popToViewController:vc animated:YES];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:self.view];
    }];
    

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==  0){
        return 74;
    }else if (indexPath.section ==  1){
        if (indexPath.row == 0){
             return 50;
        }
//           return 55;
    }
    return 0;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"";
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    if (indexPath.section == 0){
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 27, 9, 15)];
        arrowImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:arrowImageView];
        UILabel *lineLabel = [[UILabel alloc]init];
        lineLabel.frame = CGRectMake(0, 0, WIDTH, 0.5);
        lineLabel.backgroundColor = HEX_COLOR(@"D7D7D7");
        [cell.contentView addSubview:lineLabel];
        UILabel *lineLabel1 = [[UILabel alloc]init];
        lineLabel1.frame = CGRectMake(0, 73.5, WIDTH, 0.5);
        lineLabel1.backgroundColor = HEX_COLOR(@"D7D7D7");
        [cell.contentView addSubview:lineLabel1];
        
        _coverImageiew = [UIImageView drawImageViewLine:CGRectMake(14, 12, 44, 44) bgColor:[UIColor clearColor]];
        _coverImageiew.layer.masksToBounds = YES;
        _coverImageiew.layer.cornerRadius = 22;
       
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(69, 17, WIDTH - 69 - 32, 14)];
        
        _nameLabel.textColor = HEX_COLOR(@"818C9E");
        _nameLabel.font = [UIFont systemFontOfSize:12];
        
        _positionLabel = [UILabel createLabel:CGRectMake(69, 35, WIDTH - 69 - 32, 16) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"41464E")];
        _positionLabel.font = [UIFont systemFontOfSize:14];
       
       NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:self.chatId];
        if(array.count){
            ChartModel *model = array[0];

            NSString *position = [NSString stringWithFormat:@"%@%@",model.company,model.position];
            if (position.length > 0) {
                _positionLabel.text = position;
            }else{
                _positionLabel.text = @"公司职位";
            }
            _nameLabel.text = model.realname;
        
            [_coverImageiew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            [cell.contentView addSubview:_coverImageiew];
            [cell.contentView addSubview:_nameLabel];
            [cell.contentView addSubview:_positionLabel];
        }
    }
    if (indexPath.section == 1){
        if (indexPath.row == 0) {
            UILabel *lineLabel1 = [[UILabel alloc]init];
            lineLabel1.frame = CGRectMake(0, 49, WIDTH, 0.5);
            lineLabel1.backgroundColor = HEX_COLOR(@"D7D7D7");
            [cell.contentView addSubview:lineLabel1];
            
            UILabel *label = [UILabel createLabel:CGRectMake(16, 18, 120, 18) font:[UIFont systemFontOfSize:18] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"222222")];
            label.text = @"清空聊天记录";
            [cell.contentView addSubview:label];
            UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 20, 9, 15)];
            arrowImageView.image = kImageWithName(@"next_arrow");
            [cell.contentView addSubview:arrowImageView];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
        home.userId = [NSNumber numberWithInteger:self.chatId.integerValue];
        [self.navigationController pushViewController:home animated:YES];
    }
    if (indexPath.section == 1){
        if (indexPath.row == 0){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否清空聊天记录" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                
            } confirm:^{
                [self.conversation deleteAllMessages:nil];
                if ([self.setDelegate respondsToSelector:@selector(referViewChat)]){
                    [self.setDelegate referViewChat];
                }
            }];
        }
    }
}

@end
