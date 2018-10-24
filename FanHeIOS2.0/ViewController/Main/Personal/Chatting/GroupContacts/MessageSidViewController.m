//
//  MessageSidViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/7.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MessageSidViewController.h"
#import "GroupSettingsViewController.h"
#import "GroupMemberViewController.h"
#import "ChoiceFriendViewController.h"

#import "SendScanCardCell.h"

#import "SupplyAndNeedMyCell.h"
#import "JoinGroupCell.h"

#import "ChartDynamicCell.h"
#import "ActivityChatCell.h"
#import "SendCardCell.h"
#import "ActivityInviteCell.h"
#import "ViewPointCell.h"



@interface MessageSidViewController ()<UIAlertViewDelegate,EMClientDelegate,GroupMemberViewControllerDelegate,EaseMessageCellDelegate,EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    UIMenuItem *_recallItem;
    UIMenuItem *_recallMenuItem;
    
}
@property (nonatomic ,strong)id<IMessageModel> messageMOdle;
@property (nonatomic, copy) EaseSelectAtTargetCallback selectedCallback;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic ,strong) NSMutableArray *remindArray;

@property (nonatomic) NSMutableDictionary *emotionDic;
@property (nonatomic ,strong) UILabel *nameLabel;


@end

@implementation MessageSidViewController
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.scrollToBottomWhenAppear == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        return;
    }
    if (!self.isBack) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)dealloc{
        [[EMClient sharedClient] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isBack = NO;
    // Do any additional setup after loading the view.
    self.remindArray = [NSMutableArray new];
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    
    [self _setupBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitChat) name:@"ExitChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delectMessage:) name:@"delectMessage" object:nil];
    
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"bg_dialog_my"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"bg_dialog_his"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];
    
    
    NSArray *array = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"icon_chat_re_playing003"], [UIImage imageNamed:@"icon_chat_re_playing001"], [UIImage imageNamed:@"icon_chat_re_playing002"], [UIImage imageNamed:@"icon_chat_re_playing003"], nil];
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:array];
    NSArray * array1 = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"chat_receiver_audio_playing003"],[UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"],nil];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:array1];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    [[SendScanCardCell appearance] setAvatarSize:40.f];
    [[SendScanCardCell appearance] setAvatarCornerRadius:20.f];
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    [[JoinGroupCell appearance] setAvatarSize:40.f];
    [[JoinGroupCell appearance] setAvatarCornerRadius:20.f];
    
    
    [[SupplyAndNeedMyCell appearance] setAvatarSize:40.f];
    [[SupplyAndNeedMyCell appearance] setAvatarCornerRadius:20.f];
    
    
    [self _setupBarButtonItem];
    
    self.tableView.backgroundColor = HEX_COLOR(@"EFEFF4");
    [self _setupBarButtonItem];
    
    
}
#pragma maek ------ 清空聊天消息
- (void)delectMessage:(NSNotification *)notification{
    [self.conversation deleteAllMessages:nil];
    [self.messsagesSource removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    EMError *error = nil;
    EMGroup * aGroupCurrue =   [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.conversation.conversationId  error:&error];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSDictionary *ext = self.conversation.ext;
        self.nameLabel.text = aGroupCurrue.subject;
        if ([[ext objectForKey:@"subject"] length])
        {
        }
        
        if (ext && ext[kHaveUnreadAtMessage] != nil)
        {
            NSMutableDictionary *newExt = [ext mutableCopy];
            [newExt removeObjectForKey:kHaveUnreadAtMessage];
            self.conversation.ext = newExt;
        }
    }
}

- (void)tableViewDidTriggerHeaderRefresh {
    /*
     if ([[ChatDemoHelper shareHelper] isFetchHistoryChange]) {
     NSString *startMessageId = nil;
     if ([self.messsagesSource count] > 0) {
     startMessageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
     }
     
     NSLog(@"startMessageID ------- %@",startMessageId);
     [EMClient.sharedClient.chatManager asyncFetchHistoryMessagesFromServer:self.conversation.conversationId
     conversationType:self.conversation.type
     startMessageId:startMessageId
     pageSize:10
     complation:^(EMCursorResult *aResult, EMError *aError)
     {
     [super tableViewDidTriggerHeaderRefresh];
     }];
     
     } else {
     [super tableViewDidTriggerHeaderRefresh];
     }
     */
    [super tableViewDidTriggerHeaderRefresh];
    
}

#pragma mark - setup subviews

