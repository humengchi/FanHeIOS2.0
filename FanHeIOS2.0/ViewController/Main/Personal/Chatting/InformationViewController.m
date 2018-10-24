//
//  InformationViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/7/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ChatViewController.h"
#import "ChattingListCell.h"
#import "ContactsNoDataTableViewCell.h"
#import "InformationViewController.h"
#import "NONetWorkTableViewCell.h"
#import "ActivityNotificationViewController.h"
#import "TouTiaoViewController.h"
#import "MenuView.h"

#import "GroupSetUpViewController.h"
#import "MyGroupViewController.h"
#import "MessageSidViewController.h"
#import "ScanQRCodeViewController.h"
#import "JionQRcodeGroupViewController.h"
#import "WebViewController.h"
#import "GetMyselfCoffer.h"
#import "EMGroup+Category.h"

#import "ConversationsManager.h"

@interface InformationViewController () <EMChatManagerDelegate,
EMClientDelegate>
//消息
@property(nonatomic, strong) NSMutableArray *messageArray;
@property(nonatomic, assign) BOOL netWorkStat;
@property(nonatomic, strong) UITableView *messageTabView;
@property(nonatomic, strong) UIButton *showBtnNotWork;

@property (nonatomic, strong) MenuView *menuView;

@property (nonatomic, assign) BOOL menuShow;


@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, strong) NSString *remName;
@end

@implementation InformationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //    [self setNavigationBar_white];
    //更新本地好友数据
    [[AppDelegate shareInstance] updateFriendsListArrayData:nil];
    //初始化数据
    [self loadMessageData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_menuShow){
        _menuShow = NO;
        [self.menuView showMenuWithAnimation:_menuShow];
        self.menuView = nil;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //    [self setNavigationBar_kdefaultColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCustomNavigationBarNew];
    self.groupArray = [NSMutableArray array];
    
    self.view.backgroundColor = kTableViewBgColor;
    self.netWorkStat = YES;
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    self.messageArray = [NSMutableArray array];
    [self createrMessageTabView];
    
    //下拉刷新
    [self.messageTabView tableViewAddDownLoadRefreshing:^{
        [self loadMessageData];
    }];
    // 网络状态监听
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notWorkExchangeChanged:)
     name:kReachabilityChangedNotification
     object:nil];
}
#pragma mark - 自定义导航栏（白底）
- (UILabel *)createCustomNavigationBarNew{
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    barView.backgroundColor = WHITE_COLOR;
    [self.view addSubview:barView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(customNavBackButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(64, 20, WIDTH-128, 44) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"383838") ];
    titleLabel.text = @"消息";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [barView addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 63.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [barView addSubview:lineLabel];
    
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    publishBtn.frame = CGRectMake(WIDTH - 56, 20, 40, 44);
    [publishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [publishBtn setImage:[kImageWithName(@"icon_bjmp_tj") imageWithColor:HEX_COLOR(@"818c9e")] forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(showMenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:publishBtn];
    return titleLabel;
}

#pragma mark -----弹出下拉菜单
- (void)showMenButtonClicked:(UIButton *)btn{
    _menuShow = !_menuShow;
    [self.menuView showMenuWithAnimation:_menuShow];
    if(_menuShow==NO){
        self.menuView = nil;
    }
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"发起群聊", @"imageName":@"icon_trends_as"},@{@"itemName" : @"我的群聊", @"imageName":@"icon_topic_as"}];
        
        __weak typeof(self)weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(0, 0, 150, dataArray.count * 40) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
             if(tag==0){
                GroupSetUpViewController *myGroup = [[GroupSetUpViewController alloc]init];
                [weakSelf.navigationController pushViewController:myGroup animated:YES];
            }else if(tag==1){
                MyGroupViewController *myGroup = [[MyGroupViewController alloc]init];
                [weakSelf.navigationController pushViewController:myGroup animated:YES];
            }
            _menuShow = NO;
            _menuView = nil;
        } backViewTap:^{
            _menuShow = NO;
            _menuView = nil;
        }];
    }
    return _menuView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notWorkExchangeChanged:(NSNotification *)notification {
    if ([self netWorkCanContect] == NO) {
        self.netWorkStat = NO;
        if (self.messageArray && self.showBtnNotWork == nil) {
            self.showBtnNotWork = [UIButton buttonWithType:UIButtonTypeCustom];
            
            self.showBtnNotWork.frame = CGRectMake(0, 0, WIDTH, 36);
            self.messageTabView.tableHeaderView = self.showBtnNotWork;
            
            [self.showBtnNotWork setTitle:@"没有网络连接，请检查网络设置" forState:UIControlStateNormal];
            [self.showBtnNotWork setTitleColor:[UIColor colorWithHexString:@"8B4542"] forState:UIControlStateNormal];
            self.showBtnNotWork.titleLabel.font = [UIFont systemFontOfSize:14];
            self.showBtnNotWork.backgroundColor = [UIColor colorWithHexString:@"FFE1E1"];
        }
        [self.messageTabView reloadData];
    } else {
        if (self.showBtnNotWork) {
            [self.showBtnNotWork removeFromSuperview];
            self.showBtnNotWork = nil;
            
            self.messageTabView.tableHeaderView = nil;
            self.messageTabView.tableHeaderView.frame = CGRectZero;
        }
        self.netWorkStat = YES;
        [self loadMessageData];
    }
}

