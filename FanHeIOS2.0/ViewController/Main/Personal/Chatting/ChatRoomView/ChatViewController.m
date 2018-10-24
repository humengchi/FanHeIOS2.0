//
//  ChatViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatSetController.h"
#import "JinMaiSetController.h"
#import "SendCardCell.h"
#import "SendScanCardCell.h"
#import "ActivityInviteCell.h"
#import "ChoiceFriendViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "ChartDynamicCell.h"
#import "ActivityChatCell.h"
#import "EaseCustomMessageCell.h"
#import "VariousDetailController.h"
#import "ViewPointCell.h"

#import "SupplyAndNeedMyCell.h"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,EMClientDelegate,ChatSetControllerDelegate,UIGestureRecognizerDelegate,JinMaiSetControllerDelegate,EaseMessageCellDelegate>{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transpondMenuItem;
    UIMenuItem *_recallMenuItem;
    

}
@property (nonatomic ,strong)id<IMessageModel> messageMOdle;
@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic) NSMutableDictionary *emotionDic;

@end

@implementation ChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    self.isRefer = NO;

    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"bg_dialog_my"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"bg_dialog_his"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];

    
    NSArray *array = [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"icon_chat_re_playing003"], [UIImage imageNamed:@"icon_chat_re_playing001"], [UIImage imageNamed:@"icon_chat_re_playing002"], [UIImage imageNamed:@"icon_chat_re_playing003"], nil];
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:array];
    NSArray * array1 = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"chat_receiver_audio_playing003"],[UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"],nil];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:array1];

    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    [[SendCardCell appearance] setAvatarSize:40.f];
    [[SendCardCell appearance] setAvatarCornerRadius:20.f];
    [[SendScanCardCell appearance] setAvatarSize:40.f];
    [[SendScanCardCell appearance] setAvatarCornerRadius:20.f];
    [[ActivityInviteCell appearance] setAvatarSize:40.f];
    [[ActivityInviteCell appearance] setAvatarCornerRadius:20.f];
    [[ChartDynamicCell appearance] setAvatarSize:40.f];
    [[ChartDynamicCell appearance] setAvatarCornerRadius:20.f];
    
    [[SupplyAndNeedMyCell appearance] setAvatarSize:40.f];
    [[SupplyAndNeedMyCell appearance] setAvatarCornerRadius:20.f];
    
    [[ViewPointCell appearance] setAvatarSize:40.f];
    [[ViewPointCell appearance] setAvatarCornerRadius:20.f];
    [[ActivityChatCell appearance] setAvatarSize:40.f];
    [[ActivityChatCell appearance] setAvatarCornerRadius:20.f];
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self _setupBarButtonItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    self.tableView.backgroundColor = HEX_COLOR(@"EFEFF4");
   
}

- (void)dealloc{
    if(self.conversation.type == EMConversationTypeChatRoom){
        //退出聊天室，删除会话
        NSString *chatter = [self.conversation.conversationId copy];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = nil;
            [[EMClient sharedClient].roomManager leaveChatroom:chatter error:&error];
            if (error !=nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Leave chatroom '%@' failed [%@]", chatter, error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                });
            }
        });
    }
    [[EMClient sharedClient] removeDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.scrollToBottomWhenAppear == NO) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        return;
    }
    if (!self.isBack && self.pushIndex != 888) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     self.isBack = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        if ([[self.conversation.ext objectForKey:@"subject"] length]){
            self.title = [self.conversation.ext objectForKey:@"subject"];
        }
    }
}

#pragma mark - setup subviews
- (void)_setupBarButtonItem{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 64)];
    headView.backgroundColor = [UIColor whiteColor];
    headView.userInteractionEnabled = YES;
    [self.view addSubview:headView];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backButton];
    NSArray *array = [[DBInstance shareInstance] selectCharttingID:self.conversation.conversationId];
    ChartModel *usermodel;
    if(array.count){
        usermodel = array[0];
    }
    if(usermodel && usermodel.canviewphone.integerValue==1){
        UIButton *phoneBtn = [NSHelper createButton:CGRectMake(WIDTH - 75, 20, 35, 44) title:nil image:kImageWithName(@"btn_phone_gray") target:self selector:@selector(talkPhoneAction:) addttStr:nil];
        [headView addSubview:phoneBtn];
    }
    
    UIButton *myMessaegphoneBtn = [NSHelper createButton:CGRectMake(WIDTH - 40, 20, 35, 44) title:nil image:kImageWithName(@"btn_set_gray") target:self selector:@selector(messageSettingAction:) addttStr:nil];
    [headView addSubview:myMessaegphoneBtn];

    UILabel *nameLabel = [UILabel createLabel:CGRectMake(32, 25, WIDTH - 64, 14) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"818C9E")];
    if ([self.conversation.conversationId isEqualToString:@"jm_assistant"]) {
        nameLabel.frame = CGRectMake(32, 34, WIDTH - 64, 17);
        nameLabel.font = [UIFont systemFontOfSize:17];
        nameLabel.textColor = [UIColor colorWithHexString:@"41464E"];
    }
    nameLabel.text = self.title;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:nameLabel];
    UILabel *postLabel = [UILabel createLabel:CGRectMake((WIDTH -200)/2, 41, 200, 14) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"41464E")];
    postLabel.text = self.position;
    postLabel.textAlignment = NSTextAlignmentCenter;

    [headView addSubview:postLabel];
    
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, headView.frame.size.height - 0.5, WIDTH, 0.5) backColor:@"D9D9D9"];
    [headView addSubview:lineView];
}