- (void)_setupBarButtonItem
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    headView.backgroundColor = [UIColor whiteColor];
    headView.userInteractionEnabled = YES;
    [self.view addSubview:headView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backButton];
    
    self.nameLabel  = [UILabel createLabel:CGRectMake(32, 34, WIDTH - 64, 17) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"41464E")];
    self.nameLabel.font = [UIFont systemFontOfSize:17];
    self.nameLabel.text = self.titleStr;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:self.nameLabel];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 56, 20, 40, 44)];
    [clearButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [clearButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [clearButton setImage:kImageWithName(@"btn_ql_qzgl") forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(groupSetUpMessages:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:clearButton];
}
- (void)groupSetUpMessages:(UIButton *)btn{
    GroupSettingsViewController *set = [[GroupSettingsViewController alloc]init];
    set.groupID = self.conversation.conversationId;
    set.conversation = self.conversation;
    [self.navigationController pushViewController:set animated:YES];
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        self.messageTimeIntervalTag = -1;
        [self.conversation deleteAllMessages:nil];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}


- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext objectForKey:@"em_recall"]) {
        return self.timeCellHeight;
    }
    return 0;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[EaseMessageCell class]]) {
            [cell becomeFirstResponder];
            self.menuIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
        }
    }
    return YES;
}
- (void)messageViewController:(EaseMessageViewController *)viewController
               selectAtTarget:(EaseSelectAtTargetCallback)selectedCallback
{
    _selectedCallback = selectedCallback;
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:self.conversation.conversationId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:self.conversation.conversationId];
    }
    
    if (chatGroup) {
        if (!chatGroup.occupants) {
            __weak MessageSidViewController* weakSelf = self;
            [self showHudInView:self.view hint:@"Fetching group members..."];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EMError *error = nil;
                EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:chatGroup.groupId error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong MessageSidViewController *strongSelf = weakSelf;
                    if (strongSelf) {
                        [strongSelf hideHud];
                        if (error) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Fetching group members failed [%@]", error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alertView show];
                        }
                        else {
                            NSMutableArray *members = [group.occupants mutableCopy];
                            NSString *loginUser = [EMClient sharedClient].currentUsername;
                            if (loginUser) {
                                [members removeObject:loginUser];
                            }
                            if (![members count]) {
                                if (strongSelf.selectedCallback) {
                                    strongSelf.selectedCallback(nil);
                                }
                                return;
                            }
                            GroupMemberViewController *group = [[GroupMemberViewController alloc]init];
                            group.groupID = self.conversation.conversationId;
                            group.groupMemberViewControllerDelegate = self;
                            [self.navigationController pushViewController:group animated:YES];
                        }
                    }
                });
            });
        }
        else {
            NSMutableArray *members = [chatGroup.occupants mutableCopy];
            NSString *loginUser = [EMClient sharedClient].currentUsername;
            if (loginUser) {
                [members removeObject:loginUser];
            }
            if (![members count]) {
                if (_selectedCallback) {
                    _selectedCallback(nil);
                }
                return;
            }
            GroupMemberViewController *group = [[GroupMemberViewController alloc]init];
            group.groupID = self.conversation.conversationId;
            group.groupMemberViewControllerDelegate = self;
            [self.navigationController pushViewController:group animated:YES];
        }
    }
}



#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    if (model.isSender) {
        model.avatarURLPath = [DataModelInstance shareInstance].userModel.image;
        model.nickname =  [DataModelInstance shareInstance].userModel.realname;
        model.avatarImage = KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname);
    }else{
        NSMutableArray *array = [[DBInstance shareInstance]
                                 selectGroupChartModelByUserId:message.from];
        if (array.count != 0) {
            GroupChartModel *model1 = array[0];
            model.avatarURLPath = model1.image;
            model.avatarImage = KHeadImageDefaultName(model1.realname);
        }else{
            model.avatarImage = KHeadImageDefault;
            [[[BaseViewController alloc] init] updateGroupUsersDB:nil occupants:@[message.from] handler:^(BOOL result, NSMutableArray *dataArray) {
                if(result&&dataArray.count){
                    GroupChartModel *gcModel = dataArray.firstObject;
                    model.avatarURLPath = gcModel.image;
                    model.avatarImage = KHeadImageDefaultName(gcModel.realname);
//                    [self.tableView reloadData];
                }
            }];
        }
    }
    return model;
}

- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];
    
    NSMutableArray *emotionGifs = [NSMutableArray array];
    _emotionDic = [NSMutableDictionary dictionary];
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",@"icon_013",@"icon_018",@"icon_019",@"icon_020",@"icon_021",@"icon_022",@"icon_024",@"icon_027",@"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    int index = 0;
    for (NSString *name in names) {
        index++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:[NSString stringWithFormat:@"[示例%d]",index] emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [_emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    EaseEmotionManager *managerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    return @[managerDefault,managerGif];
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

- (void)messageViewControllerMarkAllMessagesAsRead:(EaseMessageViewController *)viewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
}

#pragma mark - EaseMob

#pragma mark - EMClientDelegate

- (void)userAccountDidLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userAccountDidRemoveFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userDidForbidByServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidRecall:(NSArray *)aMessages
{
    for (EMMessage *msg in aMessages) {
        if (![self.conversation.conversationId isEqualToString:msg.conversationId]){
            continue;
        }
        
        NSString *text;
        if ([msg.from isEqualToString:[EMClient sharedClient].currentUsername]) {
            text = [NSString stringWithFormat:NSLocalizedString(@"message.recall", @"You recall a message")];
        } else {
            text = [NSString stringWithFormat:NSLocalizedString(@"message.recallByOthers", @"%@ recall a message"),msg.from];
        }
        
        [self _recallWithMessage:msg text:text isSave:NO];
    }
}

#pragma mark - action

- (void)backAction
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    //    [[ChatDemoHelper shareHelper] setChatVC:nil];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:NO completion:nil];
        }
    }
    if (self.isMakeGroup) {
        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:vc animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.conversation.conversationId];
        if (self.conversation.type != EMConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation deleteAllMessages:nil];
            [self.messsagesSource removeAllObjects];
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else if ([sender isKindOfClass:[UIButton class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alertView show];
    }
}


#pragma mark - notification
- (void)exitChat
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EMClient sharedClient].chatManager importMessages:@[message] completion:nil];
    }
}

- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isViewDidAppear = NO;
    } else {
        //结束call
        self.isViewDidAppear = YES;
    }
}

#pragma mark - private

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    id<IMessageModel>model = [self.dataArray objectAtIndex:indexPath.row];
    
    NSDictionary *ext = model.message.ext;
    
    if(messageType == EMMessageBodyTypeText  && ([ext[@"money_type_special"] isEqualToString:@"joinGroup"])) {
        return;
    }
    
    if (self.menuController == nil) {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
        
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_recallMenuItem == nil) {
        _recallMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(recallMenuAction:)];
        
    }
    
    if (_transpondMenuItem == nil) {
        
        _transpondMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transpondMenuAction:)];
    }
    
    if(messageType == EMMessageBodyTypeText  && (![ext[@"money_type_special"] isEqualToString:@"rand"]||![ext[@"money_type_special"] isEqualToString:@"activity"] ) && ![model.message.from  isEqualToString:@"jm_assistant"] && ![ext[@"money_type_special"] isEqualToString:@"scanCardInformation"] && ![ext[@"money_type_special"] isEqualToString:@"shareSupply"] ) {
        if ([model.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID]) {
            [self.menuController setMenuItems:@[_deleteMenuItem]];
        }else{
            [self.menuController setMenuItems:@[_copyMenuItem,_transpondMenuItem, _deleteMenuItem]];
        }
    }else if (messageType == EMMessageBodyTypeImage){
        [self.menuController setMenuItems:@[_transpondMenuItem,_deleteMenuItem]];
    }else if ([model.message.from  isEqualToString:@"jm_assistant"]){
        if ([model.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID]) {
            [self.menuController setMenuItems:@[_deleteMenuItem]];
        }else{
            [self.menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
        }
    }else {
        if ( [ext[@"money_type_special"] isEqualToString:@"scanCardInformation"] || [ext[@"money_type_special"] isEqualToString:@"shareSupply"]) {
            [self.menuController setMenuItems:@[_transpondMenuItem,_deleteMenuItem]];
        }else{
            [self.menuController setMenuItems:@[_deleteMenuItem]];
        }
        
        
    }
    
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}
- (void)transpondMenuAction:(id)sender{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        self.isBack = YES;
        id<IMessageModel> model = nil;
        model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        
        ChoiceFriendViewController *listViewController = [[ChoiceFriendViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.messageModel = model;
        
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionPush;//可更改为其他方式
        transition.subtype = kCATransitionFromTop;//可更改为其他方式
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:listViewController animated:NO];
    }
    self.menuIndexPath = nil;
    
}
- (void)recallMenuAction:(id)sender{
    id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
    
    [self.conversation deleteMessageWithId:model.message.messageId error:nil];
    [self.messsagesSource removeObject:model.message];
    
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:@"你已经撤回消息"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:model.message.conversationId from:from to:model.message.to body:body ext:model.message.ext];
    message.chatType = EMChatTypeGroupChat;// 设置为单聊消息
    [[EMClient sharedClient].chatManager importMessages:@[message] completion:^(EMError *aError) {
        if (!aError) {
            [self tableViewDidTriggerHeaderRefresh];
            [self.dataArray removeObjectsAtIndexes:indexs];
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.menuIndexPath = nil;
        }
    }];
}