//查看网络是否能够连接
- (BOOL)netWorkCanContect {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    return [reachability isReachable];
}

#pragma mark--------- 创建消息TabView
- (void)createrMessageTabView {
    self.messageTabView =
    [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64) style:UITableViewStylePlain];
    self.messageTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageTabView.backgroundColor = kTableViewBgColor;
    self.messageTabView.delegate = self;
    self.messageTabView.dataSource = self;
    [self.view addSubview:self.messageTabView];
    self.messageTabView.tableFooterView =
    [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mafrk-- ----消息
- (void)loadMessageData {
    if (self.messageArray) {
        [self.messageArray removeAllObjects];
    }
//    self.messageArray = [[EMClient sharedClient].chatManager getAllConversations];
     [self.messageArray addObjectsFromArray:[ConversationsManager conversationModelsWithConversations:[[EMClient sharedClient].chatManager getAllConversations]]];
    [self.messageTabView.mj_header endRefreshing];
    [self.messageTabView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.messageArray count]) {
        return [self.messageArray count];
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.messageArray count]) {
        return 74;
    } else {
        return tableView.frame.size.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messageArray.count != 0) {
        static NSString *string = @"last";
        ChattingListCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
        if (!cell) {
            cell = [CommonMethod
                    getViewFromNib:NSStringFromClass([ChattingListCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        EMConversation *conversation =
        [self.messageArray objectAtIndex:indexPath.row];
        if (conversation.type == EMConversationTypeGroupChat) {
            if (![conversation.ext objectForKey:@"subject"]){
                [[EMClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:0 pageSize:-1 completion:^(NSArray *aList, EMError *aError) {
                    
                }];
                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:conversation.conversationId]) {
                        NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                        [ext setObject:group.subject forKey:@"subject"];
                        [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                        conversation.ext = ext;
                        break;
                    }
                }
            }
            
            NSDictionary *ext = conversation.ext;
            cell.name = [ext objectForKey:@"subject"];
            cell.placeholderImage = KHeadImageDefaultName(@"群组");
            cell.unreadCount = [self unreadMessageCountByConversation:conversation];
            cell.time = [self lastMessageTimeByConversation:conversation];
            cell.str = [self conversationListViewController:self latestMessageTitleForConversationModel:conversation count:cell.unreadCount];
            EMGroup *group;
            for(EMGroup *groupTmp in self.groupArray){
                if([groupTmp.groupId isEqualToString:conversation.conversationId]){
                    group = groupTmp;
                    [cell traderCharttingMessageGroup:groupTmp];
                    break;
                }
            }
            if(group == nil){
                [cell traderCharttingMessageGroupSpace:conversation.conversationId];
            }
            if(group == nil || group.hasCreated.integerValue==0){
                [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:conversation.conversationId completion:^(EMGroup *aGroup, EMError *aError) {
                    if(aGroup){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            aGroup.hasCreated = @(0);
                            aGroup.headerImage = KHeadImageDefaultName(@"群组");
                            aGroup.isMyGroupList = @(0);
                            [cell traderCharttingMessageGroup:aGroup];
                            BOOL isExit = NO;
                            NSInteger index = 0;
                            for(EMGroup *groupTmp in self.groupArray){
                                if([groupTmp.groupId isEqualToString:conversation.conversationId]){
                                    isExit = YES;
                                    break;
                                }
                                index++;
                            }
                            if(isExit==NO){
                                [self.groupArray addObject:aGroup];
                            }else{
                                [self.groupArray replaceObjectAtIndex:index withObject:aGroup];
                            }
                        });
                    }
                }];
            }
//            if ([conversation.ext[@"isTop"] isEqualToString:@"1"]) {
//                cell.backgroundColor = [UIColor grayColor];
//            }
            return cell;
        } else{
            if ([conversation.conversationId isEqualToString:@"jm_assistant"]) {
                cell.name = @"金脉小秘书";
                cell.placeholderImage = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
            }else if ([conversation.conversationId isEqualToString:@"activity_assistant"]) {
                cell.name = @"活动助手";
                cell.placeholderImage = [UIImage imageNamed:@"icon_event_assis"];
            }else if ([conversation.conversationId isEqualToString:@"jm_topic"]) {
                cell.name = @"金脉头条";
                cell.placeholderImage = [UIImage imageNamed:@"avatar_jmtt"];
            } else{
                NSMutableArray *array = [[DBInstance shareInstance]
                                         selectCharttingID:conversation.conversationId];
                if (array.count != 0) {
                    ChartModel *model = array[0];
                    cell.name = model.realname;
                    cell.imageURL = [NSURL URLWithString:model.image];
                    cell.placeholderImage = KHeadImageDefaultName(model.realname);
                }else{
                    cell.placeholderImage = KHeadImageDefaultName(@"头像");
                }
            }
            
            cell.unreadCount = [self unreadMessageCountByConversation:conversation];
            cell.time = [self lastMessageTimeByConversation:conversation];
            cell.detailMsg = [self subTitleMessageByConversation:conversation];
            [cell traderCharttingMessage];
            return cell;
        }
    } else if (!self.netWorkStat) {
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod
                    getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    } else {
        static NSString *string = @"FriendsCell";
        ContactsNoDataTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:string];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([ContactsNoDataTableViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.showImageView.image = [UIImage imageNamed:@"icon_warn_loading"];
            cell.startLabel.text = @"暂无任何消息";
        }
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.netWorkStat || self.messageArray.count == 0) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

//*改变删除按钮的title*/
- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMConversation *conversation =
    [self.messageArray objectAtIndex:indexPath.row];
    [[EMClient sharedClient]
     .chatManager deleteConversation:conversation.conversationId
     isDeleteMessages:YES
     completion:nil];
    [self.messageArray removeObjectAtIndex:indexPath.row];
    [self.messageTabView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messageArray.count == 0) {
        return;
    }
    EMConversation *conversation = [self.messageArray objectAtIndex:indexPath.row];
    [conversation markAllMessagesAsRead:nil];
    [self.messageTabView reloadData];
    
    if (conversation.type == EMConversationTypeGroupChat) {
        ChattingListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        MessageSidViewController *chatController = [[MessageSidViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:EMConversationTypeGroupChat];
        chatController.titleStr = cell.name;
        [self.navigationController pushViewController:chatController animated:YES];
    }else{
        ChatViewController *chatVC = [[ChatViewController alloc]
                                      initWithConversationChatter:conversation.conversationId
                                      conversationType:EMConversationTypeChat];
        if ([conversation.conversationId isEqualToString:@"jm_assistant"]) {
            chatVC.title = @"金脉小秘书";
            chatVC.phoneNumber = @"4001799686";
        }else if([conversation.conversationId isEqualToString:@"activity_assistant"]) {
            ActivityNotificationViewController *chat = [[ActivityNotificationViewController alloc]init];
            [self.navigationController pushViewController:chat animated:YES];
            return;
        }else if([conversation.conversationId isEqualToString:@"jm_topic"]) {
            TouTiaoViewController *chat = [[TouTiaoViewController alloc] init];
            [self.navigationController pushViewController:chat animated:YES];
            return;
        }else{
            NSMutableArray *array = [[DBInstance shareInstance]
                                     selectCharttingID:conversation.conversationId];
            if (array.count != 0) {
                ChartModel *model = array[0];
                chatVC.title = model.realname;
                chatVC.position =
                [NSString stringWithFormat:@"%@%@", model.company, model.position];
                chatVC.phoneNumber = model.phone;
            }
        }
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

// 得到最后消息时间
- (NSString *)lastMessageTimeByConversation:(EMConversation *)conversation {
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    ;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation {
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    return ret;
}

// 得到最后消息文字或者类型
- (NSString *)subTitleMessageByConversation:(EMConversation *)conversation {
    NSString *latestMessageTitle = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage: {
                latestMessageTitle = NSLocalizedString(@"[图片]", @"[image]");
            } break;
            case EMMessageBodyTypeText: {
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                if([didReceiveText hasPrefix:@"向您分享一张名片!"] && [lastMessage.from isEqualToString:[DataModelInstance shareInstance].userModel.userId.stringValue]){
                    didReceiveText = @"向ta分享一张名片!";
                }
                if([didReceiveText hasPrefix:@"邀请你参加活动："] && [lastMessage.from isEqualToString:[DataModelInstance shareInstance].userModel.userId.stringValue]){
                    didReceiveText = @"邀请ta参加活动：";
                }
                latestMessageTitle = didReceiveText;
                if ([lastMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    latestMessageTitle = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice: {
                latestMessageTitle = NSLocalizedString(@"[语音]", @"[voice]");
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"[位置]", @"[location]");
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"[视频]", @"[video]");
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"[文件]", @"[file]");
            } break;
            default: { } break; }
    }
    
    return latestMessageTitle;
}

#pragma mark - EMChatManagerDelegate
- (void)didReceiveMessages:(NSArray *)aMessages{
    for(EMMessage *message in aMessages){
        if(message && message.chatType==EMChatTypeChat){
            if(message.body.type == EMMessageBodyTypeText && [((EMTextMessageBody *)message.body).text isEqualToString:@"我们已成功交换名片，现在可以随时交流了。"]){
                [[AppDelegate shareInstance] updateFriendsListArrayData:^(BOOL result) {
                    [self loadMessageData];
                }];
                return;
            }
        }
    }
    //更新本地好友请求
    [[AppDelegate shareInstance] updateFriendsListArrayData:^(BOOL result) {
        if(result){
            [self.messageTabView reloadData];
        }
    }];
   
    //初始化数据
    [self loadMessageData];
}
- (NSAttributedString *)conversationListViewController:(InformationViewController *)conversationListViewController
                latestMessageTitleForConversationModel:(EMConversation *)conversationModel count:(NSInteger)index
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
    EMMessage *lastMessage = [conversationModel latestMessage];
    if (lastMessage) {
        NSString *latestMessageTitle = @"";
        EMMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case EMMessageBodyTypeImage:{
                latestMessageTitle = @"[图片]";
            } break;
            case EMMessageBodyTypeText:{
                // 表情映射。
                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle = didReceiveText;
                if ([lastMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                    latestMessageTitle = @"[动画表情]";
                }
            } break;
            case EMMessageBodyTypeVoice:{
                latestMessageTitle = @"声音";
            } break;
            case EMMessageBodyTypeLocation: {
                latestMessageTitle = @"位置";
            } break;
            case EMMessageBodyTypeVideo: {
                latestMessageTitle = @"视频";
            } break;
            case EMMessageBodyTypeFile: {
                latestMessageTitle = @"文件";
            } break;
            default: {
            } break;
        }
        
        if (lastMessage.chatType == EMChatTypeGroupChat) {
            if (![lastMessage.ext[@"money_type_special"]  isEqualToString:@"joinGroup"]) {
                NSString *from = lastMessage.from;
                 if (self.remName.length <= 0) {
            [[[BaseViewController alloc] init] updateGroupUsersDB:nil occupants:@[from] handler:^(BOOL result, NSMutableArray *dataArray) {
                            if(result&&dataArray.count){
                                GroupChartModel *gcModel = dataArray.firstObject;
                                self.remName = gcModel.realname;
                                [self.messageTabView reloadData];
                            }
                        }];
                 }
                if (self.remName.length > 0) {
                    from = self.remName == nil ? self.remName : self.remName;
                }
                latestMessageTitle = [NSString stringWithFormat:@"%@: %@", from, latestMessageTitle];
            }
           
        }
       
        NSDictionary *ext = conversationModel.ext;
        if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtAllMessage) {
            latestMessageTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"group.atAll", nil), latestMessageTitle];
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, NSLocalizedString(@"group.atAll", nil).length)];
            
        }
        else if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtYouMessage) {
             latestMessageTitle =[NSString stringWithFormat:@"[有人@我]%@",latestMessageTitle] ;
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
            [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, latestMessageTitle.length)];
        }
        else {
            attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
        }
    }

    return attributedStr;
}
#pragma mark ----- 消息透传
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for(EMMessage *message in aCmdMessages){
        //删除会话
        if ([message.from isEqualToString:@"jm_assistant"]) {
            return;
        }
        [[EMClient sharedClient].chatManager deleteConversation:message.from isDeleteMessages:YES completion:nil];
        for (NSInteger i = 0;i < self.messageArray.count;i++) {
            EMConversation *conversation  = self.messageArray[i];
            if ([conversation.conversationId isEqualToString:message.from]) {
                [self.messageArray removeObjectAtIndex:i];
            }
        }
        [self.messageTabView reloadData];
    }
    [[AppDelegate shareInstance] updateFriendsListArrayData:nil];
}
@end