- (void)talkPhoneAction:(UIButton *)btn{
    self.isRefer = YES;
    NSString *str = [NSString stringWithFormat:@"tel:%@",self.phoneNumber];
    UIWebView *callWebView = [[UIWebView alloc]init];
    [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebView];//也可以不加到页面上
}

- (void)messageSettingAction:(UIButton *)btn{
    self.isBack = YES;
    if ([self.conversation.conversationId isEqualToString:@"jm_assistant"]) {
        self.isPushVC = YES;
        JinMaiSetController  *chat = [[JinMaiSetController alloc]init];
            chat.conversation = self.conversation;
        chat.setJinMaiDelegate  = self;
        [self.navigationController pushViewController:chat animated:YES];
    }else{
        self.isPushVC = YES;
        ChatSetController *chat = [[ChatSetController alloc]init];
        chat.chatId = self.conversation.conversationId;
        chat.conversation = self.conversation;
        chat.setDelegate  = self;
        [self.navigationController pushViewController:chat animated:YES];
    }
}

#pragma mark ------ChatSetControllerDelegate
- (void)referViewChat{
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.cancelButtonIndex != buttonIndex) {
        self.messageTimeIntervalTag = -1;
        [self.conversation deleteAllMessages:nil];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark - EaseMessageViewControllerDelegate
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    return YES;
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
- (instancetype)initWithConversationChatter:(NSString *)conversationChatter conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        self.messageCountOfPage = 10;
        self.timeCellHeight = 30;
        self.deleteConversationIfNull = YES;
        self.scrollToBottomWhenAppear = YES;
        self.messsagesSource = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        [self.conversation markAllMessagesAsRead:nil];
    }
    return self;
}
#pragma mark - EaseMessageViewControllerDataSource


- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController{
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
//        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:[NSString stringWithFormat:@"[示例%d]",index] emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"[动画表情]" emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
            [_emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
        
    }
    EaseEmotionManager *managerGif= [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    return @[managerDefault,managerGif];
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel{
   
        BOOL flag = NO;
        if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
            return YES;
        }
        return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController messageModel:(id<IMessageModel>)messageModel{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController easeEmotion:(EaseEmotion*)easeEmotion{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark - EaseMob
#pragma mark - EMClientDelegate
- (void)didLoginFromOtherDevice{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - action
- (void)backAction{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
//    [[ChatDemoHelper shareHelper] setChatVC:nil];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:NO completion:^(NSString *aConversationId, EMError *aError) {
                
            }];
        
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
  
}

- (void)showGroupDetailAction{
    [self.view endEditing:YES];
}

- (void)deleteAllMessages:(id)sender{
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
    }else if ([sender isKindOfClass:[UIButton class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alertView show];
    }
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

#pragma mark - notification
- (void)exitGroup{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EMClient sharedClient].chatManager importMessages:@[message] completion:^(EMError *aError) {
        }];
    }
}

- (void)handleCallNotification:(NSNotification *)notification{
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
- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(EMMessageBodyType)messageType{
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
    id<IMessageModel>model = [self.dataArray objectAtIndex:indexPath.row];
  
      NSDictionary *ext = model.message.ext;
    
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
    }

    return nil;
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if ([message.from isEqualToString:@"jm_assistant"]) {
            return;
        }
        EMCmdMessageBody *body = (EMCmdMessageBody *)message.body;
        NSString *str = [NSString stringWithFormat:@"%@解除好友关系",body.action];
       
        [self showHint:str];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    message.chatType = EMChatTypeChat;// 设置为单聊消息
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


#pragma mark -- UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//   NSLog(@"tableView滚动纵坐标%f",self.tableView.contentOffset.y);
//    if(self.tableView.contentOffset.y  < 10){
//        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            [self tableViewDidTriggerHeaderRefresh];
//            [self.tableView.mj_header beginRefreshing];
//        }];
//    }
//}


@end