- (void)copyMenuAction:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        if ([self.dataArray count] == 0) {
            self.messageTimeIntervalTag = -1;
        }
    }
    
    self.menuIndexPath = nil;
}
- (void)messageViewController:(EaseMessageViewController *)viewController
  didSelectAvatarMessageModel:(id<IMessageModel>)messageModel{

    if (![messageModel.message.from isEqualToString:@"jm_assistant"])
    {
        self.isPushVC = YES;
        self.isBack = YES;
        NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
        home.userId = [NSNumber numberWithInteger:messageModel.message.from.integerValue];
        [self.navigationController pushViewController:home animated:YES];
    }
}
- (void)_recallWithMessage:(EMMessage *)msg text:(NSString *)text isSave:(BOOL)isSave
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text to:msg.conversationId messageType:msg.chatType messageExt:@{@"em_recall":@(YES)}];
    message.isRead = YES;
    [message setTimestamp:msg.timestamp];
    [message setLocalTime:msg.localTime];
    id<IMessageModel> newModel = [[EaseMessageModel alloc] initWithMessage:message];
    __block NSUInteger index = NSNotFound;
    [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
        if ([model conformsToProtocol:@protocol(IMessageModel)]) {
            if ([msg.messageId isEqualToString:model.message.messageId])
            {
                index = idx;
                *stop = YES;
            }
        }
    }];
    if (index != NSNotFound)
    {
        __block NSUInteger sourceIndex = NSNotFound;
        [self.messsagesSource enumerateObjectsUsingBlock:^(EMMessage *message, NSUInteger idx, BOOL *stop){
            if ([message isKindOfClass:[EMMessage class]]) {
                if ([msg.messageId isEqualToString:message.messageId])
                {
                    sourceIndex = idx;
                    *stop = YES;
                }
            }
        }];
        if (sourceIndex != NSNotFound) {
            [self.messsagesSource replaceObjectAtIndex:sourceIndex withObject:newModel.message];
        }
        [self.dataArray replaceObjectAtIndex:index withObject:newModel];
        [self.tableView reloadData];
    }
    
    if (isSave) {
        [self.conversation insertMessage:message error:nil];
    }
}


#pragma mark - EMChooseViewDelegate
- (void)viewController:(GroupMemberViewController *)viewController didFinishSelectedSources:(ChartModel *)model{
    if (model.realname.length > 0) {
        
        if (_selectedCallback) {
            [self.remindArray addObject:model];
            _selectedCallback(model);
            
        }
    }
    else {
        if (_selectedCallback) {
            _selectedCallback(nil);
        }
    }
    
}

- (void)viewControllerDidSelectBack:(GroupMemberViewController *)viewController
{
    if (_selectedCallback) {
        _selectedCallback(nil);
    }
}
- (UITableViewCell *)messageViewController:(UITableView *)tableView
                       cellForMessageModel:(id<IMessageModel>)messageModel{
    NSDictionary *ext = messageModel.message.ext;
    if ([ext[@"money_type_special"] isEqualToString:@"rand"]) {
        static NSString *cellID = @"SendCardCell";
        SendCardCell *sendCell = (SendCardCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        messageModel.avatarImage = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
        sendCell = [[SendCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"scanCardInformation"]) {
        static NSString *cellID = @"SendScanCardCell";
        SendScanCardCell *sendCell = (SendScanCardCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        sendCell = [[SendScanCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"activity"]) {
        static NSString *cellID = @"ActivityInviteCell";
        ActivityInviteCell *sendCell = (ActivityInviteCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        sendCell = [[ActivityInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"viewPoint"]) {
        static NSString *cellID = @"ViewPointCell";
        ViewPointCell *sendCell = (ViewPointCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        sendCell = [[ViewPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        self.messageMOdle = messageModel;
        
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"dynamic"]) {
        static NSString *cellID = @"ChartDynamicCell";
        ChartDynamicCell *sendCell = (ChartDynamicCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        sendCell = [[ChartDynamicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        self.messageMOdle = messageModel;
        
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"activityOrinformation"]) {
        static NSString *cellID = @"ActivityChatCell";
        ActivityChatCell *sendCell = (ActivityChatCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        
        sendCell = [[ActivityChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"shareSupply"]) {
        static NSString *cellID = @"SupplyAndNeedMyCell";
        SupplyAndNeedMyCell    *sendCell = (SupplyAndNeedMyCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        sendCell = [[SupplyAndNeedMyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }else if ([ext[@"money_type_special"] isEqualToString:@"joinGroup"]) {
        static NSString *cellID = @"JoinGroupCell";
        JoinGroupCell *sendCell = (JoinGroupCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        sendCell = [[JoinGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID model:messageModel];
        sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
        sendCell.delegate = self;
        [sendCell setModel:messageModel];
        return sendCell;
    }
    
    return nil;
}

@end

